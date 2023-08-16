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

var _camera_offset: Vector2

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

	if Properties.follow_has_target || Properties.has_follow_group:
		property_list.append_array(Properties.add_follow_properties())
		property_list.append_array(Properties.add_follow_framed())

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
	if property == Constants.PRIORITY_PROPERTY_NAME: 					return Properties.priority

	if property == Constants.ZOOM_PROPERTY_NAME: 						return Properties.zoom

	if property == Constants.FOLLOW_MODE_PROPERTY_NAME: 				return Properties.follow_mode
	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME:		return Properties.follow_target_offset_2D
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME: 				return Properties.follow_target_path
	if property == Constants.FOLLOW_GROUP_PROPERTY_NAME: 				return Properties.follow_group_paths

	if property == Constants.FOLLOW_PATH_PROPERTY_NAME: 				return Properties.follow_path_path

	if property == Constants.FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME:	return Properties.follow_framed_dead_zone_width
	if property == Constants.FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME:		return Properties.follow_framed_dead_zone_height
	if property == Constants.FOLLOW_VIEWFINDER_IN_PLAY_NAME:					return Properties.show_viewfinder_in_play

	if property == FOLLOW_GROUP_ZOOM_AUTO:								return follow_group_zoom_auto
	if property == FOLLOW_GROUP_ZOOM_MIN: 								return follow_group_zoom_min
	if property == FOLLOW_GROUP_ZOOM_MAX: 								return follow_group_zoom_max
	if property == FOLLOW_GROUP_ZOOM_MARGIN:							return follow_group_zoom_margin

	if property == Constants.FOLLOW_DAMPING_NAME: 						return Properties.follow_has_damping
	if property == Constants.FOLLOW_DAMPING_VALUE_NAME: 				return Properties.follow_damping_value

	if property == Constants.TWEEN_RESOURCE_PROPERTY_NAME:				return Properties.tween_resource

	if property == Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME:		return Properties.inactive_update_mode
	if property == Constants.TWEEN_ONLOAD_NAME: 						return Properties.tween_onload


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
		Constants.FollowMode.FRAMED:
			if Properties.follow_target_node:
				if not Engine.is_editor_hint():
					Properties.viewport_position = (get_follow_target_node().get_global_transform_with_canvas().get_origin() + Properties.follow_target_offset_2D) / get_viewport_rect().size

					if Properties.get_framed_side_offset() != Vector2.ZERO:

						var target_position: Vector2 = _target_position_with_offset() + _camera_offset
						var dead_zone_width: float = Properties.follow_framed_dead_zone_width
						var dead_zone_height: float = Properties.follow_framed_dead_zone_height

						if dead_zone_width == 0 || dead_zone_height == 0:
							if dead_zone_width == 0 && dead_zone_height != 0:
								global_position = _target_position_with_offset()
							elif dead_zone_width != 0 && dead_zone_height == 0:
								global_position = _target_position_with_offset()
								global_position.x += target_position.x - global_position.x
							else:
								global_position = _target_position_with_offset()
						else:
							global_position += target_position - global_position
					else:
						_camera_offset = global_position - _target_position_with_offset()
				else:
					set_global_position(_target_position_with_offset())
#					print(_target_position_with_offset())


func _target_position_with_offset() -> Vector2:
	return Properties.follow_target_node.get_global_position() + Properties.follow_target_offset_2D


##################
# Public Functions
##################
## Gets the current PhantomCameraHost this PhantomCamera2D is assigned to.
func get_pcam_host_owner() -> PhantomCameraHost:
	return Properties.pcam_host_owner


## Assigns new Zoom value.
func set_zoom(value: Vector2) -> void:
	Properties.zoom = value
## Gets current Zoom value.
func get_zoom() -> Vector2:
	return Properties.zoom


## Assigns new Priority value.
func set_priority(value: int) -> void:
	Properties.set_priority(value, self)
## Gets current Priority value.
func get_priority() -> int:
	return Properties.priority


## Assigns a new PhantomCameraTween resource to the PhantomCamera2D
func set_tween_resource(value: PhantomCameraTween) -> void:
	Properties.tween_resource = value
## Gets the PhantomCameraTween resource assigned to the PhantomCamera2D
## Returns null if there's nothing assigned to it.
func get_tween_resource() -> PhantomCameraTween:
	return Properties.tween_resource

## Assigns a new Tween Duration value. The duration value is in seconds.
## Note: This will override and make the Tween Resource unique to this PhantomCamera2D.
func set_tween_duration(value: float) -> void:
	if get_tween_resource():
		Properties.tween_resource_default.duration = value
		Properties.tween_resource_default.transition = Properties.tween_resource.transition
		Properties.tween_resource_default.ease = Properties.tween_resource.ease
		set_tween_resource(null) # Clears resource from PCam instance
	else:
		Properties.tween_resource_default.duration = value
## Gets the current Tween Duration value. The duration value is in seconds.
func get_tween_duration() -> float:
	if get_tween_resource():
		return get_tween_resource().duration
	else:
		return Properties.tween_resource_default.duration

## Assigns a new Tween Transition value.
## Note: This will override and make the Tween Resource unique to this PhantomCamera2D.
func set_tween_transition(value: Constants.TweenTransitions) -> void:
	if get_tween_resource():
		Properties.tween_resource_default.duration = Properties.tween_resource.duration
		Properties.tween_resource_default.transition = value
		Properties.tween_resource_default.ease = Properties.tween_resource.ease
		set_tween_resource(null) # Clears resource from PCam instance
	else:
		Properties.tween_resource_default.transition = value
