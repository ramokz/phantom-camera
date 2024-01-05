@tool
extends RefCounted

#region Constants

const Constants: Script = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
const PcamGroupNames: Script = preload("res://addons/phantom_camera/scripts/group_names.gd")

#endregion


#region Signals

signal dead_zone_changed

#endregion


#region Variables

var is_2D: bool

var pcam_host_owner: PhantomCameraHost
var scene_has_multiple_pcam_hosts: bool
var pcam_host_group: Array[Node]

var is_active: bool

var priority_override: bool
var priority: int = 0

var tween_onload: bool = true
var has_tweened: bool

var should_follow: bool
var has_follow_group: bool
var follow_target_node: Node
var follow_target_path: NodePath
var follow_has_target: bool
var follow_has_path_target: bool
var follow_path_node: Node
var follow_path_path: NodePath
var follow_mode: Constants.FollowMode = Constants.FollowMode.NONE
var follow_target_offset_2D: Vector2
var follow_target_offset_3D: Vector3
var follow_has_damping: bool
var follow_damping_value: float = 10

var follow_group_nodes_2D: Array[Node2D]
var follow_group_nodes_3D: Array[Node3D]
var follow_group_paths: Array[NodePath]

var follow_framed_dead_zone_width: float
var follow_framed_dead_zone_height: float
var follow_framed_initial_set: bool
var show_viewfinder_in_play: bool
var viewport_position: Vector2

var tween_resource: PhantomCameraTween
var tween_resource_default: PhantomCameraTween = PhantomCameraTween.new()

var inactive_update_mode: Constants.InactiveUpdateMode = Constants.InactiveUpdateMode.ALWAYS

#endregion


