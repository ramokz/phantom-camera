@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_3d.svg")
class_name PhantomCamera3D
extends Node3D

## Controls a scene's [Camera3D] and applies logic to it.
##
## The scene's [param Camera3D] will follow the position of the
## [param PhantomCamera3D] with the highest priority.
## Each instance can have different positional and rotational logic applied
## to them.

#region Constants

const _constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#endregion


#region Signals

## Emitted when the [param PhantomCamera3D] becomes active.
signal became_active
## Emitted when the [param PhantomCamera3D] becomes inactive.
signal became_inactive

## Emitted when [member follow_target] changes.
signal follow_target_changed

## Emitted when [member look_at_target] changes.
signal look_at_target_changed

## Emitted when dead zones changes. [br]
## [b]Note:[/b] Only applicable in [param Framed] [member FollowMode].
signal dead_zone_changed

## Emitted when the [param Camera3D] starts to tween to another
## [param PhantomCamera3D].
signal tween_started
## Emitted when the [param Camera3D] is to tweening towards another
## [param PhantomCamera3D].
signal is_tweening
## Emitted when the tween is interrupted due to another [param PhantomCamera3D]
## becoming active. The argument is the [param PhantomCamera3D] that
## interrupted the tween.
signal tween_interrupted(pcam_3d: PhantomCamera3D)
## Emitted when the [param Camera3D] completes its tween to the
## [param PhantomCamera3D].
signal tween_completed

#endregion


#region Enums

## Determines the positional logic for a given [param PhantomCamera3D]
## [br][br]
## The different modes have different functionalities and purposes, so choosing
## the correct one depends on what each [param PhantomCamera3D] is meant to do.
enum FollowMode {
	NONE 			= 0, ## Default - No follow logic is applied.
	GLUED 			= 1, ## Sticks to its target.
	SIMPLE 			= 2, ## Follows its target with an optional offset.
	GROUP 			= 3, ## Follows multiple targets with option to dynamically reframe itself.
	PATH 			= 4, ## Follows a target while being positionally confined to a [Path3D] node.
	FRAMED 			= 5, ## Applies a dead zone on the frame and only follows its target when it tries to leave it.
	THIRD_PERSON 	= 6, ## Applies a [SpringArm3D] node to the target's position and allows for rotating around it.
}

## Determines the rotational logic for a given [param PhantomCamera3D].[br][br]
## The different modes has different functionalities and purposes, so
## choosing the correct mode depends on what each [param PhantomCamera3D]
## is meant to do.
enum LookAtMode {
	NONE 	= 0, ## Default - No Look At logic is applied.
	MIMIC 	= 1, ## Copies its target's rotational value.
	SIMPLE 	= 2, ## Looks at its target in a straight line.
	GROUP	= 3, ## Looks at the centre of its targets.
}

## Determines how often an inactive [param PhantomCamera3D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive [param PhantomCamera3D] are doing when idling
## to improve performance.
enum InactiveUpdateMode {
	ALWAYS, ## Always updates the [param PhantomCamera3D], even when it's inactive.
	NEVER, 	## Never updates the [param PhantomCamera3D] when it's inactive. Reduces the amount of computational resources when inactive.
#	EXPONENTIALLY,
}

#endregion


#region Variables

## The [PhantomCameraHost] that owns this [param PhantomCamera2D].
var pcam_host_owner: PhantomCameraHost = null:
	set = set_pcam_host_owner,
	get = get_pcam_host_owner

var _is_active: bool = false

## To quickly preview a [param PhantomCamera3D] without adjusting its
## [member Priority], this property allows the selected [param PhantomCamera3D]
## to ignore the Priority system altogether and forcefully become the active
## one. It's partly designed to work within the [param viewfinder], and will be
## disabled when running a build export of the game.
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

## It defines which [param PhantomCamera3D] a scene's [param Camera3D] should
## be corresponding with and be attached to. This is decided by the
## [param PhantomCamera3D] with the highest [param priority].
## [br][br]
## Changing [param priority] will send an event to the scene's
## [PhantomCameraHost], which will then determine whether if the
## [param priority] value is greater than or equal to the currently
## highest [param PhantomCamera3D]'s in the scene. The
## [param PhantomCamera3D] with the highest value will then reattach the
## Camera accordingly.
@export var priority: int = 0:
	set = set_priority,
	get = get_priority

## Determines the positional logic for a given [param PhantomCamera3D].
## The different modes have different functionalities and purposes, so
## choosing the correct one depends on what each [param PhantomCamera3D]
## is meant to do.
@export var follow_mode: FollowMode = FollowMode.NONE:
	set(value):
		follow_mode = value

		if value == FollowMode.FRAMED:
			if _follow_framed_initial_set and follow_target:
				_follow_framed_initial_set = false
				dead_zone_changed.connect(_on_dead_zone_changed)
		else:
			if  dead_zone_changed.is_connected(_on_dead_zone_changed):
				dead_zone_changed.disconnect(_on_dead_zone_changed)

		if follow_mode == FollowMode.NONE:
			_should_follow = false
		elif follow_mode == FollowMode.GROUP and follow_targets or follow_target:
			_should_follow = true

		notify_property_list_changed()
	get:
		return follow_mode


## Determines which target should be followed.
## The [param Camera3D] will follow the position of the Follow Target based on
## the [member follow_mode] type and its parameters.
@export var follow_target: Node3D = null:
	set = set_follow_target,
	get = get_follow_target
var _should_follow: bool = false
var _follow_target_physics_based: bool = false
var _physics_interpolation_enabled = false ## TOOD - Should be anbled once toggling physics_interpolation_mode ON, when previously OFF, works in 3D

## Defines the targets that the [param PhantomCamera3D] should be following.
@export var follow_targets: Array[Node3D] = []:
	set = set_follow_targets,
	get = get_follow_targets
var _has_multiple_follow_targets: bool = false


## Determines the [Path3D] node the [param PhantomCamera3D]
## should be bound to.
## The [param PhantomCamera3D] will follow the position of the
## [member follow_target] while sticking to the closest point on this path.
@export var follow_path: Path3D = null:
	set = set_follow_path,
	get = get_follow_path


