@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg")
class_name PhantomCamera3D
extends Node3D

#region Constants

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

const FOLLOW_DISTANCE_PROPERTY_NAME: 						StringName = Constants.FOLLOW_PARAMETERS_NAME + "distance"
const FOLLOW_GROUP_DISTANCE_AUTO_NAME: 						StringName = Constants.FOLLOW_PARAMETERS_NAME + "auto_distance"
const FOLLOW_GROUP_DISTANCE_AUTO_MIN_NAME: 					StringName = Constants.FOLLOW_PARAMETERS_NAME + "min_distance"
const FOLLOW_GROUP_DISTANCE_AUTO_MAX_NAME: 					StringName = Constants.FOLLOW_PARAMETERS_NAME + "max_distance"
const FOLLOW_GROUP_DISTANCE_AUTO_DIVISOR: 					StringName = Constants.FOLLOW_PARAMETERS_NAME + "auto_distance_divisor"

const SPRING_ARM_PROPERTY_NAME: 							StringName = "spring_arm/"
const FOLLOW_SPRING_ARM_COLLISION_MASK_NAME: 				StringName = Constants.FOLLOW_PARAMETERS_NAME + SPRING_ARM_PROPERTY_NAME + "collision_mask"
const FOLLOW_SPRING_ARM_SHAPE_NAME: 						StringName = Constants.FOLLOW_PARAMETERS_NAME + SPRING_ARM_PROPERTY_NAME + "shape"
const FOLLOW_SPRING_ARM_SPRING_LENGTH_NAME: 				StringName = Constants.FOLLOW_PARAMETERS_NAME + SPRING_ARM_PROPERTY_NAME + "spring_length"
const FOLLOW_SPRING_ARM_MARGIN_NAME: 						StringName = Constants.FOLLOW_PARAMETERS_NAME + SPRING_ARM_PROPERTY_NAME + "margin"

const LOOK_AT_MODE_PROPERTY_NAME: 							StringName = "look_at_mode"
const LOOK_AT_TARGET_PROPERTY_NAME: 						StringName = "look_at_target"
const LOOK_AT_GROUP_PROPERTY_NAME: 							StringName = "look_at_group"
const LOOK_AT_PARAMETERS_NAME: 								StringName = "look_at_parameters/"
const LOOK_AT_TARGET_OFFSET_PROPERTY_NAME: 					StringName = LOOK_AT_PARAMETERS_NAME + "look_at_target_offset"

const CAMERA_3D_RESOURCE_PROPERTY_NAME: StringName = "camera_3D_resource"

#endregion


#region Signals

## Emitted when the PhantomCamera3D becomes active.
signal became_active
## Emitted when the PhantomCamera3D becomes inactive.
signal became_inactive

## Emitted when the Camera3D starts to tween to the PhantomCamera3D.
signal tween_started
## Emitted when the Camera3D is to tweening to the PhantomCamera3D.
signal is_tweening
## Emitted when the tween is interrupted due to another PhantomCamera3D becoming active.
## The argument is the PhantomCamera3D that interrupted the tween.
signal tween_interrupted(pcam_3d: PhantomCamera3D)
## Emitted when the Camera3D completes its tween to the	 PhantomCamera3D.
signal tween_completed

#endregion


#region Variables

var Properties: Object = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

## To quickly preview a PCam without adjusting its Priority, this property
## allows the selected PCam to ignore the Priority system altogether and
## forcefully become the active one. It's partly designed to work within the
## Viewfinder, and will be disabled when running a build export of the game.
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

## It defines which [code]PCam[/code] a scene's [code]Camera3D[/code] should
## be corresponding with and be attached to. This is decided by the PCam with
## the highest [code]Priority[/code].
## [br][br]
## Changing [code]Priority[/code] will send an event to the scene's
## [code]PCamHost[/code], which will then determine whether if the
## [code]Priority[/code] value is greater than or equal to the currently
## highest [code]pcam[/code]'s in the scene. The [code]PCam[/code] with the
## highest value will then reattach the Camera accordingly.
@export var priority: int = 0:
	set = set_priority,
	get = get_priority