#region _property_list

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
		"name": Constants.PRIORITY_OVERRIDE,
		"type": TYPE_BOOL,
	})

	_property_list.append({
		"name": Constants.PRIORITY_PROPERTY_NAME,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	return _property_list


func add_follow_mode_property() -> Array:
	var _property_list: Array

	var follow_mode_keys: Array = Constants.FollowMode.keys()
	if is_2D:
		follow_mode_keys.remove_at(Constants.FollowMode.THIRD_PERSON)

	_property_list.append({
		"name": Constants.FOLLOW_MODE_PROPERTY_NAME,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ", ".join(PackedStringArray(follow_mode_keys)).capitalize(),
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	return _property_list


func add_follow_target_property() -> Array:
	var _property_list: Array

	if follow_mode == Constants.FollowMode.GROUP:
		_property_list.append({
			"name": Constants.FOLLOW_GROUP_PROPERTY_NAME,
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_TYPE_STRING,
			"hint_string": TYPE_NODE_PATH,
			"usage": PROPERTY_USAGE_DEFAULT,
		})
	else:
		_property_list.append({
			"name": Constants.FOLLOW_TARGET_PROPERTY_NAME,
			"type": TYPE_NODE_PATH,
			"hint": PROPERTY_HINT_NODE_PATH_VALID_TYPES,
			"hint_string": "Node2D" + ',' + "Node3D",
			"usage": PROPERTY_USAGE_DEFAULT,
		})
		if follow_mode == Constants.FollowMode.PATH:
			_property_list.append({
				"name": Constants.FOLLOW_PATH_PROPERTY_NAME,
				"type": TYPE_NODE_PATH,
				"hint": PROPERTY_HINT_NODE_PATH_VALID_TYPES,
				"hint_string": "Path2D" + "," + "Path3D"
			})

	return _property_list


func add_follow_properties() -> Array:
	var _property_list: Array
	if follow_mode != Constants.FollowMode.NONE:
		if follow_mode == Constants.FollowMode.SIMPLE or \
			follow_mode == Constants.FollowMode.GROUP or \
			follow_mode == Constants.FollowMode.FRAMED or \
			follow_mode == Constants.FollowMode.THIRD_PERSON:
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

	if follow_mode != Constants.FollowMode.NONE:
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


func add_follow_framed() -> Array:
	var _property_list: Array

	if follow_mode == Constants.FollowMode.FRAMED:
		_property_list.append({
			"name": Constants.FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME,
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0, 1, 0.01,",
			"usage": PROPERTY_USAGE_DEFAULT,
		})
		_property_list.append({
			"name": Constants.FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME,
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0, 1, 0.01,",
			"usage": PROPERTY_USAGE_DEFAULT,
		})

		_property_list.append({
			"name": Constants.FOLLOW_VIEWFINDER_IN_PLAY_NAME,
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	return _property_list


func add_tween_properties() -> Array:
	var _property_list: Array

	_property_list.append({
		"name": Constants.TWEEN_RESOURCE_PROPERTY_NAME,
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "PhantomCameraTween"
	})

	return _property_list


func add_secondary_properties() -> Array:
	var _property_list: Array

	_property_list.append({
		"name": Constants.TWEEN_ONLOAD_NAME,
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	_property_list.append({
		"name": Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ", ".join(PackedStringArray(Constants.InactiveUpdateMode.keys())).capitalize(),
	})

	return _property_list

#endregion


#region _set

func set_phantom_host_property(property: StringName, value, pcam: Node) -> void:
	if property == Constants.PCAM_HOST:
		if value != null && value is int:
			var host_node = instance_from_id(value)
			pcam_host_owner = host_node


func set_priority_property(property: StringName, value, pcam: Node) -> void:
	if Engine.is_editor_hint() and is_instance_valid(pcam_host_owner):
		if property == Constants.PRIORITY_OVERRIDE:
			if value == true:
				priority_override = value
				pcam_host_owner.pcam_priority_override(pcam)
			else:
				priority_override = value
				pcam_host_owner.pcam_priority_updated(pcam)
				pcam_host_owner.pcam_priority_override_disabled()

	if property == Constants.PRIORITY_PROPERTY_NAME:
		set_priority(value, pcam)


func set_follow_properties(property: StringName, value, pcam: Node) -> void:
	if property == Constants.FOLLOW_MODE_PROPERTY_NAME:
		follow_mode = value

		if follow_mode != Constants.FollowMode.GROUP:
			has_follow_group = false

			if follow_mode == Constants.FollowMode.FRAMED:
				follow_framed_initial_set = true

		pcam.notify_property_list_changed()

#		match value:
#			Constants.FollowMode.NONE:
#				set_process(pcam, false)
#			_:
#				set_process(pcam, true)

	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME:
		if follow_mode != Constants.FollowMode.NONE:
			should_follow = true
		else:
			should_follow = false

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

	if property == Constants.FOLLOW_PATH_PROPERTY_NAME:
		follow_path_path = value

		var valueNodePath: NodePath = value as NodePath
		if not valueNodePath.is_empty():
			follow_has_path_target = true
			if pcam.has_node(follow_path_path):
				follow_path_node = pcam.get_node(follow_path_path)
		else:
			follow_has_path_target = false
			follow_path_node = null
		pcam.notify_property_list_changed()

	if property == Constants.FOLLOW_GROUP_PROPERTY_NAME:
		if value and value.size() > 0:
			# Clears the Array in case of reshuffling or updated Nodes
			if is_2D:
				follow_group_nodes_2D.clear()
			else:
				follow_group_nodes_3D.clear()
			follow_group_paths = value as Array[NodePath]

			if not follow_group_paths.is_empty():
				for path in follow_group_paths:
					if pcam.has_node(path):
						should_follow = true
						has_follow_group = true
						var node: Node = pcam.get_node(path)
						if node is Node2D or node is Node3D:
							# Prevents duplicated nodes from being assigned to array
							if is_2D:
								if follow_group_nodes_2D.find(node):
									follow_group_nodes_2D.append(node)
							else:
								if follow_group_nodes_3D.find(node):
									follow_group_nodes_3D.append(node)
						else:
							printerr("Assigned non-Node3D to Follow Group")

		pcam.notify_property_list_changed()

	# Framed Follow
	if property == Constants.FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME:
		follow_framed_dead_zone_width = value
		dead_zone_changed.emit()
	if property == Constants.FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME:
		follow_framed_dead_zone_height = value
		dead_zone_changed.emit()
	if property == Constants.FOLLOW_VIEWFINDER_IN_PLAY_NAME:
		show_viewfinder_in_play = value

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


func set_tween_properties(property: StringName, value, pcam: Node) -> void:
	if property == Constants.TWEEN_RESOURCE_PROPERTY_NAME:
		tween_resource = value


func set_secondary_properties(property: StringName, value, pcam: Node) -> void:
	if property == Constants.TWEEN_ONLOAD_NAME:
		tween_onload = value

	if property == Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME:
		inactive_update_mode = value


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

#endregion


#region Public Functions

func camera_enter_tree(pcam: Node) -> void:
	pcam.add_to_group(PcamGroupNames.PCAM_GROUP_NAME)

	if pcam.Properties.follow_target_path and \
		not pcam.get_parent() is SpringArm3D and \
		is_instance_valid(pcam.get_node(pcam.Properties.follow_target_path)):

		pcam.Properties.follow_target_node = pcam.get_node(pcam.Properties.follow_target_path)
	elif follow_group_paths:
		if is_2D:
			follow_group_nodes_2D.clear()
		else:
			follow_group_nodes_3D.clear()

		for path in follow_group_paths:
			if not path.is_empty() and pcam.get_node(path):
				should_follow = true
				has_follow_group = true
				if is_2D:
					follow_group_nodes_2D.append(pcam.get_node(path))
				else:
					follow_group_nodes_3D.append(pcam.get_node(path))

	if pcam.Properties.follow_path_path:
		pcam.Properties.follow_path_node = pcam.get_node(pcam.Properties.follow_path_path)

func pcam_exit_tree(pcam: Node) -> void:
	pcam.remove_from_group(PcamGroupNames.PCAM_GROUP_NAME)


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


func toggle_priorty_override(pcam: Node) -> void:
	if pcam_host_owner:
		pcam_host_owner.pcam_priority_updated(pcam)


func assign_specific_pcam_host(pcam: Node, pcam_host: PhantomCameraHost) -> void:
	pcam_host = pcam


func check_multiple_pcam_host_property(pcam: Node, multiple_host: bool = false) -> void:
	if not multiple_host:
		scene_has_multiple_pcam_hosts = false
	else:
		scene_has_multiple_pcam_hosts = true

	pcam.notify_property_list_changed()
#	pcam_host_group.append_array(host_group)


func get_framed_side_offset() -> Vector2:
	var frame_out_bounds: Vector2

	if viewport_position.x < 0.5 - follow_framed_dead_zone_width / 2:
		# Is outside left edge
		frame_out_bounds.x = -1

	if viewport_position.y < 0.5 - follow_framed_dead_zone_height / 2:
		# Is outside top edge
		frame_out_bounds.y = 1

	if viewport_position.x > 0.5 + follow_framed_dead_zone_width / 2:
		# Is outside right edge
		frame_out_bounds.x = 1

	if viewport_position.y > 0.5001 + follow_framed_dead_zone_height / 2: # 0.501 to resolve an issue where the bottom vertical Dead Zone never becoming 0 when the Dead Zone Vertical parameter is set to 0
		# Is outside bottom edge
		frame_out_bounds.y = -1

	return frame_out_bounds

#endregion
