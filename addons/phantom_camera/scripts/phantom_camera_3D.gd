@tool
class_name PhantomCamera3D
extends Node3D
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg")

#####################
# General - Variables
#####################
var _priority_property_name: StringName = "Priority"
var priority: int = 1
const PHANTOM_CAMERA_GROUP_NAME: StringName = "phantom_camera_group"
const PHANTOM_CAMERA_BASE_GROUP_NAME: StringName = "phantom_camera_base_group"

##############
# Phantom base
##############
var camera_base_group: Array
var phantom_camera_base_owner: PhantomCameraBase
var scene_has_multiple_phantom_camera_bases: bool

##################
# Follow - Variables
##################
var _follow_target_property_name: StringName = "Follow Target"
var follow_target_node: Node
var _follow_target_path: NodePath
var has_follow_target: bool = false

var _follow_target_offset_property_name: StringName = "Follow Parameters/Follow Target Offset"
var follow_target_offset: Vector3 = Vector3(0, 0, 3)

###################
# Look At - Variables
###################
var _look_at_target_property_name: StringName = "Look At Target"
var look_at_target_node: Node
var _look_at_target_path: NodePath
var has_look_at_target: bool = false

var _look_at_target_offset_property_name: StringName = "Look At Parameters/Look At Target Offset"
var look_at_target_offset: Vector3

#################
# Tween - Variables
#################
var _tween_transition_property_name: StringName = "Tween Properties / Transition"
var tween_transition: Tween.TransitionType
enum TweenTransitions {
	TRANS_LINEAR = 0,
	TRANS_SINE = 1,
	TRANS_QUINT = 2,
	TRANS_QUART = 3,
	TRANS_QUAD = 4,
	TRANS_EXPO = 5,
	TRANS_ELASTIC = 6,
	TRANS_CUBIC = 7,
	TRANS_CIRC = 8,
	TRANS_BOUNCE = 9,
	TRANS_BACK = 10,
}


var _tween_ease_property_name: StringName = "Tween Properties / Ease"
var tween_ease: Tween.EaseType
enum TweenEases {
	EASE_IN = 0,
	EASE_OUT = 1,
	EASE_IN_OUT = 2,
	EASE_OUT_IN = 3,
}

var _tween_duration_property_name: StringName = "Tween Properties / Duration"
var tween_duration: float = 1

#	TODO - Camera Smoothing
#@export_range(0, 100, 1, "or_greater") var camera_smoothing: float = 0

