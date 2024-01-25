@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg")
class_name PhantomCamera2D
extends Node2D

## Enables a 2D scene's [param Camera2D] to follow the behavior defined here.
##
## The scene's [param Camera2D] will follow the position of the
## [param PhantomCamera2D] with the highest priority.
## Each instance can have different positional and rotational logic applied
## to them.

#region Constants

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#endregion


#region Signals

## Emitted when the [param PhantomCamera2D] becomes active.
signal became_active
## Emitted when the [param PhantomCamera2D] becomes inactive.
signal became_inactive

## Emitted when follow_target changes.
signal follow_target_changed

## Emitted when dead zones changes. [br]
## [b]Note:[/b] Only applicable in Framed Follow mode.
signal dead_zone_changed

## Emitted when the Camera2D starts to tween to the [param PhantomCamera2D].
signal tween_started
## Emitted when the Camera2D is to tweening to the [param PhantomCamera2D].
signal is_tweening
## Emitted when the tween is interrupted due to another PhantomCamera2D
## becoming active. The argument is the [param PhantomCamera2D] that interrupted
## the tween.
signal tween_interrupted(pcam_2d: PhantomCamera2D)
## Emitted when the [param Camera2D] completes its tween to the
## [param PhantomCamera2D].
signal tween_completed

#endregion

#region Enums

## Determines the positional logic for a given [param PCamPhantomCamera2D]
## [br][br]
## The different modes have different functionalities and purposes, so choosing
## the correct one depends on what each [param PhantomCamera2D] is meant to do.
enum FollowMode {
	NONE 			= 0, ## Default.
	GLUED 			= 1, ## Sticks to its target.
	SIMPLE 			= 2, ## Follows its target with an optional offset.
	GROUP 			= 3, ## Follows multiple targets with option to dynamically reframe itself.
	PATH 			= 4, ## Follows a target while being positionally confined to a [Path2D] node.
	FRAMED 			= 5, ## Applies a dead zone on the frame and only follows its target when it tries to leave it.
}

## Determines how often an inactive [param PhantomCamera2D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive PCams are doing when idling to improve performance.
## The value is based on the enum type [enum InactiveUpdateMode].
enum InactiveUpdateMode {
	ALWAYS, ## Always updates the [param PhantomCamera2D], even when it's inactive.
	NEVER, ## Never updates the [param PhantomCamera2D] when it's inactive. Reduces the amount of computational resources when inactive.
#	EXPONENTIALLY,
}

#endregion

#region Variables

var Properties = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

var _pcam_host_owner: PhantomCameraHost

var _is_active: bool = false

## To quickly preview a [param PhantomCamera2D] without adjusting its
## [member priority], this property allows the selected PCam to ignore the
## Priority system altogether and forcefully become the active one. It's
## partly designed to work within the Viewfinder, and will be disabled when
## running a build export of the game.
@export var priority_override: bool = false:
	set(value):
		if Engine.is_editor_hint() and _has_valid_pcam_owner():
			if value == true:
				priority_override = value
				get_pcam_host_owner().pcam_priority_override(self)
			else:
				priority_override = value
				get_pcam_host_owner().pcam_priority_updated(self)
				get_pcam_host_owner().pcam_priority_override_disabled()
	get:
		return priority_override

## It defines which [param PhantomCamera2D] a scene's [param Camera2D] should
## be corresponding with and be attached to. This is decided by the PCam with
## the highest [param Priority].
## [br][br]
## Changing [param Priority] will send an event to the scene's
## [PhantomCameraHost], which will then determine whether if the
## [param Priority] value is greater than or equal to the currently
## highest [param PhantomCamera2D]'s in the scene. The [param PhantomCamera2D]
## with the highest value will then reattach the [param Camera2D] accordingly.
@export var priority: int = 0:
	set = set_priority,
	get = get_priority

## Determines the positional logic for a given [param PhantomCamera2D].
## The different modes have different functionalities and purposes, so 
## choosing the correct one depends on what each [param PhantomCamera2D]
## is meant to do.
@export var follow_mode: FollowMode = FollowMode.NONE:
	set(value):
		follow_mode = value

		if value == FollowMode.FRAMED:
			if _follow_framed_initial_set and follow_target:
				_follow_framed_initial_set = false
				dead_zone_changed.connect(_on_dead_zone_changed)
		else:
			if dead_zone_changed.is_connected(_on_dead_zone_changed):
				dead_zone_changed.disconnect(_on_dead_zone_changed)
		notify_property_list_changed()
	get:
		return follow_mode


## Determines which target should be followed.
## The [param Camera2D] will follow the position of the Follow Target
## based on the [member follow_mode] type and its parameters.
@export var follow_target: Node2D = null:
	set = set_follow_target,
	get = get_follow_target
