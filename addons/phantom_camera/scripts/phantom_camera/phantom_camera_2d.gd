@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_2d.svg")
class_name PhantomCamera2D
extends Node2D

## Controls a scene's [Camera2D] and applies logic to it.
##
## The scene's [param Camera2D] will follow the position of the
## [param PhantomCamera2D] with the highest priority.
## Each instance can have different positional and rotational logic applied
## to them.

#region Constants

const _constants := preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#endregion


#region Signals

## Emitted when the [param PhantomCamera2D] becomes active.
signal became_active
## Emitted when the [param PhantomCamera2D] becomes inactive.
signal became_inactive

## Emitted when [member follow_target] changes.
signal follow_target_changed

## Emitted when dead zones changes.[br]
## [b]Note:[/b] Only applicable in [param Framed] [enum FollowMode].
signal dead_zone_changed

## Emitted when the [param Camera2D] starts to tween to another [param PhantomCamera2D].
signal tween_started
## Emitted when the [param Camera2D] is to tweening towards another [param PhantomCamera2D].
signal is_tweening
## Emitted when the tween is interrupted due to another [param PhantomCamera2D]
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
	NONE 			= 0, ## Default - No follow logic is applied.
	GLUED 			= 1, ## Sticks to its target.
	SIMPLE 			= 2, ## Follows its target with an optional offset.
	GROUP 			= 3, ## Follows multiple targets with option to dynamically reframe itself.
	PATH 			= 4, ## Follows a target while being positionally confined to a [Path2D] node.
	FRAMED 			= 5, ## Applies a dead zone on the frame and only follows its target when it tries to leave it.
}

## Determines how often an inactive [param PhantomCamera2D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive [param PhantomCamera2D] are doing when idling to
## improve performance.
enum InactiveUpdateMode {
	ALWAYS, ## Always updates the [param PhantomCamera2D], even when it's inactive.
	NEVER, ## Never updates the [param PhantomCamera2D] when it's inactive. Reduces the amount of computational resources when inactive.
#	EXPONENTIALLY,
}

#endregion

#region Variables

var _is_active: bool = false

## The [PhantomCameraHost] that owns this [param PhantomCamera2D].
var pcam_host_owner: PhantomCameraHost = null:
	set = set_pcam_host_owner,
	get = get_pcam_host_owner

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

		if follow_mode == FollowMode.NONE:
			_should_follow = false
		elif follow_mode == FollowMode.GROUP and follow_targets or follow_target:
			_should_follow = true
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
var _follow_framed_offset: Vector2 = Vector2.ZERO
var _follow_target_physics_based: bool = false
var _physics_interpolation_enabled = false # NOTE - Enable for Godot 4.3 and when PhysicsInterpolationMode bug is resolved

### Defines the targets that the [param PhantomCamera2D] should be following.
@export var follow_targets: Array[Node2D] = []:
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
## overrides the [param zoom] property of the [param Camera2D] node.
@export var zoom: Vector2 = Vector2.ONE:
	set = set_zoom,
	get = get_zoom

## If enabled, will snap the [param Camera2D] to whole pixels as it moves.
## [br][br]
## This should be particularly useful in pixel art projects,
## where assets should always be aligned to the monitor's pixels to avoid
## unintended stretching.
@export var snap_to_pixel: bool = false:
	set = set_snap_to_pixel,
	get = get_snap_to_pixel

## Enables a preview of what the [PhantomCamera2D] will see in the
## scene. It works identically to how a [param Camera2D] shows which area
## will be visible during runtime. Likewise, this too will be affected by the
## [member zoom] property and the [param viewport_width] and
## [param Viewport Height] defined in the [param Project Settings].
@export var frame_preview: bool = true:
	set(value):
		frame_preview = value
		queue_redraw()
	get:
		return frame_preview

