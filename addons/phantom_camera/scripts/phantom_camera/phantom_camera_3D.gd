@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg")
class_name PhantomCamera3D
extends Node3D
## Enables a 3D scene's [param Camera3D] to follow the behavior defined here.
##
## The scene's [param Camera3D] will follow the position of the
## [param PhantomCamera3D] with the highest priority.
## Each instance can have different positional and rotational logic applied
## to them.

#region Constants

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#endregion


#region Signals

## Emitted when the [param PhantomCamera3D] becomes active.
signal became_active
## Emitted when the [param PhantomCamera3D] becomes inactive.
signal became_inactive

## Emitted when follow_target changes
signal follow_target_changed

## Emitted when dead zones changes. [br]
## [b]Note:[/b] Only applicable in Framed Follow mode.
signal dead_zone_changed

## Emitted when the [param Camera3D] starts to tween to the
## [param PhantomCamera3D].
signal tween_started
## Emitted when the [param Camera3D] is to tweening to the
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
	NONE 			= 0, ## Default.
	GLUED 			= 1, ## Sticks to its target.
	SIMPLE 			= 2, ## Follows its target with an optional offset.
	GROUP 			= 3, ## Follows multiple targets with option to dynamically reframe itself.
	PATH 			= 4, ## Follows a target while being positionally confined to a [Path3D] node.
	FRAMED 			= 5, ## Applies a dead zone on the frame and only follows its target when it tries to leave it.
	THIRD_PERSON 	= 6, ## Applies a [param SpringArm3D] node to the target's position and allows for rotating around it.
}

## Determines the rotational logic for a given [param PhantomCamera3D].[br][br]
## The different modes has different functionalities and purposes, so
## choosing the correct mode depends on what each [param PhantomCamera3D]
## is meant to do.
enum LookAtMode {
	NONE 	= 0, ## Default.
	MIMIC 	= 1, ## Copies its target's rotational value.
	SIMPLE 	= 2, ## Looks at its target in a straight line.
	GROUP	= 3, ## Looks at the centre of its targets.
}

## Determines how often an inactive [param PhantomCamera3D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive [param PhantomCamera3D] are doing when idling
## to improve performance. The value is based on the enum type
## [enum InactiveUpdateMode].
enum InactiveUpdateMode {
	ALWAYS, ## Always updates the [param PhantomCamera3D], even when it's inactive.
	NEVER, 	## Never updates the [param PhantomCamera3D] when it's inactive. Reduces the amount of computational resources when inactive.
#	EXPONENTIALLY,
}

#endregion


#region Variables

var Properties: Object = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

var _pcam_host_owner: PhantomCameraHost

var _is_active: bool = false

## To quickly preview a [param PhantomCamera3D] without adjusting its
## [param Priority], this property allows the selected [param PhantomCamera3D]
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
## [param PhantomCameraHost], which will then determine whether if the
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
		notify_property_list_changed()
	get:
		return follow_mode

var _should_follow: bool = false

## Determines which target should be followed.
## The [param Camera3D] will follow the position of the Follow Target based on
## the [member follow_mode] type and its parameters.
@export var follow_target: Node3D = null:
	set = set_follow_target,
	get = get_follow_target

## Defines the targets that the [param PhantomCamera3D] should be following.
@export var follow_targets: Array[Node3D] = [null]:
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

var _should_look_at: bool = false
var _has_look_at_target: bool = false
var _has_look_at_targets: bool = false

## Determines the rotational logic for a given [param PhantomCamera3D].
## The different modes has different functionalities and purposes,
## so choosing the correct mode depends on what each
## [param PhantomCamera3D] is meant to do.
@export var look_at_mode: LookAtMode = LookAtMode.NONE:
	set(value):
		look_at_mode = value
		notify_property_list_changed()
	get:
		return look_at_mode

## Determines which target should be looked at.
## The [param PhantomCamera3D] will update its rotational value as the
## target changes its position.
@export var look_at_target: Node3D = null:
	set = set_look_at_target,
	get = get_look_at_target