var _should_follow: bool = false
var _follow_framed_offset: Vector2

### Defines the targets that the [param PhantomCamera2D] should be following.
@export var follow_targets: Array[Node2D] = [null]:
	set = set_follow_targets,
	get = get_follow_targets
var _has_multiple_follow_targets: bool = false


## Determines the [Path2D] the [param PhantomCamera2D]
## should be bound to.
## The [param PhantomCamera2D] will follow the position of the
## [member follow_target] while sticking to the closest point on this path.
@export var follow_path: Path2D = null:
	set = set_follow_path,
	get = get_follow_path
var _has_follow_path: bool = false

## Applies a zoom level to the [param PhantomCamera2D], which effectively
## overrides the [member zoom] property of the [Camera2D] node.
@export var zoom: Vector2 = Vector2.ONE:
	set = set_zoom,
	get = get_zoom
	
## If enabled, will snap the [param Camera2D] to whole pixels as it moves
## [br][br]
## This should be particularly useful in pixel art projects,
## where assets should always be aligned to the monitor's pixels to avoid
## unintended stretching.
@export var pixel_perfect: bool = false

## Enables a preview of what the [PhantomCamera2D] will see in the
## scene. It works identically to how a [Camera2D] shows which area
## will be visible during runtime. Likewise, this too will be affected by the
## [member zoom] property and the Viewport Width and Viewport Height defined in the Project Settings.
@export var frame_preview: bool = true:
	set(value):
		frame_preview = value
		queue_redraw()
	get:
		return frame_preview

## Defines how the [param PhantomCamera2D] transition between one another.
## Changing the tween values for a given [PhantomCamera2D]
## determines how transitioning to that instance will look like.
## This is a resource type that can be either used for one
## [param PhantomCamera] or reused across multiple - both 2D and 3D.
## By default, all [param PhantomCameras] will use a [param linear]
## transition, [param easeInOut] ease with a [param 1s] duration.
@export var tween_resource: PhantomCameraTween
var tween_resource_default: PhantomCameraTween = PhantomCameraTween.new()

## By default, the moment a [param PhantomCamera2D] is instantiated into
## a scene, and has the highest priority, it will perform its tween transition.
## This is most obvious if a PCam has a long duration and is attached to a
## playable character that can be moved the moment a scene is loaded.
## Disabling the [param tween_on_load] property will disable this
## behaviour and skip the tweening entirely when instantiated.
@export var tween_onload: bool = true

## Determines how often an inactive [param PhantomCamera2D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive [param PhantomCamera2Ds] are doing when idling
## to improve performance.
@export var inactive_update_mode: InactiveUpdateMode = InactiveUpdateMode.ALWAYS

@export_group("Follow Parameters")
## Applies a damping effect on the [param Camera2D]'s movement.
## Leading to heavier / slower camera movement as the targeted node moves around.
## This is useful to avoid sharp and rapid camera movement.
@export var follow_damping: bool = false:
	set = set_follow_has_damping,
	get = get_follow_has_damping

## Defines the damping amount.[br][br]
## [b]Lower value[/b] = slower / heavier camera movement.[br][br]
## [b]Higher value[/b] = faster / sharper camera movement.
@export var follow_damping_value: float = 10:
	set = set_follow_damping_value,
	get = get_follow_damping_value

## Offsets the follow target's position.
@export var follow_offset: Vector2 = Vector2.ZERO:
	set = set_follow_target_offset,
	get = get_follow_target_offset

@export_subgroup("Follow Group")
## Enables the [param PhantomCamera2D] to dynamically zoom in and out based on
## the targets' distances between each other.
## Once enabled, the [param Camera2D] will stay as zoomed in as possible,
## limited by the [member auto_zoom_max] and start zooming out as the targets
## move further apart, limited by the [member auto_zoom_min].
## Note: Enabling this property hides and disables the [member zoom] property
## as this effectively overrides that value.
@export var auto_zoom: bool = false:
	set = set_auto_zoom,
	get = get_auto_zoom
## Sets the param minimum zoom amount, in other words how far away the
## [param Camera2D] can be from scene.[br][br]
## This only works when [member auto_zoom] is enabled.
@export var auto_zoom_min: float = 1:
	set = set_auto_zoom_min,
	get = get_auto_zoom_min

## Sets the maximum zoom amount, in other words how close the [param Camera2D]
## can move towards the scene.[br][br]
## This only works when [member auto_zoom] is enabled.
@export var auto_zoom_max: float = 5:
	set = set_auto_zoom_max,
	get = get_auto_zoom_max
## Determines how close to the edges the targets are allowed to be.
## This is useful to avoid targets being cut off at the edges of the screen.
## [br][br]

