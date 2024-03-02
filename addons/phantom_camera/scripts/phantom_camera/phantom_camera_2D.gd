@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg")
class_name PhantomCamera2D
extends Node2D

#region Constants

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

const FRAME_PREVIEW: StringName = "frame_preview"

const PIXEL_PERFECT_PROPERTY_NAME: StringName = "pixel_perfect"

const ZOOM_PROPERTY_NAME: StringName = "zoom"

const FOLLOW_GROUP_ZOOM_AUTO: StringName = Constants.FOLLOW_PARAMETERS_NAME + "auto_zoom"
const FOLLOW_GROUP_ZOOM_MIN: StringName = Constants.FOLLOW_PARAMETERS_NAME + "min_zoom"
const FOLLOW_GROUP_ZOOM_MAX: StringName = Constants.FOLLOW_PARAMETERS_NAME + "max_zoom"
const FOLLOW_GROUP_ZOOM_MARGIN: StringName = Constants.FOLLOW_PARAMETERS_NAME + "zoom_margin"

const CAMERA_2D_LIMIT: StringName = "limit/"

const DRAW_LIMITS: StringName = CAMERA_2D_LIMIT + "draw_limits"  
const LIMIT_LEFT: StringName = CAMERA_2D_LIMIT + "left"  
const LIMIT_TOP: StringName = CAMERA_2D_LIMIT + "top"  
const LIMIT_RIGHT: StringName = CAMERA_2D_LIMIT + "right"  
const LIMIT_BOTTOM: StringName = CAMERA_2D_LIMIT + "bottom"  
const LIMIT_SMOOTHED: StringName = CAMERA_2D_LIMIT + "smoothed"  
const LIMIT_NODE_PATH_PROPERTY_NAME: StringName = CAMERA_2D_LIMIT + "limit_node_target"
const LIMIT_MARGIN_PROPERTY_NAME: StringName = CAMERA_2D_LIMIT + "margin"

#endregion


#region Signals

## Emitted when the PhantomCamera2D becomes active.
signal became_active
## Emitted when the PhantomCamera2D becomes inactive.
signal became_inactive
## Emitted when follow_target changes
signal follow_target_changed

## Emitted when the Camera2D starts to tween to the PhantomCamera2D.
signal tween_started
## Emitted when the Camera2D is to tweening to the PhantomCamera2D.
signal is_tweening
## Emitted when the tween is interrupted due to another PhantomCamera2D becoming active.
## The argument is the PhantomCamera2D that interrupted the tween.
signal tween_interrupted(pcam_2d: PhantomCamera2D)
## Emitted when the Camera2D completes its tween to the PhantomCamera2D.
signal tween_completed

#endregion


#region Variables

var Properties = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

# BUG Unable to call the variable `Zoom`
# due to a bug where the setter doesn't properly register changes to it
var camera_zoom: Vector2 = Vector2.ONE

var _frame_preview: bool = true

var pixel_perfect: bool

var follow_group_zoom_auto: bool
var follow_group_zoom_min: float = 1
var follow_group_zoom_max: float = 5
var follow_group_zoom_margin: Vector4

static var draw_limits: bool
var _limit_default: int = 10000000
var _limit_sides: Vector4i
var _limit_sides_default: Vector4i = Vector4i(-_limit_default, -_limit_default, _limit_default, _limit_default)
var limit_left: int = -_limit_default
var limit_top: int = -_limit_default
var limit_right: int = _limit_default  
var limit_bottom: int = _limit_default
var limit_node_path: NodePath
var limit_margin: Vector4i
var limit_smoothed: bool
var limit_inactive_pcam: bool

var _camera_offset: Vector2

#endregion


#region Properties