## TODO Description
@export var follow_mode: Constants.FollowMode = Constants.FollowMode.NONE:
	set(value):
		follow_mode = value
		
		if value == Constants.FollowMode.FRAMED:
			if Properties.follow_framed_initial_set and follow_target:
				Properties.follow_framed_initial_set = false
				Properties.connect(Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed)
		else:
			if Properties.is_connected(Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed):
				Properties.disconnect(Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed)
		notify_property_list_changed()
	get:
		return follow_mode

var _should_follow: bool = false

var _follow_target_node: Node
## TODO Description
@export var follow_target: Node3D = null:
	set = set_follow_target,
	get = get_follow_target

var _follow_target_nodes: Array[Node3D]
## TODO Description
@export var follow_targets: Array[Node3D] = [null]:
	set = set_follow_targets,
	get = get_follow_targets
	
var _follow_path_node: Path3D
@export var follow_path: Path3D = null:
	set = set_follow_path,
	get = get_follow_path

var _should_look_at: bool = false
var _has_look_at_target: bool = false
var _has_look_at_targets: bool = false
enum LookAtMode {
	NONE 	= 0,
	MIMIC 	= 1,
	SIMPLE 	= 2,
	GROUP	= 3,
}
#var look_at_mode_enum: LookAtMode = LookAtMode.NONE

## TODO Description
@export var look_at_mode: LookAtMode = LookAtMode.NONE:
	set(value):
		look_at_mode = value
		notify_property_list_changed()

var _look_at_target_node: Node3D
## TODO Description
@export var look_at_target: Node3D = null:
	set = set_look_at_target,
	get = get_look_at_target

var _look_at_group_nodes: Array[Node3D]
## TODO Description
@export var look_at_targets: Array[Node3D] = [null]:
	set = set_look_at_targets,
	get = get_look_at_targets

## TODO Description
@export var tween_resource: PhantomCameraTween
var tween_resource_default: PhantomCameraTween = PhantomCameraTween.new()

## TODO Description
@export var inactive_update_mode: Constants.InactiveUpdateMode = Constants.InactiveUpdateMode.ALWAYS

var has_tweened: bool

## TODO Description
@export var tween_onload: bool = true


## TODO Description
@export var camera_3d_resource: Camera3DResource
var _camera_3D_resouce_default: Camera3DResource = Camera3DResource.new()

@export_group("Follow Parameters")

## TODO Description
@export var follow_damping: bool = false:
	set = set_follow_has_damping,
	get = get_follow_has_damping

## TODO Description
@export var follow_damping_value: float = 10:
	set = set_follow_damping_value,
	get = get_follow_damping_value

## TODO Description
@export var follow_offset: Vector3 = Vector3.ZERO:
	set = set_follow_target_offset,
	get = get_follow_target_offset

## TODO Description
@export var follow_distance: float = 1:
	set = set_follow_distance,
	get = get_follow_distance

## TODO Description
@export var follow_group_distance_auto: bool = false:
	set = set_auto_follow_distance,
	get = get_auto_follow_distance

## TODO Description
@export var follow_group_distance_auto_min: float = 1:
	set = set_min_auto_follow_distance,
	get = get_min_auto_follow_distance

## TODO Description
@export var follow_group_distance_auto_max: float = 5:
	set = set_max_auto_follow_distance,
	get = get_max_auto_follow_distance

## TODO Description
@export var follow_group_distance_auto_divisor: float = 10:
	set = set_auto_follow_distance_divisor,
	get = get_auto_follow_distance_divisor



@export_subgroup("Spring Arm")
var follow_spring_arm_node: SpringArm3D

## TODO Description
@export var spring_length: float = 1:
	set = set_follow_distance,
	get = get_follow_distance
	
## TODO Description
@export_flags_3d_physics var collision_mask: int = 1

## TODO Description
@export var shape: Shape3D = null

## TODO Description
@export var margin: float = 0.01

@export_group("Look At Parameters")

## TODO Description
@export var look_at_target_offset: Vector3 = Vector3.ZERO:
	set = set_look_at_target_offset,
	get = get_look_at_target_offset

var _camera_offset: Vector3
var _current_rotation: Vector3

#endregion


#region Properties