## The Vector4 parameter order goes: [param Left] - [param Top] - [param Right]
## - [param Bottom].
@export var auto_zoom_margin: Vector4 = Vector4.ZERO:
	set = set_auto_zoom_margin,
	get = get_auto_zoom_margin

@export_subgroup("Dead Zones")
## Defines the horizontal dead zone area. While the target is within it, the
## [param PhantomCamera2D] will not move in the horizontal axis.
## If the targeted node leaves the horizontal bounds, the
## [param PhantomCamera2D] will follow the target horizontally to keep
## it within bounds.
@export_range(0, 1) var dead_zone_width: float = 0:
	set(value):
		dead_zone_width = value
		dead_zone_changed.emit()
	get:
		return dead_zone_width

## Defines the vertical dead zone area. While the target is within it, the
## [param PhantomCamera2D] will not move in the vertical axis.
## If the targeted node leaves the vertical bounds, the
## [param PhantomCamera2D] will follow the target horizontally to keep
## it within bounds.
@export_range(0, 1) var dead_zone_height: float = 0:
	set(value):
		dead_zone_height = value
		dead_zone_changed.emit()
	get:
		return dead_zone_height

## Enables the [param dead zones] to be visible when running the game from the editor.
## [br]
## [param dead zones] will never be visible in build exports.
@export var show_viewfinder_in_play: bool

var _follow_framed_initial_set: bool = false

@export_group("Limit")

## Shows the [param Camera2D]'s built-in limit border.[br]
## The [param PhantomCamera2D] and [param Camera2D] can move around anywhere within it.
@export var draw_limits: bool = false:
	set(value):
		_draw_limits = value
		if Engine.is_editor_hint():
			_draw_camera_2d_limit()
	get:
		return _draw_limits
static var _draw_limits: bool

var _limit_sides: Vector4i
var _limit_sides_default: Vector4i = Vector4i(-10000000, -10000000, 10000000, 10000000)
## Defines the left side of the [param Camera2D] limit.
## The camera will not be able to move past this point.
@export var limit_left: int = -10000000:
	set = set_limit_left,
	get = get_limit_left
## Defines the top side of the [param Camera2D] limit.
## The camera will not be able to move past this point.
@export var limit_top: int = -10000000:
	set = set_limit_top,
	get = get_limit_top
## Defines the right side of the [param Camera2D] limit.
## The camera will not be able to move past this point.
@export var limit_right: int = 10000000:
	set = set_limit_right,
	get = get_limit_right
## Defines the bottom side of the [param Camera2D] limit.
## The camera will not be able to move past this point.
@export var limit_bottom: int = 10000000:
	set = set_limit_bottom,
	get = get_limit_bottom

## Allows for setting either a [TileMap] or [CollisionShape2D] node to automatically apply a limit size instead of manually adjusting the Left, Top, Right and Left properties.
## [b]TileMap[/b][br]
## The Limit will update after the [TileSet] of the [TileMap] has changed.
## Note: The limit size will only update after closing the TileMap editor bottom panel.
## [param CollisionShape2D][br]
## The limit will update in realtime as the Shape2D changes its size.
## Note: For performance reasons, resizing the [Shape2D] during runtime will not change the Limits sides.
@export_node_path("TileMap", "CollisionShape2D") var limit_target = NodePath(""):
	set = set_limit_target,
	get = get_limit_target
var _limit_node: Node2D
## Applies an offset to the [param TileMap] Limit or [param Shape2D] Limit.
## The values goes from [param Left], [param Top], [param Right]
## and [param Bottom].
@export var limit_margin: Vector4i:
	set = set_limit_margin,
	get = get_limit_margin
#@export var limit_smoothed: bool = false: # TODO - Needs proper support
	#set = set_limit_smoothing,
	#get = get_limit_smoothing
var _limit_inactive_pcam: bool

#endregion


func _validate_property(property: Dictionary) -> void:
	################
	## Follow Target
	################
	if property.name == "follow_target":
		if follow_mode == FollowMode.NONE or \
		follow_mode == FollowMode.GROUP:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	elif property.name == "follow_path" and \
	follow_mode != FollowMode.PATH:
		property.usage = PROPERTY_USAGE_NO_EDITOR


	####################
	## Follow Parameters
	####################
	elif property.name == "follow_offset":
		if follow_mode == FollowMode.GLUED or \
		follow_mode == FollowMode.NONE:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	elif property.name == "follow_damping" and \
	follow_mode == FollowMode.NONE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_damping_value" and not follow_damping:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	###############
	## Follow Group
	###############
	if property.name == "follow_targets" and follow_mode != FollowMode.GROUP:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if not auto_zoom:
		match property.name:
			"auto_zoom_min", \
			"auto_zoom_max", \
			"auto_zoom_margin":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	################
	## Follow Framed
	################
	if not follow_mode == FollowMode.FRAMED:
		match property.name:
			"dead_zone_width", \
			"dead_zone_height", \
			"show_viewfinder_in_play":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	#######
	## Zoom
	#######
	if property.name == "zoom" and auto_zoom:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	########
	## Limit
	########
	if is_instance_valid(_limit_node):
		match property.name:
			"limit_left", \
			"limit_top", \
			"limit_right", \
			"limit_bottom":
				property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "limit_margin" and not _limit_node:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	################
	## Frame Preview
	################
	if property.name == "frame_preview" and _is_active:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	notify_property_list_changed()