## Determines the rotational logic for a given [param PhantomCamera3D].
## The different modes has different functionalities and purposes,
## so choosing the correct mode depends on what each
## [param PhantomCamera3D] is meant to do.
@export var look_at_mode: LookAtMode = LookAtMode.NONE:
	set(value):
		look_at_mode = value
		if look_at_target is Node3D:
			_should_look_at = true

		if look_at_mode == LookAtMode.NONE:
			_should_look_at = false
		elif  look_at_mode == LookAtMode.GROUP and look_at_targets or look_at_target:
			_should_look_at = true

		notify_property_list_changed()
	get:
		return look_at_mode
var _should_look_at: bool = false
var _multiple_look_at_targets: bool = false

## Determines which target should be looked at.
## The [param PhantomCamera3D] will update its rotational value as the
## target changes its position.
@export var look_at_target: Node3D = null:
	set = set_look_at_target,
	get = get_look_at_target

## Defines the targets that the camera should looking at.
## It will be looking at the centre of all the assigned targets.
@export var look_at_targets: Array[Node3D] = []:
	set = set_look_at_targets,
	get = get_look_at_targets
var _valid_look_at_targets: Array[Node3D] = []

## Defines how [param ]PhantomCamera3Ds] transition between one another.
## Changing the tween values for a given [param PhantomCamera3D]
## determines how transitioning to that instance will look like.
## This is a resource type that can be either used for one
## [param PhantomCamera] or reused across multiple - both 2D and 3D.
## By default, all [param PhantomCameras] will use a [param linear]
## transition, [param easeInOut] ease with a [param 1s] duration.
@export var tween_resource: PhantomCameraTween = PhantomCameraTween.new():
	set = set_tween_resource,
	get = get_tween_resource
var _has_tweened: bool = false

## If enabled, the moment a [param PhantomCamera3D] is instantiated into
## a scene, and has the highest priority, it will perform its tween transition.
## This is most obvious if a [param PhantomCamera3D] has a long duration and
## is attached to a playable character that can be moved the moment a scene
## is loaded. Disabling the [param tween_on_load] property will
## disable this behaviour and skip the tweening entirely when instantiated.
@export var tween_on_load: bool = true:
	set = set_tween_on_load,
	get = get_tween_on_load

## Determines how often an inactive [param PhantomCamera3D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive [param PhantomCamera3Ds] are doing when idling
## to improve performance.
@export var inactive_update_mode: InactiveUpdateMode = InactiveUpdateMode.ALWAYS:
	set = set_inactive_update_mode,
	get = get_inactive_update_mode


## A resource type that allows for overriding the [param Camera3D] node's
## properties.
@export var camera_3d_resource: Camera3DResource = Camera3DResource.new():
	set = set_camera_3d_resource,
	get = get_camera_3d_resource

@export_group("Follow Parameters")
## Offsets the [member follow_target] position.
@export var follow_offset: Vector3 = Vector3.ZERO:
	set = set_follow_offset,
	get = get_follow_offset

## Applies a damping effect on the camera's movement.
## Leading to heavier / slower camera movement as the targeted node moves around.
## This is useful to avoid sharp and rapid camera movement.
@export var follow_damping: bool = false:
	set = set_follow_damping,
	get = get_follow_damping

## Defines the damping amount. The ideal range should be somewhere between 0-1.[br][br]
## The damping amount can be specified in the individual axis.[br][br]
## [b]Lower value[/b] = faster / sharper camera movement.[br]
## [b]Higher value[/b] = slower / heavier camera movement.
@export var follow_damping_value: Vector3 = Vector3(0.1, 0.1, 0.1):
	set = set_follow_damping_value,
	get = get_follow_damping_value
var _follow_velocity_ref: Vector3 = Vector3.ZERO # Stores and applies the velocity of the movement

## Sets a distance offset from the centre of the target's position.
## The distance is applied to the [param PhantomCamera3D]'s local z axis.
@export var follow_distance: float = 1:
	set = set_follow_distance,
	get = get_follow_distance

## Enables the [param PhantomCamera3D] to automatically distance
## itself as the [param follow targets] move further apart.[br]
## It looks at the longest axis between the different targets and interpolates
## the distance length between the [member auto_follow_distance_min] and
## [member follow_group_distance] properties.[br][br]
## Note: Enabling this property hides and disables the [member follow_distance]
## property as this effectively overrides that property.
@export var auto_follow_distance: bool = false:
	set = set_auto_follow_distance,
	get = get_auto_follow_distance

## Sets the minimum distance between the Camera and centre of [AABB].
## [br][br]
## Note: This distance will only ever be reached when all the targets are in
## the exact same [param Vector3] coordinate, which will very unlikely
## happen, so adjust the value here accordingly.
@export var auto_follow_distance_min: float = 1:
	set = set_auto_follow_distance_min,
	get = get_auto_follow_distance_min

## Sets the maximum distance between the Camera and centre of [AABB].
@export var auto_follow_distance_max: float = 5:
	set = set_auto_follow_distance_max,
	get = get_auto_follow_distance_max

## Determines how fast the [member auto_follow_distance] moves between the
## maximum and minimum distance. The higher the value, the sooner the
## maximum distance is reached.[br][br]
## This value should be based on the sizes of the [member auto_follow_distance_min]
## and [member auto_follow_distance_max].[br]
## E.g. if the value between the [member auto_follow_distance_min] and
## [member auto_follow_distance_max] is small, consider keeping the number low
## and vice versa.
@export var auto_follow_distance_divisor: float = 10:
	set = set_auto_follow_distance_divisor,
	get = get_auto_follow_distance_divisor

@export_subgroup("Dead Zones")
## Defines the horizontal dead zone area. While the target is within it, the
## [param PhantomCamera3D] will not move in the horizontal axis.
## If the targeted node leaves the horizontal bounds, the
## [param PhantomCamera3D] will follow the target horizontally to keep
## it within bounds.
@export_range(0, 1) var dead_zone_width: float = 0:
	set(value):
		dead_zone_width = value
		dead_zone_changed.emit()
	get:
		return dead_zone_width

## Defines the vertical dead zone area. While the target is within it, the
## [param PhantomCamera3D] will not move in the vertical axis.
## If the targeted node leaves the vertical bounds, the
## [param PhantomCamera3D] will follow the target horizontally to keep
## it within bounds.
@export_range(0, 1) var dead_zone_height: float = 0:
	set(value):
		dead_zone_height = value
		dead_zone_changed.emit()
	get:
		return dead_zone_height