func _validate_property(property: Dictionary) -> void:
	###############
	## Follow Target
	###############
	if property.name == "follow_target":
		if follow_mode == Constants.FollowMode.NONE or \
		follow_mode == Constants.FollowMode.GROUP:
			property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "follow_targets":
		if follow_mode != Constants.FollowMode.GROUP:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "follow_path" and \
	follow_mode != Constants.FollowMode.PATH:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "follow_offset" and \
	(follow_mode == Constants.FollowMode.GLUED or follow_mode == Constants.FollowMode.PATH):
			property.usage = PROPERTY_USAGE_NO_EDITOR
			
	
	if property.name == "follow_damping" and \
	follow_mode == Constants.FollowMode.NONE:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "follow_damping_value" and not follow_damping:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_distance":
		if follow_mode != Constants.FollowMode.GROUP or \
		follow_mode != Constants.FollowMode.FRAMED:
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_group_distance_auto":
		if follow_mode == Constants.FollowMode.GROUP:
			property.usage = PROPERTY_USAGE_EDITOR
		else:
			property.usage = PROPERTY_USAGE_NONE

	if not follow_group_distance_auto:
		match property.name:
			"follow_group_distance_auto_max", \
			"follow_group_distance_auto_min",\
			"follow_group_distance_auto_divisor":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	#############
	## Spring Arm
	#############
	
	if not follow_mode == Constants.FollowMode.THIRD_PERSON:
		match property.name:
			"spring_length", \
			"collision_mask", \
			"shape", \
			"margin":
				property.usage = PROPERTY_USAGE_NO_EDITOR
	
	
	###############
	## Look At
	###############
	if property.name == "look_at_target" and \
	look_at_mode == LookAtMode.NONE:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	
	if property.name == "look_at_targets" and \
	look_at_mode != LookAtMode.GROUP:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "look_at_target_offset" and \
	look_at_mode == LookAtMode.NONE:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	notify_property_list_changed()
#
	#if property == Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME:		return Properties.inactive_update_mode
	#if property == Constants.TWEEN_ONLOAD_NAME: 						return Properties.tween_onload
#
	#if property ==  CAMERA_3D_RESOURCE_PROPERTY_NAME:					return _camera_3D_resouce

#endregion

#region Private Functions

func _enter_tree() -> void:
	Properties.is_2D = false;
	Properties.camera_enter_tree(self)
	Properties.assign_pcam_host(self)

	#if not get_parent() is SpringArm3D:
		#if look_at_target:
			#_look_at_target_node = look_at_target
		#elif look_at_targets:
			#print("Pringin")
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
	if follow_mode == Constants.FollowMode.THIRD_PERSON:
		if not Engine.is_editor_hint():
			if not is_instance_valid(follow_spring_arm_node):
				follow_spring_arm_node = SpringArm3D.new()
				get_parent().add_child.call_deferred(follow_spring_arm_node)
	if follow_mode == Constants.FollowMode.FRAMED:
		if not Engine.is_editor_hint():
			_camera_offset = global_position - _get_target_position_offset()
			_current_rotation = get_global_rotation()


func _process(delta: float) -> void:
	if not Properties.is_active:
		match inactive_update_mode:
			Constants.InactiveUpdateMode.NEVER:
				return