#region Private Functions

func _enter_tree() -> void:
	Properties.is_2D = true
	Properties.camera_enter_tree(self)
	set_pcam_host()

	update_limit_all_sides()


func _exit_tree() -> void:
	if _has_valid_pcam_owner():
		get_pcam_host_owner().pcam_removed_from_scene(self)

	Properties.pcam_exit_tree(self)


func _process(delta: float) -> void:
	if not _is_active:
		match inactive_update_mode:
			InactiveUpdateMode.NEVER:
				return
			InactiveUpdateMode.ALWAYS:
				# Only triggers if limit isn't default
				if _limit_inactive_pcam:
					set_global_position(
						_set_limit_clamp_position(global_position)
					)
#			InactiveUpdateMode.EXPONENTIALLY:
#				TODO

	if not _should_follow: return
	
	match follow_mode:
		FollowMode.GLUED:
			if follow_target:
				_set_pcam_global_position(follow_target.global_position, delta)
		FollowMode.SIMPLE:
			if follow_target:
				_set_pcam_global_position(_target_position_with_offset(), delta)
		FollowMode.GROUP:
			if follow_targets.size() == 1:
				_set_pcam_global_position(follow_targets[0].global_position, delta)
			elif _has_multiple_follow_targets and follow_targets.size() > 1:
				var rect: Rect2 = Rect2(follow_targets[0].global_position, Vector2.ZERO)
				for node in follow_targets:
					rect = rect.expand(node.global_position)
					if auto_zoom:
						rect = rect.grow_individual(
							auto_zoom_margin.x, 
							auto_zoom_margin.y,
							auto_zoom_margin.z,
							auto_zoom_margin.w)
#						else:
#							rect = rect.grow_individual(-80, 0, 0, 0)
				if auto_zoom:
					var screen_size: Vector2 = get_viewport_rect().size
					if rect.size.x > rect.size.y * screen_size.aspect():
						zoom = clamp(screen_size.x / rect.size.x, auto_zoom_min, auto_zoom_max) * Vector2.ONE
					else:
						zoom = clamp(screen_size.y / rect.size.y, auto_zoom_min, auto_zoom_max) * Vector2.ONE
				_set_pcam_global_position(rect.get_center(), delta)
		FollowMode.PATH:
				if follow_targets and follow_path:
					var path_position: Vector2 = follow_path.global_position
					_set_pcam_global_position(
						follow_path.curve.get_closest_point(
							_target_position_with_offset() - path_position
						) + path_position,
						delta)
		FollowMode.FRAMED:
			if follow_target:
				if not Engine.is_editor_hint():
					Properties.viewport_position = (get_follow_target().get_global_transform_with_canvas().get_origin() + follow_offset) / get_viewport_rect().size

					if Properties.get_framed_side_offset(dead_zone_width, dead_zone_height) != Vector2.ZERO:
						var glo_pos: Vector2
						var target_position: Vector2 = _target_position_with_offset() + _follow_framed_offset

						if dead_zone_width == 0 || dead_zone_height == 0:
							if dead_zone_width == 0 && dead_zone_height != 0:
								_set_pcam_global_position(_target_position_with_offset(), delta)
							elif dead_zone_width != 0 && dead_zone_height == 0:
								glo_pos = _target_position_with_offset()
								glo_pos.x += target_position.x - global_position.x
								_set_pcam_global_position(glo_pos, delta)
							else:
								_set_pcam_global_position(_target_position_with_offset(), delta)
						else:
							_set_pcam_global_position(target_position, delta)
					else:
						_follow_framed_offset = global_position - _target_position_with_offset()
				else:
					_set_pcam_global_position(_target_position_with_offset(), delta)


func _set_pcam_global_position(_global_position: Vector2, delta: float) -> void:
	if _limit_inactive_pcam and not Properties.has_tweened:
		_global_position = _set_limit_clamp_position(_global_position)

	if get_follow_has_damping():
		set_global_position(
			get_global_position().lerp(
				_global_position,
				delta * follow_damping_value
			)
		)
	else:
		set_global_position(_global_position)


