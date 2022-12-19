@tool
extends RefCounted

const Constants: Script = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
const PhantomCameraGroupNames: Script = preload("res://addons/phantom_camera/scripts/group_names.gd")

var phantom_camera_host_owner: PhantomCameraHost
var scene_has_multiple_phantom_camera_hosts: bool
var camera_host_group: Array[Node]

var priority: int = 0

var follow_target_node: Node
var follow_target_path: NodePath
var has_follow_target: bool = false

var follow_target_offset

###################
# Tween - Variables
###################
var tween_transition: Tween.TransitionType
var tween_linear: bool

var tween_ease: Tween.EaseType

var tween_duration: float = 1

var is_2D: bool


func enter_tree(phantom_camera: Node):
	phantom_camera.add_to_group(PhantomCameraGroupNames.PHANTOM_CAMERA_GROUP_NAME)
	if phantom_camera.Properties.follow_target_path:
		phantom_camera.Properties.follow_target_node = phantom_camera.get_node(phantom_camera.Properties.follow_target_path)


func add_multiple_hosts_properties() -> Array:
	var _property_list: Array

	if scene_has_multiple_phantom_camera_hosts:
		_property_list.append({
			"name": Constants.PHANTOM_CAMERA_HOST,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(PackedStringArray(camera_host_group)),
			"usage": PROPERTY_USAGE_DEFAULT,
		})

	return _property_list