#			Constants.InactiveUpdateMode.EXPONENTIALLY:
#				TODO

	if _should_follow:
		match follow_mode:
			Constants.FollowMode.GLUED:
				if follow_target:
					_interpolate_position(
						follow_target.get_global_position(),
						delta
					)
			Constants.FollowMode.SIMPLE:
				if follow_target:
					_interpolate_position(
						_get_target_position_offset(),
						delta
					)
			Constants.FollowMode.GROUP:
				if Properties.has_follow_group:
					if follow_targets.size() == 1:
						_interpolate_position(
							follow_targets[0].get_global_position() +
							follow_offset +
							get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance),
							delta
						)
					elif follow_targets.size() > 1:
						var bounds: AABB = AABB(follow_targets[0].get_global_position(), Vector3.ZERO)
						for node in follow_targets:
							bounds = bounds.expand(node.get_global_position())

						var distance: float
						if follow_group_distance_auto:
							distance = lerp(follow_group_distance_auto_min, follow_group_distance_auto_max, bounds.get_longest_axis_size() / follow_group_distance_auto_divisor)
							distance = clamp(distance, follow_group_distance_auto_min, follow_group_distance_auto_max)
						else:
							distance = follow_distance

						_interpolate_position(
							bounds.get_center() +
							follow_offset +
							get_transform().basis.z * Vector3(distance, distance, distance),
							delta
						)
			Constants.FollowMode.PATH:
				if follow_target and follow_path:
					var path_position: Vector3 = follow_path.get_global_position()
					_interpolate_position(
						follow_path.curve.get_closest_point(follow_target.get_global_position() - path_position) + path_position,
						delta
					)
			Constants.FollowMode.FRAMED:
				if Properties.follow_target_node:
					if not Engine.is_editor_hint():
						if !is_active() || get_pcam_host_owner().trigger_pcam_tween:
							_interpolate_position(
								_get_position_offset_distance(),
								delta
							)
							return
						
						Properties.viewport_position = get_viewport().get_camera_3d().unproject_position(_get_target_position_offset())
						var visible_rect_size: Vector2 = get_viewport().get_viewport().size
						Properties.viewport_position = Properties.viewport_position / visible_rect_size
						_current_rotation = get_global_rotation()

						if _current_rotation != get_global_rotation():
							_interpolate_position(
								_get_position_offset_distance(),
								delta
							)

						if Properties.get_framed_side_offset() != Vector2.ZERO:
							var target_position: Vector3 = _get_target_position_offset() + _camera_offset
							var dead_zone_width: float = Properties.follow_framed_dead_zone_width
							var dead_zone_height: float = Properties.follow_framed_dead_zone_height
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
								if _current_rotation != get_global_rotation():
									var opposite: float = sin(-get_global_rotation().x) * follow_distance + _get_target_position_offset().y
									glo_pos.y = _get_target_position_offset().y + opposite
									glo_pos.z = sqrt(pow(follow_distance, 2) - pow(opposite, 2)) + _get_target_position_offset().z
									glo_pos.x = global_position.x

									_interpolate_position(
										glo_pos,
										delta
									)
									_current_rotation = get_global_rotation()
								else:
									_interpolate_position(
										target_position,
										delta
									)
						else:
							_camera_offset = global_position - _get_target_position_offset()
							_current_rotation = get_global_rotation()
					else:
						set_global_position(_get_position_offset_distance())
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
			Constants.FollowMode.THIRD_PERSON:
				if follow_target:
					if not Engine.is_editor_hint():
						if is_instance_valid(follow_target):
							if is_instance_valid(follow_spring_arm_node):
								if not get_parent() == follow_spring_arm_node:
									var follow_target: Node3D = follow_target
									follow_spring_arm_node.set_rotation_degrees(get_rotation_degrees())
									follow_spring_arm_node.set_length(follow_distance)
									follow_spring_arm_node.set_collision_mask(collision_mask)
									follow_spring_arm_node.set_shape(shape)
									follow_spring_arm_node.set_margin(margin)
									follow_spring_arm_node.set_global_position(_get_target_position_offset()) # Ensure the PCam3D starts at the right position at runtime

									if not is_tween_on_load():
										Properties.has_tweened = true

									reparent(follow_spring_arm_node)

								_interpolate_position(
									_get_target_position_offset(),
									delta,
									follow_spring_arm_node
								)
					else:
						set_global_position(_get_position_offset_distance())

	if _should_look_at:
		match look_at_mode:
			LookAtMode.MIMIC:
				if _has_look_at_target:
					set_global_rotation(_look_at_target_node.get_global_rotation())
			LookAtMode.SIMPLE:
				if _has_look_at_target:
					look_at(_look_at_target_node.get_global_position() + look_at_target_offset)
			LookAtMode.GROUP:
				if _has_look_at_targets:
					if _look_at_group_nodes.size() == 1:
						look_at(_look_at_group_nodes[0].get_global_position())
					elif _look_at_group_nodes.size() > 1:
						var bounds: AABB = AABB(_look_at_group_nodes[0].get_global_position(), Vector3.ZERO)
						for node in _look_at_group_nodes:
							bounds = bounds.expand(node.get_global_position())
						look_at(bounds.get_center())


func _get_target_position_offset() -> Vector3:
	return follow_target.get_global_position() + follow_offset


func _get_position_offset_distance() -> Vector3:
	return _get_target_position_offset() + \
	get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance)


func _interpolate_position(_global_position: Vector3, delta: float, target: Node3D = self) -> void:
	if follow_damping:
		target.set_global_position(
			target.get_global_position().lerp(
				_global_position,
				delta * follow_damping_value
			)
		)
	else:
		target.set_global_position(_global_position)


func _get_raw_unprojected_position() -> Vector2:
	return get_viewport().get_camera_3d().unproject_position(follow_target.get_global_position() + follow_offset)