func _set_limit_clamp_position(value: Vector2) -> Vector2i:
	var camera_frame_rect_size: Vector2 = _camera_frame_rect().size
	value.x = clampf(value.x, _limit_sides.x + camera_frame_rect_size.x / 2, _limit_sides.z - camera_frame_rect_size.x / 2)
	value.y = clampf(value.y, _limit_sides.y + camera_frame_rect_size.y / 2, _limit_sides.w - camera_frame_rect_size.y / 2)
	return value


func _draw():
	if not Engine.is_editor_hint(): return
	
	if frame_preview and not _is_active:
		var screen_size_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
		var screen_size_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
		var screen_size_zoom: Vector2 = Vector2(screen_size_width / get_zoom().x, screen_size_height / get_zoom().y)
		draw_rect(_camera_frame_rect(), Color("3ab99a"), false, 2)


func _camera_frame_rect() -> Rect2:
	var screen_size_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screen_size_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	var screen_size_zoom: Vector2 = Vector2(screen_size_width / get_zoom().x, screen_size_height / get_zoom().y)

	return Rect2(-screen_size_zoom / 2, screen_size_zoom)


func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if Engine.is_editor_hint(): # Used for updating Limit when a CollisionShape2D is applied
			if not _is_active:
				update_limit_all_sides()


func _on_tile_map_changed() -> void:
	update_limit_all_sides()


func _target_position_with_offset() -> Vector2:
	return follow_target.global_position + follow_offset


func _on_dead_zone_changed() -> void:
	set_global_position( _target_position_with_offset() )


func _has_valid_pcam_owner() -> bool:
	if not is_instance_valid(get_pcam_host_owner()): return false
	if not is_instance_valid(get_pcam_host_owner().camera_2D): return false
	return true


func _draw_camera_2d_limit() -> void:
	if _has_valid_pcam_owner():
		get_pcam_host_owner().camera_2D.set_limit_drawing_enabled(draw_limits)


func _check_limit_is_not_default() -> void:
	if _limit_sides == _limit_sides_default:
		_limit_inactive_pcam = false
	else:
		_limit_inactive_pcam = true


func _set_camera_2d_limit(side: int, limit: int) -> void:
	if not _has_valid_pcam_owner(): return
	if not _is_active: return
	get_pcam_host_owner().camera_2D.set_limit(side, limit)


#endregion


#region Public Functions

func update_limit_all_sides() -> void:
	var limit_rect: Rect2

	if not is_instance_valid(_limit_node):
		_limit_sides.y = limit_top
		_limit_sides.x = limit_left
		_limit_sides.z = limit_right
		_limit_sides.w = limit_bottom
	elif _limit_node is TileMap:
		var tile_map: TileMap = _limit_node as TileMap
		var tile_map_size: Vector2 = Vector2(tile_map.get_used_rect().size) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()
		var tile_map_position: Vector2 = tile_map.global_position + Vector2(tile_map.get_used_rect().position) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()

		## Calculates the Rect2 based on the Tile Map position and size
		limit_rect = Rect2(tile_map_position, tile_map_size)

		## Calculates the Rect2 based on the Tile Map position and size + margin
		limit_rect = Rect2(
			limit_rect.position + Vector2(limit_margin.x, limit_margin.y),
			limit_rect.size - Vector2(limit_margin.x, limit_margin.y) - Vector2(limit_margin.z, limit_margin.w)
		)

		# Left
		_limit_sides.x = roundi(limit_rect.position.x)
		# Top
		_limit_sides.y = roundi(limit_rect.position.y)
		# Right
		_limit_sides.z = roundi(limit_rect.position.x + limit_rect.size.x)
		# Bottom
		_limit_sides.w = roundi(limit_rect.position.y + limit_rect.size.y)
	elif _limit_node is CollisionShape2D:
		var collision_shape_2d = _limit_node as CollisionShape2D

		if not collision_shape_2d.get_shape(): return

		var shape_2d: Shape2D = collision_shape_2d.get_shape()
		var shape_2d_size: Vector2 = shape_2d.get_rect().size
		var shape_2d_position: Vector2 = collision_shape_2d.global_position + Vector2(shape_2d.get_rect().position)

		## Calculates the Rect2 based on the Tile Map position and size
		limit_rect = Rect2(shape_2d_position, shape_2d_size)

		## Calculates the Rect2 based on the Tile Map position and size + margin
		limit_rect = Rect2(
			limit_rect.position + Vector2(limit_margin.x, limit_margin.y),
			limit_rect.size - Vector2(limit_margin.x, limit_margin.y) - Vector2(limit_margin.z, limit_margin.w)
		)

		# Left
		_limit_sides.x = roundi(limit_rect.position.x)
		# Top
		_limit_sides.y = roundi(limit_rect.position.y)
		# Right
		_limit_sides.z = roundi(limit_rect.position.x + limit_rect.size.x)
		# Bottom
		_limit_sides.w = roundi(limit_rect.position.y + limit_rect.size.y)

	_check_limit_is_not_default()

	if _is_active and _has_valid_pcam_owner():
		_set_camera_2d_limit(SIDE_LEFT, _limit_sides.x)
		_set_camera_2d_limit(SIDE_TOP, _limit_sides.y)
		_set_camera_2d_limit(SIDE_RIGHT, _limit_sides.z)
		_set_camera_2d_limit(SIDE_BOTTOM, _limit_sides.w)