## Defines the targets that the camera should looking at.
## It will be looking at the centre of all the assigned targets.
@export var look_at_targets: Array[Node3D] = [null]:
	set = set_look_at_targets,
	get = get_look_at_targets
var _valid_look_at_targets: Array[Node3D] = [null]

## Defines how [param ]PhantomCamera3Ds] transition between one another.
## Changing the tween values for a given [param PhantomCamera3D]
## determines how transitioning to that instance will look like.
## This is a resource type that can be either used for one
## [param PhantomCamera] or reused across multiple - both 2D and 3D.
## By default, all [param PhantomCameras] will use a [param linear]
## transition, [param easeInOut] ease with a [param 1s] duration.
@export var tween_resource: PhantomCameraTween = PhantomCameraTween.new()
var tween_resource_default: PhantomCameraTween = PhantomCameraTween.new()

## By default, the moment a [param PhantomCamera3D] is instantiated into
## a scene, and has the highest priority, it will perform its tween transition.
## This is most obvious if a [param PhantomCamera3D] has a long duration and
## is attached to a playable character that can be moved the moment a scene
## is loaded. Disabling the [param Tween on Load] property will
## disable this behaviour and skip the tweening entirely when instantiated.
@export var tween_onload: bool = true

## Determines how often an inactive [param PhantomCamera3D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive [param PhantomCamera3Ds] are doing when idling
## to improve performance.
@export var inactive_update_mode: InactiveUpdateMode = InactiveUpdateMode.ALWAYS

var has_tweened: bool

## A resource type that allows for overriding the [param Camera3D] node's
## properties.
@export var camera_3d_resource: Camera3DResource
var _camera_3D_resouce_default: Camera3DResource = Camera3DResource.new()

@export_group("Follow Parameters")

## Applies a damping effect on the Camera's movement.
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
@export var follow_offset: Vector3 = Vector3.ZERO:
	set = set_follow_target_offset,
	get = get_follow_target_offset

## Sets a distance offset from the centre of the target's position.
## The distance is applied to the [param PhantomCamera3D]'s local z axis.
@export var follow_distance: float = 1:
	set = set_follow_distance,
	get = get_follow_distance

## Enables the [param PhantomCamera3D] to automatically distance
## itself as the [param follow targets] move further apart.[br]
## It looks at the longest axis between the different targets and interpolates
## the distance length between the [member auto_distance_min] and
## [member follow_group_distance Distance] properties below.[br][br]
## Note: Enabling this property hides and disables the [member distance]
## property as this effectively overrides that value.
@export var auto_distance: bool = false:
	set = set_auto_distance,
	get = get_auto_distance

## Sets the minimum distance between the Camera and centre of [AABB].
## [br][br]
## Note: This distance will only ever be reached when all the targets are in
## the exact same [param Vector3] coordinate, which will very unlikely
## happen, so adjust the value here accordingly.
@export var auto_distance_min: float = 1:
	set = set_auto_distance_min,
	get = get_auto_distance_min

## Sets the maximum distance between the Camera and centre of [AABB].
@export var auto_distance_max: float = 5:
	set = set_auto_distance_max,
	get = get_auto_distance_max

## Determines how fast the [param auto_distance] moves between the
## maximum and minimum distance. The higher the value, the sooner the
## maximum distance is reached.[br][br]
## This value should be based on the sizes of the [param auto_distance_min]
## and [member auto_distance_max].[br]
## E.g. if the value between the [member auto_distance_min] and
## [member auto_distance_max] is small, consider keeping the number low
## and vice versa.
@export var auto_distance_divisor: float = 10:
	set = set_auto_distance_divisor,
	get = get_auto_distance_divisor

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

var _follow_framed_initial_set: bool = false

@export_subgroup("Spring Arm")
var _follow_spring_arm: SpringArm3D

## Defines the [member SpringArm3D.spring_length].
@export var spring_length: float = 1:
	set = set_follow_distance,
	get = get_follow_distance

## Defines the [member SpringArm3D.collision_mask] node's Collision Mask.
@export_flags_3d_physics var collision_mask: int = 1

