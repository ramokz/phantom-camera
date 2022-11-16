@tool
#extends "res://addons/phantom_camera/scripts/phantom_camera.gd"
extends Node3D
class_name PhantomCamera3D

@icon("res://addons/phantom_camera/icons/PhantomCameraIcon.svg")


var _if_pcam_3D: bool = true
var _if_pcam_2D: bool

##################
# Follow Variables
##################
var follow_target_node: Node
var _follow_target_path: NodePath
var has_follow_target: bool = false
var _follow_target_offset: Vector3 = Vector3(0, 0, 3)

###################
# Look At Variables
###################
var look_at_target_node: Node
var _look_at_target_path: NodePath
var has_look_at_target: bool = false
var look_at_target_offset: Vector2 = Vector2(0, 0)

#################
# Tween Variables
#################
var transition_easing: Tween.EaseType


@export var transition_duration: float = 1:
	set(value):
		if value < 0:
			value = 0
		transition_duration = value

@export_range(0, 100, 1, "or_greater") var camera_smoothing: float = 0
#@export_range(0, 1000, 0.001, "or_greater") var transition_duration: float = 0
@export_range(1, 100, 1, "or_greater") var priority: int = 1:
	set(value):
		priority = value
		PhantomCameraManager.pcam_priority_updated(self)


func _get_property_list() -> Array:
	var ret: Array

#	ret.append({
#		"name": "Transition Duration",
#		"type": TYPE_INT,
#		"hint": PROPERTY_HINT_ENUM,
#		"hint_string": PoolString,
#		"usage": PROPERTY_USAGE_DEFAULT
#	})

#	ret.append({
#		"name": "Transition Duration",
#		"type": TYPE_FLOAT,
#		"hint": PROPERTY_HINT_RANGE,
#		"hint_string": "0, 100, 0.001, or_greater",
#		"usage": PROPERTY_USAGE_DEFAULT
#	})
#
#	ret.append({
#		"name": "Properties",
#		"type": TYPE_NIL,
#		"hint": "Outline_",
#		"usage": PROPERTY_USAGE_GROUP
#	})

	if _if_pcam_2D:
		ret.append({
			"name": "Follow Target 2D",
			"type": TYPE_VECTOR2,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	if _if_pcam_3D:
		ret.append({
			"name": "Follow Target",
			"type": TYPE_NODE_PATH,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

		if has_follow_target:
			ret.append({
				"name": "Follow Parameters/Follow Target Offset",
				"type": TYPE_VECTOR3,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT
			})

		ret.append({
			"name": "Look At Target",
			"type": TYPE_NODE_PATH,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

		if has_look_at_target:
			ret.append({
				"name": "Look At Parameters/Look At Target Offset",
				"type": TYPE_VECTOR2,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT
			})

	return ret


func _set(property: StringName, value) -> bool:
	if property == "Transition Duration":
		transition_duration = value

	if property == "Follow Target":
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

	if property == "Look At Target":
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

	if property == "Follow Parameters/Follow Target Offset":
		if value == Vector3.ZERO:
			printerr("Follow Offset cannot be 0,0,0, resetting to 0,0,1")
			_follow_target_offset = Vector3(0,0,1)
		else:
			_follow_target_offset = value

	if property == "Look At Parameters/Look At Target Offset":
		look_at_target_offset = value


	return false


func _get(property: StringName):
	if property == "Transition Duration": return transition_duration

	if property == "Follow Target": return _follow_target_path
	if property == "Follow Parameters/Follow Target Offset": return _follow_target_offset

	if property == "Look At Target": return _look_at_target_path
	if property == "Look At Parameters/Look At Target Offset": return look_at_target_offset


func _enter_tree() -> void:
	PhantomCameraManager.phantom_camera_added_to_scene(self)

	if _look_at_target_path:
		look_at_target_node = get_node(_look_at_target_path)

	if _follow_target_path:
		follow_target_node = get_node(_follow_target_path)
#		set_position(follow_target_node.position)

func _exit_tree() -> void:
	PhantomCameraManager.phantom_camera_removed_from_scene(self)


func _process(delta: float) -> void:
#	 TODO - Should only follow if currently active camera
#	print(follow_target_node)
#	print(_follow_target_offset)
	if follow_target_node:

		if camera_smoothing == 0:
			set_position(
				follow_target_node.position + _follow_target_offset
			)
		else:
			# TODO - Change camera_smoothing value to something more sensible in the editor
			set_position(
				position.lerp(
					follow_target_node.position + _follow_target_offset,
					delta / camera_smoothing * 10
				)
			)