## Enables the dead zones to be visible when running the game from the editor.
## Dead zones will never be visible in build exports.
@export var show_viewfinder_in_play: bool = false

## Defines the position of the [member follow_target] within the viewport.[br]
## This is only used for when [member follow_mode] is set to [param Framed].
var viewport_position: Vector2
var _follow_framed_initial_set: bool = false
var _follow_framed_offset: Vector3

@export_subgroup("Spring Arm")
var _follow_spring_arm: SpringArm3D

## Defines the [member SpringArm3D.spring_length].
@export var spring_length: float = 1:
	set = set_spring_length,
	get = get_spring_length

## Defines the [member SpringArm3D.collision_mask] node's Collision Mask.
@export_flags_3d_physics var collision_mask: int = 1:
	set = set_collision_mask,
	get = get_collision_mask

## Defines the [member SpringArm3D.shape] node's Shape3D.
@export var shape: Shape3D = null:
	set = set_shape,
	get = get_shape

## Defines the [member SpringArm3D.margin] node's Margin.
@export var margin: float = 0.01:
	set = set_margin,
	get = get_margin

@export_group("Look At Parameters")
## Offsets the target's [param Vector3] position that the
## [param PhantomCamera3D] is looking at.
@export var look_at_offset: Vector3 = Vector3.ZERO:
	set = set_look_at_offset,
	get = get_look_at_offset

## Applies a damping effect on the camera's rotation.
## Leading to heavier / slower camera movement as the targeted node moves around.
## This is useful to avoid sharp and rapid camera rotation.
@export var look_at_damping: bool = false:
	set = set_look_at_damping,
	get = get_look_at_damping

## Defines the Rotational damping amount. The ideal range is typicall somewhere between 0-1.[br][br]
## The damping amount can be specified in the individual axis.[br][br]
## [b]Lower value[/b] = faster / sharper camera rotation.[br]
## [b]Higher value[/b] = slower / heavier camera rotation.
@export_range(0.0, 1.0, 0.001, "or_greater") var look_at_damping_value: float = 0.25:
	set = set_look_at_damping_value,
	get = get_look_at_damping_value

var _current_rotation: Vector3

#endregion

# NOTE - Temp solution until Godot has better plugin autoload recognition out-of-the-box.
var _phantom_camera_manager: Node


#region Property Validator

func _validate_property(property: Dictionary) -> void:
	################
	## Follow Target
	################
	if property.name == "follow_target":
		if follow_mode == FollowMode.NONE or \
		follow_mode == FollowMode.GROUP:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_path" and \
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

	if property.name == "follow_distance":
		if not follow_mode == FollowMode.FRAMED:
			if not follow_mode == FollowMode.GROUP or \
			auto_follow_distance: \
				property.usage = PROPERTY_USAGE_NO_EDITOR

	###############
	## Group Follow
	###############
	if property.name == "follow_targets" and \
	not follow_mode == FollowMode.GROUP:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "auto_follow_distance" and \
	not follow_mode == FollowMode.GROUP:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if not auto_follow_distance:
		match property.name:
			"auto_follow_distance_min", \
			"auto_follow_distance_max", \
			"auto_follow_distance_divisor":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	###############
	## Framed Follow
	###############
	if not follow_mode == FollowMode.FRAMED:
		match property.name:
			"dead_zone_width", \
			"dead_zone_height", \
			"show_viewfinder_in_play":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	######################
	## Third Person Follow
	######################
	if not follow_mode == FollowMode.THIRD_PERSON:
		match property.name:
			"spring_length", \
			"collision_mask", \
			"shape", \
			"margin":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	##########
	## Look At
	##########
	if look_at_mode == LookAtMode.NONE:
		match property.name:
			"look_at_target", \
			"look_at_offset" , \
			"look_at_damping", \
			"look_at_damping_value":
				property.usage = PROPERTY_USAGE_NO_EDITOR
	elif look_at_mode == LookAtMode.GROUP:
		match property.name:
			"look_at_target":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "look_at_target":
		if look_at_mode == LookAtMode.NONE or \
		look_at_mode == LookAtMode.GROUP:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "look_at_targets" and \
	not look_at_mode == LookAtMode.GROUP:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "look_at_damping_value" and \
	not look_at_damping:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	notify_property_list_changed()
#endregion

#region Private Functions

func _enter_tree() -> void:
	_phantom_camera_manager = get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME)

	_phantom_camera_manager.pcam_added(self)

	if not _phantom_camera_manager.get_phantom_camera_hosts().is_empty():
		set_pcam_host_owner(_phantom_camera_manager.get_phantom_camera_hosts()[0])

	#if not get_parent() is SpringArm3D:
		#if look_at_target:
			#_look_at_target_node = look_at_target
		#elif look_at_targets:
			#_look_at_group_nodes.clear()
			#for path in look_at_targets:
				#if not path.is_empty() and path:
					#_should_look_at = true
					#_has_look_at_targets = true
					#_look_at_group_nodes.append(path)


func _exit_tree() -> void:
	_phantom_camera_manager.pcam_removed(self)

	if _has_valid_pcam_owner():
		get_pcam_host_owner().pcam_removed_from_scene(self)



func _ready():
	if follow_mode == FollowMode.THIRD_PERSON:
		if not Engine.is_editor_hint():
			if not is_instance_valid(_follow_spring_arm):
				_follow_spring_arm = SpringArm3D.new()
				_follow_spring_arm.top_level = true
				_follow_spring_arm.rotation = global_rotation
				_follow_spring_arm.position = _get_target_position_offset() if is_instance_valid(follow_target) else global_position
				_follow_spring_arm.spring_length = spring_length
				_follow_spring_arm.collision_mask = collision_mask
				_follow_spring_arm.shape = shape
				_follow_spring_arm.margin = margin
				get_parent().add_child.call_deferred(_follow_spring_arm)
				reparent.call_deferred(_follow_spring_arm)
	if follow_mode == FollowMode.FRAMED:
		if not Engine.is_editor_hint():
			_follow_framed_offset = global_position - _get_target_position_offset()
			_current_rotation = global_rotation


func _process(delta: float) -> void:
	if not _follow_target_physics_based:
		_process_logic(delta)


func _physics_process(delta: float):
	if _follow_target_physics_based:
		_process_logic(delta)