## Defines the [member SpringArm3D.shape] node's Shape3D.
@export var shape: Shape3D = null

## Defines the [member SpringArm3D.margin] node's Margin.
@export var margin: float = 0.01

@export_group("Look At Parameters")

## Offsets the target's [param Vector3] position that the
## [param PhantomCamera3D] is looking at.
@export var look_at_target_offset: Vector3 = Vector3.ZERO:
	set = set_look_at_target_offset,
	get = get_look_at_target_offset

var _follow_framed_offset: Vector3
var _current_rotation: Vector3

#endregion


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
	if property.name == "follow_offset":
		if follow_mode == FollowMode.GLUED or \
		follow_mode == FollowMode.PATH or \
		follow_mode == FollowMode.NONE:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_damping" and \
	follow_mode == FollowMode.NONE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_damping_value" and not follow_damping:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_distance":
		if not follow_mode == FollowMode.FRAMED:
			if not follow_mode == FollowMode.GROUP or \
			auto_distance: \
				property.usage = PROPERTY_USAGE_NO_EDITOR

	###############
	## Group Follow
	###############
	if property.name == "follow_targets" and \
	not follow_mode == FollowMode.GROUP:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "auto_distance" and \
	not follow_mode == FollowMode.GROUP:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if not auto_distance:
		match property.name:
			"auto_distance_min", \
			"auto_distance_max", \
			"auto_distance_divisor":
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
	if property.name == "look_at_target":
		if look_at_mode == LookAtMode.NONE or \
		look_at_mode == LookAtMode.GROUP:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "look_at_targets" and \
	not look_at_mode == LookAtMode.GROUP:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "look_at_target_offset" and \
	look_at_mode == LookAtMode.NONE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	notify_property_list_changed()
#endregion

#region Private Functions

func _enter_tree() -> void:
	Properties.is_2D = false;
	Properties.camera_enter_tree(self)
	set_pcam_host()

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
	if _has_valid_pcam_owner():
		get_pcam_host_owner().pcam_removed_from_scene(self)

	Properties.pcam_exit_tree(self)


func _ready():
	if follow_mode == FollowMode.THIRD_PERSON:
		if not Engine.is_editor_hint():
			if not is_instance_valid(_follow_spring_arm):
				_follow_spring_arm = SpringArm3D.new()
				get_parent().add_child.call_deferred(_follow_spring_arm)
	if follow_mode == FollowMode.FRAMED:
		if not Engine.is_editor_hint():
			_follow_framed_offset = global_position - _get_target_position_offset()
			_current_rotation = global_rotation


func _process(delta: float) -> void:
	if not _is_active:
		match inactive_update_mode:
			InactiveUpdateMode.NEVER:
				return
