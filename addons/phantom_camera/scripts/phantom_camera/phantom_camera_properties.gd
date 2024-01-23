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


#region _set

func set_follow_properties(property: StringName, value, pcam: Node) -> void:

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


func get_framed_side_offset(dead_zone_width: float, dead_zone_height: float) -> Vector2:
	var frame_out_bounds: Vector2

	if viewport_position.x < 0.5 - dead_zone_width / 2:
		# Is outside left edge
		frame_out_bounds.x = -1

	if viewport_position.y < 0.5 - dead_zone_height / 2:
		# Is outside top edge
		frame_out_bounds.y = 1

	if viewport_position.x > 0.5 + dead_zone_width / 2:
		# Is outside right edge
		frame_out_bounds.x = 1

	if viewport_position.y > 0.5001 + dead_zone_height / 2: # 0.501 to resolve an issue where the bottom vertical Dead Zone never becoming 0 when the Dead Zone Vertical parameter is set to 0
		# Is outside bottom edge
		frame_out_bounds.y = -1

	return frame_out_bounds

#endregion
