@tool
#extends "res://addons/phantom_camera/scripts/phantom_camera.gd"
extends Node3D
class_name PhantomCamera3D

@icon("res://addons/phantom_camera/icons/PhantomCameraIcon.svg")

var _follow_target_offset: Vector3 = Vector3(0, 0, 3)

var _if_phantom_camera_3D: bool = true
var _if_phantom_camera_2D: bool

var _has_follow_target: bool = false
var _follow_target_path: NodePath
var _follow_target_node: Node

var _look_at_target_node: Node
var _look_at_target_path: NodePath
var _has_look_at_target: bool = false

#func is_3D_phantom_camera() -> void:
#	_if_phantom_camera_3D = true
#	notify_property_list_changed()

func _get_property_list() -> Array:
	var ret: Array

	if _if_phantom_camera_2D:
		ret.append({
			"name": "Follow Target 2D",
			"type": TYPE_VECTOR2,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	if _if_phantom_camera_3D:
		ret.append({
			"name": "Follow Target 3D",
			"type": TYPE_NODE_PATH,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

		if _has_follow_target:
			ret.append({
				"name": "Follow Target Offset",
				"type": TYPE_VECTOR3,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT
			})

		ret.append({
			"name": "Look At Target 3D",
			"type": TYPE_NODE_PATH,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

		if _has_look_at_target:
			ret.append({
				"name": "Look At Target Offset 3D",
				"type": TYPE_VECTOR3,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT
			})

	return ret

func _set(property: StringName, value) -> bool:
	var retval: bool = true

	if property == "Follow Target 3D":
		_follow_target_path = value
		var valueNodePath: NodePath = value as NodePath
		if not valueNodePath.is_empty():
			_has_follow_target = true
			if has_node(_follow_target_path):
				_follow_target_node = get_node(_follow_target_path)
		else:
			_has_follow_target = false
			_follow_target_node = null

		notify_property_list_changed()

	if property == "Look At Target 3D":
		_look_at_target_path = value
		var valueNodePath: NodePath = value as NodePath
		if not valueNodePath.is_empty():
			_has_look_at_target = true
			if has_node(_look_at_target_path):
				_look_at_target_node = get_node(_look_at_target_path)
		else:
			_has_look_at_target = false
			_look_at_target_node = null

		notify_property_list_changed()


	if property == "Follow Target Offset":
		_follow_target_offset = value

	return false

func _get(property: StringName):
	if property == "Follow Target 3D": return _follow_target_path
	if property == "Look At Target 3D": return _look_at_target_path
	if property == "Follow Target Offset": return _follow_target_offset


#@export var look_at_target_path: NodePath:
#	set(value):
#		look_at_target_path = value
#
#		if value.is_empty():
#			look_at_target_node = null
#
#		if has_node(look_at_target_path):
#			look_at_target_node = get_node(look_at_target_path)
#
#@export var follow_target_path: NodePath:
#	set(value):
#		follow_target_path = value
#		print("Follow value is: ", value)
#
#		if value.is_empty():
#			print("Value cleared")
#			follow_target_node = null
#
#		if has_node(follow_target_path):
#			follow_target_node = get_node(follow_target_path)

#@export var is_camera_active: bool: set = set_active_camera
@export_range(0, 100, 1, "or_greater") var camera_smoothing: float = 0

@export_range(1, 100, 1, "or_greater") var priority: int = 1:
	set(value):
		priority = value
		PhantomCameraManager.pcam_priority_updated(self)

var _initial_position
var _follow_target_initial_position
var _set_initial_position: bool = false

#func _ready() -> void:
#	if look_at_target_path:
#		_look_at_target_node = get_node(look_at_target_path)
#
#	if follow_target_path:
#		_follow_target_node = get_node(follow_target_path)

func _enter_tree() -> void:
	PhantomCameraManager.phantom_camera_added_to_scene(self)


	if _look_at_target_path:
		_look_at_target_node = get_node(_look_at_target_path)

	if _follow_target_path:
		_follow_target_node = get_node(_follow_target_path)
#		set_position(_follow_target_node.position)

func _exit_tree() -> void:
	PhantomCameraManager.phantom_camera_removed_from_scene(self)
#	is_3D_phantom_camera()


func _process(delta: float) -> void:
#	 TODO - Should only follow if currently active camera
#	print(follow_target_node)
	if _follow_target_node:
		if camera_smoothing == 0:
			set_position(
				_follow_target_node.position + _follow_target_offset
			)
		else:
			# TODO - Change camera_smoothing value to something more sensible in the editor
			set_position(
				position.lerp(
					_follow_target_node.position + _follow_target_offset,
					delta / camera_smoothing * 10
				)
			)

#	if look_at_target_node:
#		self.look_at(look_at_target_node.position + look_offset)