func _on_dead_zone_changed() -> void:
	set_global_position( _get_position_offset_distance() )


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

## Assigns the PhantomCamera3D to a new PhantomCameraHost.
func assign_pcam_host() -> void:
	Properties.assign_pcam_host(self)
## Gets the current PhantomCameraHost this PhantomCamera3D is assigned to.
func get_pcam_host_owner() -> PhantomCameraHost:
	return Properties.pcam_host_owner


## Assigns new Priority value.
func set_priority(value: int) -> void:
	if value < 0:
		printerr("Phantom Camera's priority cannot be less than 0")
		priority = 0
	else:
		priority = value

	if _has_valid_pcam_owner():
		get_pcam_host_owner().pcam_priority_updated(self)
## Gets current Priority value.
func get_priority() -> int:
	return priority


## Assigns a new PhantomCameraTween resource to the PhantomCamera3D
func set_tween_resource(value: PhantomCameraTween) -> void:
	tween_resource = value
## Gets the PhantomCameraTween resource assigned to the PhantomCamera3D
## Returns null if there's nothing assigned to it.
func get_tween_resource() -> PhantomCameraTween:
	return tween_resource

## Assigns a new Tween Duration value. The duration value is in seconds.
## Note: This will override and make the Tween Resource unique to this PhantomCamera3D.
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
	if tween_resource:
		return tween_resource.duration
	else:
		return tween_resource_default.duration

## Assigns a new Tween Transition value.
## Note: This will override and make the Tween Resource unique to this PhantomCamera3D.
func set_tween_transition(value: Constants.TweenTransitions) -> void:
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
## Note: This will override and make the Tween Resource unique to this PhantomCamera3D.
func set_tween_ease(value: Constants.TweenEases) -> void:
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


## Gets current active state of the PhantomCamera3D.
## If it returns true, it means the PhantomCamera3D is what the Camera2D is currently following.
func is_active() -> bool:
	return Properties.is_active


## Enables or disables the Tween on Load.
func set_tween_on_load(value: bool) -> void:
	tween_onload = value
## Gets the current Tween On Load value.
func is_tween_on_load() -> bool:
	return tween_onload


## Gets the current follow mode as an enum int based on Constants.FOLLOW_MODE enum.
## Note: Setting Follow Mode purposely not added. A separate PCam should be used instead.
func get_follow_mode() -> int:
	return follow_mode


## Assigns a new Node3D as the Follow Target.
func set_follow_target(value: Node3D) -> void:
	follow_target = value
	_should_follow = true
## Removes the current Node3D Follow Target.
func erase_follow_target() -> void:
	_should_follow = false
	follow_target = null
## Gets the current Node3D target.
func get_follow_target():
	return follow_target


## Assigns a new Path3D to the Follow Path property.
func set_follow_path(value: Path3D) -> void:
	follow_path = value
	#_follow_path_node = value
## Erases the current Path3D frp, the Follow Target
func erase_follow_path() -> void:
	_follow_path_node = null
## Gets the current Path2D from the Follow Path property.
func get_follow_path():
	return follow_path


## Assigns a new Vector3 for the Follow Target Offset property.
func set_follow_target_offset(value: Vector3) -> void:
	follow_offset = value
## Gets the current Vector3 for the Follow Target Offset property.
func get_follow_target_offset() -> Vector3:
	return follow_offset


## Enables or disables Follow Damping.
func set_follow_has_damping(value: bool) -> void:
	follow_damping = value
	notify_property_list_changed()
## Gets the currents Follow Damping property.
func get_follow_has_damping() -> bool:
	return follow_damping


## Assigns new Damping value.
func set_follow_damping_value(value: float) -> void:
	follow_damping_value = value
## Gets the currents Follow Damping value.
func get_follow_damping_value() -> float:
	return follow_damping_value


## Assigns a new Follow Distance value.
func set_follow_distance(value: float) -> void:
	follow_distance = value
## Gets Follow Distance value.
func get_follow_distance() -> float:
	return follow_distance

func set_follow_targets(value: Array[Node3D]) -> void:
	follow_targets = value

## Adds a single Node3D to Follow Group array.
func append_follow_group_node(value: Node3D) -> void:
	if not follow_targets.has(value):
		follow_targets.append(value)
		Properties.should_follow = true
		Properties.has_follow_group = true
	else:
		printerr(value, " is already part of Follow Group")
