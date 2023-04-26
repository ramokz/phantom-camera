@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg")
class_name PhantomCamera3D
extends Node3D

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

const FOLLOW_DISTANCE_PROPERTY_NAME: 		StringName = Constants.FOLLOW_PARAMETERS_NAME + "distance"
const FOLLOW_GROUP_DISTANCE_AUTO_NAME: 		StringName = Constants.FOLLOW_PARAMETERS_NAME + "auto_distance"
const FOLLOW_GROUP_DISTANCE_AUTO_MIN_NAME: 	StringName = Constants.FOLLOW_PARAMETERS_NAME + "min_distance"
const FOLLOW_GROUP_DISTANCE_AUTO_MAX_NAME: 	StringName = Constants.FOLLOW_PARAMETERS_NAME + "max_distance"
const FOLLOW_GROUP_DISTANCE_AUTO_DIVISOR: 	StringName = Constants.FOLLOW_PARAMETERS_NAME + "auto_distance_divisor"

const LOOK_AT_TARGET_PROPERTY_NAME: 		StringName = "look_at_target"
const LOOK_AT_GROUP_PROPERTY_NAME: 			StringName = "look_at_group"
const LOOK_AT_PARAMETERS_NAME: 				StringName = "look_at_parameters/"
const LOOK_AT_MODE_PROPERTY_NAME: 			StringName = "look_at_mode"
const LOOK_AT_TARGET_OFFSET_PROPERTY_NAME: 	StringName = LOOK_AT_PARAMETERS_NAME + "look_at_target_offset"

var Properties: Object = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

var follow_distance: float = 1
var _follow_group_distance_auto: 			bool
var _follow_group_distance_auto_min: 		float = 1
var _follow_group_distance_auto_max: 		float = 5
var _follow_group_distance_auto_divisor:	float = 10


enum LookAtMode {
	NONE 	= 0,
	MIMIC 	= 1,
	SIMPLE 	= 2,
	GROUP	= 3,
}

var _look_at_target_node: Node3D
var _look_at_target_path: NodePath

var _look_at_group_nodes: Array[Node3D]
var _look_at_group_paths: Array[NodePath]

var _should_look_at: 			bool
var _has_look_at_target: 		bool
var _has_look_at_target_group: 	bool

var look_at_mode: LookAtMode = LookAtMode.NONE

var look_at_target_offset: Vector3


func _get_property_list() -> Array:
	var property_list: Array[Dictionary]