func reset_limit_all_sides() -> void:
	limit_left = _limit_sides_default.x
	limit_top = _limit_sides_default.y
	limit_right = _limit_sides_default.z
	limit_bottom = _limit_sides_default.w
	
	if not _has_valid_pcam_owner(): return
	if not _is_active: return
	get_pcam_host_owner().camera_2D.set_limit(SIDE_LEFT, limit_left)
	get_pcam_host_owner().camera_2D.set_limit(SIDE_TOP, limit_top)
	get_pcam_host_owner().camera_2D.set_limit(SIDE_RIGHT, limit_right)
	get_pcam_host_owner().camera_2D.set_limit(SIDE_BOTTOM, limit_bottom)
	
	#update_limit_all_sides()
	
	#_set_camera_2d_limit(SIDE_LEFT, -10000000)
	#_set_camera_2d_limit(SIDE_TOP, -10000000)
	#_set_camera_2d_limit(SIDE_RIGHT, 10000000)
	#_set_camera_2d_limit(SIDE_BOTTOM, 10000000)

#endregion


#region Setter & Getter Functions

## Assigns the [param PhantomCamera2D] to a new [param PhantomCameraHost].
func set_pcam_host() -> void:
	var pcam_host_group: Array[Node] = get_tree().get_nodes_in_group("phantom_camera_host_group")

	if pcam_host_group.size() == 1:
		_pcam_host_owner = pcam_host_group[0]
		_pcam_host_owner.pcam_added_to_scene(self)
#	else:
#		for camera_host in camera_host_group:
#			print("Multiple PhantomCameraBases in scene")
#			print(pcam_host_group)
#			print(pcam.get_tree().get_nodes_in_group(PhantomCameraGroupNames.PHANTOM_CAMERA_HOST_GROUP_NAME))
#			multiple_pcam_host_group.append(camera_host)
#			return nullfunc assign_pcam_host() -> void:
## Gets the current PhantomCameraHost this PhantomCamera2D is assigned to.
func get_pcam_host_owner() -> PhantomCameraHost:
	return _pcam_host_owner

## Assigns new Zoom value.
func set_zoom(value: Vector2) -> void:
	zoom = value
	queue_redraw()
## Gets current Zoom value.
func get_zoom() -> Vector2:
	return zoom


## Assigns new Priority value.
func set_priority(value: int) -> void:
	priority = abs(value)

	if _has_valid_pcam_owner():
		get_pcam_host_owner().pcam_priority_updated(self)
## Gets current Priority value.
func get_priority() -> int:
	return priority


## Assigns a new PhantomCameraTween resource to the PhantomCamera2D
func set_tween_resource(value: PhantomCameraTween) -> void:
	tween_resource = value
## Gets the PhantomCameraTween resource assigned to the PhantomCamera2D
## Returns null if there's nothing assigned to it.
func get_tween_resource() -> PhantomCameraTween:
	return tween_resource

## Assigns a new Tween Duration value. The duration value is in seconds.
## Note: This will override and make the Tween Resource unique to this PhantomCamera2D.
func set_tween_duration(value: float) -> void:
	if get_tween_resource():
		tween_resource_default.duration = value
		tween_resource_default.transition = tween_resource.transition
		tween_resource_default.ease = tween_resource.ease
		set_tween_resource(null) # Clears resource from PCam instance
	else:
		tween_resource_default.duration = value
## Gets the current Tween Duration value. The duration value is in seconds.
func get_tween_duration() -> float:
	if get_tween_resource():
		return get_tween_resource().duration
	else:
		return tween_resource_default.duration

## Assigns a new Tween Transition value.
## Note: This will override and make the Tween Resource unique to this PhantomCamera2D.
func set_tween_transition(value: int) -> void:
	if get_tween_resource():
		tween_resource_default.duration = tween_resource.duration
		tween_resource_default.transition = value
		tween_resource_default.ease = tween_resource.ease
		set_tween_resource(null) # Clears resource from PCam instance
	else:
		tween_resource_default.transition = value
