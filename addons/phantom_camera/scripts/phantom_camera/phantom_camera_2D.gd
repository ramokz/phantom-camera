@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg")
class_name PhantomCamera2D
extends Node2D

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
var Properties = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

const ZOOM_PROPERTY_NAME: StringName = "Zoom"
var zoom: Vector2 = Vector2.ONE

const FOLLOW_GROUP_ZOOM_AUTO: StringName = Constants.FOLLOW_PARAMETERS_NAME + "Auto Zoom"
const FOLLOW_GROUP_ZOOM_MIN: StringName = Constants.FOLLOW_PARAMETERS_NAME + "Min Zoom"
const FOLLOW_GROUP_ZOOM_MAX: StringName = Constants.FOLLOW_PARAMETERS_NAME + "Max Zoom"
const FOLLOW_GROUP_ZOOM_MARGIN: StringName = Constants.FOLLOW_PARAMETERS_NAME + "Zoom Margin"
var follow_group_zoom_auto: bool
var follow_group_zoom_min: float = 1
var follow_group_zoom_max: float = 5
var follow_group_zoom_margin: Vector4

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

	if Properties.follow_mode == Constants.FollowMode.GROUP:
		property_list.append({
			"name": FOLLOW_GROUP_ZOOM_AUTO,
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
		})
		if follow_group_zoom_auto:
			property_list.append({
				"name": FOLLOW_GROUP_ZOOM_MIN,
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.01, 100, 0.01,",
				"usage": PROPERTY_USAGE_DEFAULT,
			})

			property_list.append({
				"name": FOLLOW_GROUP_ZOOM_MAX,
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.01, 100, 0.01,",
				"usage": PROPERTY_USAGE_DEFAULT,
			})

			property_list.append({
				"name": FOLLOW_GROUP_ZOOM_MARGIN,
				"type": TYPE_VECTOR4,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0, 100, 0.01,",
				"usage": PROPERTY_USAGE_DEFAULT,
			})


	property_list.append_array(Properties.add_follow_properties())
	property_list.append_array(Properties.add_tween_properties())

	return property_list


func _set(property: StringName, value) -> bool:
	Properties.set_priority_property(property, value, self)
#	Properties.set_trigger_onload_properties(property, value, self)

	# ZOOM
	if property == ZOOM_PROPERTY_NAME:
		if value.x == 0:
			zoom.x = 0.001
		else:
			zoom.x = value.x

		if value.y == 0:
			zoom.y = 0.001
		else:
			zoom.y = value.y

	# ZOOM CLAMP
	if property == FOLLOW_GROUP_ZOOM_AUTO:
		follow_group_zoom_auto = value
		notify_property_list_changed()

	if property == FOLLOW_GROUP_ZOOM_MIN:
		if value > 0:
			follow_group_zoom_min = value
		else:
			follow_group_zoom_min = 0

	if property == FOLLOW_GROUP_ZOOM_MAX:
		if value > 0:
			follow_group_zoom_max = value
		else:
			follow_group_zoom_max = 0

	if property == FOLLOW_GROUP_ZOOM_MARGIN:
		follow_group_zoom_margin = value

	Properties.set_follow_properties(property, value, self)
	Properties.set_tween_properties(property, value, self)

	return false


func _get(property: StringName):
	if property == Constants.PRIORITY_PROPERTY_NAME: 				return Properties.priority
#	if property == Constants.TRIGGER_ONLOAD_NAME: return Properties.trigger_onload

	if property == ZOOM_PROPERTY_NAME: 								return zoom

	if property == Constants.FOLLOW_MODE_PROPERTY_NAME: 			return Properties.follow_mode
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME: 			return Properties.follow_target_path
	if property == Constants.FOLLOW_GROUP_PROPERTY_NAME: 			return Properties.follow_group_paths
	if property == FOLLOW_GROUP_ZOOM_AUTO:							return follow_group_zoom_auto
	if property == FOLLOW_GROUP_ZOOM_MIN: 							return follow_group_zoom_min
	if property == FOLLOW_GROUP_ZOOM_MAX: 							return follow_group_zoom_max
	if property == FOLLOW_GROUP_ZOOM_MARGIN: 						return follow_group_zoom_margin

	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME:	return Properties.follow_target_offset_2D
	if property == Constants.FOLLOW_DAMPING_NAME: 					return Properties.follow_has_damping
	if property == Constants.FOLLOW_DAMPING_VALUE_NAME: 			return Properties.follow_damping_value

	if property == Constants.TWEEN_RESOURCE_PROPERTY_NAME: 			return Properties.tween_resource


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
					var rect: Rect2 = Rect2(Properties.follow_group_nodes_2D[0].get_global_position(), Vector2.ZERO)
					var screen_size: Vector2 = get_viewport_rect().size
					for node in Properties.follow_group_nodes_2D:
						rect = rect.expand(node.get_global_position())
						rect = rect.grow_individual(
							follow_group_zoom_margin.x,
							follow_group_zoom_margin.y,
							follow_group_zoom_margin.z,
							follow_group_zoom_margin.w)
					if rect.size.x > rect.size.y * screen_size.aspect():
						zoom = clamp(screen_size.x / rect.size.x, follow_group_zoom_min, follow_group_zoom_max) * Vector2.ONE
					else:
						zoom = clamp(screen_size.y / rect.size.y, follow_group_zoom_min, follow_group_zoom_max) * Vector2.ONE
					set_global_position(rect.get_center())

##################
# Public Functions
##################
func set_priority(value: int) -> void:
	Properties.set_priority(value, self)


func get_priority() -> int:
	return Properties.priority


# Tween Functions
func get_tween_duration() -> float:
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