############
# Properties
############
func _get_property_list() -> Array:
	var ret: Array

	######################
	# General - Properties
	######################
	ret.append({
		"name": _priority_property_name,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	#####################
	# Follow - Properties
	#####################
	ret.append({
		"name": _follow_target_property_name,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	if has_follow_target:
		ret.append({
			"name": _follow_target_offset_property_name,
			"type": TYPE_VECTOR3,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	######################
	# Look At - Properties
	######################
	ret.append({
		"name": _look_at_target_property_name,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	if has_look_at_target:
		ret.append({
			"name": _look_at_target_offset_property_name,
			"type": TYPE_VECTOR3,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	####################
	# Tween - Properties
	####################
	ret.append({
		"name": _tween_duration_property_name,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	ret.append({
		"name": _tween_transition_property_name,
		"type": TYPE_NIL,
		"hint_string": "Transition_",
		"usage": PROPERTY_USAGE_GROUP
	})

	ret.append({
		"name": _tween_transition_property_name,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(PackedStringArray(TweenTransitions.keys())),
		"usage": PROPERTY_USAGE_DEFAULT
	})

	ret.append({
		"name": _tween_ease_property_name,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(PackedStringArray(TweenEases.keys())),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	return ret


func _set(property: StringName, value) -> bool:
	######################
	# General - Properties
	######################
	if property == _priority_property_name:
		if value < 1:
			priority = 1
		else:
			priority = value

		if phantom_camera_base_owner:
			phantom_camera_base_owner.phantom_camera_priority_updated(self)
		else:
#			Has no Phantom Camera Base
			pass

	#####################
	# Follow - Properties
	#####################
	if property == _follow_target_property_name:
		_follow_target_path = value
		var valueNodePath: NodePath = value as NodePath
		if not valueNodePath.is_empty():
			has_follow_target = true
			if has_node(_follow_target_path):
				follow_target_node = get_node(_follow_target_path)
		else:
			has_follow_target = false
			follow_target_node = null

		notify_property_list_changed()
	if property == _follow_target_offset_property_name:
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
	if property == _tween_duration_property_name:
		tween_duration = value
	if property == _tween_transition_property_name:
		match value:
			Tween.TRANS_LINEAR: 	tween_transition = Tween.TRANS_LINEAR
			Tween.TRANS_BACK: 		tween_transition = Tween.TRANS_BACK
			Tween.TRANS_QUINT: 		tween_transition = Tween.TRANS_QUINT
			Tween.TRANS_QUART: 		tween_transition = Tween.TRANS_QUART
			Tween.TRANS_QUAD: 		tween_transition = Tween.TRANS_QUAD
			Tween.TRANS_EXPO: 		tween_transition = Tween.TRANS_EXPO
			Tween.TRANS_ELASTIC: 	tween_transition = Tween.TRANS_ELASTIC
			Tween.TRANS_CUBIC:		tween_transition = Tween.TRANS_CUBIC
			Tween.TRANS_BOUNCE: 	tween_transition = Tween.TRANS_BOUNCE
			Tween.TRANS_BACK: 		tween_transition = Tween.TRANS_BACK
	if property == _tween_ease_property_name:
		match value:
			Tween.EASE_IN: 			tween_ease = Tween.EASE_IN
			Tween.EASE_OUT: 		tween_ease = Tween.EASE_OUT
			Tween.EASE_IN_OUT: 		tween_ease = Tween.EASE_IN_OUT
			Tween.EASE_OUT_IN: 		tween_ease = Tween.EASE_OUT_IN
	return false


func _get(property: StringName):
	######################
	# General - Properties
	######################
	if property == _priority_property_name: return priority

	#####################
	# Follow - Properties
	#####################
	if property == _follow_target_property_name: return _follow_target_path
	if property == _follow_target_offset_property_name: return follow_target_offset

	######################
	# Look At - Properties
	######################
	if property == _look_at_target_property_name: return _look_at_target_path
	if property == _look_at_target_offset_property_name: return look_at_target_offset

	####################
	# Tween - Properties
	####################
	if property == _tween_duration_property_name: return tween_duration
	if property == _tween_transition_property_name: return tween_transition
	if property == _tween_ease_property_name: return tween_ease


##############
# Initializers
##############
func _enter_tree() -> void:
	add_to_group("phantom_camera_group")

	camera_base_group = get_tree().get_nodes_in_group(PHANTOM_CAMERA_BASE_GROUP_NAME)

	if camera_base_group.size() > 0:
		if camera_base_group.size() == 1:
			phantom_camera_base_owner = camera_base_group[0]
			phantom_camera_base_owner.phantom_camera_added_to_scene(self)
			pass
		else:
			for camera_base in camera_base_group:
				print("Multiple PhantomCameraBases in scene")
	else:
		print("No camera base added")

	phantom_camera_base_owner.phantom_camera_added_to_scene(self)

	if _look_at_target_path:
		look_at_target_node = get_node(_look_at_target_path)

	if _follow_target_path:
		follow_target_node = get_node(_follow_target_path)
#		set_position(follow_target_node.position)

func _exit_tree() -> void:
	phantom_camera_base_owner.phantom_camera_removed_from_scene(self)
	print("phantom_camera leaving tree")


###########
# Functions
###########
func _physics_process(delta: float) -> void:
	if follow_target_node:

#		if camera_smoothing == 0:
			set_position(
				follow_target_node.position + follow_target_offset
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