## Gets the current Tween Transition value.
func get_tween_transition() -> int:
	if get_tween_resource():
		return get_tween_resource().transition
	else:
		return tween_resource_default.transition

## Assigns a new Tween Ease value.
## Note: This will override and make the Tween Resource unique to this PhantomCamera2D.
func set_tween_ease(value: int) -> void:
	if get_tween_resource():
		tween_resource_default.duration = tween_resource.duration
		tween_resource_default.transition = tween_resource.transition
		tween_resource_default.ease = value
		set_tween_resource(null) # Clears resource from PCam instance
	else:
		tween_resource_default.ease = value
## Gets the current Tween Ease value.
func get_tween_ease() -> int:
	if get_tween_resource():
		return get_tween_resource().ease
	else:
		return tween_resource_default.ease

## Sets the [param PhantomCamera2D] active state[br][br]
## [b][color=yellow]Important:[/color][/b] This value can only be changed
## from the [PhantomCameraHost] script.
func set_is_active(node, value) -> void:
	if is_instance_of(node, PhantomCameraHost):
		_is_active = value
	else:
		printerr("PCam can only be set from the PhantomCameraHost")
## Gets current active state of the PhantomCamera2D.
## If it returns true, it means the PhantomCamera2D is what the Camera2D is currently following.
func is_active() -> bool:
	return _is_active


## Enables or disables the Tween on Load.
func set_tween_on_load(value: bool) -> void:
	tween_onload = value
## Gets the current Tween On Load value.
func is_tween_on_load() -> bool:
	return tween_onload


## Gets the current follow mode as an enum int based on FOLLOW_MODE enum.
## Note: Setting Follow Mode purposely not added. A separate PCam should be used instead.
func get_follow_mode() -> int:
	return follow_mode


## Assigns a new Node2D as the Follow Target property.
func set_follow_target(value: Node2D) -> void:
	if follow_target == value: return
	follow_target = value
	if is_instance_valid(value):
		_should_follow = true
	else:
		_should_follow = false
	follow_target_changed.emit()
## Erases the current Node2D from the Follow Target property.
func erase_follow_target() -> void:
	if follow_target == null: return
	_should_follow = false
	follow_target = null
	follow_target_changed.emit()
## Gets the current Node2D target property.
func get_follow_target() -> Node2D:
	return follow_target


## Assigns a new Path2D to the Follow Path property.
func set_follow_path(value: Path2D) -> void:
	follow_path = value
## Erases the current Path2D from the Follow Path property.
func erase_follow_path() -> void:
	follow_path = null
## Gets the current Path2D from the Follow Path property.
func get_follow_path() -> Path2D:
	return follow_path


## Assigns a new Vector2 for the Follow Target Offset property.
func set_follow_target_offset(value: Vector2) -> void:
	follow_offset = value
## Gets the current Vector2 for the Follow Target Offset property.
func get_follow_target_offset() -> Vector2:
	return follow_offset


## Enables or disables Follow Damping.
func set_follow_has_damping(value: bool) -> void:
	follow_damping = value
	notify_property_list_changed()
## Gets the current Follow Damping property.
func get_follow_has_damping() -> bool:
	return follow_damping

## Assigns new Damping value.
func set_follow_damping_value(value: float) -> void:
	follow_damping_value = value
## Gets the current Follow Damping value.
func get_follow_damping_value() -> float:
	return follow_damping_value

## Enables or disables Pixel Perfect following.
func set_pixel_perfect(value: bool) -> void:
	pixel_perfect = value
## Gets the current Pixel Perfect property.
func get_pixel_perfect() -> bool:
	return pixel_perfect


func set_follow_targets(value: Array[Node2D]) -> void:
	# TODO - This shouldn't be needed.
	# Needs a fix to avoid triggering this setter when not in Group Follow
	if not follow_mode == FollowMode.GROUP: return

	follow_targets = value

	if follow_targets.is_empty():
		_should_follow = false
		_has_multiple_follow_targets = false
		return

	var valid_instances: int = 0
	for target in follow_targets:
		if is_instance_valid(target):
			_should_follow = true
			valid_instances += 1
			
			if valid_instances > 1:
				_has_multiple_follow_targets = true
## Adds a single Node2D to Follow Group array.
func append_follow_group_node(value: Node2D) -> void:
	if not is_instance_valid(value):
		printerr(value, " is not a valid instance")
		return
	if not follow_targets.has(value):
		follow_targets.append(value)
		_should_follow = true
		_has_multiple_follow_targets = true
	else:
		printerr(value, " is already part of Follow Group")