## Defines how the [param PhantomCamera2D] transition between one another.
## Changing the tween values for a given [param PhantomCamera2D]
## determines how transitioning to that instance will look like.
## This is a resource type that can be either used for one
## [param PhantomCamera] or reused across multiple - both 2D and 3D.
## By default, all [param PhantomCameras] will use a [param linear]
## transition, [param easeInOut] ease with a [param 1s] duration.
@export var tween_resource: PhantomCameraTween = PhantomCameraTween.new():
	set = set_tween_resource,
	get = get_tween_resource
var _tween_skip: bool = false

var tween_duration: float:
	set = set_tween_duration,
	get = get_tween_duration

var tween_transition: PhantomCameraTween.TransitionType:
	set = set_tween_transition,
	get = get_tween_transition

var tween_ease: PhantomCameraTween.EaseType:
	set = set_tween_ease,
	get = get_tween_ease

## If enabled, the moment a [param PhantomCamera3D] is instantiated into
## a scene, and has the highest priority, it will perform its tween transition.
## This is most obvious if a [param PhantomCamera3D] has a long duration and
## is attached to a playable character that can be moved the moment a scene
## is loaded. Disabling the [param tween_on_load] property will
## disable this behaviour and skip the tweening entirely when instantiated.
@export var tween_on_load: bool = true:
	set = set_tween_on_load,
	get = get_tween_on_load

## Determines how often an inactive [param PhantomCamera2D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive [param PhantomCamera2Ds] are doing when idling
## to improve performance.
@export var inactive_update_mode: InactiveUpdateMode = InactiveUpdateMode.ALWAYS

@export_group("Follow Parameters")
## Offsets the [member follow_target] position.
@export var follow_offset: Vector2 = Vector2.ZERO:
	set = set_follow_offset,
	get = get_follow_offset

## Applies a damping effect on the [param Camera2D]'s movement.
## Leading to heavier / slower camera movement as the targeted node moves around.
## This is useful to avoid sharp and rapid camera movement.
@export var follow_damping: bool = false:
	set = set_follow_damping,
	get = get_follow_damping

## Defines the damping amount. The ideal range should be somewhere between 0-1.[br][br]
## The damping amount can be specified in the individual axis.[br][br]
## [b]Lower value[/b] = faster / sharper camera movement.[br]
## [b]Higher value[/b] = slower / heavier camera movement.
@export var follow_damping_value: Vector2 = Vector2(0.1, 0.1):
	set = set_follow_damping_value,
	get = get_follow_damping_value
var _velocity_ref: Vector2 = Vector2.ZERO # Stores and applies the velocity of the movement

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
@export var show_viewfinder_in_play: bool = false

## Defines the position of the [member follow_target] within the viewport.[br]
## This is only used for when [member follow_mode] is set to [param Framed].
var viewport_position: Vector2
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

## Allows for setting either a [TileMap] or [CollisionShape2D] node to
## automatically apply a limit size instead of manually adjusting the Left,
## Top, Right and Left properties.[br][br]
## [b]TileMap[/b][br]
## The Limit will update after the [TileSet] of the [TileMap] has changed.[br]
## [b]Note:[/b] The limit size will only update after closing the TileMap editor
## bottom panel.
## [br][br]
## [b]CollisionShape2D[/b][br]
## The limit will update in realtime as the Shape2D changes its size.
## Note: For performance reasons, resizing the [Shape2D] during runtime will not change the Limits sides.
@export_node_path("TileMap", "CollisionShape2D") var limit_target = NodePath(""):
	set = set_limit_target,
	get = get_limit_target
var _limit_node: Node2D
## Applies an offset to the [TileMap] Limit or [Shape2D] Limit.
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

