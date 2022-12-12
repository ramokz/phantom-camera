@tool
class_name PhantomCamera3D
extends Node3D
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg")

const PhantomCameraConstants = preload("phantom_camera/phantom_camera_constants.gd")
var Phantom_Camera_Variables = preload("phantom_camera/phantom_camera_variables.gd").new()

var phantom_camera_host_owner: PhantomCameraHost3D

var follow_target_offset: Vector3 = Vector3(0, 0, 3)

###################
# Look At - Variables
###################
const _look_at_target_property_name: StringName = "Look At Target"
var look_at_target_node: Node
var _look_at_target_path: NodePath
var has_look_at_target: bool = false

const _look_at_target_offset_property_name: StringName = "Look At Parameters/Look At Target Offset"
var look_at_target_offset: Vector3
var tween_linear: bool


############
# Properties
############
func _get_property_list() -> Array:
	var property_list: Array[Dictionary]

	######################
	# General - Properties
	######################
	property_list.append({
		"name": PhantomCameraConstants.PRIORITY_PROPERTY_NAME,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	#####################
	# Follow - Properties
	#####################
	property_list.append({
		"name": PhantomCameraConstants.FOLLOW_TARGET_PROPERTY_NAME,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	if Phantom_Camera_Variables.has_follow_target:
		property_list.append({
			"name": PhantomCameraConstants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME,
			"type": TYPE_VECTOR3,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

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

	####################
	# Tween - Properties
	####################
	property_list.append({
		"name": PhantomCameraConstants.TWEEN_DURATION_PROPERTY_NAME,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	property_list.append({
		"name": PhantomCameraConstants.TWEEN_TRANSITION_PROPERTY_NAME,
		"type": TYPE_NIL,
		"hint_string": "Transition_",
		"usage": PROPERTY_USAGE_GROUP
	})

	property_list.append({
		"name": PhantomCameraConstants.TWEEN_TRANSITION_PROPERTY_NAME,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(PackedStringArray(PhantomCameraConstants.TweenTransitions.keys())),
		"usage": PROPERTY_USAGE_DEFAULT
	})

	if not tween_linear:
		property_list.append({
			"name": PhantomCameraConstants.TWEEN_EASE_PROPERTY_NAME,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(PackedStringArray(PhantomCameraConstants.TweenEases.keys())),
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return property_list


func _set(property: StringName, value) -> bool:
	######################
	# General - Properties
	######################
	if property == PhantomCameraConstants.PRIORITY_PROPERTY_NAME:
		set_priority(value)

	#####################
	# Follow - Properties
	#####################
	if property == PhantomCameraConstants.FOLLOW_TARGET_PROPERTY_NAME:
		Phantom_Camera_Variables.follow_target_path = value
		var valueNodePath: NodePath = value as NodePath
		if not valueNodePath.is_empty():
			Phantom_Camera_Variables.has_follow_target = true
			if has_node(Phantom_Camera_Variables.follow_target_path):
				Phantom_Camera_Variables.follow_target_node = get_node(Phantom_Camera_Variables.follow_target_path)
		else:
			Phantom_Camera_Variables.has_follow_target = false
			Phantom_Camera_Variables.follow_target_node = null

		notify_property_list_changed()
	if property == PhantomCameraConstants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME:
		if value == Vector3.ZERO:
			printerr("Follow Offset cannot be 0,0,0, resetting to 0,0,1")
			follow_target_offset = Vector3(0,0,1)
		else:
			follow_target_offset = value

	######################
	# Look At - Properties
	######################
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

	####################
	# Tween - Properties
	####################
	if property == PhantomCameraConstants.TWEEN_DURATION_PROPERTY_NAME:
		Phantom_Camera_Variables.tween_duration = value
	if property == PhantomCameraConstants.TWEEN_TRANSITION_PROPERTY_NAME:
		tween_linear = false
		match value:
			Tween.TRANS_LINEAR:
				Phantom_Camera_Variables.tween_transition = Tween.TRANS_LINEAR
				tween_linear = true # Disables Easing property as it has no effect on Linear transitions
			Tween.TRANS_BACK: 		Phantom_Camera_Variables.tween_transition = Tween.TRANS_BACK
			Tween.TRANS_SINE: 		Phantom_Camera_Variables.tween_transition = Tween.TRANS_SINE
			Tween.TRANS_QUINT: 		Phantom_Camera_Variables.tween_transition = Tween.TRANS_QUINT
			Tween.TRANS_QUART: 		Phantom_Camera_Variables.tween_transition = Tween.TRANS_QUART
			Tween.TRANS_QUAD: 		Phantom_Camera_Variables.tween_transition = Tween.TRANS_QUAD
			Tween.TRANS_EXPO: 		Phantom_Camera_Variables.tween_transition = Tween.TRANS_EXPO
			Tween.TRANS_ELASTIC: 	Phantom_Camera_Variables.tween_transition = Tween.TRANS_ELASTIC
			Tween.TRANS_CUBIC:		Phantom_Camera_Variables.tween_transition = Tween.TRANS_CUBIC
			Tween.TRANS_BOUNCE: 	Phantom_Camera_Variables.tween_transition = Tween.TRANS_BOUNCE
			Tween.TRANS_BACK: 		Phantom_Camera_Variables.tween_transition = Tween.TRANS_BACK
			11:
				print("Transition is custom")
				Phantom_Camera_Variables.tween_transition = 11
		notify_property_list_changed()
	if property == PhantomCameraConstants.TWEEN_EASE_PROPERTY_NAME:
		match value:
			Tween.EASE_IN: 			Phantom_Camera_Variables.tween_ease = Tween.EASE_IN
			Tween.EASE_OUT: 		Phantom_Camera_Variables.tween_ease = Tween.EASE_OUT
			Tween.EASE_IN_OUT: 		Phantom_Camera_Variables.tween_ease = Tween.EASE_IN_OUT
			Tween.EASE_OUT_IN: 		Phantom_Camera_Variables.tween_ease = Tween.EASE_OUT_IN
	return false


func _get(property: StringName):

	######################
	# General - Properties
	######################
	if property == PhantomCameraConstants.PRIORITY_PROPERTY_NAME: return Phantom_Camera_Variables.priority

	#####################
	# Follow - Properties
	#####################
	if property == PhantomCameraConstants.FOLLOW_TARGET_PROPERTY_NAME: return Phantom_Camera_Variables.follow_target_path
	if property == PhantomCameraConstants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: return follow_target_offset

	######################
	# Look At - Properties
	######################
	if property == _look_at_target_property_name: return _look_at_target_path
	if property == _look_at_target_offset_property_name: return look_at_target_offset

	####################
	# Tween - Properties
	####################
	if property == PhantomCameraConstants.TWEEN_DURATION_PROPERTY_NAME: return Phantom_Camera_Variables.tween_duration
	if property == PhantomCameraConstants.TWEEN_TRANSITION_PROPERTY_NAME: return Phantom_Camera_Variables.tween_transition
	if property == PhantomCameraConstants.TWEEN_EASE_PROPERTY_NAME: return Phantom_Camera_Variables.tween_ease


##############
# Private Functions
##############
func _enter_tree() -> void:
#	Phantom_Camera_Variables = PhantomCameraVariables.new()

	add_to_group(PhantomCameraConstants.PHANTOM_CAMERA_GROUP_NAME)

	Phantom_Camera_Variables.camera_host_group = get_tree().get_nodes_in_group(PhantomCameraConstants.PHANTOM_CAMERA_HOST_GROUP_NAME)

	if Phantom_Camera_Variables.camera_host_group.size() > 0:
		if Phantom_Camera_Variables.camera_host_group.size() == 1:
			phantom_camera_host_owner = Phantom_Camera_Variables.camera_host_group[0]
			phantom_camera_host_owner.phantom_camera_added_to_scene(self)
			pass
		else:
			for camera_host in Phantom_Camera_Variables.camera_host_group:
				print("Multiple PhantomCameraBases in scene")
	else:
		print("No camera base added")

	phantom_camera_host_owner.phantom_camera_added_to_scene(self)

	if _look_at_target_path:
		look_at_target_node = get_node(_look_at_target_path)

	if Phantom_Camera_Variables.follow_target_path:
		Phantom_Camera_Variables.follow_target_node = get_node(Phantom_Camera_Variables.follow_target_path)


func _exit_tree() -> void:
	if phantom_camera_host_owner:
		phantom_camera_host_owner.phantom_camera_removed_from_scene(self)
		print("phantom_camera leaving tree")


func _physics_process(delta: float) -> void:
	if Phantom_Camera_Variables.follow_target_node:

#		if camera_smoothing == 0:
		set_position(
			Phantom_Camera_Variables.follow_target_node.position + follow_target_offset
		)
#		else:
#			# TODO - Change camera_smoothing value to something more sensible in the editor
#			set_position(
#				position.lerp(
#					follow_target_node.position + _follow_target_offset,
#					delta / camera_smoothing * 10
#				)
#			)
	if look_at_target_node:
		look_at(look_at_target_node.position)

##################
# Public Functions
##################
func set_priority(value: int) -> void:
	if value < 1:
		Phantom_Camera_Variables.priority = 1
	else:
		Phantom_Camera_Variables.priority = value

	if phantom_camera_host_owner:
		phantom_camera_host_owner.phantom_camera_priority_updated(self)
	else:
#			TODO - Add logic to handle Phantom Camera Host in scene
		pass

func get_priority() -> int:
	return Phantom_Camera_Variables.priority

func get_tween_duration() -> float:
	return Phantom_Camera_Variables.tween_duration

func get_tween_transition() -> int:
	return Phantom_Camera_Variables.tween_transition