#			InactiveUpdateMode.EXPONENTIALLY:
#				TODO

	if not _should_follow: return
	
	match follow_mode:
		FollowMode.GLUED:
			if follow_target:
				_interpolate_position(
					follow_target.global_position,
					delta
				)
		FollowMode.SIMPLE:
			if follow_target:
				_interpolate_position(
					_get_target_position_offset(),
					delta
				)
		FollowMode.GROUP:
			if follow_targets:
				if follow_targets.size() == 1:
					_interpolate_position(
						follow_targets[0].global_position +
						follow_offset +
						get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance),
						delta
					)
				elif follow_targets.size() > 1:
					var bounds: AABB = AABB(follow_targets[0].global_position, Vector3.ZERO)
					for node in follow_targets:
						if is_instance_valid(node):
							bounds = bounds.expand(node.global_position)

					var distance: float
					if auto_distance:
						distance = lerp(auto_distance_min, auto_distance_max, bounds.get_longest_axis_size() / auto_distance_divisor)
						distance = clamp(distance, auto_distance_min, auto_distance_max)
					else:
						distance = follow_distance

					_interpolate_position(
						bounds.get_center() +
						follow_offset +
						get_transform().basis.z * Vector3(distance, distance, distance),
						delta
					)
		FollowMode.PATH:
			if follow_target and follow_path:
				var path_position: Vector3 = follow_path.global_position
				_interpolate_position(
					follow_path.curve.get_closest_point(follow_target.global_position - path_position) + path_position,
					delta
				)
		FollowMode.FRAMED:
			if follow_target:
				if not Engine.is_editor_hint():
					if not _is_active || get_pcam_host_owner().trigger_pcam_tween:
						_interpolate_position(
							_get_position_offset_distance(),
							delta
						)
						return

					Properties.viewport_position = get_viewport().get_camera_3d().unproject_position(_get_target_position_offset())
					var visible_rect_size: Vector2 = get_viewport().get_viewport().size
					Properties.viewport_position = Properties.viewport_position / visible_rect_size
					_current_rotation = global_rotation

					if _current_rotation != global_rotation:
						_interpolate_position(
							_get_position_offset_distance(),
							delta
						)

					if Properties.get_framed_side_offset(dead_zone_width, dead_zone_height) != Vector2.ZERO:
						var target_position: Vector3 = _get_target_position_offset() + _follow_framed_offset
						#var dead_zone_width: float = dead_zone_width
						#var dead_zone_height: float = dead_zone_height
						var glo_pos: Vector3

						if dead_zone_width == 0 || dead_zone_height == 0:
							if dead_zone_width == 0 && dead_zone_height != 0:
								glo_pos = _get_position_offset_distance()
								glo_pos.z = target_position.z
								_interpolate_position(
									glo_pos,
									delta
								)
							elif dead_zone_width != 0 && dead_zone_height == 0:
								glo_pos = _get_position_offset_distance()
								glo_pos.x = target_position.x
								_interpolate_position(
									glo_pos,
									delta
								)
							else:
								_interpolate_position(
									_get_position_offset_distance(),
									delta
								)
						else:
							if _current_rotation != global_rotation:
								var opposite: float = sin(-global_rotation.x) * follow_distance + _get_target_position_offset().y
								glo_pos.y = _get_target_position_offset().y + opposite
								glo_pos.z = sqrt(pow(follow_distance, 2) - pow(opposite, 2)) + _get_target_position_offset().z
								glo_pos.x = global_position.x

								_interpolate_position(
									glo_pos,
									delta
								)
								_current_rotation = global_rotation
							else:
								_interpolate_position(
									target_position,
									delta
								)
					else:
						_follow_framed_offset = global_position - _get_target_position_offset()
						_current_rotation = global_rotation
				else:
					global_position = _get_position_offset_distance()
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

					Properties.viewport_position = unprojected_position
		FollowMode.THIRD_PERSON:
			if follow_target:
				if not Engine.is_editor_hint():
					if is_instance_valid(follow_target):
						if is_instance_valid(_follow_spring_arm):
							if not get_parent() == _follow_spring_arm:
								var follow_target: Node3D = follow_target
								_follow_spring_arm.rotation = rotation
								_follow_spring_arm.global_position = _get_target_position_offset() # Ensure the PCam3D starts at the right position at runtime
								_follow_spring_arm.spring_length = spring_length
								_follow_spring_arm.collision_mask = collision_mask
								_follow_spring_arm.shape = shape
								_follow_spring_arm.margin = margin

								if not is_tween_on_load():
									has_tweened = true

								reparent(_follow_spring_arm)

							_interpolate_position(
								_get_target_position_offset(),
								delta,
								_follow_spring_arm
							)
				else:
					global_position = _get_position_offset_distance()

	if _should_look_at:
		if not _has_look_at_target: return
		match look_at_mode:
			LookAtMode.MIMIC:
				global_rotation = look_at_target.global_rotation
			LookAtMode.SIMPLE:
				look_at(look_at_target.global_position + look_at_target_offset)
			LookAtMode.GROUP:
				if not _has_look_at_targets:
					#print("Single target")
					look_at(look_at_targets[0].global_position)
				else:
					var bounds: AABB = AABB(look_at_targets[0].global_position, Vector3.ZERO)
					for node in look_at_targets:
						bounds = bounds.expand(node.global_position)
					look_at(bounds.get_center())