func _process_logic(delta: float) -> void:
	if not _is_active:
		match inactive_update_mode:
			InactiveUpdateMode.NEVER:	return
			# InactiveUpdateMode.EXPONENTIALLY:
			# TODO - Trigger positional updates less frequently as more Pcams gets added
	if _should_follow:
		_follow(delta)
	if _should_look_at:
		_look_at() # TODO - Delta needs to be applied, pending Godot's 3D Physics Interpolation to be implemented


func _follow(delta: float) -> void:
	var follow_position: Vector3

	var follow_target_node: Node3D = self

	match follow_mode:
		FollowMode.GLUED:
			if follow_target:
				follow_position = follow_target.global_position
		FollowMode.SIMPLE:
			if follow_target:
				follow_position = _get_target_position_offset()
		FollowMode.GROUP:
			if follow_targets:
				if follow_targets.size() == 1:
					follow_position = \
						follow_targets[0].global_position + \
						follow_offset + \
						get_transform().basis.z * \
						Vector3(follow_distance, follow_distance, follow_distance)

				elif follow_targets.size() > 1:
					var bounds: AABB = AABB(follow_targets[0].global_position, Vector3.ZERO)
					for node in follow_targets:
						if is_instance_valid(node):
							bounds = bounds.expand(node.global_position)

					var distance: float
					if auto_follow_distance:
						distance = lerp(auto_follow_distance_min, auto_follow_distance_max, bounds.get_longest_axis_size() / auto_follow_distance_divisor)
						distance = clamp(distance, auto_follow_distance_min, auto_follow_distance_max)
					else:
						distance = follow_distance

					follow_position = \
						bounds.get_center() + \
						follow_offset + \
						get_transform().basis.z * \
						Vector3(distance, distance, distance)
		FollowMode.PATH:
			if follow_target and follow_path:
				var path_position: Vector3 = follow_path.global_position
				follow_position = \
					follow_path.curve.get_closest_point(
						follow_target.global_position - path_position
					) + path_position
		FollowMode.FRAMED:
			if follow_target:
				if not Engine.is_editor_hint():
					if not _is_active || get_pcam_host_owner().get_trigger_pcam_tween():
						follow_position = _get_position_offset_distance()
						_interpolate_position(follow_position, delta)
						return

					viewport_position = get_viewport().get_camera_3d().unproject_position(_get_target_position_offset())
					var visible_rect_size: Vector2 = get_viewport().get_viewport().size
					viewport_position = viewport_position / visible_rect_size
					_current_rotation = global_rotation

					if _current_rotation != global_rotation:
						follow_position = _get_position_offset_distance()

					if _get_framed_side_offset() != Vector2.ZERO:
						var target_position: Vector3 = _get_target_position_offset() + _follow_framed_offset
						var glo_pos: Vector3

						if dead_zone_width == 0 || dead_zone_height == 0:
							if dead_zone_width == 0 && dead_zone_height != 0:
								glo_pos = _get_position_offset_distance()
								glo_pos.z = target_position.z
								follow_position = glo_pos
							elif dead_zone_width != 0 && dead_zone_height == 0:
								glo_pos = _get_position_offset_distance()
								glo_pos.x = target_position.x
								follow_position = glo_pos
							else:
								follow_position = _get_position_offset_distance()
						else:
							if _current_rotation != global_rotation:
								var opposite: float = sin(-global_rotation.x) * follow_distance + _get_target_position_offset().y
								glo_pos.y = _get_target_position_offset().y + opposite
								glo_pos.z = sqrt(pow(follow_distance, 2) - pow(opposite, 2)) + _get_target_position_offset().z
								glo_pos.x = global_position.x

								follow_position = glo_pos
								_current_rotation = global_rotation
							else:
								follow_position = target_position
					else:
						_follow_framed_offset = global_position - _get_target_position_offset()
						_current_rotation = global_rotation
						return
				else:
					follow_position = _get_position_offset_distance()
					var unprojected_position: Vector2 = _get_raw_unprojected_position()
					var viewport_width: float = get_viewport().size.x
					var viewport_height: float = get_viewport().size.y
					var camera_aspect: Camera3D.KeepAspect = get_viewport().get_camera_3d().keep_aspect
					var visible_rect_size: Vector2 = get_viewport().get_viewport().size

					unprojected_position = unprojected_position - visible_rect_size / 2
					if camera_aspect == Camera3D.KeepAspect.KEEP_HEIGHT:
#							Landscape View
						var aspect_ratio_scale: float = viewport_width / viewport_height
						unprojected_position.x = (unprojected_position.x / aspect_ratio_scale + 1) / 2
						unprojected_position.y = (unprojected_position.y + 1) / 2
					else:
#							Portrait View
						var aspect_ratio_scale: float = viewport_height / viewport_width
						unprojected_position.x = (unprojected_position.x + 1) / 2
						unprojected_position.y = (unprojected_position.y / aspect_ratio_scale + 1) / 2

					viewport_position = unprojected_position
		FollowMode.THIRD_PERSON:
			if follow_target:
				if not Engine.is_editor_hint():
					if is_instance_valid(follow_target) and is_instance_valid(_follow_spring_arm):
						follow_position = _get_target_position_offset()
						follow_target_node = _follow_spring_arm
				else:
					follow_position = _get_position_offset_distance()

	_interpolate_position(follow_position, delta, follow_target_node)


func _look_at() -> void:
	match look_at_mode:
		LookAtMode.MIMIC:
			global_rotation = look_at_target.global_rotation
		LookAtMode.SIMPLE:
			_interpolate_rotation(look_at_target.global_position)
		LookAtMode.GROUP:
			if not _multiple_look_at_targets:
				if look_at_targets.size() == 0: return
				_interpolate_rotation(look_at_targets[0].global_position)
			else:
				var bounds: AABB = AABB(look_at_targets[0].global_position, Vector3.ZERO)
				for node in look_at_targets:
					bounds = bounds.expand(node.global_position)
				_interpolate_rotation(bounds.get_center())


func _get_target_position_offset() -> Vector3:
	return follow_target.global_position + follow_offset


func _get_position_offset_distance() -> Vector3:
	return _get_target_position_offset() + \
	get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance)


func _set_follow_velocity(index: int, value: float) -> void:
	_follow_velocity_ref[index] = value