# NOTE - Temp solution until Godot has better plugin autoload recognition out-of-the-box.
var _phantom_camera_manager: Node


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


	if follow_mode == FollowMode.NONE:
		match property.name:
			"follow_offset", \
			"follow_damping", \
			"follow_damping_value":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_offset":
		if follow_mode == FollowMode.PATH or \
		follow_mode == FollowMode.GLUED:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_damping_value" and not follow_damping:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	###############
	## Follow Group
	###############
	if follow_mode != FollowMode.GROUP:
		match property.name:
			"follow_targets", \
			"auto_zoom":
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
	_phantom_camera_manager = get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME)
	_phantom_camera_manager.pcam_added(self)
	update_limit_all_sides()

	if not _phantom_camera_manager.get_phantom_camera_hosts().is_empty():
		set_pcam_host_owner(_phantom_camera_manager.get_phantom_camera_hosts()[0])

	if not visibility_changed.is_connected(_check_visibility):
		visibility_changed.connect(_check_visibility)


func _exit_tree() -> void:
	_phantom_camera_manager.pcam_removed(self)

	if _has_valid_pcam_owner():
		get_pcam_host_owner().pcam_removed_from_scene(self)


func _process(delta: float) -> void:
	if _follow_target_physics_based: return
	_process_logic(delta)


func _physics_process(delta: float):
	if not _follow_target_physics_based: return
	_process_logic(delta)


func _process_logic(delta: float) -> void:
	if not _is_active:
		match inactive_update_mode:
			InactiveUpdateMode.NEVER: return
			InactiveUpdateMode.ALWAYS:
				# Only triggers if limit isn't default
				if _limit_inactive_pcam:
					global_position = _set_limit_clamp_position(global_position)
#			InactiveUpdateMode.EXPONENTIALLY:
#				TODO - Trigger positional updates less frequently as more Pcams gets added
	_limit_checker()
	
	if _should_follow:
		if not follow_mode == FollowMode.GROUP:
			if follow_target.is_queued_for_deletion():
				follow_target = null
				return
		_follow(delta)


func _limit_checker() -> void:
	## TODO - Needs to see if this can be triggerd only from CollisionShape2D Transform changes
	if Engine.is_editor_hint():
		if draw_limits:
			update_limit_all_sides()


func _follow(delta: float) -> void:
	var follow_position: Vector2

	match follow_mode:
		FollowMode.GLUED:
			if follow_target:
				follow_position = follow_target.global_position
		FollowMode.SIMPLE:
			if follow_target:
				follow_position = _target_position_with_offset()
		FollowMode.GROUP:
			if follow_targets.size() == 1:
				follow_position = follow_targets[0].global_position
			elif _has_multiple_follow_targets and follow_targets.size() > 1:
				var rect: Rect2 = Rect2(follow_targets[0].global_position, Vector2.ZERO)
				for node in follow_targets:
					rect = rect.expand(node.global_position)
					if auto_zoom:
						rect = rect.grow_individual(
							auto_zoom_margin.x,
							auto_zoom_margin.y,
							auto_zoom_margin.z,
							auto_zoom_margin.w
						)
#						else:
#							rect = rect.grow_individual(-80, 0, 0, 0)
				if auto_zoom:
					var screen_size: Vector2 = get_viewport_rect().size
					if rect.size.x > rect.size.y * screen_size.aspect():
						zoom = clamp(screen_size.x / rect.size.x, auto_zoom_min, auto_zoom_max) * Vector2.ONE
					else:
						zoom = clamp(screen_size.y / rect.size.y, auto_zoom_min, auto_zoom_max) * Vector2.ONE
				follow_position = rect.get_center()
		FollowMode.PATH:
				if follow_target and follow_path:
					var path_position: Vector2 = follow_path.global_position

					follow_position = \
						follow_path.curve.get_closest_point(
							_target_position_with_offset() - path_position
						) + path_position

		FollowMode.FRAMED:
			if follow_target:
				if not Engine.is_editor_hint():
					viewport_position = (get_follow_target().get_global_transform_with_canvas().get_origin() + follow_offset) / get_viewport_rect().size

					if _get_framed_side_offset() != Vector2.ZERO:
						var glo_pos: Vector2
						var target_position: Vector2 = _target_position_with_offset() + _follow_framed_offset

						if dead_zone_width == 0 || dead_zone_height == 0:
							if dead_zone_width == 0 && dead_zone_height != 0:
								follow_position = _target_position_with_offset()
							elif dead_zone_width != 0 && dead_zone_height == 0:
								glo_pos = _target_position_with_offset()
								glo_pos.x += target_position.x - global_position.x
								follow_position = glo_pos
							else:
								follow_position = _target_position_with_offset()
						else:
							follow_position = target_position
					else:
						_follow_framed_offset = global_position - _target_position_with_offset()
						return
				else:
					follow_position = _target_position_with_offset()

	_interpolate_position(follow_position, delta)