func _get_target_position_offset() -> Vector3:
	return follow_target.global_position + follow_offset


func _get_position_offset_distance() -> Vector3:
	return _get_target_position_offset() + \
	get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance)


func _interpolate_position(_global_position: Vector3, delta: float, target: Node3D = self) -> void:
	if follow_damping:
		target.global_position = \
			target.global_position.lerp(
				_global_position,
				delta * follow_damping_value
			)
	else:
		target.global_position = _global_position


func _get_raw_unprojected_position() -> Vector2:
	return get_viewport().get_camera_3d().unproject_position(follow_target.global_position + follow_offset)


func _on_dead_zone_changed() -> void:
	global_position = _get_position_offset_distance()


func _has_valid_pcam_owner() -> bool:
	if not is_instance_valid(get_pcam_host_owner()): return false
	if not is_instance_valid(get_pcam_host_owner().camera_3D): return false
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

## Assigns the [param PhantomCamera3D] to a new [param PhantomCameraHost].
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
#			return null
## Gets the current [param PhantomCameraHost] this [param PhantomCamera3D] is
## assigned to.
func get_pcam_host_owner() -> PhantomCameraHost:
	return _pcam_host_owner


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

## Assigns a new [param Tween] Duration value. The duration value is in
## [param seconds]. [br]
## Note: This will override and make the Tween Resource unique
## to this [param PhantomCamera3D].
func set_tween_duration(value: float) -> void:
	if get_tween_resource():
		tween_resource_default.duration = value
		tween_resource_default.transition = tween_resource.transition
		tween_resource_default.ease = tween_resource.ease
		set_tween_resource(null) # Clears resource from PCam instance
	else:
		tween_resource_default.duration = value
## Gets the current [param Tween] Duration value. The duration value is in
## [param seconds].
func get_tween_duration() -> float:
	if tween_resource:
		return tween_resource.duration
	else:
		return tween_resource_default.duration

## Assigns a new Tween Transition value.
## Note: This will override and make the Tween Resource unique to this
## [param PhantomCamera3D].
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
		return tween_resource.transition
	else:
		return tween_resource_default.transition

## Assigns a new Tween Ease value.
## Note: This will override and make the Tween Resource unique to this
## [param PhantomCamera3D].
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
		return tween_resource.ease
	else:
		return tween_resource_default.ease

## Sets the [param PhantomCamera3D] active state[br][br]
## [b][color=yellow]Important:[/color][/b] This value can only be changed
## from the [PhantomCameraHost] script.
func set_is_active(node: Node, value: bool) -> void:
	if is_instance_of(node, PhantomCameraHost):
		_is_active = value
	else:
		printerr("PCam can only be set from the PhantomCameraHost")
## Gets current active state of the [param PhantomCamera3D].
## If it returns true, it means the [param PhantomCamera3D] is what the
## [param Camera3D] is currently following.
func is_active() -> bool:
	return _is_active


## Enables or disables the Tween on Load.
func set_tween_on_load(value: bool) -> void:
	tween_onload = value
## Gets the current Tween On Load value.
func is_tween_on_load() -> bool:
	return tween_onload


## Gets the current follow mode as an enum int based on FOLLOW_MODE enum.
## Note: Setting Follow Mode purposely not added. A separate
## [param PhantomCamera] should be used instead.
func get_follow_mode() -> int:
	return follow_mode


## Assigns a new [Node3D] as the [member follow_target].
func set_follow_target(value: Node3D) -> void:
	if follow_target == value: return
	follow_target = value
	if is_instance_valid(value):
		_should_follow = true
	else:
		_should_follow = false
	follow_target_changed.emit()
## Removes the current [Node3D] [member follow_target].
func erase_follow_target() -> void:
	if follow_target == null: return
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


## Assigns a new [param Vector3] for the [param follow_target_offset] property.
func set_follow_target_offset(value: Vector3) -> void:
	follow_offset = value
## Gets the current [param Vector3] for the [param follow_target_offset] property.
func get_follow_target_offset() -> Vector3:
	return follow_offset