func _interpolate_position(target_position: Vector3, delta: float, camera_target: Node3D = self) -> void:
	if follow_damping:
		for index in 3:
			camera_target.global_position[index] = _smooth_damp(
				target_position[index],
				camera_target.global_position[index],
				index,
				_follow_velocity_ref[index],
				_set_follow_velocity,
				follow_damping_value[index]
			)
	else:
		camera_target.global_position = target_position


func _interpolate_rotation(target_trans: Vector3) -> void:
	var direction: Vector3 = (target_trans - global_position + look_at_offset).normalized()
	var target_basis: Basis = Basis().looking_at(direction)
	var target_quat: Quaternion = target_basis.get_rotation_quaternion().normalized()
	if look_at_damping:
		var current_quat: Quaternion = quaternion.normalized()

		var damping_time: float = max(0.0001, look_at_damping_value)
		var t: float = min(1.0, get_process_delta_time() / damping_time)

		var dot: float = current_quat.dot(target_quat)

		if dot < 0.0:
			target_quat = -target_quat
			dot = -dot

		dot = clampf(dot, -1.0, 1.0)

		var theta: float = acos(dot) * t
		var sin_theta: float = sin(theta)
		var sin_theta_total: float = sin(acos(dot))

		# Stop interpolating once sin_theta_total reaches a very low value or 0
		if sin_theta_total < 0.00001:
			return

		var ratio_a: float = cos(theta) - dot * sin_theta / sin_theta_total
		var ratio_b: float = sin_theta / sin_theta_total

		quaternion = current_quat * ratio_a + target_quat * ratio_b
	else:
		quaternion = target_quat


func _smooth_damp(target_axis: float, self_axis: float, index: int, current_velocity: float, set_velocity: Callable, damping_time: float, rot: bool = false) -> float:
		damping_time = maxf(0.0001, damping_time)
		var omega: float = 2 / damping_time
		var delta: float = get_process_delta_time()
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


func _get_raw_unprojected_position() -> Vector2:
	return get_viewport().get_camera_3d().unproject_position(follow_target.global_position + follow_offset)


func _on_dead_zone_changed() -> void:
	global_position = _get_position_offset_distance()


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

func _set_layer(current_layers: int, layer_number: int, value: bool) -> int:
	var mask: int = current_layers

	# From https://github.com/godotengine/godot/blob/51991e20143a39e9ef0107163eaf283ca0a761ea/scene/3d/camera_3d.cpp#L638
	if layer_number < 1 or layer_number > 20:
		printerr("Render layer must be between 1 and 20.")
	else:
		if value:
			mask |= 1 << (layer_number - 1)
		else:
			mask &= ~(1 << (layer_number - 1))

	return mask

func _has_valid_pcam_owner() -> bool:
	if not is_instance_valid(get_pcam_host_owner()): return false
	if not is_instance_valid(get_pcam_host_owner().camera_3d): return false
	return true

#endregion

# TBD
#func get_unprojected_position() -> Vector2:
	#var unprojected_position: Vector2 = _get_raw_unprojected_position()
	#var viewport_width: float = get_viewport().size.x
	#var viewport_height: float = get_viewport().size.y
	#var camera_aspect: Camera3D.KeepAspect = get_viewport().get_camera_3d().keep_aspect
	#var visible_rect_size: Vector2 = get_viewport().size
#
	#unprojected_position = unprojected_position - visible_rect_size / 2
	#if camera_aspect == Camera3D.KeepAspect.KEEP_HEIGHT:
##	print("Landscape View")
		#var aspect_ratio_scale: float = viewport_width / viewport_height
		#unprojected_position.x = (unprojected_position.x / aspect_ratio_scale + 1) / 2
		#unprojected_position.y = (unprojected_position.y + 1) / 2
	#else:
##	print("Portrait View")
		#var aspect_ratio_scale: float = viewport_height / viewport_width
		#unprojected_position.x = (unprojected_position.x + 1) / 2
		#unprojected_position.y = (unprojected_position.y / aspect_ratio_scale + 1) / 2
#
	#return unprojected_position


#region Setter & Getter Functions

## Assigns the value of the [param has_tweened] property.[br]
## [b][color=yellow]Important:[/color][/b] This value can only be changed
## from the [PhantomCameraHost] script.
func set_has_tweened(caller: Node, value: bool) -> void:
	if is_instance_of(caller, PhantomCameraHost):
		_has_tweened = value
	else:
		printerr("Can only be called PhantomCameraHost class")
## Returns the current [param has_tweened] value.
func get_has_tweened() -> bool:
	return _has_tweened


## Assigns the [param PhantomCamera3D] to a new [PhantomCameraHost].[br]
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
#			return null
## Sets a PCamHost to
#func assign_pcam_host(value: PhantomCameraHost) -> void:
	#pcam_host_owner = value
## Gets the current [PhantomCameraHost] this [param PhantomCamera3D] is
## assigned to.
func get_pcam_host_owner() -> PhantomCameraHost:
	return pcam_host_owner


## Assigns new [member priority] value.
func set_priority(value: int) -> void:
	priority = abs(value) # TODO - Make any minus values be 0
	if _has_valid_pcam_owner():
		get_pcam_host_owner().pcam_priority_updated(self)
## Gets current [param Priority] value.
func get_priority() -> int:
	return priority


## Assigns a new [PhantomCameraTween] resource to the [param PhantomCamera3D].
func set_tween_resource(value: PhantomCameraTween) -> void:
	tween_resource = value
## Gets the [param PhantomCameraTween] resource assigned to the [param PhantomCamera3D].
## Returns null if there's nothing assigned to it.
func get_tween_resource() -> PhantomCameraTween:
	return tween_resource

## Assigns a new [param Tween Duration] to the [member tween_resource] value.[br]
## The duration value is in seconds.
func set_tween_duration(value: float) -> void:
	tween_resource.duration = value
## Gets the current [param Tween] Duration value. The duration value is in
## [param seconds].
func get_tween_duration() -> float:
	return tween_resource.duration

## Assigns a new [param Tween Transition] to the [member tween_resource] value.[br]
## The duration value is in seconds.
func set_tween_transition(value: int) -> void:
	tween_resource.transition = value
## Gets the current [param Tween Transition] value.
func get_tween_transition() -> int:
	return tween_resource.transition

## Assigns a new [param Tween Ease] to the [member tween_resource] value.[br]
## The duration value is in seconds.
func set_tween_ease(value: int) -> void:
	tween_resource.ease = value