## Adds an Array of type Node2D to Follow Group array.
func append_follow_group_node_array(value: Array[Node2D]) -> void:
	for val in value:
		if not is_instance_valid(val): continue
		if not follow_targets.has(val):
			follow_targets.append(val)
			_should_follow = true
			if follow_targets.size() > 1:
				_has_multiple_follow_targets = true
		else:
			printerr(value, " is already part of Follow Group")
## Removes Node2D from Follow Group array.
func erase_follow_group_node(value: Node2D) -> void:
	follow_targets.erase(value)
	if follow_targets.size() < 1:
		_should_follow = false
		_has_multiple_follow_targets = false
## Gets all Node2D from Follow Group array.
func get_follow_targets() -> Array[Node2D]:
	return follow_targets


## Enables or disables Auto zoom when using Group Follow.
func set_auto_zoom(value: bool) -> void:
	auto_zoom = value
	notify_property_list_changed()
## Gets Auto Zoom state.
func get_auto_zoom() -> bool:
	return auto_zoom

## Assigns new Min Auto Zoom value.
func set_auto_zoom_min(value: float) -> void:
	auto_zoom_min = value
## Gets Min Auto Zoom value.
func get_auto_zoom_min() -> float:
	return auto_zoom_min

## Assigns new Max Auto Zoom value.
func set_auto_zoom_max(value: float) -> void:
	auto_zoom_max = value
## Gets Max Auto Zoom value.
func get_auto_zoom_max() -> float:
	return auto_zoom_max

## Assigns new Zoom Auto Margin value.
func set_auto_zoom_margin(value: Vector4) -> void:
	auto_zoom_margin = value
## Gets Zoom Auto Margin value.
func get_auto_zoom_margin() -> Vector4:
	return auto_zoom_margin

## Assign a the Camera2D Left Limit Side value.
func set_limit_left(value: int) -> void:
	limit_left = value
	update_limit_all_sides()
## Gets the Camera2D Left Limit value.
func get_limit_left() -> int:
	return limit_left

## Assign a the Camera2D Top Limit Side value.
func set_limit_top(value: int) -> void:
	limit_top = value
	update_limit_all_sides()
## Gets the Camera2D Top Limit value.
func get_limit_top() -> int:
	return limit_top

## Assign a the Camera2D Right Limit Side value.
func set_limit_right(value: int) -> void:
	limit_right = value
	update_limit_all_sides()
## Gets the Camera2D Right Limit value.
func get_limit_right() -> int:
	return limit_right

## Assign a the Camera2D Bottom Limit Side value.
func set_limit_bottom(value: int) -> void:
	limit_bottom = value
	update_limit_all_sides()
## Gets the Camera2D Bottom Limit value.
func get_limit_bottom() -> int:
	return limit_bottom

# Set Tile Map Limit Node.
func set_limit_target(value: NodePath) -> void:
	limit_target = value
	
	set_notify_transform(false)
	
	# Waits for PCam2d's _ready() before trying to validate limit_node_path
	if not is_node_ready(): await ready
	
	# Removes signal from existing TileMap node
	if is_instance_valid(get_node_or_null(value)):
		var prev_limit_node: Node2D = _limit_node
		if prev_limit_node is TileMap:
			if prev_limit_node.changed.is_connected(_on_tile_map_changed):
				prev_limit_node.changed.disconnect(_on_tile_map_changed)
		
		if _limit_node is TileMap:
			var tile_map_node: TileMap = get_node(value)
			tile_map_node.changed.connect(_on_tile_map_changed)

		elif _limit_node is CollisionShape2D:
			var col_shape: CollisionShape2D = get_node(value)
			if col_shape.get_shape() == null:
				printerr("No Shape2D in: ", col_shape.name)
			else:
				set_notify_transform(true)
	
	_limit_node = get_node_or_null(value)

	notify_property_list_changed()
	update_limit_all_sides()
	
	
## Get Tile Map Limit Node
func get_limit_target() -> NodePath:
	if not limit_target: # TODO - Fixes an spam error if if limit_taret is empty
		return NodePath("")
	else:
		return limit_target

## Set Tile Map Limit Margin.
func set_limit_margin(value: Vector4) -> void:
	limit_margin = value
	update_limit_all_sides()
## Get Tile Map Limit Margin.
func get_limit_margin() -> Vector4:
	return limit_margin

### Enables or disables the Limit Smoothing beaviour.
#func set_limit_smoothing(value: bool) -> void:
	#limit_smoothed = value
	#if is_active() and _has_valid_pcam_owner():
		#get_pcam_host_owner().camera_2D.reset_smoothing()
### Returns the Limit Smoothing beaviour.
#func get_limit_smoothing() -> bool:
	#return limit_smoothed

## Gets Interactive Update Mode property.
func get_inactive_update_mode() -> int:
	return inactive_update_mode

#endregion