func _set_velocity(index: int, value: float):
	_velocity_ref[index] = value


func _interpolate_position(target_position: Vector2, delta: float) -> void:
	if _limit_inactive_pcam and not _tween_skip:
		target_position = _set_limit_clamp_position(target_position)

	if follow_damping:
		for index in 2:
			global_position[index] = \
				_smooth_damp(
					target_position[index],
					global_position[index],
					index,
					_velocity_ref[index],
					_set_velocity,
					follow_damping_value[index],
					delta
				)
	else:
		global_position = target_position


func _smooth_damp(target_axis: float, self_axis: float, index: int, current_velocity: float, set_velocity: Callable, damping_time: float, delta: float) -> float:
		damping_time = maxf(0.0001, damping_time)
		var omega: float = 2 / damping_time
		var x: float = omega * delta
		var exponential: float = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x)
		var diff: float = self_axis - target_axis
		var _target_axis: float = target_axis

		var max_change: float = INF * damping_time
		diff = clampf(diff, -max_change, max_change)
		target_axis = self_axis - diff

		var temp: float = (current_velocity + omega * diff) * delta
		set_velocity.call(index, (current_velocity - omega * temp) * exponential)
		var output: float = target_axis + (diff + temp) * exponential

		## To prevent overshooting
		if (_target_axis - self_axis > 0.0) == (output > _target_axis):
			output = _target_axis
			set_velocity.call(index, (output - _target_axis) / delta)

		return output


func _set_limit_clamp_position(value: Vector2) -> Vector2:
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


func _on_tile_map_changed() -> void:
	update_limit_all_sides()


func _target_position_with_offset() -> Vector2:
	return follow_target.global_position + follow_offset


func _on_dead_zone_changed() -> void:
	set_global_position( _target_position_with_offset() )


func _has_valid_pcam_owner() -> bool:
	if not is_instance_valid(get_pcam_host_owner()): return false
	if not is_instance_valid(get_pcam_host_owner().camera_2d): return false
	return true


func _get_framed_side_offset() -> Vector2:
	var frame_out_bounds: Vector2

	if viewport_position.x < 0.5 - dead_zone_width / 2:
		# Is outside left edge
		frame_out_bounds.x = -1

	if viewport_position.y < 0.5 - dead_zone_height / 2:
		# Is outside top edge
		frame_out_bounds.y = 1

	if viewport_position.x > 0.5 + dead_zone_width / 2:
		# Is outside right edge
		frame_out_bounds.x = 1

	if viewport_position.y > 0.5001 + dead_zone_height / 2: # 0.501 to resolve an issue where the bottom vertical Dead Zone never becoming 0 when the Dead Zone Vertical parameter is set to 0
		# Is outside bottom edge
		frame_out_bounds.y = -1

	return frame_out_bounds


func _draw_camera_2d_limit() -> void:
	if _has_valid_pcam_owner():
		get_pcam_host_owner().camera_2d.set_limit_drawing_enabled(draw_limits)


func _check_limit_is_not_default() -> void:
	if _limit_sides == _limit_sides_default:
		_limit_inactive_pcam = false
	else:
		_limit_inactive_pcam = true


func _set_camera_2d_limit(side: int, limit: int) -> void:
	if not _has_valid_pcam_owner(): return
	if not _is_active: return
	get_pcam_host_owner().camera_2d.set_limit(side, limit)


func _check_visibility() -> void:
	if not is_instance_valid(pcam_host_owner): return
	pcam_host_owner.refresh_pcam_list_priorty()