## Gets the current [param Tween Ease] value.
func get_tween_ease() -> int:
	return tween_resource.ease

## Sets the [param PhantomCamera3D] active state[br]
## [b][color=yellow]Important:[/color][/b] This value can only be changed
## from the [PhantomCameraHost] script.
func set_is_active(node: Node, value: bool) -> void:
	if node is PhantomCameraHost:
		_is_active = value
	else:
		printerr("PCams can only be set from the PhantomCameraHost")
## Gets current active state of the [param PhantomCamera3D].
## If it returns true, it means the [param PhantomCamera3D] is what the
## [param Camera3D] is currently following.
func is_active() -> bool:
	return _is_active


## Enables or disables the [member tween_on_load].
func set_tween_on_load(value: bool) -> void:
	tween_on_load = value
## Gets the current [member tween_on_load] value.
func get_tween_on_load() -> bool:
	return tween_on_load


## Gets the current follow mode as an enum int based on [member FollowMode] enum.[br]
## [b]Note:[/b] Setting [member follow_mode] has purposely not been added.
## A separate [param PhantomCamera3D] instance should be used instead.
func get_follow_mode() -> int:
	return follow_mode


## Assigns a new [Node3D] as the [member follow_target].
func set_follow_target(value: Node3D) -> void:
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
## Removes the current [Node3D] [member follow_target].
func erase_follow_target() -> void:
	if follow_target == null: return
	_follow_target_physics_based = false
	_should_follow = false
	follow_target = null
	follow_target_changed.emit()
## Gets the current Node3D target.
func get_follow_target() -> Node3D:
	return follow_target


## Assigns a new [Path3D] to the [member follow_path] property.
func set_follow_path(value: Path3D) -> void:
	follow_path = value
## Erases the current [Path3D] from [member follow_path] property.
func erase_follow_path() -> void:
	follow_path = null
## Gets the current [Path3D] from the [member follow_path] property.
func get_follow_path() -> Path3D:
	return follow_path


## Assigns a new [param follow_targets] array value.
func set_follow_targets(value: Array[Node3D]) -> void:
	if follow_targets == value: return

	follow_targets = value

	if follow_targets.is_empty():
		_should_follow = false
		_has_multiple_follow_targets = false
		_follow_target_physics_based = false
		return

	var valid_instances: int
	_follow_target_physics_based = false
	for target in follow_targets:
		if is_instance_valid(target):
			_should_follow = true
			valid_instances += 1

			_check_physics_body(target)

			if valid_instances > 1:
				_has_multiple_follow_targets = true
## Adds a single [Node3D] to [member follow_targets] array.
func append_follow_targets(value: Node3D) -> void:
	if not is_instance_valid(value):
		printerr(value, " is not a valid instance")
		return

	if not follow_targets.has(value):
		follow_targets.append(value)
		_should_follow = true
		_has_multiple_follow_targets = true
		_check_physics_body(value)
	else:
		printerr(value, " is already part of Follow Group")
## Adds an Array of type [Node3D] to [member follow_targets] array.
func append_follow_targets_array(value: Array[Node3D]) -> void:
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
## Removes [Node3D] from [member follow_targets].
func erase_follow_targets(value: Node3D) -> void:
	follow_targets.erase(value)
	_follow_target_physics_based = false
	for target in follow_targets:
		_check_physics_body(target)

	if follow_targets.size() < 2:
		_has_multiple_follow_targets = false
	if follow_targets.size() < 1:
		_should_follow = false
## Gets all [Node3D] from [follow_targets].
func get_follow_targets() -> Array[Node3D]:
	return follow_targets

## Returns true if the [param PhantomCamera3D] has more than one member in the
## [member follow_targets] array.
func get_has_multiple_follow_targets() -> bool:
	return _has_multiple_follow_targets

func _check_physics_body(target: Node3D) -> void:
	if target is PhysicsBody3D:
		## NOTE - Feature Toggle
		#if Engine.get_version_info().major == 4 and \
		#Engine.get_version_info().minor < XX:
		if ProjectSettings.get_setting("phantom_camera/tips/show_jitter_tips"):
			print_rich("Following or Looking at a [b]PhysicsBody3D[/b] node will likely result in jitter - on lower physics ticks in particular.")
			print_rich("Will have proper support once 3D Physics Interpolation becomes part of the core Godot engine.")
			print_rich("Until then, try following the guide on the [url=https://phantom-camera.dev/support/faq#i-m-seeing-jitter-what-can-i-do]documentation site[/url] for better results.")
			print_rich("This tip can be disabled from within [code]Project Settings / Phantom Camera / Tips / Show Jitter Tips[/code]")
		return
		## TODO - Enable once Godot supports 3D Physics Interpolation
		#elif not ProjectSettings.get_setting("physics/common/physics_interpolation"):
				#printerr("Physics Interpolation is disabled in the Project Settings, recommend enabling it to smooth out physics-based camera movement")
		#_follow_target_physics_based = true


## Assigns a new [param Vector3] for the [param follow_offset] property.
func set_follow_offset(value: Vector3) -> void:
	follow_offset = value

## Gets the current [param Vector3] for the [param follow_offset] property.
func get_follow_offset() -> Vector3:
	return follow_offset


## Enables or disables [member follow_damping].
func set_follow_damping(value: bool) -> void:
	follow_damping = value
	notify_property_list_changed()

## Gets the currents [member follow_damping] property.
func get_follow_damping() -> bool:
	return follow_damping


## Assigns new [member follow_damping_value] value.
func set_follow_damping_value(value: Vector3) -> void:
	## TODO - Should be using @export_range once minimum version support is Godot 4.3
	if value.x < 0: value.x = 0
	elif value.y < 0: value.y = 0
	elif value.z < 0: value.z = 0
	follow_damping_value = value

## Gets the currents [member follow_damping_value] value.
func get_follow_damping_value() -> Vector3:
	return follow_damping_value


## Assigns a new [member follow_distance] value.
func set_follow_distance(value: float) -> void:
	follow_distance = value

## Gets [member follow_distance] value.
func get_follow_distance() -> float:
	return follow_distance


## Enables or disables [member auto_follow_distance] when using Group Follow.
func set_auto_follow_distance(value: bool) -> void:
	auto_follow_distance = value
	notify_property_list_changed()