#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	property_list.append_array(Properties.add_multiple_hosts_properties())

	property_list.append_array(Properties.add_priority_properties())
	property_list.append_array(Properties.add_follow_mode_property())

	if Properties.follow_mode != Constants.FollowMode.NONE:
		property_list.append_array(Properties.add_follow_target_property())

		if Properties.follow_mode == Constants.FollowMode.GROUP:
			if not _follow_group_distance_auto:
				property_list.append({
					"name": FOLLOW_DISTANCE_PROPERTY_NAME,
					"type": TYPE_FLOAT,
					"hint": PROPERTY_HINT_NONE,
					"usage": PROPERTY_USAGE_DEFAULT,
				})

			if Properties.follow_mode == Constants.FollowMode.GROUP:
				property_list.append({
					"name": FOLLOW_GROUP_DISTANCE_AUTO_NAME,
					"type": TYPE_BOOL,
					"hint": PROPERTY_HINT_NONE,
					"usage": PROPERTY_USAGE_DEFAULT,
				})

				if _follow_group_distance_auto:
					property_list.append({
						"name": FOLLOW_GROUP_DISTANCE_AUTO_MIN_NAME,
						"type": TYPE_FLOAT,
						"hint": PROPERTY_HINT_NONE,
						"usage": PROPERTY_USAGE_DEFAULT,
					})

					property_list.append({
						"name": FOLLOW_GROUP_DISTANCE_AUTO_MAX_NAME,
						"type": TYPE_FLOAT,
						"hint": PROPERTY_HINT_NONE,
						"usage": PROPERTY_USAGE_DEFAULT,
					})

					property_list.append({
						"name": FOLLOW_GROUP_DISTANCE_AUTO_DIVISOR,
						"type": TYPE_FLOAT,
						"hint": PROPERTY_HINT_RANGE,
						"hint_string": "0.01, 100, 0.01,",
						"usage": PROPERTY_USAGE_DEFAULT,
					})

	if Properties.follow_has_target || Properties.has_follow_group:
		property_list.append_array(Properties.add_follow_properties())

	property_list.append({
		"name": LOOK_AT_MODE_PROPERTY_NAME,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ", ".join(PackedStringArray(LookAtMode.keys())).capitalize(),
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	if look_at_mode != LookAtMode.NONE:
		if look_at_mode == LookAtMode.GROUP:
			property_list.append({
				"name": LOOK_AT_GROUP_PROPERTY_NAME,
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_TYPE_STRING,
				"hint_string": TYPE_NODE_PATH,
				"usage": PROPERTY_USAGE_DEFAULT,
			})
		else:
			property_list.append({
				"name": LOOK_AT_TARGET_PROPERTY_NAME,
				"type": TYPE_NODE_PATH,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
			})
		if _should_look_at:
			if look_at_mode == LookAtMode.SIMPLE:
				property_list.append({
					"name": LOOK_AT_TARGET_OFFSET_PROPERTY_NAME,
					"type": TYPE_VECTOR3,
					"hint": PROPERTY_HINT_NONE,
					"usage": PROPERTY_USAGE_DEFAULT,
				})

	property_list.append_array(Properties.add_tween_properties())
	property_list.append_array(Properties.add_secondary_properties())

	return property_list


func _set(property: StringName, value) -> bool:
#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	Properties.set_phantom_host_property(property, value, self)

	Properties.set_priority_property(property, value, self)

	Properties.set_follow_properties(property, value, self)
	if property == FOLLOW_DISTANCE_PROPERTY_NAME:
		if value == 0:
			follow_distance = 0.001
		else:
			follow_distance = value

	if property == FOLLOW_GROUP_DISTANCE_AUTO_NAME:
		_follow_group_distance_auto = value
		notify_property_list_changed()

	if property == FOLLOW_GROUP_DISTANCE_AUTO_MIN_NAME:
		_follow_group_distance_auto_min = value

	if property == FOLLOW_GROUP_DISTANCE_AUTO_MAX_NAME:
		_follow_group_distance_auto_max = value

	if property == FOLLOW_GROUP_DISTANCE_AUTO_DIVISOR:
		_follow_group_distance_auto_divisor = value


	# Look At Properties
	if property == LOOK_AT_MODE_PROPERTY_NAME:
		look_at_mode = value

		if look_at_mode == LookAtMode.NONE:
			_should_look_at = false
#			Properties.set_process(self, false)
		else:
			_should_look_at = true
#			Properties.set_process(self, true)

		notify_property_list_changed()

	if property == LOOK_AT_GROUP_PROPERTY_NAME:
		if value.size() > 0:
			_look_at_group_nodes.clear()

			_look_at_group_paths = value as Array[NodePath]

			if not _look_at_group_paths.is_empty():
				for path in _look_at_group_paths:
					if has_node(path):
						_should_look_at = true
						_has_look_at_target_group = true
						var node: Node = get_node(path)
						if node is Node3D:
							# Prevents duplicated nodes from being assigned to array
							if _look_at_group_nodes.find(node):
								_look_at_group_nodes.append(node)
						else:
							printerr("Assigned non-Node3D to Look At Group")

		notify_property_list_changed()

	if property == LOOK_AT_TARGET_PROPERTY_NAME:
		_look_at_target_path = value
		var value_node_path: NodePath = value as NodePath
		if not value_node_path.is_empty():
			_should_look_at = true
			_has_look_at_target = true
			if has_node(_look_at_target_path):
				set_rotation(Vector3(0,0,0))
				_look_at_target_node = get_node(_look_at_target_path)
		else:
			_should_look_at = false
			_has_look_at_target = false
			_look_at_target_node = null

		notify_property_list_changed()

	if property == LOOK_AT_TARGET_OFFSET_PROPERTY_NAME:
		look_at_target_offset = value

	Properties.set_tween_properties(property, value, self)
	Properties.set_secondary_properties(property, value, self)

	return false


func _get(property: StringName):
#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	if property == Constants.PHANTOM_CAMERA_HOST: return Properties.pcam_host_owner.name

	if property == Constants.PRIORITY_PROPERTY_NAME: 				return Properties.priority

	if property == Constants.FOLLOW_MODE_PROPERTY_NAME: 			return Properties.follow_mode
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME: 			return Properties.follow_target_path
	if property == Constants.FOLLOW_GROUP_PROPERTY_NAME: 			return Properties.follow_group_paths
	if property == Constants.FOLLOW_PATH_PROPERTY_NAME: 			return Properties.follow_path_path
	if property == FOLLOW_DISTANCE_PROPERTY_NAME:				 	return follow_distance
	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME	: 	return Properties.follow_target_offset_3D
	if property == FOLLOW_GROUP_DISTANCE_AUTO_NAME:					return _follow_group_distance_auto
	if property == FOLLOW_GROUP_DISTANCE_AUTO_MIN_NAME:				return _follow_group_distance_auto_min
	if property == FOLLOW_GROUP_DISTANCE_AUTO_MAX_NAME:				return _follow_group_distance_auto_max
	if property == FOLLOW_GROUP_DISTANCE_AUTO_DIVISOR:				return _follow_group_distance_auto_divisor
	if property == Constants.FOLLOW_DAMPING_NAME: 					return Properties.follow_has_damping
	if property == Constants.FOLLOW_DAMPING_VALUE_NAME: 			return Properties.follow_damping_value

	if property == LOOK_AT_TARGET_PROPERTY_NAME: 					return _look_at_target_path
	if property == LOOK_AT_MODE_PROPERTY_NAME: 						return look_at_mode
	if property == LOOK_AT_TARGET_OFFSET_PROPERTY_NAME: 			return look_at_target_offset
	if property == LOOK_AT_GROUP_PROPERTY_NAME:						return _look_at_group_paths

	if property == Constants.TWEEN_RESOURCE_PROPERTY_NAME: 			return Properties.tween_resource

	if property == Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME:		return Properties.inactive_update_mode
	if property == Constants.TWEEN_ONLOAD_NAME: 						return Properties.tween_onload


###################
# Private Functions
###################
func _enter_tree() -> void:
	Properties.is_3D = true;
	Properties.camera_enter_tree(self)
	Properties.assign_pcam_host(self)

	if _look_at_target_path:
		_look_at_target_node = get_node(_look_at_target_path)
	elif _look_at_group_paths:
		_look_at_group_nodes.clear()
		for path in _look_at_group_paths:
			if not path.is_empty() and get_node(path):
				_should_look_at = true
				_has_look_at_target_group = true
				_look_at_group_nodes.append(get_node(path))


func _exit_tree() -> void:
	if Properties.pcam_host_owner:
		Properties.pcam_host_owner.pcam_removed_from_scene(self)
	
	Properties.pcam_exit_tree(self)


func _physics_process(delta: float) -> void:
	if not Properties.is_active:
		match Properties.inactive_update_mode:
			Constants.InactiveUpdateMode.NEVER:
				return
#			Constants.InactiveUpdateMode.EXPONENTIALLY:
#				TODO

	if Properties.should_follow:
		match Properties.follow_mode:
			Constants.FollowMode.GLUED:
				if Properties.follow_target_node:
					set_global_position(Properties.follow_target_node.get_global_position())
			Constants.FollowMode.SIMPLE:
				if Properties.follow_target_node:
					set_global_position(
						Properties.follow_target_node.global_position +
						Properties.follow_target_offset_3D
					)
			Constants.FollowMode.GROUP:
				if Properties.has_follow_group:
					if Properties.follow_group_nodes_3D.size() == 1:
						set_global_position(
							Properties.follow_group_nodes_3D[0].get_position() +
							Properties.follow_target_offset_3D +
							get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance)
						)
					else:
						var bounds: AABB = AABB(Properties.follow_group_nodes_3D[0].get_position(), Vector3.ZERO)
						for node in Properties.follow_group_nodes_3D:
							bounds = bounds.expand(node.get_position())

						var distance: float
						if _follow_group_distance_auto:
							distance = lerp(_follow_group_distance_auto_min, _follow_group_distance_auto_max, bounds.get_longest_axis_size() / _follow_group_distance_auto_divisor)
							distance = clamp(distance, _follow_group_distance_auto_min, _follow_group_distance_auto_max)
						else:
							distance = follow_distance

						set_global_position(
							bounds.get_center() +
							Properties.follow_target_offset_3D +
							get_transform().basis.z * Vector3(distance, distance, distance)
						)
			Constants.FollowMode.PATH:
				if Properties.follow_target_node and Properties.follow_path_node:
					var path_position: Vector3 = Properties.follow_path_node.get_global_position()
					set_global_position(
						Properties.follow_path_node.curve.get_closest_point(Properties.follow_target_node.get_global_position() - path_position) +
						path_position
					)

#				Constants.FollowMode.FRAMED_FOLLOW:
#					set_global_position(
#						Properties.follow_target_node.position +
#						Properties.follow_target_offset_3D +
#						get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance)
#					)

	if _should_look_at:
		match look_at_mode:
			LookAtMode.MIMIC:
				if _has_look_at_target:
					set_rotation(_look_at_target_node.get_rotation())
			LookAtMode.SIMPLE:
				if _has_look_at_target:
					look_at(_look_at_target_node.get_position() + look_at_target_offset)
			LookAtMode.GROUP:
				if _has_look_at_target_group:
					if _look_at_group_nodes.size() == 1:
						look_at(_look_at_group_nodes[0].get_position())
					else:
						var bounds: AABB = AABB(_look_at_group_nodes[0].get_position(), Vector3.ZERO)
						for node in _look_at_group_nodes:
							bounds = bounds.expand(node.get_position())
						look_at(bounds.get_center())


##################
# Public Functions
##################
func assign_pcam_host() -> void:
	Properties.assign_pcam_host(self)


func set_priority(value: int) -> void:
	Properties.set_priority(value, self)
func get_priority() -> int:
	return Properties.priority


func add_node_to_look_at_group(node: Node3D) -> void:
	if not _look_at_group_nodes.has(node):
		_look_at_group_nodes.append(node)
func remove_node_from_look_at_group(node: Node3D) -> void:
	_look_at_group_nodes.erase(node)


func get_tween_duration() -> float:
#	return Properties.tween_duration
	if Properties.tween_resource:
		return Properties.tween_resource.duration
	else:
		return Properties.tween_resource_default.duration
func get_tween_transition() -> int:
	if Properties.tween_resource:
		return Properties.tween_resource.transition
	else:
		return Properties.tween_resource_default.transition
func get_tween_ease() -> int:
	if Properties.tween_resource:
		return Properties.tween_resource.ease
	else:
		return Properties.tween_resource_default.ease
