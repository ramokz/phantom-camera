@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg")
class_name PhantomCamera2D
extends Node2D

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
var Properties = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

const ZOOM_PROPERTY_NAME: StringName = "Zoom"
var zoom: Vector2 = Vector2(1, 1)

func _get_property_list() -> Array:
	var property_list: Array[Dictionary]
	property_list.append_array(Properties.add_priority_properties())
#	property_list.append_array(Properties.add_trigger_onload_properties())

	property_list.append({
		"name": ZOOM_PROPERTY_NAME,
		"type": TYPE_VECTOR2,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT
	})

	property_list.append_array(Properties.add_follow_mode_property())

	if Properties.follow_mode != Constants.FollowMode.NONE:
		property_list.append_array(Properties.add_follow_target_property())

	property_list.append_array(Properties.add_follow_properties())
	property_list.append_array(Properties.add_tween_properties())

	return property_list


func _set(property: StringName, value) -> bool:
	Properties.set_priority_property(property, value, self)
#	Properties.set_trigger_onload_properties(property, value, self)

	if property == ZOOM_PROPERTY_NAME:
		if value.x == 0:
			zoom.x = 0.001
		else:
			zoom.x = value.x

		if value.y == 0:
			zoom.y = 0.001
		else:
			zoom.y = value.y

	Properties.set_follow_properties(property, value, self)
	Properties.set_tween_properties(property, value, self)

	return false


func _get(property: StringName):
	if property == Constants.PRIORITY_PROPERTY_NAME: return Properties.priority
#	if property == Constants.TRIGGER_ONLOAD_NAME: return Properties.trigger_onload

	if property == ZOOM_PROPERTY_NAME: return zoom

	if property == Constants.FOLLOW_MODE_PROPERTY_NAME: return Properties.follow_mode
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME: return Properties.follow_target_path
	if property == Constants.FOLLOW_GROUP_PROPERTY_NAME: return Properties.follow_group_paths

	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: return Properties.follow_target_offset_2D
	if property == Constants.FOLLOW_DAMPING_NAME: return Properties.follow_has_damping
	if property == Constants.FOLLOW_DAMPING_VALUE_NAME: return Properties.follow_damping_value

	if property == Constants.TWEEN_DURATION_PROPERTY_NAME: return Properties.tween_duration
	if property == Constants.TWEEN_TRANSITION_PROPERTY_NAME: return Properties.tween_transition
	if property == Constants.TWEEN_EASE_PROPERTY_NAME: return Properties.tween_ease


###################
# Private Functions
###################
func _enter_tree() -> void:
	Properties.camera_enter_tree(self)
	Properties.assign_pcam_host(self)


func _exit_tree() -> void:
	if Properties.pcam_host_owner:
		Properties.pcam_host_owner.pcam_removed_from_scene(self)


func _physics_process(delta: float) -> void:
	if not Properties.should_follow: return

	match Properties.follow_mode:
		Constants.FollowMode.SIMPLE:
			if Properties.follow_target_node:
				set_global_position(
					Properties.follow_target_node.get_global_position() +
					Properties.follow_target_offset_2D
				)
		Constants.FollowMode.GLUED:
			if Properties.follow_target_node:
				set_global_position(Properties.follow_target_node.position)
		Constants.FollowMode.GROUP:
			if Properties.has_follow_group:
				if Properties.follow_group_nodes_2D.size() == 1:
					set_global_position(Properties.follow_group_nodes_2D[0].get_position())
				else:
					var bounds: Rect2 = Rect2(Properties.follow_group_nodes_2D[0].get_position(), Vector2.ZERO)
					for node in Properties.follow_group_nodes_2D:
						bounds = bounds.expand(node.get_position())
					set_global_position(bounds.get_center())


##################
# Public Functions
##################
func set_priority(value: int) -> void:
	Properties.set_priority(value, self)


func get_priority() -> int:
	return Properties.priority


func get_tween_duration() -> float:
	return Properties.tween_duration


func get_tween_transition() -> int:
	return Properties.tween_transition


func get_tween_ease() -> int:
	return Properties.tween_ease
