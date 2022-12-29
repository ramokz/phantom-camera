@tool
class_name PhantomCamera3D
extends Node3D
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg")

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

var Properties: Object = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

#####################
# Look At - Variables
#####################
const _look_at_target_property_name: StringName = "Look At Target"
var look_at_target_node: Node3D
var _look_at_target_path: NodePath
var has_look_at_target: bool = false

const _look_at_target_offset_property_name: StringName = "Look At Parameters/Look At Target Offset"
var look_at_target_offset: Vector3


############
# Properties
############
func _get_property_list() -> Array:
	var property_list: Array[Dictionary]

#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	property_list.append_array(Properties.add_multiple_hosts_properties())

	property_list.append_array(Properties.add_priority_properties())
	property_list.append_array(Properties.add_trigger_onload_properties())
	property_list.append_array(Properties.add_follow_properties())

	######################
	# Look At - Properties
	######################
	property_list.append({
		"name": _look_at_target_property_name,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	if has_look_at_target:
		property_list.append({
			"name": _look_at_target_offset_property_name,
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
	Properties.set_trigger_onload_properties(property, value, self)	
	Properties.set_follow_properties(property, value, self)

	if property == _look_at_target_property_name:
		_look_at_target_path = value
		var valueNodePath: NodePath = value as NodePath
		if not valueNodePath.is_empty():
			has_look_at_target = true
			if has_node(_look_at_target_path):
				look_at_target_node = get_node(_look_at_target_path)
		else:
			has_look_at_target = false
			look_at_target_node = null

		notify_property_list_changed()
	if property == _look_at_target_offset_property_name:
		look_at_target_offset = value

	Properties.set_tween_properties(property, value, self)
	return false


func _get(property: StringName):
#	return PhantomCameraProperties.get_properties(property)

	#####################################
	# Multiple Phantom Hosts - Properties
	#####################################
#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	if property == Constants.PHANTOM_CAMERA_HOST: return Properties.phantom_camera_host_owner.name

	#######################
	# Priority - Properties
	#######################
	if property == Constants.PRIORITY_PROPERTY_NAME: return Properties.priority

	#############################
	# Trigger Onload - Properties
	#############################
	if property == Constants.TRIGGER_ONLOAD_NAME: return Properties.trigger_onload

	#####################
	# Follow - Properties
	#####################
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME: return Properties.follow_target_path
	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: return Properties.follow_target_offset

	######################
	# Look At - Properties
	######################
	if property == _look_at_target_property_name: return _look_at_target_path
	if property == _look_at_target_offset_property_name: return look_at_target_offset

	####################
	# Tween - Properties
	####################
	if property == Constants.TWEEN_DURATION_PROPERTY_NAME: return Properties.tween_duration
	if property == Constants.TWEEN_TRANSITION_PROPERTY_NAME: return Properties.tween_transition
	if property == Constants.TWEEN_EASE_PROPERTY_NAME: return Properties.tween_ease


###################
# Private Functions
###################
func _enter_tree() -> void:
	Properties.enter_tree(self)
	Properties.assign_phantom_camera_host(self)
	if _look_at_target_path:
		look_at_target_node = get_node(_look_at_target_path)

func _exit_tree() -> void:
	if Properties.phantom_camera_host_owner:
		Properties.phantom_camera_host_owner.phantom_camera_removed_from_scene(self)


func _physics_process(delta: float) -> void:
	if Properties.follow_target_node:
		set_position(Properties.follow_target_node.position + Properties.follow_target_offset)

	if look_at_target_node:
		look_at(look_at_target_node.position)


##################
# Public Functions
##################
func assign_phantom_camera_host() -> void:
	Properties.assign_phantom_camera_host(self)


func set_priority(value: int) -> void:
	Properties.set_priority(value, self)


func get_priority() -> int:
	return Properties.priority


func get_tween_duration() -> float:
	return Properties.tween_duration


func get_tween_transition() -> int:
	return Properties.tween_transition