#endregion


#region Public Functions

## Updates the limit sides based what has been set to define it
## This should be automatic, but can be called manully if need be.
func update_limit_all_sides() -> void:
	var limit_rect: Rect2

	if not is_instance_valid(_limit_node):
		_limit_sides.x = limit_left
		_limit_sides.y = limit_top
		_limit_sides.z = limit_right
		_limit_sides.w = limit_bottom
	elif _limit_node is TileMap:
		var tile_map: TileMap = _limit_node as TileMap
		var tile_map_size: Vector2 = Vector2(tile_map.get_used_rect().size) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()
		var tile_map_position: Vector2 = tile_map.global_position + Vector2(tile_map.get_used_rect().position) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()

		## Calculates the Rect2 based on the Tile Map position and size + margin
		limit_rect = Rect2(
			tile_map_position + Vector2(limit_margin.x, limit_margin.y),
			tile_map_size - Vector2(limit_margin.x, limit_margin.y) - Vector2(limit_margin.z, limit_margin.w)
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


func reset_limit() -> void:
	if not _has_valid_pcam_owner(): return
	if not _is_active: return
	get_pcam_host_owner().camera_2d.set_limit(SIDE_LEFT, _limit_sides_default.x)
	get_pcam_host_owner().camera_2d.set_limit(SIDE_TOP, _limit_sides_default.y)
	get_pcam_host_owner().camera_2d.set_limit(SIDE_RIGHT, _limit_sides_default.z)
	get_pcam_host_owner().camera_2d.set_limit(SIDE_BOTTOM, _limit_sides_default.w)


## Assigns the value of the [param has_tweened] property.
## [b][color=yellow]Important:[/color][/b] This value can only be changed
## from the [PhantomCameraHost] script.
func set_tween_skip(caller: Node, value: bool) -> void:
	if is_instance_of(caller, PhantomCameraHost):
		_tween_skip = value
	else:
		printerr("Can only be called PhantomCameraHost class")
## Returns the current [param has_tweened] value.
func get_tween_skip() -> bool:
	return _tween_skip

#endregion


#region Setter & Getter Functions

## Assigns the [param PhantomCamera2D] to a new [PhantomCameraHost].[br]
## [b][color=yellow]Important:[/color][/b] This is currently restricted to
## plugin internals. Proper support will be added in issue #26.
func set_pcam_host_owner(value: PhantomCameraHost) -> void:
	pcam_host_owner = value
	if is_instance_valid(pcam_host_owner):
		pcam_host_owner.pcam_added_to_scene(self)
	#if value.size() == 1:
#	else:
#		for camera_host in camera_host_group:
#			print("Multiple PhantomCameraBases in scene")
#			print(pcam_host_group)
#			print(pcam.get_tree().get_nodes_in_group(PhantomCameraGroupNames.PHANTOM_CAMERA_HOST_GROUP_NAME))
#			multiple_pcam_host_group.append(camera_host)
#			return nullfunc assign_pcam_host() -> void:
## Gets the current [PhantomCameraHost] this [param PhantomCamera2D] is
## assigned to.
func get_pcam_host_owner() -> PhantomCameraHost:
	return pcam_host_owner


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


## Assigns a new [param Tween Duration] to the [member tween_resource] value.[br]
## The duration value is in seconds.
func set_tween_duration(value: float) -> void:
	tween_resource.duration = value

## Gets the current [param Tween Duration] value inside the
## [member tween_resource].[br]
## The duration value is in seconds.
func get_tween_duration() -> float:
	return tween_resource.duration


## Assigns a new [param Tween Transition] value inside the
## [member tween_resource].
func set_tween_transition(value: int) -> void:
	tween_resource.transition = value

## Gets the current [param Tween Transition] value  inside the
## [member tween_resource].
func get_tween_transition() -> int:
	return tween_resource.transition


## Assigns a new [param Tween Ease] value inside the [member tween_resource].
func set_tween_ease(value: int) -> void:
	tween_resource.ease = value

## Gets the current [param Tween Ease] value inside the [member tween_resource].
func get_tween_ease() -> int:
	return tween_resource.ease


## Sets the [param PhantomCamera2D] active state.[br]
## [b][color=yellow]Important:[/color][/b] This value can only be changed
## from the [PhantomCameraHost] script.
func set_is_active(node, value) -> void:
	if node is PhantomCameraHost:
		_is_active = value
	else:
		printerr("PCams can only be set from the PhantomCameraHost")

## Gets current active state of the [param PhantomCamera2D].
## If it returns true, it means the [param PhantomCamera2D] is what the
## [param Camera2D] is currently following.
func is_active() -> bool:
	return _is_active


## Enables or disables the [member tween_on_load].
func set_tween_on_load(value: bool) -> void:
	tween_on_load = value

## Gets the current [member tween_on_load] value.
func get_tween_on_load() -> bool:
	return tween_on_load


## Gets the current follow mode as an enum int based on [enum FollowMode].[br]
## [b]Note:[/b] Setting [enum FollowMode] purposely not added.
## A separate PCam should be used instead.
func get_follow_mode() -> int:
	return follow_mode


## Assigns a new [Node2D] as the [member follow_target].
func set_follow_target(value: Node2D) -> void:
	if follow_target == value: return
	follow_target = value
	_follow_target_physics_based = false
	if is_instance_valid(value):
		_should_follow = true
		_check_physics_body(value)
	else:
		_should_follow = false
	follow_target_changed.emit()
	notify_property_list_changed()

## Erases the current [member follow_target].
func erase_follow_target() -> void:
	if follow_target == null: return
	_should_follow = false
	follow_target = null
	_follow_target_physics_based = false
	follow_target_changed.emit()

## Gets the current [member follow_target].
func get_follow_target() -> Node2D:
	return follow_target


## Assigns a new [Path2D] to the [member follow_path].
func set_follow_path(value: Path2D) -> void:
	follow_path = value

## Erases the current [Path2D] from the [member follow_path] property.
func erase_follow_path() -> void:
	follow_path = null

## Gets the current [Path2D] from the [member follow_path].
func get_follow_path() -> Path2D:
	return follow_path


## Assigns a new [param follow_targets] array value.
func set_follow_targets(value: Array[Node2D]) -> void:
	if follow_targets == value: return

	follow_targets = value

	if follow_targets.is_empty():
		_should_follow = false
		_has_multiple_follow_targets = false
		return

	_follow_target_physics_based = false
	var valid_instances: int = 0
	for target in follow_targets:
		if is_instance_valid(target):
			_should_follow = true
			valid_instances += 1

			_check_physics_body(target)

			if valid_instances > 1:
				_has_multiple_follow_targets = true

## Appends a single [Node2D] to [member follow_targets].
func append_follow_targets(value: Node2D) -> void:
	if not is_instance_valid(value):
		printerr(value, " is not a valid Node2D instance.")
		return
	if not follow_targets.has(value):
		follow_targets.append(value)
		_should_follow = true
		_has_multiple_follow_targets = true
		_check_physics_body(value)
	else:
		printerr(value, " is already part of Follow Group")

## Adds an Array of type [Node2D] to [member follow_targets].
func append_follow_targets_array(value: Array[Node2D]) -> void:
	for target in value:
		if not is_instance_valid(target): continue
		if not follow_targets.has(target):
			follow_targets.append(target)
			_should_follow = true
			_check_physics_body(target)
			if follow_targets.size() > 1:
				_has_multiple_follow_targets = true
		else:
			printerr(value, " is already part of Follow Group")

## Removes a [Node2D] from [member follow_targets] array.
func erase_follow_targets(value: Node2D) -> void:
	follow_targets.erase(value)
	_follow_target_physics_based = false
	for target in follow_targets:
		_check_physics_body(target)
	if follow_targets.size() < 2:
		_has_multiple_follow_targets = false
	if follow_targets.size() < 1:
		_should_follow = false

## Gets all [Node2D] from [member follow_targets] array.
func get_follow_targets() -> Array[Node2D]:
	return follow_targets


func _check_physics_body(target: Node2D) -> void:
	if target is PhysicsBody2D:
		## NOTE - Feature Toggle
		if Engine.get_version_info().major == 4 and \
		Engine.get_version_info().minor < 3:
			if ProjectSettings.get_setting("phantom_camera/tips/show_jitter_tips"):
				print_rich("Following a [b]PhysicsBody2D[/b] node will likely result in jitter - on lower physics ticks in particular.")
				print_rich("Once Godot 4.3 is released, will strongly recommend upgrading to that as it has built-in support for 2D Physics Interpolation.")
				print_rich("Until then, try following the guide on the [url=https://phantom-camera.dev/support/faq#i-m-seeing-jitter-what-can-i-do]documentation site[/url] for better results.")
				print_rich("This tip can be disabled from within [code]Project Settings / Phantom Camera / Tips / Show Jitter Tips[/code]")
			return
		## NOTE - Only supported in Godot 4.3 or above
		elif not ProjectSettings.get_setting("physics/common/physics_interpolation") and ProjectSettings.get_setting("phantom_camera/tips/show_jitter_tips"):
				printerr("Physics Interpolation is disabled in the Project Settings, recommend enabling it to smooth out physics-based camera movement")
				print_rich("This tip can be disabled from within [code]Project Settings / Phantom Camera / Tips / Show Jitter Tips[/code]")
		_follow_target_physics_based = true


## Assigns a new Vector2 for the Follow Target Offset property.
func set_follow_offset(value: Vector2) -> void:
	follow_offset = value

## Gets the current Vector2 for the Follow Target Offset property.
func get_follow_offset() -> Vector2:
	return follow_offset


## Enables or disables Follow Damping.
func set_follow_damping(value: bool) -> void:
	follow_damping = value
	notify_property_list_changed()

## Gets the current Follow Damping property.
func get_follow_damping() -> bool:
	return follow_damping


## Assigns new Damping value.
func set_follow_damping_value(value: Vector2) -> void:
	## TODO - Should be using @export_range once minimum version support is Godot 4.3
	if value.x < 0: value.x = 0
	elif value.y < 0: value.y = 0
	follow_damping_value = value

## Gets the current Follow Damping value.
func get_follow_damping_value() -> Vector2:
	return follow_damping_value


## Enables or disables [member snap_to_pixel].
func set_snap_to_pixel(value: bool) -> void:
	snap_to_pixel = value

## Gets the current [member snap_to_pixel] value.
func get_snap_to_pixel() -> bool:
	return snap_to_pixel


## Returns true if the [param PhantomCamera2D] has more than one member in the
## [follow_targets] array.
func get_has_multiple_follow_targets() -> bool:
	return _has_multiple_follow_targets


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


## Sets a limit side based on the side parameter.[br]
## It's recommended to pass the [enum Side] enum as the sid parameter.
func set_limit(side: int, value: int) -> void:
	match side:
		SIDE_LEFT: 		limit_left = value
		SIDE_TOP: 		limit_top = value
		SIDE_RIGHT: 	limit_right = value
		SIDE_BOTTOM: 	limit_bottom = value
		_:				printerr("Not a valid Side.")

## Gets the limit side
func get_limit(value: int) -> int:
	match value:
		SIDE_LEFT: 		return limit_left
		SIDE_TOP: 		return limit_top
		SIDE_RIGHT: 	return limit_right
		SIDE_BOTTOM: 	return limit_bottom
		_:
						printerr("Not a valid Side.")
						return -1


## Assign a the Camera2D Left Limit Side value.
func set_limit_left(value: int) -> void:
	_limit_target_exist_error()
	limit_left = value
	update_limit_all_sides()

## Gets the Camera2D Left Limit value.
func get_limit_left() -> int:
	return limit_left


## Assign a the Camera2D Top Limit Side value.
func set_limit_top(value: int) -> void:
	_limit_target_exist_error()
	limit_top = value
	update_limit_all_sides()

## Gets the Camera2D Top Limit value.
func get_limit_top() -> int:
	return limit_top


## Assign a the Camera2D Right Limit Side value.
func set_limit_right(value: int) -> void:
	_limit_target_exist_error()
	limit_right = value
	update_limit_all_sides()

## Gets the Camera2D Right Limit value.
func get_limit_right() -> int:
	return limit_right


## Assign a the Camera2D Bottom Limit Side value.
func set_limit_bottom(value: int) -> void:
	_limit_target_exist_error()
	limit_bottom = value
	update_limit_all_sides()

## Gets the Camera2D Bottom Limit value.
func get_limit_bottom() -> int:
	return limit_bottom


func _limit_target_exist_error() -> void:
	if not limit_target.is_empty():
		printerr("Unable to set Limit Side due to Limit Target ", _limit_node.name,  " being assigned")


# Sets a [memeber limit_target] node.
func set_limit_target(value: NodePath) -> void:
	limit_target = value

	# Waits for PCam2d's _ready() before trying to validate limit_node_path
	if not is_node_ready(): await ready

	# Removes signal from existing TileMap node
	if is_instance_valid(get_node_or_null(value)):
		var prev_limit_node: Node2D = _limit_node
		var new_limit_node: Node2D = get_node(value)

		if prev_limit_node is TileMap:
			if prev_limit_node.changed.is_connected(_on_tile_map_changed):
				prev_limit_node.changed.disconnect(_on_tile_map_changed)

		if new_limit_node is TileMap:
			if not new_limit_node.changed.is_connected(_on_tile_map_changed):
				new_limit_node.changed.connect(_on_tile_map_changed)
		elif new_limit_node is CollisionShape2D:
			var col_shape: CollisionShape2D = get_node(value)

			if col_shape.shape == null:
				printerr("No Shape2D in: ", col_shape.name)
				reset_limit()
				limit_target = null
				return
		else:
			printerr("Limit Target is not a TileMap or CollisionShape2D node")
			return

	elif value == NodePath(""):
		reset_limit()
		limit_target = null
	else:
		printerr("Limit Target cannot be found")
		return

	_limit_node = get_node_or_null(value)

	notify_property_list_changed()
	update_limit_all_sides()

## Get [member limit_target] node.
func get_limit_target() -> NodePath:
	if not limit_target: # TODO - Fixes an spam error if if limit_taret is empty
		return NodePath("")
	else:
		return limit_target


## Set Tile Map Limit Margin.
func set_limit_margin(value: Vector4i) -> void:
	limit_margin = value
	update_limit_all_sides()
## Get Tile Map Limit Margin.
func get_limit_margin() -> Vector4i:
	return limit_margin


### Enables or disables the Limit Smoothing beaviour.
#func set_limit_smoothing(value: bool) -> void:
	#limit_smoothed = value
	#if is_active() and _has_valid_pcam_owner():
		#get_pcam_host_owner().camera_2d.reset_smoothing()
### Returns the Limit Smoothing beaviour.
#func get_limit_smoothing() -> bool:
	#return limit_smoothed


## Sets [member inactive_update_mode] property.
func set_inactive_update_mode(value: int) -> void:
	inactive_update_mode = value

## Gets [enum InactiveUpdateMode] value.
func get_inactive_update_mode() -> int:
	return inactive_update_mode


func set_follow_target_physics_based(value: bool, caller: Node) -> void:
	if is_instance_of(caller, PhantomCameraHost):
		_follow_target_physics_based = value
	else:
		printerr("set_follow_target_physics_based() is for internal use only.")
func get_follow_target_physics_based() -> bool:
	return _follow_target_physics_based


func get_class() -> String:
	return "PhantomCamera2D"


func is_class(value) -> bool:
	return value == "PhantomCamera2D"

#endregion