## Adds an Array of type Node3D to Follow Group array.
func append_follow_group_node_array(value: Array[Node3D]) -> void:
	for val in value:
		if not follow_targets.has(val):
			follow_targets.append(val)
			Properties.should_follow = true
			Properties.has_follow_group = true
		else:
			printerr(value, " is already part of Follow Group")
## Removes Node3D from Follow Group array.
func erase_follow_group_node(value: Node3D) -> void:
	follow_targets.erase(value)
	if get_follow_targets().size() < 1:
		Properties.should_follow = false
		Properties.has_follow_group = false
## Gets all Node3D from Follow Group array.
func get_follow_targets() -> Array[Node3D]:
	return follow_targets

## Enables or disables Auto Follow Distance when using Group Follow.
func set_auto_follow_distance(value: bool) -> void:
	follow_group_distance_auto = value
	notify_property_list_changed()
## Gets Auto Follow Distance state.
func get_auto_follow_distance() -> bool:
	return follow_group_distance_auto

## Assigns new Min Auto Follow Distance value.
func set_min_auto_follow_distance(value: float) -> void:
	follow_group_distance_auto_min = value
## Gets Min Auto Follow Distance value.
func get_min_auto_follow_distance() -> float:
	return follow_group_distance_auto_min

## Assigns new Max Auto Follow Distance value.
func set_max_auto_follow_distance(value: float) -> void:
	follow_group_distance_auto_max = value
## Gets Max Auto Follow Distance value.
func get_max_auto_follow_distance() -> float:
	return follow_group_distance_auto_max

## Assigns new Auto Follow Distance Divisor value.
func set_auto_follow_distance_divisor(value: float) -> void:
	follow_group_distance_auto_divisor = value
## Gets Auto Follow Divisor value.
func get_auto_follow_distance_divisor() -> float:
	return follow_group_distance_auto_divisor

## Assigns new rotation (in radians) value to SpringArm for Third Person Follow mode.
func set_third_person_rotation(value: Vector3) -> void:
	follow_spring_arm_node.rotation = value
## Gets the rotation value (in radians) from the SpringArm for Third Person Follow mode.
func get_third_person_rotation() -> Vector3:
	return follow_spring_arm_node.rotation
## Assigns new rotation (in degrees) value to SpringArm for Third Person Follow mode.
func set_third_person_rotation_degrees(value: Vector3) -> void:
	follow_spring_arm_node.rotation_degrees = value
## Gets the rotation value (in degrees) from the SpringArm for Third Person Follow mode.
func get_third_person_rotation_degrees() -> Vector3:
	return follow_spring_arm_node.rotation_degrees

## Assigns a new Third Person SpringArm3D Length value.
func set_spring_arm_spring_length(value: float) -> void:
	follow_distance = value
	follow_spring_arm_node.set_length(value)
## Gets Third Person SpringArm3D Length value.
func get_spring_arm_spring_length() -> float:
	return follow_distance

## Assigns a new Third Person SpringArm3D Collision Mask value.
func set_spring_arm_collision_mask(value: int) -> void:
	collision_mask = value
## Gets Third Person SpringArm3D Collision Mask value.
func get_spring_arm_collision_mask() -> int:
	return collision_mask

## Assigns a new Third Person SpringArm3D Shape value.
func set_spring_arm_shape(value: Shape3D) -> void:
	shape = value
## Gets Third Person SpringArm3D Shape value.
func get_spring_arm_shape() -> Shape3D:
	return shape

## Assigns a new Third Person SpringArm3D Margin value.
func set_spring_arm_margin(value: float) -> void:
	margin = value
## Gets Third Person SpringArm3D Margin value.
func get_spring_arm_margin() -> float:
	return margin


## Gets Look At Mode. Value is based on LookAtMode enum.
## Note: To set a new Look At Mode, a separate PhantomCamera3D should be used.
func get_look_at_mode() -> int:
	return look_at_mode

## Assigns new Node3D as Look At Target.
func set_look_at_target(value: Node3D) -> void:
	look_at_target = value
	#_look_at_target_node = get_node_or_null(value)
	if is_instance_valid(_look_at_target_node):
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
	#_look_at_group_nodes = []
	#for val in value:
		#_look_at_group_nodes.append(get_node_or_null(val))
	notify_property_list_changed()

