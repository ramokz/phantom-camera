@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg")
class_name PhantomCamera2D
extends Node2D

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
var Properties = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

const FRAME_PREVIEW: StringName = "frame_preview"
var _frame_preview: bool = true

const FOLLOW_GROUP_ZOOM_AUTO: StringName = Constants.FOLLOW_PARAMETERS_NAME + "auto_zoom"
const FOLLOW_GROUP_ZOOM_MIN: StringName = Constants.FOLLOW_PARAMETERS_NAME + "min_zoom"
const FOLLOW_GROUP_ZOOM_MAX: StringName = Constants.FOLLOW_PARAMETERS_NAME + "max_zoom"
const FOLLOW_GROUP_ZOOM_MARGIN: StringName = Constants.FOLLOW_PARAMETERS_NAME + "zoom_margin"
var follow_group_zoom_auto: bool
var follow_group_zoom_min: float = 1
var follow_group_zoom_max: float = 5
var follow_group_zoom_margin: Vector4

## Limit  
const CAMERA_2D_LIMIT: StringName = "limit/"

const CAMERA_2D_DRAW_LIMITS: StringName = CAMERA_2D_LIMIT + "draw_limits"  
const CAMERA_2D_LIMIT_LEFT: StringName = CAMERA_2D_LIMIT + "left"  
const CAMERA_2D_LIMIT_TOP: StringName = CAMERA_2D_LIMIT + "top"  
const CAMERA_2D_LIMIT_RIGHT: StringName = CAMERA_2D_LIMIT + "right"  
const CAMERA_2D_LIMIT_BOTTOM: StringName = CAMERA_2D_LIMIT + "bottom"  
const CAMERA_2D_LIMIT_SMOOTHED: StringName = CAMERA_2D_LIMIT + "smoothed"  
static var camera_2d_draw_limits: bool
var camera_2d_limit_left: int = -10000000
var camera_2d_limit_top: int = -10000000
var camera_2d_limit_right: int = 10000000  
var camera_2d_limit_bottom: int = 10000000
var camera_2d_limit_smoothed: bool

const TILE_MAP_LIMIT_NODE_PROPERTY_NAME: StringName = CAMERA_2D_LIMIT + "tile_map_limit_target"  
const TILE_MAP_LIMIT_MARGIN_PROPERTY_NAME: StringName = CAMERA_2D_LIMIT + "tile_map_limit_margin"  
var tile_map_limit_node_path: NodePath
var tile_map_limit_margin: Vector4
var tile_map_limit_rect_border: Rect2
var tile_map_limit_rect_zone: Rect2

var _camera_offset: Vector2