## Gets [member auto_follow_distance] state.
func get_auto_follow_distance() -> bool:
	return auto_follow_distance


## Assigns new [member auto_follow_distance_min] value.
func set_auto_follow_distance_min(value: float) -> void:
	auto_follow_distance_min = value

## Gets [member auto_follow_distance_min] value.
func get_auto_follow_distance_min() -> float:
	return auto_follow_distance_min


## Assigns new [member auto_follow_distance_max] value.
func set_auto_follow_distance_max(value: float) -> void:
	auto_follow_distance_max = value
## Gets [member auto_follow_distance_max] value.
func get_auto_follow_distance_max() -> float:
	return auto_follow_distance_max


## Assigns new [member auto_follow_distance_divisor] value.
func set_auto_follow_distance_divisor(value: float) -> void:
	auto_follow_distance_divisor = value

## Gets [member auto_follow_distance_divisor] value.
func get_auto_follow_distance_divisor() -> float:
	return auto_follow_distance_divisor


## Assigns new rotation (in radians) value to [SpringArm3D] for
## [param ThirdPerson] [enum FollowMode].
func set_third_person_rotation(value: Vector3) -> void:
	_follow_spring_arm.rotation = value

## Gets the rotation value (in radians) from the [SpringArm3D] for
## [param ThirdPerson] [enum FollowMode].
func get_third_person_rotation() -> Vector3:
	return _follow_spring_arm.rotation


## Assigns new rotation (in degrees) value to [SpringArm3D] for
## [param ThirdPerson] [enum FollowMode].
func set_third_person_rotation_degrees(value: Vector3) -> void:
	_follow_spring_arm.rotation_degrees = value

## Gets the rotation value (in degrees) from the [SpringArm3D] for
## [param ThirdPerson] [enum FollowMode].
func get_third_person_rotation_degrees() -> Vector3:
	return _follow_spring_arm.rotation_degrees


## Assigns new [Quaternion] value to [SpringArm3D] for [param ThirdPerson]
## [enum FollowMode].
func set_third_person_quaternion(value: Quaternion) -> void:
	_follow_spring_arm.quaternion = value

## Gets the [Quaternion] value of the [SpringArm3D] for [param ThirdPerson]
## [enum Follow mode].
func get_third_person_quaternion() -> Quaternion:
	return _follow_spring_arm.quaternion


## Assigns a new ThirdPerson [member SpringArm3D.length] value.
func set_spring_length(value: float) -> void:
	follow_distance = value
	if is_instance_valid(_follow_spring_arm):
		_follow_spring_arm.spring_length = value

## Gets the [member SpringArm3D.length]
## from a [param ThirdPerson] [enum follow_mode] instance.
func get_spring_length() -> float:
	return follow_distance


## Assigns a new [member collision_mask] to the [SpringArm3D] when [enum FollowMode]
## is set to [param ThirdPerson].
func set_collision_mask(value: int) -> void:
	collision_mask = value
	if is_instance_valid(_follow_spring_arm):
		_follow_spring_arm.collision_mask = collision_mask

## Enables or disables a specific [member collision_mask] layer for the
## [SpringArm3D] when [enum FollowMode] is set to [param ThirdPerson].
func set_collision_mask_value(value: int, enabled: bool) -> void:
	collision_mask = _set_layer(collision_mask, value, enabled)
	if is_instance_valid(_follow_spring_arm):
		_follow_spring_arm.collision_mask = collision_mask

## Gets [member collision_mask] from the [SpringArm3D] when [enum FollowMode]
## is set to [param ThirdPerson].
func get_collision_mask() -> int:
	return collision_mask


## Assigns a new [SpringArm3D.shape] when [enum FollowMode]
## is set to [param ThirdPerson].
func set_shape(value: Shape3D) -> void:
	shape = value
	if is_instance_valid(_follow_spring_arm):
		_follow_spring_arm.shape = shape

## Gets [param ThirdPerson] [member SpringArm3D.shape] value.
func get_shape() -> Shape3D:
	return shape


## Assigns a new [member SpringArm3D.margin] value when [enum FollowMode]
## is set to [param ThirdPerson].
func set_margin(value: float) -> void:
	margin = value
	if is_instance_valid(_follow_spring_arm):
		_follow_spring_arm.margin = margin

## Gets the [SpringArm3D.margin] when [enum FollowMode] is set to
## [param ThirdPerson].
func get_margin() -> float:
	return margin


## Gets the current [member look_at_mode]. Value is based on [enum LookAtMode]
## enum.[br]
## Note: To set a new [member look_at_mode], a separate [param PhantomCamera3D] should
## be used.
func get_look_at_mode() -> int:
	return look_at_mode


## Assigns new [Node3D] as [member look_at_target].
func set_look_at_target(value: Node3D) -> void:
	look_at_target = value
	_check_physics_body(value)
	#_look_at_target_node = get_node_or_null(value)
	look_at_target_changed
	if is_instance_valid(look_at_target):
		_should_look_at = true
	else:
		_should_look_at = false
	notify_property_list_changed()

## Gets current [Node3D] from [member look_at_target] property.
func get_look_at_target():
	return look_at_target


## Sets an array of type [Node3D] to [member set_look_at_targets].
func set_look_at_targets(value: Array[Node3D]) -> void:
	if look_at_targets == value: return
	look_at_targets = value

	if look_at_mode != LookAtMode.GROUP: return

	if look_at_targets.is_empty():
		_should_look_at = false
		_multiple_look_at_targets = false
	else:
		var valid_instances: int = 0
		for target in look_at_targets:
			if is_instance_valid(target):
				valid_instances += 1
				_should_look_at = true
				_valid_look_at_targets.append(target)
				_check_physics_body(target)

			if valid_instances > 1:
				_multiple_look_at_targets = true
			elif valid_instances == 0:
				_should_look_at = false
				_multiple_look_at_targets = false
	notify_property_list_changed()

## Appends a [Node3D] to [member look_at_targets] array.
func append_look_at_target(value: Node3D) -> void:
	if not look_at_targets.has(value):
		look_at_targets.append(value)
		_valid_look_at_targets.append(value)
		_check_physics_body(value)
		if look_at_targets.size() > 1:
			_multiple_look_at_targets = true
	else:
		printerr(value, " is already part of Look At Group")