## Enables or disables [member follow_damping].
func set_follow_has_damping(value: bool) -> void:
	follow_damping = value
	notify_property_list_changed()
## Gets the currents [member follow_damping] property.
func get_follow_has_damping() -> bool:
	return follow_damping


## Assigns new [member follow_damping_value] value.
func set_follow_damping_value(value: float) -> void:
	follow_damping_value = value
## Gets the currents [member follow_damping_value] value.
func get_follow_damping_value() -> float:
	return follow_damping_value


## Assigns a new [member follow_distance] value.
func set_follow_distance(value: float) -> void:
	follow_distance = value
## Gets [member follow_distance] value.
func get_follow_distance() -> float:
	return follow_distance

## Assigns a new [param follow_targets] array value.
func set_follow_targets(value: Array[Node3D]) -> void:
	# TODO - This shouldn't be needed.
	# Needs a fix to avoid triggering this setter when not in Group Follow
	if not follow_mode == FollowMode.GROUP: return

	follow_targets = value

	if follow_targets.is_empty():
		_should_follow = false
		_has_multiple_follow_targets = false
		return
	
	var valid_instances: int
	for target in follow_targets:
		if is_instance_valid(target):
			_should_follow = true
			_has_multiple_follow_targets = true
			return
		else:
			_should_follow = false
			_has_multiple_follow_targets = false

## Adds a single [Node3D] to [member follow_targets] array.
func append_follow_group_node(value: Node3D) -> void:
	if not is_instance_valid(value):
		printerr(value, " is not a valid instance")
		return
	
	if not follow_targets.has(value):
		follow_targets.append(value)
		_should_follow = true
		_has_multiple_follow_targets = true
	else:
		printerr(value, " is already part of Follow Group")
## Adds an Array of type [Node3D] to [member follow_targets] array.
func append_follow_group_node_array(value: Array[Node3D]) -> void:
	for val in value:
		if not is_instance_valid(val): continue
		if not follow_targets.has(val):
			follow_targets.append(val)
			_should_follow = true
			if follow_targets.size() > 1:
				_has_multiple_follow_targets = true
		else:
			printerr(value, " is already part of Follow Group")
## Removes [Node3D] from [member follow_targets].
func erase_follow_group_node(value: Node3D) -> void:
	follow_targets.erase(value)
	if follow_targets.size() < 2:
		_has_multiple_follow_targets = false
	if follow_targets.size() < 1:
		_should_follow = false
## Gets all [Node3D] from [follow_targets].
func get_follow_targets() -> Array[Node3D]:
	return follow_targets

## Enables or disables [member auto_distnace] when using Group Follow.
func set_auto_distance(value: bool) -> void:
	auto_distance = value
	notify_property_list_changed()
## Gets [member auto_distance] state.
func get_auto_distance() -> bool:
	return auto_distance

## Assigns new [member auto_distance_min] value.
func set_auto_distance_min(value: float) -> void:
	auto_distance_min = value
## Gets [member auto_distance_min] value.
func get_auto_distance_min() -> float:
	return auto_distance_min

## Assigns new [member auto_distance_max] value.
func set_auto_distance_max(value: float) -> void:
	auto_distance_max = value
## Gets [member auto_distance_max] value.
func get_auto_distance_max() -> float:
	return auto_distance_max

## Assigns new [member auto_distance_divisor] value.
func set_auto_distance_divisor(value: float) -> void:
	auto_distance_divisor = value
## Gets [member auto_distance_divisor] value.
func get_auto_distance_divisor() -> float:
	return auto_distance_divisor

## Assigns new rotation (in radians) value to [SpringArm3D] for Third Person Follow mode.
func set_third_person_rotation(value: Vector3) -> void:
	_follow_spring_arm.rotation = value
## Gets the rotation value (in radians) from the SpringArm for Third Person Follow mode.
func get_third_person_rotation() -> Vector3:
	return _follow_spring_arm.rotation
## Assigns new rotation (in degrees) value to SpringArm for Third Person Follow mode.
func set_third_person_rotation_degrees(value: Vector3) -> void:
	_follow_spring_arm.rotation_degrees = value