func _get_property_list() -> Array:
	var property_list: Array[Dictionary]
	property_list.append_array(Properties.add_priority_properties())

	property_list.append({
		"name": Constants.ZOOM_PROPERTY_NAME,
		"type": TYPE_VECTOR2,
		"hint": PROPERTY_HINT_LINK
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

	property_list.append({
		"name": FRAME_PREVIEW,
		"type": TYPE_BOOL,
	})

	property_list.append({
		"name": CAMERA_2D_DRAW_LIMITS,
		"type": TYPE_BOOL
	})
		
	if not tile_map_limit_node_path:
		property_list.append({
			"name": CAMERA_2D_LIMIT_LEFT,
			"type": TYPE_INT
		})
		property_list.append({
			"name": CAMERA_2D_LIMIT_TOP,
			"type": TYPE_INT
		})
		property_list.append({
			"name": CAMERA_2D_LIMIT_RIGHT,
			"type": TYPE_INT
		})
		property_list.append({
			"name": CAMERA_2D_LIMIT_BOTTOM,
			"type": TYPE_INT
		})
	property_list.append({
		"name": CAMERA_2D_LIMIT_SMOOTHED,
		"type": TYPE_BOOL
	})
		
	
	property_list.append({
		"name": TILE_MAP_LIMIT_NODE_PROPERTY_NAME,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NODE_PATH_VALID_TYPES,
		"hint_string": "TileMap",
	})
	if tile_map_limit_node_path:
		property_list.append({
			"name": TILE_MAP_LIMIT_MARGIN_PROPERTY_NAME,
			"type": TYPE_VECTOR4,
		})


	property_list.append_array(Properties.add_tween_properties())

	property_list.append_array(Properties.add_secondary_properties())

	return property_list


func _set(property: StringName, value) -> bool:
	Properties.set_priority_property(property, value, self)

	# ZOOM
	if property == Constants.ZOOM_PROPERTY_NAME:
		Properties.zoom = Vector2(absf(value.x), absf(value.y))
		queue_redraw()

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
	
	if property == CAMERA_2D_DRAW_LIMITS:
		camera_2d_draw_limits = value
		if Engine.is_editor_hint():
			_draw_camera_2d_limit()
	if property == CAMERA_2D_LIMIT_LEFT:
		camera_2d_limit_left = value
		_set_camera_2d_limit(SIDE_LEFT, value)
	if property == CAMERA_2D_LIMIT_TOP:
		camera_2d_limit_top = value
		_set_camera_2d_limit(SIDE_TOP, value)
	if property == CAMERA_2D_LIMIT_RIGHT:
		camera_2d_limit_right = value
		_set_camera_2d_limit(SIDE_RIGHT, value)
	if property == CAMERA_2D_LIMIT_BOTTOM:
		camera_2d_limit_bottom = value
		_set_camera_2d_limit(SIDE_BOTTOM, value)
	if property == CAMERA_2D_LIMIT_SMOOTHED:
		camera_2d_limit_smoothed = value
	
	if property == TILE_MAP_LIMIT_NODE_PROPERTY_NAME:
		if value is NodePath:
			value = value as NodePath
			tile_map_limit_node_path = value
			
			set_camera_2d_limit_all_sides()
		elif value is TileMap:
			if is_instance_valid(value):
				tile_map_limit_node_path = value.get_path()
				set_camera_2d_limit_all_sides()
			
		notify_property_list_changed()
	if property == TILE_MAP_LIMIT_MARGIN_PROPERTY_NAME:
		tile_map_limit_margin = value
		set_camera_2d_limit_all_sides()
	
	if property == FRAME_PREVIEW:
		_frame_preview = true if value == null else value
		queue_redraw()

	return false


func _get(property: StringName):
	if property == Constants.PRIORITY_OVERRIDE: 						return Properties.priority_override
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
	
	if property == CAMERA_2D_DRAW_LIMITS:								return camera_2d_draw_limits
	if property == CAMERA_2D_LIMIT_LEFT:								return camera_2d_limit_left
	if property == CAMERA_2D_LIMIT_TOP:									return camera_2d_limit_top
	if property == CAMERA_2D_LIMIT_RIGHT:								return camera_2d_limit_right
	if property == CAMERA_2D_LIMIT_BOTTOM:								return camera_2d_limit_bottom
	if property == CAMERA_2D_LIMIT_SMOOTHED:							return camera_2d_limit_smoothed
	if property == TILE_MAP_LIMIT_NODE_PROPERTY_NAME:					return tile_map_limit_node_path
	if property == TILE_MAP_LIMIT_MARGIN_PROPERTY_NAME:					return tile_map_limit_margin
	
	if property == FRAME_PREVIEW: 										return _frame_preview


###################
# Private Functions
###################
func _enter_tree() -> void:
	Properties.is_2D = true
	Properties.camera_enter_tree(self)
	Properties.assign_pcam_host(self)


func _exit_tree() -> void:
	if Properties.pcam_host_owner:
		Properties.pcam_host_owner.pcam_removed_from_scene(self)

	Properties.pcam_exit_tree(self)


func _process(delta: float) -> void:
	if not Properties.is_active:
		match Properties.inactive_update_mode:
			Constants.InactiveUpdateMode.NEVER:
				return
#			Constants.InactiveUpdateMode.EXPONENTIALLY:
#				TODO

	if not Properties.should_follow: return

	match Properties.follow_mode:
		Constants.FollowMode.GLUED:
			if Properties.follow_target_node:
				set_global_position(Properties.follow_target_node.get_global_position())
		Constants.FollowMode.SIMPLE:
			if Properties.follow_target_node:
				set_global_position(_target_position_with_offset())
		Constants.FollowMode.GROUP:
			if Properties.has_follow_group:
				if Properties.follow_group_nodes_2D.size() == 1:
					set_global_position(Properties.follow_group_nodes_2D[0].get_global_position())
				else:
					var rect: Rect2 = Rect2(Properties.follow_group_nodes_2D[0].get_global_position(), Vector2.ZERO)
					for node in Properties.follow_group_nodes_2D:
						rect = rect.expand(node.get_global_position())
						if follow_group_zoom_auto:
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
					set_global_position(rect.get_center())
		Constants.FollowMode.PATH:
				if Properties.follow_target_node and Properties.follow_path_node:
					var path_position: Vector2 = Properties.follow_path_node.get_global_position()
					set_global_position(
						Properties.follow_path_node.curve.get_closest_point(
							Properties.follow_target_node.get_global_position() - path_position
						) + path_position)
		Constants.FollowMode.FRAMED:
			if Properties.follow_target_node:
				if not Engine.is_editor_hint():
					Properties.viewport_position = (get_follow_target_node().get_global_transform_with_canvas().get_origin() + Properties.follow_target_offset_2D) / get_viewport_rect().size

					if Properties.get_framed_side_offset() != Vector2.ZERO:
						var glo_pos: Vector2

						var target_position: Vector2 = _target_position_with_offset() + _camera_offset
						var dead_zone_width: float = Properties.follow_framed_dead_zone_width
						var dead_zone_height: float = Properties.follow_framed_dead_zone_height

						if dead_zone_width == 0 || dead_zone_height == 0:
							if dead_zone_width == 0 && dead_zone_height != 0:
								set_global_position(_target_position_with_offset())
							elif dead_zone_width != 0 && dead_zone_height == 0:
								glo_pos = _target_position_with_offset()
								glo_pos.x += target_position.x - global_position.x
								set_global_position(glo_pos)
							else:
								set_global_position(_target_position_with_offset())
						else:
							set_global_position(target_position)
					else:
						_camera_offset = get_global_position() - _target_position_with_offset()
				else:
					set_global_position(_target_position_with_offset())


func _draw():
	if not OS.has_feature("editor"): return # Only appears in the editor
	
	if Engine.is_editor_hint():
		if not _frame_preview or Properties.is_active: return
		var screen_size_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
		var screen_size_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
		var screen_size_zoom: Vector2 = Vector2(screen_size_width / get_zoom().x, screen_size_height / get_zoom().y)
		
		draw_rect(Rect2(-screen_size_zoom / 2, screen_size_zoom), Color("3ab99a"), false, 2)


func _target_position_with_offset() -> Vector2:
	return Properties.follow_target_node.get_global_position() + Properties.follow_target_offset_2D


func _has_valid_pcam_owner() -> bool:
	if not is_instance_valid(get_pcam_host_owner()):
		return false
	if not is_instance_valid(get_pcam_host_owner().camera_2D):
		return false
	
	return true

func _draw_camera_2d_limit() -> void:
	if _has_valid_pcam_owner():
		get_pcam_host_owner().camera_2D.set_limit_drawing_enabled(camera_2d_draw_limits)

func _set_camera_2d_limit(side: int, limit: int) -> void:
	_has_valid_pcam_owner()
	if not is_active(): return
	get_pcam_host_owner().camera_2D.set_limit(side, limit)

func set_camera_2d_limit_all_sides() -> void:
	if not _has_valid_pcam_owner() or not is_active(): return
	
	var sides_limit: Vector4
	if tile_map_limit_node_path:
		if not is_instance_valid(get_node(tile_map_limit_node_path)): return
		
		var tile_map: TileMap = get_node(tile_map_limit_node_path)
		var tile_map_size: Vector2 = Vector2(tile_map.get_used_rect().size) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()
		var tile_map_position: Vector2 = tile_map.get_global_position() + Vector2(tile_map.get_used_rect().position) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()

		## Calculates the Rect2 based on the Tile Map position and size
		tile_map_limit_rect_border = Rect2(tile_map_position, tile_map_size)

		## Calculates the Rect2 based on the Tile Map position and size + margin
		tile_map_limit_rect_zone = Rect2(
			tile_map_limit_rect_border.position + Vector2(tile_map_limit_margin.x, tile_map_limit_margin.y),
			tile_map_limit_rect_border.size - Vector2(tile_map_limit_margin.x, tile_map_limit_margin.y) - Vector2(tile_map_limit_margin.z, tile_map_limit_margin.w)
		)
		
		# Left
		sides_limit.x = tile_map_limit_rect_zone.position.x
		# Top
		sides_limit.y = tile_map_limit_rect_zone.position.y
		# Right
		sides_limit.z = tile_map_limit_rect_zone.position.x + tile_map_limit_rect_zone.size.x
		# Bottom
		sides_limit.w = tile_map_limit_rect_zone.position.y + tile_map_limit_rect_zone.size.y
	else:
		sides_limit.x = camera_2d_limit_left
		sides_limit.y = camera_2d_limit_top
		sides_limit.z = camera_2d_limit_right
		sides_limit.w = camera_2d_limit_bottom
	
	_set_camera_2d_limit(SIDE_LEFT, sides_limit.x)
	_set_camera_2d_limit(SIDE_TOP, sides_limit.y)
	_set_camera_2d_limit(SIDE_RIGHT, sides_limit.z)
	_set_camera_2d_limit(SIDE_BOTTOM, sides_limit.w)

##################
# Public Functions
##################
## Assigns the PhantomCamera2D to a new PhantomCameraHost.
func assign_pcam_host() -> void:
	Properties.assign_pcam_host(self)
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

## Assigns a new Node2D as the Follow Target property.
func set_follow_target_node(value: Node2D) -> void:
	Properties.follow_target_node = value
	Properties.should_follow = true
## Erases the current Node2D from the Follow Target property.
func erase_follow_target_node() -> void:
	Properties.should_follow = false
	Properties.follow_target_node = null
## Gets the current Node2D target property.
func get_follow_target_node():
	if Properties.follow_target_node:
		return Properties.follow_target_node
	else:
		printerr("No Follow Target Node assigned")


## Assigns a new Path2D to the Follow Path property.
func set_follow_path(value: Path2D) -> void:
	Properties.follow_path_node = value
## Erases the current Path2D from the Follow Path property.
func erase_follow_path() -> void:
	Properties.follow_path_node = null
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
		Properties.should_follow = true
		Properties.has_follow_group = true
	else:
		printerr(value, " is already part of Follow Group")
## Adds an Array of type Node2D to Follow Group array.
func append_follow_group_node_array(value: Array[Node2D]) -> void:
	for val in value:
		if not Properties.follow_group_nodes_2D.has(val):
			Properties.follow_group_nodes_2D.append(val)
			Properties.should_follow = true
			Properties.has_follow_group = true
		else:
			printerr(val, " is already part of Follow Group")
## Removes Node2D from Follow Group array.
func erase_follow_group_node(value: Node2D) -> void:
	Properties.follow_group_nodes_2D.erase(value)
	if Properties.follow_group_nodes_2D.size() < 1:
		Properties.should_follow = false
		Properties.has_follow_group = false
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

## Sets the Camera2D Limit value.
func set_limit(side: int, value: int) -> void:
	match side:
		SIDE_LEFT: 		camera_2d_limit_left = value
		SIDE_TOP: 		camera_2d_limit_top = value
		SIDE_RIGHT: 	camera_2d_limit_right = value
		SIDE_BOTTOM: 	camera_2d_limit_bottom = value
		_:				printerr("Not a valid Side parameter.")
## Gets the Camera2D Limit value.
func get_camera_2d_limit(side: int) -> int:
	match side:
		SIDE_LEFT: 		return camera_2d_limit_left
		SIDE_TOP: 		return camera_2d_limit_left
		SIDE_RIGHT: 	return camera_2d_limit_left
		SIDE_BOTTOM: 	return camera_2d_limit_left
		_:
						printerr("Not a valid Side parameter.")
						return -1

## Set Tile Map Clamp Node.
func set_tile_map_limit_node(value: TileMap) -> void:
	tile_map_limit_node_path = value.get_path()
## Get Tile Map Clamp Node
func get_tile_map_limit_node() -> TileMap:
	if not get_node_or_null(tile_map_limit_node_path):
		printerr("No Tile Map Clamp Node set")
	return get_node(tile_map_limit_node_path)

## Set Tile Map Clamp Margin.
func set_tile_map_limit_margin(value: Vector4) -> void:
	tile_map_limit_margin = value
## Get Tile Map Clamp Margin.
func get_tile_map_limit_margin() -> Vector4:
	return tile_map_limit_margin


## Gets Interactive Update Mode property.
func get_inactive_update_mode() -> String:
	return Constants.InactiveUpdateMode.keys()[Properties.inactive_update_mode].capitalize()