func add_priority_properties() -> Array:
	var _property_list: Array

	_property_list.append({
		"name": Constants.PRIORITY_PROPERTY_NAME,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	return _property_list


func add_follow_properties() -> Array:
	var _property_list: Array

	_property_list.append({
		"name": Constants.FOLLOW_TARGET_PROPERTY_NAME,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	if has_follow_target:
		if is_2D:
			_property_list.append({
				"name": Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME,
				"type": TYPE_VECTOR2,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
			})
		else:
			_property_list.append({
				"name": Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME,
				"type": TYPE_VECTOR3,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
			})

	return _property_list


func add_tween_properties() -> Array:
	var _property_list: Array

	####################
	# Tween - Properties
	####################
	_property_list.append({
		"name": Constants.TWEEN_DURATION_PROPERTY_NAME,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	_property_list.append({
		"name": Constants.TWEEN_TRANSITION_PROPERTY_NAME,
		"type": TYPE_NIL,
		"hint_string": "Transition_",
		"usage": PROPERTY_USAGE_GROUP,
	})

	_property_list.append({
		"name": Constants.TWEEN_TRANSITION_PROPERTY_NAME,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(PackedStringArray(Constants.TweenTransitions.keys())),
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	if not tween_linear:
		_property_list.append({
			"name": Constants.TWEEN_EASE_PROPERTY_NAME,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(PackedStringArray(Constants.TweenEases.keys())),
			"usage": PROPERTY_USAGE_DEFAULT,
		})

	return _property_list


func set_phantom_host_property(property: StringName, value, phantom_camera: Node):
	if property == Constants.PHANTOM_CAMERA_HOST:
		if value != null && value is int:
			var host_node = instance_from_id(value)
			phantom_camera_host_owner = host_node


func set_priority_property(property: StringName, value, phantom_camera: Node):
	if property == Constants.PRIORITY_PROPERTY_NAME:
		set_priority(value, phantom_camera)


func set_follow_properties(property: StringName, value, phantom_camera: Node):
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME:
		follow_target_path = value
		var valueNodePath: NodePath = value as NodePath
		if not valueNodePath.is_empty():
			_reset_follow_target_offset()

			has_follow_target = true
			if phantom_camera.has_node(follow_target_path):
				follow_target_node = phantom_camera.get_node(follow_target_path)
		else:
			_reset_follow_target_offset()
			has_follow_target = false
			follow_target_node = null
		phantom_camera.notify_property_list_changed()

	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME:
		if value is Vector3:
			if value == Vector3.ZERO:
				printerr("Follow Offset cannot be 0,0,0, resetting to 0,0,1")
				follow_target_offset = Vector3(0,0,1)
			else:
				follow_target_offset = value
		elif value is Vector2:
			follow_target_offset = value


func _reset_follow_target_offset() -> void:
	if is_2D:
		follow_target_offset = Vector2.ZERO
	else:
		follow_target_offset = Vector3.ZERO


func set_tween_properties(property: StringName, value, phantom_camera):
	####################
	# Tween - Properties
	####################
	if property == Constants.TWEEN_DURATION_PROPERTY_NAME:
		tween_duration = value
	if property == Constants.TWEEN_TRANSITION_PROPERTY_NAME:
		tween_linear = false
		match value:
			Tween.TRANS_LINEAR:
				tween_transition = Tween.TRANS_LINEAR
				tween_linear = true # Disables Easing property as it has no effect on Linear transitions
			Tween.TRANS_BACK: 		tween_transition = Tween.TRANS_BACK
			Tween.TRANS_SINE: 		tween_transition = Tween.TRANS_SINE
			Tween.TRANS_QUINT: 		tween_transition = Tween.TRANS_QUINT
			Tween.TRANS_QUART: 		tween_transition = Tween.TRANS_QUART
			Tween.TRANS_QUAD: 		tween_transition = Tween.TRANS_QUAD
			Tween.TRANS_EXPO: 		tween_transition = Tween.TRANS_EXPO
			Tween.TRANS_ELASTIC: 	tween_transition = Tween.TRANS_ELASTIC
			Tween.TRANS_CUBIC:		tween_transition = Tween.TRANS_CUBIC
			Tween.TRANS_BOUNCE: 	tween_transition = Tween.TRANS_BOUNCE
			Tween.TRANS_BACK: 		tween_transition = Tween.TRANS_BACK
			11:
				tween_transition = 11
		phantom_camera.notify_property_list_changed()
	if property == Constants.TWEEN_EASE_PROPERTY_NAME:
		match value:
			Tween.EASE_IN: 			tween_ease = Tween.EASE_IN
			Tween.EASE_OUT: 		tween_ease = Tween.EASE_OUT
			Tween.EASE_IN_OUT: 		tween_ease = Tween.EASE_IN_OUT
			Tween.EASE_OUT_IN: 		tween_ease = Tween.EASE_OUT_IN


func set_priority(value: int, phantom_camera: Node) -> void:
	if value < 0:
		printerr("Phantom Camera's priority cannot be less than 0")
		priority = 0
	else:
		priority = value

	if phantom_camera_host_owner:
		phantom_camera_host_owner.phantom_camera_priority_updated(phantom_camera)
#	else:
##		TODO - Add logic to handle Phantom Camera Host in scene
#		printerr("Trying to change priority without a Phantom Camera Host - Please attached one to a Camera3D")
#		pass


func assign_phantom_camera_host(phantom_camera: Node) -> void:
	camera_host_group = phantom_camera.get_tree().get_nodes_in_group(PhantomCameraGroupNames.PHANTOM_CAMERA_HOST_GROUP_NAME)

	if camera_host_group.size() == 1:
		phantom_camera_host_owner = phantom_camera.Properties.camera_host_group[0]
		phantom_camera_host_owner.phantom_camera_added_to_scene(phantom_camera)
#	else:
#		for camera_host in camera_host_group:
#			print("Multiple PhantomCameraBases in scene")
#			print(phantom_camera_host_group)
#			print(phantom_camera.get_tree().get_nodes_in_group(PhantomCameraGroupNames.PHANTOM_CAMERA_HOST_GROUP_NAME))
#			multiple_phantom_camera_host_group.append(camera_host)
#			return null

func assign_specific_phantom_camera_host(phantom_camera: Node, phantom_camera_host: PhantomCameraHost) -> void:
	phantom_camera_host_owner = phantom_camera_host

func check_multiple_phantom_camera_host_property(phantom_camera: Node, multiple_host: bool = false) -> void:
	if not multiple_host:
		scene_has_multiple_phantom_camera_hosts = false
	else:
		scene_has_multiple_phantom_camera_hosts = true

	phantom_camera.notify_property_list_changed()
#	phantom_camera_host_group.append_array(host_group)


# NOTE - Throws an error at the minute, needs to find a reusable solution
#func get_properties(property: StringName):
#	######################
#	# General - Properties
#	######################
#	if property == PhantomCameraConstants.PRIORITY_PROPERTY_NAME: return priority
#
#	#####################
#	# Follow - Properties
#	#####################
#	if property == PhantomCameraConstants.FOLLOW_TARGET_PROPERTY_NAME: return follow_target_path
#	if property == PhantomCameraConstants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: return follow_target_offset
#
#	####################
#	# Tween - Properties
#	####################
#	if property == PhantomCameraConstants.TWEEN_DURATION_PROPERTY_NAME: return tween_duration
#	if property == PhantomCameraConstants.TWEEN_TRANSITION_PROPERTY_NAME: return tween_transition
#	if property == PhantomCameraConstants.TWEEN_EASE_PROPERTY_NAME: return tween_ease