## Gets the rotation value (in degrees) from the SpringArm for Third Person Follow mode.
func get_third_person_rotation_degrees() -> Vector3:
	return _follow_spring_arm.rotation_degrees
## Assigns new quaternion value to SpringArm for Third Person Follow mode.
func set_third_person_quaternion(value: Quaternion) -> void:
	_follow_spring_arm.quaternion = value
## Gets the quaternion value of the SpringArm for Third Person Follow mode.
func get_third_person_quaternion() -> Quaternion:
	return _follow_spring_arm.quaternion

## Assigns a new Third Person [member SpringArm3D.length] value.
func set_spring_arm_spring_length(value: float) -> void:
	follow_distance = value
	_follow_spring_arm.spring_length = value
## Gets Third Person [SpringArm3D] Length value.
func get_spring_arm_spring_length() -> float:
	return follow_distance

## Assigns a new Third Person [member SpringArm3D.collision_mask]
## value.
func set_spring_arm_collision_mask(value: int) -> void:
	collision_mask = value
## Gets Third Person SpringArm3D Collision Mask value.
func get_spring_arm_collision_mask() -> int:
	return collision_mask

## Assigns a new Third Person [member SpringArm3D.shape] value.
func set_spring_arm_shape(value: Shape3D) -> void:
	shape = value
## Gets Third Person SpringArm3D Shape value.
func get_spring_arm_shape() -> Shape3D:
	return shape

## Assigns a new Third Person [member SpringArm3D.margin] value.
func set_spring_arm_margin(value: float) -> void:
	margin = value
## Gets Third Person SpringArm3D Margin value.
func get_spring_arm_margin() -> float:
	return margin


## Gets Look At Mode. Value is based on [enum LookAtMode] enum.
## Note: To set a new Look At Mode, a separate PhantomCamera3D should be used.
func get_look_at_mode() -> int:
	return look_at_mode

## Assigns new Node3D as Look At Target.
func set_look_at_target(value: Node3D) -> void:
	look_at_target = value
	#_look_at_target_node = get_node_or_null(value)
	if is_instance_valid(look_at_target):
		_should_look_at = true
		_has_look_at_target = true
	notify_property_list_changed()
## Gets current Node3D from Look At Target property.
func get_look_at_target():
	return look_at_target


## Assigns a new Vector3 to the Look At Target Offset value.
func set_look_at_target_offset(value: Vector3) -> void:
	look_at_target_offset = value
## Gets the current Look At Target Offset value.
func get_look_at_target_offset() -> Vector3:
	return look_at_target_offset

func set_look_at_targets(value: Array[Node3D]) -> void:
	look_at_targets = value
	
	if look_at_targets.is_empty():
		_should_look_at = false
		_has_look_at_targets = false

	var valid_instances: int = 0
	for target in look_at_targets:
		if is_instance_valid(target):
			valid_instances += 1
			_should_look_at = true
			_valid_look_at_targets.append(target)
		
		if valid_instances > 1:
			print("Larger than 1")
			_has_look_at_targets = true
			break
		elif valid_instances == 0:
			print("Invalid instances")
			_should_look_at = false
			_has_look_at_targets = false
	
	notify_property_list_changed()

## Appends Node3D to Look At Group array.
func append_look_at_group_node(value: Node3D) -> void:
	if not look_at_targets.has(value):
		look_at_targets.append(value)
		_valid_look_at_targets.append(value)
		_has_look_at_targets = true
	else:
		printerr(value, " is already part of Look At Group")
## Appends array of type Node3D to Look At Group array.
func append_look_at_group_node_array(value: Array[NodePath]) -> void:
	for val in value:
		if not look_at_targets.has(val):
			look_at_targets.append(val)
			_valid_look_at_targets.append(val)
			_has_look_at_targets = true
		else:
			printerr(val, " is already part of Look At Group")
## Removes Node3D from Look At Group array.
func erase_look_at_group_node(value: Node3D) -> void:
	look_at_targets.erase(value)
	_valid_look_at_targets.erase(value)
	if look_at_targets.size() < 1:
		_has_look_at_targets = false
