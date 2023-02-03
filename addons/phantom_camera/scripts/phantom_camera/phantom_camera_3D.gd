@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg")
class_name PhantomCamera3D
extends Node3D

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

var Properties: Object = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

var follow_distance: float = 1

const LOOK_AT_TARGET_PROPERTY_NAME: StringName = "Look At Target"
var _look_at_target_node: Node3D
var _look_at_target_path: NodePath
var _has_look_at_target: bool = false

const FOLLOW_DISTANCE_PROPERTY_NAME: StringName = Constants.FOLLOW_PARAMETERS_NAME + "Distance"

const LOOK_AT_TARGET_OFFSET_PROPERTY_NAME: StringName = "Look At Parameters/Look At Target Offset"
var look_at_target_offset: Vector3


func _get_property_list() -> Array:
	var property_list: Array[Dictionary]

#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	property_list.append_array(Properties.add_multiple_hosts_properties())

	property_list.append_array(Properties.add_priority_properties())
#	property_list.append_array(Properties.add_trigger_onload_properties())

	property_list.append_array(Properties.add_follow_target_property())
	property_list.append_array(Properties.add_follow_mode_property())

#	if Properties.follow_mode == Constants.FollowMode.FRAMED_FOLLOW:
#		property_list.append({
#			"name": FOLLOW_DISTANCE_PROPERTY_NAME,
#			"type": TYPE_FLOAT,
#			"hint": PROPERTY_HINT_NONE,
#			"usage": PROPERTY_USAGE_DEFAULT,
#		})

	property_list.append_array(Properties.add_follow_properties())

	property_list.append({
		"name": LOOK_AT_TARGET_PROPERTY_NAME,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	if _has_look_at_target:
		property_list.append({
			"name": LOOK_AT_TARGET_OFFSET_PROPERTY_NAME,
			"type": TYPE_VECTOR3,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	property_list.append_array(Properties.add_tween_properties())

	return property_list


func _set(property: StringName, value) -> bool:
#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	Properties.set_phantom_host_property(property, value, self)
	Properties.set_priority_property(property, value, self)
#	Properties.set_trigger_onload_properties(property, value, self)
	Properties.set_follow_properties(property, value, self)

	if property == FOLLOW_DISTANCE_PROPERTY_NAME:
		if value == 0:
			follow_distance = 0.001
		else:
			follow_distance = value

	if property == LOOK_AT_TARGET_PROPERTY_NAME:
		_look_at_target_path = value
		var valueNodePath: NodePath = value as NodePath
		if not valueNodePath.is_empty():
			_has_look_at_target = true
			if has_node(_look_at_target_path):
				set_rotation(Vector3(0,0,0))
				_look_at_target_node = get_node(_look_at_target_path)
				Properties.set_process(self, true)
		else:
			Properties.set_process(self, false)
			_has_look_at_target = false
			_look_at_target_node = null

		notify_property_list_changed()
	if property == LOOK_AT_TARGET_OFFSET_PROPERTY_NAME:
		look_at_target_offset = value

	Properties.set_tween_properties(property, value, self)
	return false


func _get(property: StringName):
#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	if property == Constants.PHANTOM_CAMERA_HOST: return Properties.pcam_host_owner.name

	if property == Constants.PRIORITY_PROPERTY_NAME: return Properties.priority

#	if property == Constants.TRIGGER_ONLOAD_NAME: return Properties.trigger_onload

	if property == Constants.FOLLOW_MODE_PROPERTY_NAME: return Properties.follow_mode
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME: return Properties.follow_target_path
	if property == FOLLOW_DISTANCE_PROPERTY_NAME: return follow_distance
	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: return Properties.follow_target_offset_3D
	if property == Constants.FOLLOW_DAMPING_NAME: return Properties.follow_has_damping
	if property == Constants.FOLLOW_DAMPING_VALUE_NAME: return Properties.follow_damping_value

	if property == LOOK_AT_TARGET_PROPERTY_NAME: return _look_at_target_path
	if property == LOOK_AT_TARGET_OFFSET_PROPERTY_NAME: return look_at_target_offset

	if property == Constants.TWEEN_DURATION_PROPERTY_NAME: return Properties.tween_duration
	if property == Constants.TWEEN_TRANSITION_PROPERTY_NAME: return Properties.tween_transition
	if property == Constants.TWEEN_EASE_PROPERTY_NAME: return Properties.tween_ease


###################
# Private Functions
###################
func _enter_tree() -> void:
	Properties.is_3D = true;
	Properties.camera_enter_tree(self)
	Properties.assign_pcam_host(self)
	if _look_at_target_path:
		_look_at_target_node = get_node(_look_at_target_path)


func _exit_tree() -> void:
	if Properties.pcam_host_owner:
		Properties.pcam_host_owner.pcam_removed_from_scene(self)


func _ready() -> void:
	if Properties.follow_target_path.is_empty() and _look_at_target_path.is_empty():
		Properties.set_process(self, false)


func _physics_process(delta: float) -> void:
	if Properties.follow_target_node:
		match Properties.follow_mode:

			Constants.FollowMode.SIMPLE_FOLLOW:
				set_global_position(
					Properties.follow_target_node.position +
					Properties.follow_target_offset_3D
				)

#			Constants.FollowMode.FRAMED_FOLLOW:
#				set_global_position(
#					Properties.follow_target_node.position +
#					Properties.follow_target_offset_3D +
#					get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance)
#				)

			Constants.FollowMode.GLUED_FOLLOW:
				set_global_position(Properties.follow_target_node.position)

	if _look_at_target_node:
		look_at(_look_at_target_node.position)


##################
# Public Functions
##################
func assign_pcam_host() -> void:
	Properties.assign_pcam_host(self)


func set_priority(value: int) -> void:
	Properties.set_priority(value, self)


func get_priority() -> int:
	return Properties.priority


func get_tween_duration() -> float:
	return Properties.tween_duration


func get_tween_transition() -> int:
	return Properties.tween_transition


func get_tween_ease() -> int:
	return Properties.tween_ease