## Appends Node3D to Look At Group array.
func append_look_at_group_node(value: Node3D) -> void:
	if not _look_at_group_nodes.has(value):
		_look_at_group_nodes.append(value)
		_has_look_at_targets = true
	else:
		printerr(value, " is already part of Look At Group")
## Appends array of type Node3D to Look At Group array.
func append_look_at_group_node_array(value: Array[NodePath]) -> void:
	for val in value:
		if not _look_at_group_nodes.has(val):
			_look_at_group_nodes.append(val)
			_has_look_at_targets = true
		else:
			printerr(val, " is already part of Look At Group")
## Removes Node3D from Look At Group array.
func erase_look_at_group_node(value: Node3D) -> void:
	_look_at_group_nodes.erase(value)
	if _look_at_group_nodes.size() < 1:
		_has_look_at_targets = false
## Gets all the Node3D in Look At Group array.
func get_look_at_targets() -> Array[Node3D]:
	return look_at_targets


## Gets Inactive Update Mode property.
func get_inactive_update_mode() -> int:
	return inactive_update_mode

## Assogms a new Camera3D Resource to this PhantomCamera3D
func set_camera_3D_resource(value: Camera3DResource) -> void:
	camera_3d_resource = value
## Gets the Camera3D resource assigned to the PhantomCamera3D
## Returns null if there's nothing assigned to it.
func get_camera_3D_resource() -> Camera3DResource:
	return camera_3d_resource

## Assigns a new Camera3D Cull Mask value.
## Note: This will override and make the Camera3D Resource unique to this PhantomCamera3D.
func set_camera_cull_mask(value: int) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = value
		_camera_3D_resouce_default.h_offset = camera_3d_resource.h_offset
		_camera_3D_resouce_default.v_offset = camera_3d_resource.v_offset
		_camera_3D_resouce_default.fov = camera_3d_resource.fov
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.cull_mask = value
## Gets the Camera3D fov value assigned this PhantomCamera. The duration value is in seconds.
func get_camera_cull_mask() -> int:
	if get_camera_3D_resource():
		return camera_3d_resource.cull_mask
	else:
		return _camera_3D_resouce_default.cull_mask

## Assigns a new Camera3D H Offset value.
## Note: This will override and make the Camera3D Resource unique to this PhantomCamera3D.
func set_camera_h_offset(value: float) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = camera_3d_resource.cull_mask
		_camera_3D_resouce_default.h_offset = value
		_camera_3D_resouce_default.v_offset = camera_3d_resource.v_offset
		_camera_3D_resouce_default.fov = camera_3d_resource.fov
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.h_offset = value
## Gets the Camera3D fov value assigned this PhantomCamera. The duration value is in seconds.
func get_camera_h_offset() -> float:
	if get_camera_3D_resource():
		return camera_3d_resource.h_offset
	else:
		return _camera_3D_resouce_default.h_offset

## Assigns a new Camera3D V Offset value.
## Note: This will override and make the Camera3D Resource unique to this PhantomCamera3D.
func set_camera_v_offset(value: float) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = camera_3d_resource.cull_mask
		_camera_3D_resouce_default.h_offset = camera_3d_resource.h_offset
		_camera_3D_resouce_default.v_offset = value
		_camera_3D_resouce_default.fov = camera_3d_resource.fov
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.v_offset = value
## Gets the Camera3D fov value assigned this PhantomCamera. The duration value is in seconds.
func get_camera_v_offset() -> float:
	if get_camera_3D_resource():
		return camera_3d_resource.v_offset
	else:
		return _camera_3D_resouce_default.v_offset

## Assigns a new Camera3D FOV value.
## Note: This will override and make the Camera3D Resource unique to this PhantomCamera3D.
func set_camera_fov(value: float) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = camera_3d_resource.cull_mask
		_camera_3D_resouce_default.h_offset = camera_3d_resource.h_offset
		_camera_3D_resouce_default.v_offset = camera_3d_resource.v_offset
		_camera_3D_resouce_default.fov = value
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.fov = value
## Gets the Camera3D fov value assigned this PhantomCamera. The duration value is in seconds.
func get_camera_fov() -> float:
	if get_camera_3D_resource():
		return camera_3d_resource.fov
	else:
		return _camera_3D_resouce_default.fov

#endregion
