@tool
extends RefCounted

const Constants: Script = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
const PcamGroupNames: Script = preload("res://addons/phantom_camera/scripts/group_names.gd")

var is_3D: bool

var pcam_host_owner: PhantomCameraHost
var scene_has_multiple_pcam_hosts: bool
var pcam_host_group: Array[Node]

var priority: int = 0

var trigger_onload: bool = true

var follow_target_node: Node
var follow_target_path: NodePath
var follow_has_target: bool = false

var follow_mode: Constants.FollowMode = Constants.FollowMode.NONE
var follow_target_offset_2D: Vector2
var follow_target_offset_3D: Vector3
var follow_has_damping: bool
var follow_damping_value: float = 10

var tween_transition: Tween.TransitionType
var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT
var tween_linear: bool
var tween_duration: float = 1


func camera_enter_tree(pcam: Node):
	pcam.add_to_group(PcamGroupNames.PCAM_GROUP_NAME)
	if pcam.Properties.follow_target_path:
		pcam.Properties.follow_target_node = pcam.get_node(pcam.Properties.follow_target_path)


func add_multiple_hosts_properties() -> Array:
	var _property_list: Array

	if scene_has_multiple_pcam_hosts:
		_property_list.append({
			"name": Constants.PCAM_HOST,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(PackedStringArray(pcam_host_group)),
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


func add_trigger_onload_properties() -> Array:
	var _property_list: Array

	_property_list.append({
		"name": Constants.TRIGGER_ONLOAD_NAME,
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	return _property_list


func add_follow_target_property() -> Array:
	var _property_list: Array

	_property_list.append({
		"name": Constants.FOLLOW_TARGET_PROPERTY_NAME,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	return _property_list


func add_follow_mode_property() -> Array:
	var _property_list: Array

	if follow_has_target:
		_property_list.append({
			"name": Constants.FOLLOW_MODE_PROPERTY_NAME,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ", ".join(PackedStringArray(Constants.FollowMode.keys())).capitalize(),
			"usage": PROPERTY_USAGE_DEFAULT,
		})

	return _property_list


func add_follow_properties() -> Array:
	var _property_list: Array

	if follow_has_target:
		if follow_mode != Constants.FollowMode.NONE:
			if follow_mode != Constants.FollowMode.GLUED_FOLLOW:
				if is_3D:
					_property_list.append({
						"name": Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME,
						"type": TYPE_VECTOR3,
						"hint": PROPERTY_HINT_NONE,
						"usage": PROPERTY_USAGE_DEFAULT,
					})
				else:
					_property_list.append({
						"name": Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME,
						"type": TYPE_VECTOR2,
						"hint": PROPERTY_HINT_NONE,
						"usage": PROPERTY_USAGE_DEFAULT,
					})

			_property_list.append({
				"name": Constants.FOLLOW_DAMPING_NAME,
				"type": TYPE_BOOL,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
			})

			if follow_has_damping:
				_property_list.append({
					"name": Constants.FOLLOW_DAMPING_VALUE_NAME,
					"type": TYPE_FLOAT,
					"hint": PROPERTY_HINT_RANGE,
					"hint_string": "0.01, 100, 0.01,",
					"usage": PROPERTY_USAGE_DEFAULT,
				})

	return _property_list


func add_tween_properties() -> Array:
	var _property_list: Array

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
		"hint_string": ", ".join(PackedStringArray(Constants.TweenTransitions.keys())).capitalize(),
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	if not tween_linear:
		_property_list.append({
			"name": Constants.TWEEN_EASE_PROPERTY_NAME,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ", ".join(PackedStringArray(Constants.TweenEases.keys())).capitalize(),
			"usage": PROPERTY_USAGE_DEFAULT,
		})

	return _property_list


func set_phantom_host_property(property: StringName, value, pcam: Node):
	if property == Constants.PCAM_HOST:
		if value != null && value is int:
			var host_node = instance_from_id(value)
			pcam_host_owner = host_node


func set_priority_property(property: StringName, value, pcam: Node):
	if property == Constants.PRIORITY_PROPERTY_NAME:
		set_priority(value, pcam)


func set_trigger_onload_properties(property: StringName, value, pcam: Node):
	if property == Constants.TRIGGER_ONLOAD_NAME:
		trigger_onload = value


func set_follow_properties(property: StringName, value, pcam: Node):
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME:
		follow_target_path = value
		var valueNodePath: NodePath = value as NodePath
		if not valueNodePath.is_empty():
			follow_has_target = true
			if pcam.has_node(follow_target_path):
				follow_target_node = pcam.get_node(follow_target_path)
		else:
			follow_has_target = false
			follow_target_node = null
		pcam.notify_property_list_changed()

	if property == Constants.FOLLOW_MODE_PROPERTY_NAME:
		follow_mode = value
		pcam.notify_property_list_changed()

		match value:
			Constants.FollowMode.NONE:
				set_process(pcam, false)
			_:
				set_process(pcam, true)

	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME:
		if value is Vector3:
			follow_target_offset_3D = value
		else:
			follow_target_offset_2D = value

	if property == Constants.FOLLOW_DAMPING_NAME:
		follow_has_damping = value
		pcam.notify_property_list_changed()

	if property == Constants.FOLLOW_DAMPING_VALUE_NAME:
		follow_damping_value = value


func set_tween_properties(property: StringName, value, pcam: Node):
	if property == Constants.TWEEN_DURATION_PROPERTY_NAME:
		tween_duration = value
	if property == Constants.TWEEN_TRANSITION_PROPERTY_NAME:
		tween_linear = false
		match value:
			Tween.TRANS_LINEAR:
				tween_transition = Tween.TRANS_LINEAR
				tween_linear = true # Disables Easing property as it has no effect on Linear transitions
			Tween.TRANS_SINE: 		tween_transition = Tween.TRANS_SINE
			Tween.TRANS_QUINT: 		tween_transition = Tween.TRANS_QUINT
			Tween.TRANS_QUART: 		tween_transition = Tween.TRANS_QUART
			Tween.TRANS_QUAD: 		tween_transition = Tween.TRANS_QUAD
			Tween.TRANS_EXPO: 		tween_transition = Tween.TRANS_EXPO
			Tween.TRANS_ELASTIC: 	tween_transition = Tween.TRANS_ELASTIC
			Tween.TRANS_CUBIC:		tween_transition = Tween.TRANS_CUBIC
			Tween.TRANS_CIRC:		tween_transition = Tween.TRANS_CIRC
			Tween.TRANS_BOUNCE: 	tween_transition = Tween.TRANS_BOUNCE
			Tween.TRANS_BACK: 		tween_transition = Tween.TRANS_BACK
			11:
				tween_transition = 11
		pcam.notify_property_list_changed()
	if property == Constants.TWEEN_EASE_PROPERTY_NAME:
		match value:
			Tween.EASE_IN: 			tween_ease = Tween.EASE_IN
			Tween.EASE_OUT: 		tween_ease = Tween.EASE_OUT
			Tween.EASE_IN_OUT: 		tween_ease = Tween.EASE_IN_OUT
			Tween.EASE_OUT_IN: 		tween_ease = Tween.EASE_OUT_IN


func set_priority(value: int, pcam: Node) -> void:
	if value < 0:
		printerr("Phantom Camera's priority cannot be less than 0")
		priority = 0
	else:
		priority = value

	if pcam_host_owner:
		pcam_host_owner.pcam_priority_updated(pcam)
#	else:
##		TODO - Add logic to handle Phantom Camera Host in scene
#		printerr("Trying to change priority without a Phantom Camera Host - Please attached one to a Camera3D")
#		pass


func assign_pcam_host(pcam: Node) -> void:
	pcam_host_group = pcam.get_tree().get_nodes_in_group(PcamGroupNames.PCAM_HOST_GROUP_NAME)

	if pcam_host_group.size() == 1:
		pcam_host_owner = pcam.Properties.pcam_host_group[0]
		pcam_host_owner.pcam_added_to_scene(pcam)
#	else:
#		for camera_host in camera_host_group:
#			print("Multiple PhantomCameraBases in scene")
#			print(pcam_host_group)
#			print(pcam.get_tree().get_nodes_in_group(PhantomCameraGroupNames.PHANTOM_CAMERA_HOST_GROUP_NAME))
#			multiple_pcam_host_group.append(camera_host)
#			return null


func assign_specific_pcam_host(pcam: Node, pcam_host: PhantomCameraHost) -> void:
	pcam_host = pcam


func check_multiple_pcam_host_property(pcam: Node, multiple_host: bool = false) -> void:
	if not multiple_host:
		scene_has_multiple_pcam_hosts = false
	else:
		scene_has_multiple_pcam_hosts = true

	pcam.notify_property_list_changed()
#	pcam_host_group.append_array(host_group)

func set_process(pcam: Node, enabled: bool) -> void:
	pcam.set_process(enabled)
	pcam.set_physics_process(enabled)

# NOTE - Throws an error at the minute, need to find a reusable solution
#func get_properties(property: StringName):
#	# General - Properties
#	if property == PhantomCameraConstants.PRIORITY_PROPERTY_NAME: return priority
#
#	# Follow - Properties
#	if property == PhantomCameraConstants.FOLLOW_TARGET_PROPERTY_NAME: return follow_target_path
#	if property == PhantomCameraConstants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: return follow_target_offset
#
#	# Tween - Properties
#	if property == PhantomCameraConstants.TWEEN_DURATION_PROPERTY_NAME: return tween_duration
#	if property == PhantomCameraConstants.TWEEN_TRANSITION_PROPERTY_NAME: return tween_transition
#	if property == PhantomCameraConstants.TWEEN_EASE_PROPERTY_NAME: return tween_ease