func _get_property_list() -> Array:
	var property_list: Array[Dictionary]
	property_list.append_array(Properties.add_priority_properties())

	property_list.append({
		"name": ZOOM_PROPERTY_NAME,
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

	property_list.append_array(Properties.add_follow_properties())
	property_list.append_array(Properties.add_follow_framed())

	property_list.append({
		"name": FRAME_PREVIEW,
		"type": TYPE_BOOL,
	})

	property_list.append({
		"name": PIXEL_PERFECT_PROPERTY_NAME,
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	property_list.append({
		"name": DRAW_LIMITS,
		"type": TYPE_BOOL
	})

	if limit_node_path.is_empty():
		property_list.append({
			"name": LIMIT_LEFT,
			"type": TYPE_INT
		})
		property_list.append({
			"name": LIMIT_TOP,
			"type": TYPE_INT
		})
		property_list.append({
			"name": LIMIT_RIGHT,
			"type": TYPE_INT
		})
		property_list.append({
			"name": LIMIT_BOTTOM,
			"type": TYPE_INT
		})

	property_list.append({
		"name": LIMIT_NODE_PATH_PROPERTY_NAME,
		"type": TYPE_NODE_PATH,
		"hint": PROPERTY_HINT_NODE_PATH_VALID_TYPES,
		"hint_string": "TileMap" + "," + "CollisionShape2D",
	})

	if limit_node_path:
		property_list.append({
			"name": LIMIT_MARGIN_PROPERTY_NAME,
			"type": TYPE_VECTOR4I,
		})
	property_list.append({
		"name": LIMIT_SMOOTHED,
		"type": TYPE_BOOL
	})

	property_list.append_array(Properties.add_tween_properties())

	property_list.append_array(Properties.add_secondary_properties())

	return property_list

#endregion


#region _set

func _set(property: StringName, value) -> bool:
	Properties.set_priority_property(property, value, self)

	# ZOOM
	if property == ZOOM_PROPERTY_NAME:
		camera_zoom = Vector2(absf(value.x), absf(value.y))
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

	if property == PIXEL_PERFECT_PROPERTY_NAME:
		pixel_perfect = value

	Properties.set_follow_properties(property, value, self)
	Properties.set_tween_properties(property, value, self)
	Properties.set_secondary_properties(property, value, self)
	
	if property == DRAW_LIMITS:
		draw_limits = value
		if Engine.is_editor_hint():
			_draw_camera_2d_limit()
	
	# TODO - Move other properties to use this match (switch) statement
	match property:
		LIMIT_LEFT:
			limit_left = value
			update_limit_all_sides()
		LIMIT_TOP:
			limit_top = value
			update_limit_all_sides()
		LIMIT_RIGHT:
			limit_right = value
			update_limit_all_sides()
		LIMIT_BOTTOM:
			limit_bottom = value
			update_limit_all_sides()

	if property == LIMIT_SMOOTHED:
		limit_smoothed = value
	
	if property == LIMIT_NODE_PATH_PROPERTY_NAME:
		_set_limit_node(value)

	if property == LIMIT_MARGIN_PROPERTY_NAME:
		limit_margin = value
		update_limit_all_sides()

	if property == FRAME_PREVIEW:
		_frame_preview = true if value == null else value
		queue_redraw()

	return false


func _set_limit_node(value: NodePath) -> void:
	set_notify_transform(false)
	
	# Waits for PCam2d's _ready() before trying to validate limit_node_path 
	if not is_node_ready(): await ready
	
	# Removes signal from existing TileMap node
	if is_instance_valid(get_node_or_null(limit_node_path)):
		var prev_limit_node: Node2D = get_node(limit_node_path)
		if prev_limit_node is TileMap:
			if prev_limit_node.changed.is_connected(_on_tile_map_changed):
				prev_limit_node.changed.disconnect(_on_tile_map_changed)
	
	var limit_node: Node2D = get_node_or_null(value)
	
	if is_instance_valid(limit_node):
		if limit_node is TileMap:
			var tile_map_node: TileMap = get_node(value)
			tile_map_node.changed.connect(_on_tile_map_changed)

		elif limit_node is CollisionShape2D:
			var col_shape: CollisionShape2D = get_node(value)
			if col_shape.get_shape() == null:
				printerr("No Shape2D in: ", col_shape.name)
				value = NodePath()
			else:
				set_notify_transform(true)

	limit_node_path = value

	notify_property_list_changed()
	update_limit_all_sides()

#endregion


#region _get

func _get(property: StringName):
	if property == Constants.PRIORITY_OVERRIDE: 						return Properties.priority_override
	if property == Constants.PRIORITY_PROPERTY_NAME: 					return Properties.priority

	if property == ZOOM_PROPERTY_NAME: 									return camera_zoom

	if property == Constants.FOLLOW_MODE_PROPERTY_NAME: 				return Properties.follow_mode
	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME:		return Properties.follow_target_offset_2D
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME: 				return Properties.follow_target_path
	if property == Constants.FOLLOW_GROUP_PROPERTY_NAME: 				return Properties.follow_group_paths

	if property == Constants.FOLLOW_PATH_PROPERTY_NAME: 				return Properties.follow_path_path

	if property == Constants.FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME:	return Properties.follow_framed_dead_zone_width
	if property == Constants.FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME:		return Properties.follow_framed_dead_zone_height
	if property == Constants.FOLLOW_VIEWFINDER_IN_PLAY_NAME:			return Properties.show_viewfinder_in_play

	if property == PIXEL_PERFECT_PROPERTY_NAME:        					return pixel_perfect
	
	if property == FOLLOW_GROUP_ZOOM_AUTO:								return follow_group_zoom_auto
	if property == FOLLOW_GROUP_ZOOM_MIN: 								return follow_group_zoom_min
	if property == FOLLOW_GROUP_ZOOM_MAX: 								return follow_group_zoom_max
	if property == FOLLOW_GROUP_ZOOM_MARGIN:							return follow_group_zoom_margin

	if property == Constants.FOLLOW_DAMPING_NAME: 						return Properties.follow_has_damping
	if property == Constants.FOLLOW_DAMPING_VALUE_NAME: 				return Properties.follow_damping_value

	if property == Constants.TWEEN_RESOURCE_PROPERTY_NAME:				return Properties.tween_resource

	if property == Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME:		return Properties.inactive_update_mode
	if property == Constants.TWEEN_ONLOAD_NAME: 						return Properties.tween_onload
	
	if property == DRAW_LIMITS:											return draw_limits
	if property == LIMIT_LEFT:											return limit_left
	if property == LIMIT_TOP:											return limit_top
	if property == LIMIT_RIGHT:											return limit_right
	if property == LIMIT_BOTTOM:										return limit_bottom
	if property == LIMIT_NODE_PATH_PROPERTY_NAME:						return limit_node_path
	if property == LIMIT_MARGIN_PROPERTY_NAME:							return limit_margin
	if property == LIMIT_SMOOTHED:										return limit_smoothed
	
	if property == FRAME_PREVIEW: 										return _frame_preview

#endregion


#region _property_can_revert

func _property_can_revert(property: StringName) -> bool:
	match property:
		Constants.PRIORITY_OVERRIDE: 									return true
		Constants.PRIORITY_PROPERTY_NAME: 								return true
		
		ZOOM_PROPERTY_NAME: 											return true
		
		Constants.FOLLOW_TARGET_PROPERTY_NAME: 							return true
		Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: 					return true
		
		Constants.FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME: 				return true
		Constants.FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME: 				return true
		Constants.FOLLOW_VIEWFINDER_IN_PLAY_NAME:						return true
		
		Constants.FOLLOW_DAMPING_NAME: 									return true
		Constants.FOLLOW_DAMPING_VALUE_NAME: 							return true
		
		Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME: 					return true
		Constants.TWEEN_ONLOAD_NAME: 									return true
		
		PIXEL_PERFECT_PROPERTY_NAME: 									return true
		
		DRAW_LIMITS: 													return true
		LIMIT_LEFT: 													return true
		LIMIT_TOP:														return true
		LIMIT_RIGHT: 													return true
		LIMIT_BOTTOM: 													return true
		LIMIT_NODE_PATH_PROPERTY_NAME: 									return true
		LIMIT_MARGIN_PROPERTY_NAME: 									return true
		LIMIT_SMOOTHED: 												return true
		
		FRAME_PREVIEW: 													return true
		
		_:
			return false

#endregion


#region _property_get_revert

func _property_get_revert(property: StringName):
	match property:
		Constants.PRIORITY_OVERRIDE: 									return false
		Constants.PRIORITY_PROPERTY_NAME: 								return 0
		
		ZOOM_PROPERTY_NAME:												return Vector2.ONE
		
		Constants.FOLLOW_TARGET_PROPERTY_NAME:							return NodePath()
		Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: 					return Vector2.ZERO
		
		Constants.FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME: 				return 0.5
		Constants.FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME: 				return 0.5
		Constants.FOLLOW_VIEWFINDER_IN_PLAY_NAME:						return false
		
		Constants.FOLLOW_DAMPING_NAME: 									return false
		Constants.FOLLOW_DAMPING_VALUE_NAME: 							return 10.0
		
		Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME: 					return Constants.InactiveUpdateMode.ALWAYS
		Constants.TWEEN_ONLOAD_NAME: 									return true
		
		PIXEL_PERFECT_PROPERTY_NAME: 									return false
		
		DRAW_LIMITS: 													return true
		LIMIT_LEFT: 													return -10000000
		LIMIT_TOP: 														return -10000000
		LIMIT_RIGHT: 													return 10000000
		LIMIT_BOTTOM: 													return 10000000
		LIMIT_NODE_PATH_PROPERTY_NAME: 									return NodePath()
		LIMIT_MARGIN_PROPERTY_NAME: 									return Vector4i.ZERO
		LIMIT_SMOOTHED: 												return false
		
		FRAME_PREVIEW: 													return true

#endregion


#region Private Functions

func _enter_tree() -> void:
	Properties.is_2D = true
	Properties.camera_enter_tree(self)
	Properties.assign_pcam_host(self)

	update_limit_all_sides()

func _exit_tree() -> void:
	if _has_valid_pcam_owner():
		get_pcam_host_owner().pcam_removed_from_scene(self)

	Properties.pcam_exit_tree(self)


func _process(delta: float) -> void:
	if not Properties.is_active:
		match Properties.inactive_update_mode:
			Constants.InactiveUpdateMode.NEVER:
				return
			Constants.InactiveUpdateMode.ALWAYS:
				# Only triggers if limit isn't default
				if limit_inactive_pcam:
					set_global_position(
						_set_limit_clamp_position(get_global_position())
					)
#			Constants.InactiveUpdateMode.EXPONENTIALLY:
#				TODO

	if not Properties.should_follow: return

	match Properties.follow_mode:
		Constants.FollowMode.GLUED:
			if Properties.follow_target_node:
				_set_pcam_global_position(Properties.follow_target_node.get_global_position(), delta)
		Constants.FollowMode.SIMPLE:
			if Properties.follow_target_node:
				_set_pcam_global_position(_target_position_with_offset(), delta)
		Constants.FollowMode.GROUP:
			if Properties.has_follow_group:
				if Properties.follow_group_nodes_2D.size() == 1:
					_set_pcam_global_position(Properties.follow_group_nodes_2D[0].get_global_position(), delta)
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
							camera_zoom = clamp(screen_size.x / rect.size.x, follow_group_zoom_min, follow_group_zoom_max) * Vector2.ONE
						else:
							camera_zoom = clamp(screen_size.y / rect.size.y, follow_group_zoom_min, follow_group_zoom_max) * Vector2.ONE
					_set_pcam_global_position(rect.get_center(), delta)
		Constants.FollowMode.PATH:
				if Properties.follow_target_node and Properties.follow_path_node:
					var path_position: Vector2 = Properties.follow_path_node.get_global_position()
					_set_pcam_global_position(
						Properties.follow_path_node.curve.get_closest_point(
							Properties.follow_target_node.get_global_position() - path_position
						) + path_position,
						delta)
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
								_set_pcam_global_position(_target_position_with_offset(), delta)
							elif dead_zone_width != 0 && dead_zone_height == 0:
								glo_pos = _target_position_with_offset()
								glo_pos.x += target_position.x - global_position.x
								_set_pcam_global_position(glo_pos, delta)
							else:
								_set_pcam_global_position(_target_position_with_offset(), delta)
						else:
							_set_pcam_global_position(target_position, delta)
					else:
						_camera_offset = get_global_position() - _target_position_with_offset()
				else:
					_set_pcam_global_position(_target_position_with_offset(), delta)


func _set_pcam_global_position(_global_position: Vector2, delta: float) -> void:
	if limit_inactive_pcam and not Properties.has_tweened:
		_global_position = _set_limit_clamp_position(_global_position)

	if Properties.follow_has_damping:
		set_global_position(
			get_global_position().lerp(
				_global_position,
				delta * Properties.follow_damping_value
			)
		)
	else:
		set_global_position(_global_position)


func _set_limit_clamp_position(value: Vector2) -> Vector2i:
	var camera_frame_rect_size: Vector2 = _camera_frame_rect().size
	value.x = clampf(value.x, _limit_sides.x + camera_frame_rect_size.x / 2, _limit_sides.z - camera_frame_rect_size.x / 2)
	value.y = clampf(value.y, _limit_sides.y + camera_frame_rect_size.y / 2, _limit_sides.w - camera_frame_rect_size.y / 2)
	return value


func _draw():
	if not Engine.is_editor_hint(): return

	if _frame_preview or not is_active():
		var screen_size_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
		var screen_size_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
		var screen_size_zoom: Vector2 = Vector2(screen_size_width / get_zoom().x, screen_size_height / get_zoom().y)
		
		draw_rect(_camera_frame_rect(), Color("3ab99a"), false, 2)


func _camera_frame_rect() -> Rect2:
	var screen_size_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screen_size_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	var screen_size_zoom: Vector2 = Vector2(screen_size_width / get_zoom().x, screen_size_height / get_zoom().y)
	
	return Rect2(-screen_size_zoom / 2, screen_size_zoom)


func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if Engine.is_editor_hint(): # Used for updating Limit when a CollisionShape2D is applied
			if not is_active():
				update_limit_all_sides()


func _on_tile_map_changed() -> void:
	update_limit_all_sides()


func _target_position_with_offset() -> Vector2:
	return Properties.follow_target_node.get_global_position() + Properties.follow_target_offset_2D


func _has_valid_pcam_owner() -> bool:
	if not is_instance_valid(get_pcam_host_owner()): return false
	if not is_instance_valid(get_pcam_host_owner().camera_2D): return false
	return true


func _draw_camera_2d_limit() -> void:
	if _has_valid_pcam_owner():
		get_pcam_host_owner().camera_2D.set_limit_drawing_enabled(draw_limits)


func _check_limit_is_not_default() -> void:
	if _limit_sides == _limit_sides_default:
		limit_inactive_pcam = false
	else:
		limit_inactive_pcam = true


func _set_camera_2d_limit(side: int, limit: int) -> void:
	if not _has_valid_pcam_owner(): return
	if not is_active(): return
	get_pcam_host_owner().camera_2D.set_limit(side, limit)

#endregion


#region Public Functions

func update_limit_all_sides() -> void:
	var limit_node = get_node_or_null(limit_node_path)
	
	var limit_rect: Rect2
	
	if not is_instance_valid(limit_node):
		_limit_sides.y = limit_top
		_limit_sides.x = limit_left
		_limit_sides.z = limit_right
		_limit_sides.w = limit_bottom
	elif limit_node is TileMap:
		var tile_map: TileMap = limit_node as TileMap
		var tile_map_size: Vector2 = Vector2(tile_map.get_used_rect().size) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()
		var tile_map_position: Vector2 = tile_map.get_global_position() + Vector2(tile_map.get_used_rect().position) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()

		## Calculates the Rect2 based on the Tile Map position and size
		limit_rect = Rect2(tile_map_position, tile_map_size)

		## Calculates the Rect2 based on the Tile Map position and size + margin
		limit_rect = Rect2(
			limit_rect.position + Vector2(limit_margin.x, limit_margin.y),
			limit_rect.size - Vector2(limit_margin.x, limit_margin.y) - Vector2(limit_margin.z, limit_margin.w)
		)
		
		# Left
		_limit_sides.x = roundi(limit_rect.position.x)
		# Top
		_limit_sides.y = roundi(limit_rect.position.y)
		# Right
		_limit_sides.z = roundi(limit_rect.position.x + limit_rect.size.x)
		# Bottom
		_limit_sides.w = roundi(limit_rect.position.y + limit_rect.size.y)
	elif limit_node is CollisionShape2D:
		var collision_shape_2d = limit_node as CollisionShape2D
		
		if not collision_shape_2d.get_shape(): return
		
		var shape_2d: Shape2D = collision_shape_2d.get_shape()
		var shape_2d_size: Vector2 = shape_2d.get_rect().size
		var shape_2d_position: Vector2 = collision_shape_2d.get_global_position() + Vector2(shape_2d.get_rect().position)

		## Calculates the Rect2 based on the Tile Map position and size
		limit_rect = Rect2(shape_2d_position, shape_2d_size)

		## Calculates the Rect2 based on the Tile Map position and size + margin
		limit_rect = Rect2(
			limit_rect.position + Vector2(limit_margin.x, limit_margin.y),
			limit_rect.size - Vector2(limit_margin.x, limit_margin.y) - Vector2(limit_margin.z, limit_margin.w)
		)

		# Left
		_limit_sides.x = roundi(limit_rect.position.x)
		# Top
		_limit_sides.y = roundi(limit_rect.position.y)
		# Right
		_limit_sides.z = roundi(limit_rect.position.x + limit_rect.size.x)
		# Bottom
		_limit_sides.w = roundi(limit_rect.position.y + limit_rect.size.y)
	
	_check_limit_is_not_default()

	if is_active() and _has_valid_pcam_owner():
		_set_camera_2d_limit(SIDE_LEFT, _limit_sides.x)
		_set_camera_2d_limit(SIDE_TOP, _limit_sides.y)
		_set_camera_2d_limit(SIDE_RIGHT, _limit_sides.z)
		_set_camera_2d_limit(SIDE_BOTTOM, _limit_sides.w)


func reset_limit_all_sides() -> void:
	_set_camera_2d_limit(SIDE_LEFT, -_limit_default)
	_set_camera_2d_limit(SIDE_TOP, -_limit_default)
	_set_camera_2d_limit(SIDE_RIGHT, _limit_default)
	_set_camera_2d_limit(SIDE_BOTTOM, _limit_default)

#endregion


#region Setter & Getter Functions

## Assigns the PhantomCamera2D to a new PhantomCameraHost.
func assign_pcam_host() -> void:
	Properties.assign_pcam_host(self)
## Gets the current PhantomCameraHost this PhantomCamera2D is assigned to.
func get_pcam_host_owner() -> PhantomCameraHost:
	return Properties.pcam_host_owner


## Assigns new Zoom value.
func set_zoom(value: Vector2) -> void:
	camera_zoom = value
## Gets current Zoom value.
func get_zoom() -> Vector2:
	return camera_zoom


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
	if Properties.follow_target_node == value:
		return
	Properties.follow_target_node = value
	Properties.should_follow = Properties.follow_target_node != null
	follow_target_changed.emit()
## Erases the current Node2D from the Follow Target property.
func erase_follow_target_node() -> void:
	if Properties.follow_target_node == null:
		return
	Properties.follow_target_node = null
	Properties.should_follow = false
	follow_target_changed.emit()
## Gets the current Node2D target property.
func get_follow_target_node():
	return Properties.follow_target_node


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
## Gets the current Follow Damping property.
func get_follow_has_damping() -> bool:
	return Properties.follow_has_damping

## Assigns new Damping value.
func set_follow_damping_value(value: float) -> void:
	Properties.follow_damping_value = value
## Gets the current Follow Damping value.
func get_follow_damping_value() -> float:
	return Properties.follow_damping_value

## Enables or disables Pixel Perfect following.
func set_pixel_perfect(value: bool) -> void:
	pixel_perfect = value
## Gets the current Pixel Perfect property.
func get_pixel_perfect() -> bool:
	return pixel_perfect


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

## Assign a the Camera2D Limit Side value.
func set_limit(side: int, value: int) -> void:
	if not limit_node_path.is_empty():
		printerr("Unable to set Limit Side due to Limit Node, ", get_node(limit_node_path).name,  ", being assigned")
	else:
		match side:
			SIDE_LEFT: 		limit_left = value
			SIDE_TOP: 		limit_top = value
			SIDE_RIGHT: 	limit_right = value
			SIDE_BOTTOM: 	limit_bottom = value
			_:				printerr("Not a valid Side parameter.")
		update_limit_all_sides()
## Gets the Camera2D Limit value.
func get_limit(side: int) -> int:
	match side:
		SIDE_LEFT: 		return limit_left
		SIDE_TOP: 		return limit_top
		SIDE_RIGHT: 	return limit_right
		SIDE_BOTTOM: 	return limit_bottom
		_:
						printerr("Not a valid Side parameter.")
						return -1

# Set Tile Map Limit Node.
func set_limit_node(value: Node2D) -> void:
	_set_limit_node(value.get_path())
## Get Tile Map Limit Node
func get_limit_node() -> Node2D:
	if not get_node_or_null(limit_node_path):
		printerr("No Tile Map Limit Node set")
		return null
	return get_node(limit_node_path)

## Set Tile Map Limit Margin.
func set_limit_margin(value: Vector4) -> void:
	limit_margin = value
## Get Tile Map Limit Margin.
func get_limit_margin() -> Vector4:
	return limit_margin

## Enables or disables the Limit Smoothing beaviour.
func set_limit_smoothing_enabled(value: bool) -> void:
	limit_smoothed = value
	if is_active() and _has_valid_pcam_owner():
		get_pcam_host_owner().camera_2D.reset_smoothing()
## Returns the Limit Smoothing beaviour.
func get_limit_smoothing_enabled() -> bool:
	return limit_smoothed

## Gets Interactive Update Mode property.
func get_inactive_update_mode() -> String:
	return Constants.InactiveUpdateMode.keys()[Properties.inactive_update_mode].capitalize()

#endregion