## Appends an array of type [Node3D] to [member look_at_targets] array.
func append_look_at_targets_array(value: Array[NodePath]) -> void:
	for val in value:
		if not look_at_targets.has(get_node(val)):
			var node: Node3D = get_node(val)
			look_at_targets.append(node)
			_valid_look_at_targets.append(node)
			_check_physics_body(node)
			if look_at_targets.size() > 1:
				_multiple_look_at_targets = true
		else:
			printerr(val, " is already part of Look At Group")

## Removes [Node3D] from [member look_at_targets] array.
func erase_look_at_targets_member(value: Node3D) -> void:
	look_at_targets.erase(value)
	_valid_look_at_targets.erase(value)
	_check_physics_body(value)
	if look_at_targets.size() < 1:
		_multiple_look_at_targets = false

## Gets all the [Node3D] instances in [member look_at_targets].
func get_look_at_targets() -> Array[Node3D]:
	return look_at_targets


## Assigns a new [Vector3] to the [member look_at_offset] value.
func set_look_at_offset(value: Vector3) -> void:
	look_at_offset = value

## Gets the current [member look_at_offset] value.
func get_look_at_offset() -> Vector3:
	return look_at_offset


## Enables or disables [member look_at_damping].
func set_look_at_damping(value: bool) -> void:
	look_at_damping = value
	notify_property_list_changed()

## Gets the currents [member look_at_damping] property.
func get_look_at_damping() -> bool:
	return look_at_damping


## Assigns new [member look_at_damping_value] value.
func set_look_at_damping_value(value: float) -> void:
	look_at_damping_value = value

## Gets the currents [member look_at_damping_value] value.
func get_look_at_damping_value() -> float:
	return look_at_damping_value


## Sets [member inactive_update_mode] property.
func set_inactive_update_mode(value: int) -> void:
	inactive_update_mode = value

## Gets [member inactive_update_mode] property.
func get_inactive_update_mode() -> int:
	return inactive_update_mode


## Assigns a [Camera3DResource].
func set_camera_3d_resource(value: Camera3DResource) -> void:
	camera_3d_resource = value

## Gets the [Camera3DResource]
func get_camera_3d_resource() -> Camera3DResource:
	return camera_3d_resource


## Assigns a new [member Camera3D.cull_mask] value.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_cull_mask(value: int) -> void:
	camera_3d_resource.cull_mask = value
	if _is_active: get_pcam_host_owner().camera_3d.cull_mask = value

## Enables or disables a specific [member Camera3D.cull_mask] layer.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_cull_mask_value(layer_number: int, value: bool) -> void:
	var mask: int = _set_layer(get_cull_mask(), layer_number, value)
	camera_3d_resource.cull_mask = mask
	if _is_active: get_pcam_host_owner().camera_3d.cull_mask = mask

## Gets the [member Camera3D.cull_mask] value assigned to the [Camera3DResource].
func get_cull_mask() -> int:
	return camera_3d_resource.cull_mask


## Assigns a new [member Camera3D.h_offset] value.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_h_offset(value: float) -> void:
	camera_3d_resource.h_offset = value
	if _is_active: get_pcam_host_owner().camera_3d.h_offset = value

## Gets the [member Camera3D.h_offset] value assigned to the [param Camera3DResource].
func get_h_offset() -> float:
	return camera_3d_resource.h_offset


## Assigns a new [Camera3D.v_offset] value.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_v_offset(value: float) -> void:
	camera_3d_resource.v_offset = value
	if _is_active: get_pcam_host_owner().camera_3d.v_offset = value

## Gets the [member Camera3D.v_offset] value assigned to the [param Camera3DResource].
func get_v_offset() -> float:
	return camera_3d_resource.v_offset


## Assigns a new [Camera3D.projection] value.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_projection(value: int) -> void:
	camera_3d_resource.projection = value
	if _is_active: get_pcam_host_owner().camera_3d.projection = value

## Gets the [member Camera3D.projection] value assigned to the [param Camera3DResource].
func get_projection() -> int:
	return camera_3d_resource.projection


## Assigns a new [member Camera3D.fov] value.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_fov(value: float) -> void:
	camera_3d_resource.fov = value
	if _is_active: get_pcam_host_owner().camera_3d.fov = value

## Gets the [member Camera3D.fov] value assigned to the [param Camera3DResource].
func get_fov() -> float:
	return camera_3d_resource.fov


## Assigns a new [member Camera3D.size] value.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_size(value: float) -> void:
	camera_3d_resource.size = value
	if _is_active: get_pcam_host_owner().camera_3d.size = value

## Gets the [member Camera3D.size] value assigned to the [param Camera3DResource].
func get_size() -> float:
	return camera_3d_resource.size


## Assigns a new [member Camera3D.frustum_offset] value.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_frustum_offset(value: Vector2) -> void:
	camera_3d_resource.frustum_offset = value
	if _is_active: get_pcam_host_owner().camera_3d.frustum_offset = value

## Gets the [member Camera3D.frustum_offset] value assigned to the [param Camera3DResource].
func get_frustum_offset() -> Vector2:
	return camera_3d_resource.frustum_offset


## Assigns a new [member Camera3D.near] value.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_near(value: float) -> void:
	camera_3d_resource.near = value
	if _is_active: get_pcam_host_owner().camera_3d.near = value

## Gets the [member Camera3D.near] value assigned to the [param Camera3DResource].
func get_near() -> float:
	return camera_3d_resource.near


## Assigns a new [member Camera3D.far] value.[br]
## [b]Note:[/b] This will override and make the [param Camera3DResource] unique to
## this [param PhantomCamera3D].
func set_far(value: float) -> void:
	camera_3d_resource.far = value
	if _is_active: get_pcam_host_owner().camera_3d.far = value

## Gets the [member Camera3D.far] value assigned to the [param Camera3DResource].
func get_far() -> float:
	return camera_3d_resource.far


func set_follow_target_physics_based(value: bool, caller: Node) -> void:
	if is_instance_of(caller, PhantomCameraHost):
		_follow_target_physics_based = value
	else:
		printerr("set_follow_target_physics_based is for internal use only.")

func get_follow_target_physics_based() -> bool:
	return _follow_target_physics_based


func get_class() -> String:
	return "PhantomCamera3D"


func is_class(value) -> bool:
	return value == "PhantomCamera3D"

#endregion
