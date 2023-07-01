@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg")
class_name PhantomCamera2D
extends Node2D

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
var Properties = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

const FOLLOW_GROUP_ZOOM_AUTO: StringName = Constants.FOLLOW_PARAMETERS_NAME + "auto_zoom"
const FOLLOW_GROUP_ZOOM_MIN: StringName = Constants.FOLLOW_PARAMETERS_NAME + "min_zoom"
const FOLLOW_GROUP_ZOOM_MAX: StringName = Constants.FOLLOW_PARAMETERS_NAME + "max_zoom"
const FOLLOW_GROUP_ZOOM_MARGIN: StringName = Constants.FOLLOW_PARAMETERS_NAME + "zoom_margin"
var follow_group_zoom_auto: bool
var follow_group_zoom_min: float = 1
var follow_group_zoom_max: float = 5
var follow_group_zoom_margin: Vector4

func _get_property_list() -> Array:
	var property_list: Array[Dictionary]
	property_list.append_array(Properties.add_priority_properties())

	property_list.append({
		"name": Constants.ZOOM_PROPERTY_NAME,
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
	property_list.append_array(Properties.add_secondary_properties())

	return property_list


func _set(property: StringName, value) -> bool:
	Properties.set_priority_property(property, value, self)

	# ZOOM
	if property == Constants.ZOOM_PROPERTY_NAME:
		if value.x == 0:
			Properties.zoom.x = 0.001
		else:
			Properties.zoom.x = value.x

		if value.y == 0:
			Properties.zoom.y = 0.001
		else:
			Properties.zoom.y = value.y

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
	Properties.set_secondary_properties(property, value, self)

	return false


func _get(property: StringName):
	if property == Constants.PRIORITY_PROPERTY_NAME: 				return Properties.priority

	if property == Constants.ZOOM_PROPERTY_NAME: 					return Properties.zoom

	if property == Constants.FOLLOW_MODE_PROPERTY_NAME: 			return Properties.follow_mode
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME: 			return Properties.follow_target_path
	if property == Constants.FOLLOW_GROUP_PROPERTY_NAME: 			return Properties.follow_group_paths
	if property == Constants.FOLLOW_PATH_PROPERTY_NAME: 			return Properties.follow_path_path
	if property == FOLLOW_GROUP_ZOOM_AUTO:							return follow_group_zoom_auto
	if property == FOLLOW_GROUP_ZOOM_MIN: 							return follow_group_zoom_min
	if property == FOLLOW_GROUP_ZOOM_MAX: 							return follow_group_zoom_max
	if property == FOLLOW_GROUP_ZOOM_MARGIN:						return follow_group_zoom_margin
	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME:	return Properties.follow_target_offset_2D
	if property == Constants.FOLLOW_DAMPING_NAME: 					return Properties.follow_has_damping
	if property == Constants.FOLLOW_DAMPING_VALUE_NAME: 			return Properties.follow_damping_value

	if property == Constants.TWEEN_RESOURCE_PROPERTY_NAME:			return Properties.tween_resource

	if property == Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME:	return Properties.inactive_update_mode
	if property == Constants.TWEEN_ONLOAD_NAME: 					return Properties.tween_onload


###################
# Private Functions
###################
func _enter_tree() -> void:
	Properties.camera_enter_tree(self)
	Properties.assign_pcam_host(self)


func _exit_tree() -> void:
	if Properties.pcam_host_owner:
		Properties.pcam_host_owner.pcam_removed_from_scene(self)

	Properties.pcam_exit_tree(self)

func _physics_process(delta: float) -> void:
#	print(follow_group_zoom_margin)
	if not Properties.is_active:
		match Properties.inactive_update_mode:
			Constants.InactiveUpdateMode.NEVER:
				return
#			Constants.InactiveUpdateMode.EXPONENTIALLY:
#				TODO

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
					for node in Properties.follow_group_nodes_2D:
						rect = rect.expand(node.get_global_position())
						if follow_group_zoom_auto:
#							print(follow_group_zoom_margin.x)
							rect = rect.grow_individual(
								follow_group_zoom_margin.x,
								follow_group_zoom_margin.y,
								follow_group_zoom_margin.z,
								follow_group_zoom_margin.w)
#						else:
#							rect = rect.grow_individual(-80, 0, 0, 0)
					if follow_group_zoom_auto:
						var screen_size: Vector2 = get_viewport_rect().size
						if rect.size.x > rect.size.y * screen_size.aspect():
							Properties.zoom = clamp(screen_size.x / rect.size.x, follow_group_zoom_min, follow_group_zoom_max) * Vector2.ONE
						else:
							Properties.zoom = clamp(screen_size.y / rect.size.y, follow_group_zoom_min, follow_group_zoom_max) * Vector2.ONE
#					print(Properties.zoom)
					set_global_position(rect.get_center())
		Constants.FollowMode.PATH:
				if Properties.follow_target_node and Properties.follow_path_node:
					var path_position: Vector2 = Properties.follow_path_node.get_global_position()
					set_global_position(
						Properties.follow_path_node.curve.get_closest_point(Properties.follow_target_node.get_global_position() - path_position) +
						path_position
					)


##################
# Public Functions
##################
func get_pcam_host_owner() -> PhantomCameraHost:
	return Properties.pcam_host_owner


func set_zoom(value: Vector2) -> void:
	Properties.zoom = value
func get_zoom() -> Vector2:
	return Properties.zoom


func set_priority(value: int) -> void:
	Properties.set_priority(value, self)
func get_priority() -> int:
	return Properties.priority


func set_tween_duration(value: float) -> void:
	if Properties.tween_resource:
		Properties.tween_resource_default.duration = value
		Properties.tween_resource_default.transition = Properties.tween_resource.transition
		Properties.tween_resource_default.ease = Properties.tween_resource.ease
		Properties.tween_resource = null # Clears resource from PCam instance
	else:
		Properties.tween_resource_default.duration = value
func get_tween_duration() -> float:
	if Properties.tween_resource:
		return Properties.tween_resource.duration
	else:
		return Properties.tween_resource_default.duration

func set_tween_transition(value: Constants.TweenTransitions) -> void:
	if Properties.tween_resource:
		Properties.tween_resource_default.duration = Properties.tween_resource.duration
		Properties.tween_resource_default.transition = value
		Properties.tween_resource_default.ease = Properties.tween_resource.ease
		Properties.tween_resource = null # Clears resource from PCam instance
	else:
		Properties.tween_resource_default.transition = value
func get_tween_transition() -> int:
	if Properties.tween_resource:
		return Properties.tween_resource.transition
	else:
		return Properties.tween_resource_default.transition

func set_tween_ease(value: Constants.TweenEases) -> void:
	if Properties.tween_resource:
		Properties.tween_resource_default.duration = Properties.tween_resource.duration
		Properties.tween_resource_default.transition = Properties.tween_resource.ease
		Properties.tween_resource_default.ease = value
		Properties.tween_resource = null # Clears resource from PCam instance
	else:
		Properties.tween_resource_default.ease = value
func get_tween_ease() -> int:
	if Properties.tween_resource:
		return Properties.tween_resource.ease
	else:
		return Properties.tween_resource_default.ease


func is_active() -> bool:
	return Properties.is_active


func set_tween_on_load(value: bool) -> void:
	Properties.tween_onload = value
func is_tween_on_load() -> bool:
	return Properties.tween_onload


func set_follow_target_node(value: Node2D) -> void:
	Properties.follow_target_node = value
func get_follow_target_node():
	if Properties.follow_target_node:
		return Properties.follow_target_node
	else:
		printerr("No Follow Target Node assigned")

func set_follow_path(value: Path2D) -> void:
	Properties.follow_path_node = value
func get_follow_path():
	if Properties.follow_path_node:
		return Properties.follow_path_node
	else:
		printerr("No Follow Path assigned")

func get_follow_mode() -> String:
	return Constants.FollowMode.keys()[Properties.follow_mode].capitalize()
# Note: Setting Follow Mode purposely not added. A separate PCam should be used instead.

func set_follow_target_offset(value: Vector2) -> void:
	Properties.follow_target_offset_2D = value
func get_follow_target_offset() -> Vector2:
	return Properties.follow_target_offset_2D

func set_follow_has_damping(value: bool) -> void:
	Properties.follow_has_damping = value
func get_follow_has_damping() -> bool:
	return Properties.follow_has_damping
	
func set_follow_damping_value(value: float) -> void:
	Properties.follow_damping_value = value
func get_follow_damping_value() -> float:
	return Properties.follow_damping_value


func append_follow_group_node(value: Node2D) -> void:
	if not Properties.follow_group_nodes_2D.has(value):
		Properties.follow_group_nodes_2D.append(value)
	else:
		printerr(value, " is already part of Follow Group")
func append_array_follow_group_nodes(value: Array[Node2D]) -> void:
	for val in value:
		if not Properties.follow_group_nodes_2D.has(val):
			Properties.follow_group_nodes_2D.append(val)
		else:
			printerr(val, " is already part of Follow Group")
func erase_follow_group_node(value: Node2D) -> void:
	Properties.follow_group_nodes_2D.erase(value)
func get_follow_group_nodes() -> Array[Node2D]:
	return Properties.follow_group_nodes_2D

func set_auto_zoom(value: bool) -> void:
	follow_group_zoom_auto = value
func get_auto_zoom() -> bool:
	return follow_group_zoom_auto

func set_min_zoom(value: float) -> void:
	follow_group_zoom_min = value
func get_min_zoom() -> float:
	return follow_group_zoom_min

func set_max_zoom(value: float) -> void:
	follow_group_zoom_max = value
func get_max_zoom() -> float:
	return follow_group_zoom_max

func set_zoom_margin(value: Vector4) -> void:
	follow_group_zoom_margin = value
func get_zoom_margin() -> Vector4:
	return follow_group_zoom_margin


func get_inactive_update_mode() -> String:
	return Constants.InactiveUpdateMode.keys()[Properties.inactive_update_mode].capitalize()