## Gets all the Node3D in Look At Group array.
func get_look_at_targets() -> Array[Node3D]:
	return look_at_targets


## Gets Inactive Update Mode property.
func get_inactive_update_mode() -> int:
	return inactive_update_mode

## Assigns a new [param Camera3D] Resource to this
## [param PhantomCamera3D].
func set_camera_3D_resource(value: Camera3DResource) -> void:
	camera_3d_resource = value
## Gets the Camera3D resource assigned to the PhantomCamera3D
## Returns null if there's nothing assigned to it.
func get_camera_3D_resource() -> Camera3DResource:
	return camera_3d_resource

## Assigns a new [member Camera3D.cull_mask] value.
## Note: This will override and make the [param Camera3D] Resource unique to
## this [param PhantomCamera3D].
func set_camera_cull_mask(value: int) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = value
		_camera_3D_resouce_default.h_offset = camera_3d_resource.h_offset
		_camera_3D_resouce_default.v_offset = camera_3d_resource.v_offset
		_camera_3D_resouce_default.fov = camera_3d_resource.fov
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.cull_mask = value
	if _is_active: get_pcam_host_owner().camera_3D.cull_mask = value
## Gets the [member Camera3D.cull_mask] value assigned this [param PhantomCamera].
## The duration value is in seconds.
func get_camera_cull_mask() -> int:
	if get_camera_3D_resource():
		return camera_3d_resource.cull_mask
	else:
		return _camera_3D_resouce_default.cull_mask

## Assigns a new [member Camera3D.h_offset] value.[br]
## Note: This will override and make the [param Camera3D] Resource unique to
## this [param PhantomCamera3D].
func set_camera_h_offset(value: float) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = camera_3d_resource.cull_mask
		_camera_3D_resouce_default.h_offset = value
		_camera_3D_resouce_default.v_offset = camera_3d_resource.v_offset
		_camera_3D_resouce_default.fov = camera_3d_resource.fov
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.h_offset = value
	if _is_active: get_pcam_host_owner().camera_3D.h_offset = value
## Gets the [member Camera3D.h_offset] value assigned this
## [param PhantomCamera3D]. The duration value is in [param seconds].
func get_camera_h_offset() -> float:
	if get_camera_3D_resource():
		return camera_3d_resource.h_offset
	else:
		return _camera_3D_resouce_default.h_offset

## Assigns a new [Camera3D.v_offset] value.[br]
## Note: This will override and make the [param Camera3D] Resource unique to
## this [param PhantomCamera3D].
func set_camera_v_offset(value: float) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = camera_3d_resource.cull_mask
		_camera_3D_resouce_default.h_offset = camera_3d_resource.h_offset
		_camera_3D_resouce_default.v_offset = value
		_camera_3D_resouce_default.fov = camera_3d_resource.fov
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.v_offset = value
	if _is_active: get_pcam_host_owner().camera_3D.v_offset = value
## Gets the Camera3D fov value assigned this PhantomCamera. The duration value is in seconds.
func get_camera_v_offset() -> float:
	if get_camera_3D_resource():
		return camera_3d_resource.v_offset
	else:
		return _camera_3D_resouce_default.v_offset

## Assigns a new [member Camera3D.fov] value.[br]
## Note: This will override and make the [param Camera3D] Resource unique to
## this [param PhantomCamera3D].
func set_camera_fov(value: float) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = camera_3d_resource.cull_mask
		_camera_3D_resouce_default.h_offset = camera_3d_resource.h_offset
		_camera_3D_resouce_default.v_offset = camera_3d_resource.v_offset
		_camera_3D_resouce_default.fov = value
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.fov = value
	if _is_active: get_pcam_host_owner().camera_3D.fov = value
## Gets the [member Camera3D.fov] value assigned this [param PhantomCamera3D].
## The duration value is in [param seconds].
func get_camera_fov() -> float:
	if get_camera_3D_resource():
		return camera_3d_resource.fov
	else:
		return _camera_3D_resouce_default.fov

#endregion