## Gets the current Tween Transition value.
func get_tween_transition() -> int:
	if get_tween_resource():
		return get_tween_resource().transition
	else:
		return Properties.tween_resource_default.transition
		
## Assigns a new Tween Ease value.
## Note: This will override and make the Tween Resource unique to this PhantomCamera2D.
func set_tween_ease(value: Constants.TweenEases) -> void:
	if get_tween_resource():
		Properties.tween_resource_default.duration = Properties.tween_resource.duration
		Properties.tween_resource_default.transition = Properties.tween_resource.ease
		Properties.tween_resource_default.ease = value
		set_tween_resource(null) # Clears resource from PCam instance
	else:
		Properties.tween_resource_default.ease = value
## Gets the current Tween Ease value.
func get_tween_ease() -> int:
	if get_tween_resource():
		return get_tween_resource().ease
	else:
		return Properties.tween_resource_default.ease


## Gets current active state of the PhantomCamera2D.
## If it returns true, it means the PhantomCamera2D is what the Camera2D is currently following. 
func is_active() -> bool:
	return Properties.is_active


## Enables or disables the Tween on Load. 
func set_tween_on_load(value: bool) -> void:
	Properties.tween_onload = value
## Gets the current Tween On Load value.
func is_tween_on_load() -> bool:
	return Properties.tween_onload


## Gets the current follow mode as an enum int based on Constants.FOLLOW_MODE enum.
## Note: Setting Follow Mode purposely not added. A separate PCam should be used instead.
func get_follow_mode() -> int:
	return Properties.follow_mode

## Assigns a new Node2D as the Follow Target.
func set_follow_target_node(value: Node2D) -> void:
	Properties.follow_target_node = value
## Gets the current Node2D target.
func get_follow_target_node():
	if Properties.follow_target_node:
		return Properties.follow_target_node
	else:
		printerr("No Follow Target Node assigned")


## Assigns a new Path2D to the Follow Path property.
func set_follow_path(value: Path2D) -> void:
	Properties.follow_path_node = value
## Gets the current Path2D from the Follow Path property.
func get_follow_path():
	if Properties.follow_path_node:
		return Properties.follow_path_node
	else:
		printerr("No Follow Path assigned")


## Assigns a new Vector2 for the Follow Target Offset property.
func set_follow_target_offset(value: Vector2) -> void:
	Properties.follow_target_offset_2D = value
## Gets the current Vector2 for the Follow Target Offset property.
func get_follow_target_offset() -> Vector2:
	return Properties.follow_target_offset_2D


## Enables or disables Follow Damping.
func set_follow_has_damping(value: bool) -> void:
	Properties.follow_has_damping = value
## Gets the currents Follow Damping property.
func get_follow_has_damping() -> bool:
	return Properties.follow_has_damping

## Assigns new Damping value.
func set_follow_damping_value(value: float) -> void:
	Properties.follow_damping_value = value
## Gets the currents Follow Damping value.
func get_follow_damping_value() -> float:
	return Properties.follow_damping_value


## Adds a single Node2D to Follow Group array.
func append_follow_group_node(value: Node2D) -> void:
	if not Properties.follow_group_nodes_2D.has(value):
		Properties.follow_group_nodes_2D.append(value)
	else:
		printerr(value, " is already part of Follow Group")
## Adds an Array of type Node2D to Follow Group array.
func append_follow_group_node_array(value: Array[Node2D]) -> void:
	for val in value:
		if not Properties.follow_group_nodes_2D.has(val):
			Properties.follow_group_nodes_2D.append(val)
		else:
			printerr(val, " is already part of Follow Group")
## Removes Node2D from Follow Group array.
func erase_follow_group_node(value: Node2D) -> void:
	Properties.follow_group_nodes_2D.erase(value)
## Gets all Node2D from Follow Group array.
func get_follow_group_nodes() -> Array[Node2D]:
	return Properties.follow_group_nodes_2D


## Enables or disables Auto zoom when using Group Follow.
func set_auto_zoom(value: bool) -> void:
	follow_group_zoom_auto = value
## Gets Auto Zoom state.
func get_auto_zoom() -> bool:
	return follow_group_zoom_auto

## Assigns new Min Auto Zoom value.
func set_min_auto_zoom(value: float) -> void:
	follow_group_zoom_min = value
## Gets Min Auto Zoom value.
func get_min_auto_zoom() -> float:
	return follow_group_zoom_min

## Assigns new Max Auto Zoom value.
func set_max_auto_zoom(value: float) -> void:
	follow_group_zoom_max = value
## Gets Max Auto Zoom value.
func get_max_auto_zoom() -> float:
	return follow_group_zoom_max

## Assigns new Zoom Auto Margin value.
func set_zoom_auto_margin(value: Vector4) -> void:
	follow_group_zoom_margin = value
## Gets Zoom Auto Margin value.
func get_zoom_auto_margin() -> Vector4:
	return follow_group_zoom_margin


## Gets Interactive Update Mode property.
func get_inactive_update_mode() -> String:
	return Constants.InactiveUpdateMode.keys()[Properties.inactive_update_mode].capitalize()
