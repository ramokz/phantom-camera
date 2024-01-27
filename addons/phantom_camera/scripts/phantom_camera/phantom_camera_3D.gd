@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg")
class_name PhantomCamera3D
extends Node3D

#region Constants

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

const FOLLOW_DISTANCE_PROPERTY_NAME: 						StringName = Constants.FOLLOW_PARAMETERS_NAME + "distance"
const FOLLOW_GROUP_DISTANCE_AUTO_NAME: 						StringName = Constants.FOLLOW_PARAMETERS_NAME + "auto_distance"
const FOLLOW_GROUP_DISTANCE_AUTO_MIN_NAME: 					StringName = Constants.FOLLOW_PARAMETERS_NAME + "min_distance"
const FOLLOW_GROUP_DISTANCE_AUTO_MAX_NAME: 					StringName = Constants.FOLLOW_PARAMETERS_NAME + "max_distance"
const FOLLOW_GROUP_DISTANCE_AUTO_DIVISOR: 					StringName = Constants.FOLLOW_PARAMETERS_NAME + "auto_distance_divisor"

const SPRING_ARM_PROPERTY_NAME: 							StringName = "spring_arm/"
const FOLLOW_SPRING_ARM_COLLISION_MASK_NAME: 				StringName = Constants.FOLLOW_PARAMETERS_NAME + SPRING_ARM_PROPERTY_NAME + "collision_mask"
const FOLLOW_SPRING_ARM_SHAPE_NAME: 						StringName = Constants.FOLLOW_PARAMETERS_NAME + SPRING_ARM_PROPERTY_NAME + "shape"
const FOLLOW_SPRING_ARM_SPRING_LENGTH_NAME: 				StringName = Constants.FOLLOW_PARAMETERS_NAME + SPRING_ARM_PROPERTY_NAME + "spring_length"
const FOLLOW_SPRING_ARM_MARGIN_NAME: 						StringName = Constants.FOLLOW_PARAMETERS_NAME + SPRING_ARM_PROPERTY_NAME + "margin"

const LOOK_AT_MODE_PROPERTY_NAME: 							StringName = "look_at_mode"
const LOOK_AT_TARGET_PROPERTY_NAME: 						StringName = "look_at_target"
const LOOK_AT_GROUP_PROPERTY_NAME: 							StringName = "look_at_group"
const LOOK_AT_PARAMETERS_NAME: 								StringName = "look_at_parameters/"
const LOOK_AT_TARGET_OFFSET_PROPERTY_NAME: 					StringName = LOOK_AT_PARAMETERS_NAME + "look_at_target_offset"

const CAMERA_3D_RESOURCE_PROPERTY_NAME: StringName = "camera_3D_resource"

#endregion


#region Signals

## Emitted when the PhantomCamera3D becomes active.
signal became_active
## Emitted when the PhantomCamera3D becomes inactive.
signal became_inactive
## Emitted when follow_target changes
signal follow_target_changed

## Emitted when the Camera3D starts to tween to the PhantomCamera3D.
signal tween_started
## Emitted when the Camera3D is to tweening to the PhantomCamera3D.
signal is_tweening
## Emitted when the tween is interrupted due to another PhantomCamera3D becoming active.
## The argument is the PhantomCamera3D that interrupted the tween.
signal tween_interrupted(pcam_3d: PhantomCamera3D)
## Emitted when the Camera3D completes its tween to the	 PhantomCamera3D.
signal tween_completed

#endregion


#region Variables

var Properties: Object = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_properties.gd").new()

var follow_distance: float = 1:
	set(value):
		follow_distance = value
		if is_instance_valid(Properties.follow_target_node) and Properties.follow_mode != Constants.FollowMode.THIRD_PERSON:
			set_global_position(_get_target_position_offset())
	get:
		return follow_distance

var _follow_group_distance_auto: bool
var _follow_group_distance_auto_min: float = 1
var _follow_group_distance_auto_max: float = 5
var _follow_group_distance_auto_divisor: float = 10
var _camera_offset: Vector3
var _current_rotation: Vector3

var _follow_spring_arm_node: SpringArm3D
var _follow_spring_arm_collision_mask: int = 1
var _follow_spring_arm_shape: Shape3D
var _follow_spring_arm_margin: float = 0.01


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

var _should_look_at: bool
var _has_look_at_target: bool
var _has_look_at_target_group: bool

var look_at_mode_enum: LookAtMode = LookAtMode.NONE

var look_at_target_offset: Vector3

var _camera_3D_resouce: Camera3DResource
var _camera_3D_resouce_default: Camera3DResource = Camera3DResource.new()

#endregion


#region Properties

func _get_property_list() -> Array:
	var property_list: Array[Dictionary]

#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	property_list.append_array(Properties.add_multiple_hosts_properties())

	property_list.append_array(Properties.add_priority_properties())
	property_list.append_array(Properties.add_follow_mode_property())

	if Properties.follow_mode != Constants.FollowMode.NONE:
		property_list.append_array(Properties.add_follow_target_property())

		if Properties.follow_mode == Constants.FollowMode.GROUP or \
		Properties.follow_mode == Constants.FollowMode.FRAMED:
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

		if Properties.follow_mode == Constants.FollowMode.THIRD_PERSON:
			property_list.append({
				"name": FOLLOW_SPRING_ARM_SPRING_LENGTH_NAME,
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
			})
			property_list.append({
				"name": FOLLOW_SPRING_ARM_COLLISION_MASK_NAME,
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_LAYERS_3D_PHYSICS,
				"usage": PROPERTY_USAGE_DEFAULT,
			})
			property_list.append({
				"name": FOLLOW_SPRING_ARM_SHAPE_NAME,
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Shape3D"
			})
			property_list.append({
				"name": FOLLOW_SPRING_ARM_MARGIN_NAME,
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
			})

	property_list.append_array(Properties.add_follow_properties())
	property_list.append_array(Properties.add_follow_framed())

	property_list.append({
		"name": LOOK_AT_MODE_PROPERTY_NAME,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ", ".join(PackedStringArray(LookAtMode.keys())).capitalize(),
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	if look_at_mode_enum != LookAtMode.NONE:
		if look_at_mode_enum == LookAtMode.GROUP:
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
			if look_at_mode_enum == LookAtMode.SIMPLE or look_at_mode_enum == LookAtMode.GROUP:
				property_list.append({
					"name": LOOK_AT_TARGET_OFFSET_PROPERTY_NAME,
					"type": TYPE_VECTOR3,
					"hint": PROPERTY_HINT_NONE,
					"usage": PROPERTY_USAGE_DEFAULT,
				})

	property_list.append_array(Properties.add_tween_properties())
	property_list.append_array(Properties.add_secondary_properties())

	property_list.append({
		"name": CAMERA_3D_RESOURCE_PROPERTY_NAME,
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Camera3DResource"
	})

	return property_list


func _set(property: StringName, value) -> bool:
#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	Properties.set_phantom_host_property(property, value, self)
	Properties.set_priority_property(property, value, self)

	Properties.set_follow_properties(property, value, self)

	if Properties.follow_mode == Constants.FollowMode.FRAMED:
		if Properties.follow_framed_initial_set and Properties.follow_target_node:
			Properties.follow_framed_initial_set = false
			Properties.connect(Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed)
	else:
		if Properties.is_connected(Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed):
			Properties.disconnect(Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed)

	if property == FOLLOW_DISTANCE_PROPERTY_NAME or property == FOLLOW_SPRING_ARM_SPRING_LENGTH_NAME:
		if value <= 0:
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


	if property == FOLLOW_SPRING_ARM_COLLISION_MASK_NAME:
		_follow_spring_arm_collision_mask = value

	if property == FOLLOW_SPRING_ARM_MARGIN_NAME:
		_follow_spring_arm_margin = value

	if property == FOLLOW_SPRING_ARM_SHAPE_NAME:
		_follow_spring_arm_shape = value


	# Look At Properties
	if property == LOOK_AT_MODE_PROPERTY_NAME:
		if value == null:
			value = LookAtMode.NONE

		look_at_mode_enum = value

		if look_at_mode_enum == LookAtMode.NONE:
			_should_look_at = false
		else:
			_should_look_at = true

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
		if not is_node_ready(): await ready
		
		if not value_node_path.is_empty():
			_should_look_at = true
			if has_node(_look_at_target_path):
				_has_look_at_target = true
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

	if property == CAMERA_3D_RESOURCE_PROPERTY_NAME:
		_camera_3D_resouce = value

	return false


func _get(property: StringName):
#	TODO - For https://github.com/MarcusSkov/phantom-camera/issues/26
#	if property == Constants.PHANTOM_CAMERA_HOST: return Properties.pcam_host_owner.name

	if property == Constants.PRIORITY_OVERRIDE: 						return Properties.priority_override
	if property == Constants.PRIORITY_PROPERTY_NAME: 					return Properties.priority

	if property == Constants.FOLLOW_MODE_PROPERTY_NAME: 				return Properties.follow_mode
	if property == Constants.FOLLOW_TARGET_PROPERTY_NAME: 				return Properties.follow_target_path
	if property == Constants.FOLLOW_GROUP_PROPERTY_NAME: 				return Properties.follow_group_paths
	if property == Constants.FOLLOW_PATH_PROPERTY_NAME: 				return Properties.follow_path_path
	if property == FOLLOW_DISTANCE_PROPERTY_NAME:				 		return follow_distance
	if property == Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME	: 		return Properties.follow_target_offset_3D

	if property == FOLLOW_GROUP_DISTANCE_AUTO_NAME:						return _follow_group_distance_auto
	if property == FOLLOW_GROUP_DISTANCE_AUTO_MIN_NAME:					return _follow_group_distance_auto_min
	if property == FOLLOW_GROUP_DISTANCE_AUTO_MAX_NAME:					return _follow_group_distance_auto_max
	if property == FOLLOW_GROUP_DISTANCE_AUTO_DIVISOR:					return _follow_group_distance_auto_divisor

	if property == Constants.FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME:	return Properties.follow_framed_dead_zone_width
	if property == Constants.FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME:		return Properties.follow_framed_dead_zone_height
	if property == Constants.FOLLOW_VIEWFINDER_IN_PLAY_NAME:			return Properties.show_viewfinder_in_play

	if property == FOLLOW_SPRING_ARM_COLLISION_MASK_NAME:				return _follow_spring_arm_collision_mask
	if property == FOLLOW_SPRING_ARM_SHAPE_NAME:						return _follow_spring_arm_shape
	if property == FOLLOW_SPRING_ARM_SPRING_LENGTH_NAME:				return follow_distance
	if property == FOLLOW_SPRING_ARM_MARGIN_NAME:						return _follow_spring_arm_margin

	if property == Constants.FOLLOW_DAMPING_NAME: 						return Properties.follow_has_damping
	if property == Constants.FOLLOW_DAMPING_VALUE_NAME: 				return Properties.follow_damping_value

	if property == LOOK_AT_MODE_PROPERTY_NAME: 							return look_at_mode_enum
	if property == LOOK_AT_TARGET_PROPERTY_NAME: 						return _look_at_target_path
	if property == LOOK_AT_TARGET_OFFSET_PROPERTY_NAME: 				return look_at_target_offset
	if property == LOOK_AT_GROUP_PROPERTY_NAME:							return _look_at_group_paths

	if property == Constants.TWEEN_RESOURCE_PROPERTY_NAME: 				return Properties.tween_resource

	if property == Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME:		return Properties.inactive_update_mode
	if property == Constants.TWEEN_ONLOAD_NAME: 						return Properties.tween_onload

	if property ==  CAMERA_3D_RESOURCE_PROPERTY_NAME:					return _camera_3D_resouce

#endregion


#region _property_can_revert

func _property_can_revert(property: StringName) -> bool:
	match property:
		Constants.PRIORITY_OVERRIDE: 									return true
		Constants.PRIORITY_PROPERTY_NAME: 								return true
		
		Constants.FOLLOW_TARGET_PROPERTY_NAME:							return true
		Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: 					return true
		
		FOLLOW_DISTANCE_PROPERTY_NAME:				 					return true
		FOLLOW_GROUP_DISTANCE_AUTO_NAME:								return true
		FOLLOW_GROUP_DISTANCE_AUTO_MIN_NAME:							return true
		FOLLOW_GROUP_DISTANCE_AUTO_MAX_NAME:							return true
		FOLLOW_GROUP_DISTANCE_AUTO_DIVISOR:								return true
		
		Constants.FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME: 				return true
		Constants.FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME: 				return true
		Constants.FOLLOW_VIEWFINDER_IN_PLAY_NAME:						return true

		FOLLOW_SPRING_ARM_COLLISION_MASK_NAME:							return true
		FOLLOW_SPRING_ARM_SHAPE_NAME:									return true
		FOLLOW_SPRING_ARM_SPRING_LENGTH_NAME:							return true
		FOLLOW_SPRING_ARM_MARGIN_NAME:									return true
		
		Constants.FOLLOW_DAMPING_NAME: 									return true
		Constants.FOLLOW_DAMPING_VALUE_NAME: 							return true
		
		Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME: 					return true
		Constants.TWEEN_ONLOAD_NAME: 									return true
		
		CAMERA_3D_RESOURCE_PROPERTY_NAME: 								return true
		
		_:
			return false

#endregion


#region _property_get_revert

func _property_get_revert(property: StringName) -> Variant:
	match property:
		Constants.PRIORITY_OVERRIDE: 									return false
		Constants.PRIORITY_PROPERTY_NAME: 								return 0
		
		Constants.FOLLOW_TARGET_PROPERTY_NAME:							return NodePath()
		Constants.FOLLOW_TARGET_OFFSET_PROPERTY_NAME: 					return Vector3.ZERO
		
		FOLLOW_DISTANCE_PROPERTY_NAME:				 					return 1
		FOLLOW_GROUP_DISTANCE_AUTO_NAME:								return false
		FOLLOW_GROUP_DISTANCE_AUTO_MIN_NAME:							return 1
		FOLLOW_GROUP_DISTANCE_AUTO_MAX_NAME:							return 5
		FOLLOW_GROUP_DISTANCE_AUTO_DIVISOR:								return 10
		
		Constants.FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME: 				return 0.5
		Constants.FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME: 				return 0.5
		Constants.FOLLOW_VIEWFINDER_IN_PLAY_NAME:						return false
		
		FOLLOW_SPRING_ARM_COLLISION_MASK_NAME:							return 1
		FOLLOW_SPRING_ARM_SHAPE_NAME:									return null
		FOLLOW_SPRING_ARM_SPRING_LENGTH_NAME:							return 1
		FOLLOW_SPRING_ARM_MARGIN_NAME:									return 0.01
		
		Constants.FOLLOW_DAMPING_NAME: 									return false
		Constants.FOLLOW_DAMPING_VALUE_NAME: 							return 10
		
		Constants.INACTIVE_UPDATE_MODE_PROPERTY_NAME: 					return Constants.InactiveUpdateMode.ALWAYS
		Constants.TWEEN_ONLOAD_NAME: 									return true
		
		CAMERA_3D_RESOURCE_PROPERTY_NAME: 								return null
	
	return null
#endregion


#region Private Functions

func _enter_tree() -> void:
	Properties.is_2D = false;
	Properties.camera_enter_tree(self)
	Properties.assign_pcam_host(self)

	if not get_parent() is SpringArm3D:
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
	if _has_valid_pcam_owner():
		get_pcam_host_owner().pcam_removed_from_scene(self)

	Properties.pcam_exit_tree(self)


func _ready():
	if Properties.follow_mode == Constants.FollowMode.THIRD_PERSON:
		if not Engine.is_editor_hint():
			if not is_instance_valid(_follow_spring_arm_node):
				_follow_spring_arm_node = SpringArm3D.new()
				get_parent().add_child.call_deferred(_follow_spring_arm_node)
	if Properties.follow_mode == Constants.FollowMode.FRAMED:
		if not Engine.is_editor_hint():
			_camera_offset = global_position - _get_target_position_offset()
			_current_rotation = get_global_rotation()


func _process(delta: float) -> void:
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
					_interpolate_position(
						Properties.follow_target_node.get_global_position(),
						delta
					)
			Constants.FollowMode.SIMPLE:
				if Properties.follow_target_node:
					_interpolate_position(
						_get_target_position_offset(),
						delta
					)
			Constants.FollowMode.GROUP:
				if Properties.has_follow_group:
					if Properties.follow_group_nodes_3D.size() == 1:
						_interpolate_position(
							Properties.follow_group_nodes_3D[0].get_global_position() +
							Properties.follow_target_offset_3D +
							get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance),
							delta
						)
					elif Properties.follow_group_nodes_3D.size() > 1:
						var bounds: AABB = AABB(Properties.follow_group_nodes_3D[0].get_global_position(), Vector3.ZERO)
						for node in Properties.follow_group_nodes_3D:
							bounds = bounds.expand(node.get_global_position())

						var distance: float
						if _follow_group_distance_auto:
							distance = lerp(_follow_group_distance_auto_min, _follow_group_distance_auto_max, bounds.get_longest_axis_size() / _follow_group_distance_auto_divisor)
							distance = clamp(distance, _follow_group_distance_auto_min, _follow_group_distance_auto_max)
						else:
							distance = follow_distance

						_interpolate_position(
							bounds.get_center() +
							Properties.follow_target_offset_3D +
							get_transform().basis.z * Vector3(distance, distance, distance),
							delta
						)
			Constants.FollowMode.PATH:
				if Properties.follow_target_node and Properties.follow_path_node:
					var path_position: Vector3 = Properties.follow_path_node.get_global_position()
					_interpolate_position(
						Properties.follow_path_node.curve.get_closest_point(Properties.follow_target_node.get_global_position() - path_position) + path_position,
						delta
					)
			Constants.FollowMode.FRAMED:
				if Properties.follow_target_node:
					if not Engine.is_editor_hint():
						if !is_active() || get_pcam_host_owner().trigger_pcam_tween:
							_interpolate_position(
								_get_position_offset_distance(),
								delta
							)
							return
						
						Properties.viewport_position = get_viewport().get_camera_3d().unproject_position(_get_target_position_offset())
						var visible_rect_size: Vector2 = get_viewport().get_viewport().size
						Properties.viewport_position = Properties.viewport_position / visible_rect_size
						_current_rotation = get_global_rotation()

						if _current_rotation != get_global_rotation():
							_interpolate_position(
								_get_position_offset_distance(),
								delta
							)

						if Properties.get_framed_side_offset() != Vector2.ZERO:
							var target_position: Vector3 = _get_target_position_offset() + _camera_offset
							var dead_zone_width: float = Properties.follow_framed_dead_zone_width
							var dead_zone_height: float = Properties.follow_framed_dead_zone_height
							var glo_pos: Vector3

							if dead_zone_width == 0 || dead_zone_height == 0:
								if dead_zone_width == 0 && dead_zone_height != 0:
									glo_pos = _get_position_offset_distance()
									glo_pos.z = target_position.z
									_interpolate_position(
										glo_pos,
										delta
									)
								elif dead_zone_width != 0 && dead_zone_height == 0:
									glo_pos = _get_position_offset_distance()
									glo_pos.x = target_position.x
									_interpolate_position(
										glo_pos,
										delta
									)
								else:
									_interpolate_position(
										_get_position_offset_distance(),
										delta
									)
							else:
								if _current_rotation != get_global_rotation():
									var opposite: float = sin(-get_global_rotation().x) * follow_distance + _get_target_position_offset().y
									glo_pos.y = _get_target_position_offset().y + opposite
									glo_pos.z = sqrt(pow(follow_distance, 2) - pow(opposite, 2)) + _get_target_position_offset().z
									glo_pos.x = global_position.x

									_interpolate_position(
										glo_pos,
										delta
									)
									_current_rotation = get_global_rotation()
								else:
									_interpolate_position(
										target_position,
										delta
									)
						else:
							_camera_offset = global_position - _get_target_position_offset()
							_current_rotation = get_global_rotation()
					else:
						set_global_position(_get_position_offset_distance())
						var unprojected_position: Vector2 = _get_raw_unprojected_position()
						var viewport_width: float = get_viewport().size.x
						var viewport_height: float = get_viewport().size.y
						var camera_aspect: Camera3D.KeepAspect = get_viewport().get_camera_3d().keep_aspect
						var visible_rect_size: Vector2 = get_viewport().get_viewport().size

						unprojected_position = unprojected_position - visible_rect_size / 2
						if camera_aspect == Camera3D.KeepAspect.KEEP_HEIGHT:
#							Landscape View
							var aspect_ratio_scale: float = viewport_width / viewport_height
							unprojected_position.x = (unprojected_position.x / aspect_ratio_scale + 1) / 2
							unprojected_position.y = (unprojected_position.y + 1) / 2
						else:
#							Portrait View
							var aspect_ratio_scale: float = viewport_height / viewport_width
							unprojected_position.x = (unprojected_position.x + 1) / 2
							unprojected_position.y = (unprojected_position.y / aspect_ratio_scale + 1) / 2

						Properties.viewport_position = unprojected_position
			Constants.FollowMode.THIRD_PERSON:
				if Properties.follow_target_node:
					if not Engine.is_editor_hint():
						if is_instance_valid(Properties.follow_target_node):
							if is_instance_valid(_follow_spring_arm_node):
								if not get_parent() == _follow_spring_arm_node:
									var follow_target: Node3D = Properties.follow_target_node
									_follow_spring_arm_node.set_rotation_degrees(get_rotation_degrees())
									_follow_spring_arm_node.set_length(follow_distance)
									_follow_spring_arm_node.set_collision_mask(_follow_spring_arm_collision_mask)
									_follow_spring_arm_node.set_shape(_follow_spring_arm_shape)
									_follow_spring_arm_node.set_margin(_follow_spring_arm_margin)
									_follow_spring_arm_node.set_global_position(_get_target_position_offset()) # Ensure the PCam3D starts at the right position at runtime

									if not is_tween_on_load():
										Properties.has_tweened = true

									reparent(_follow_spring_arm_node)

								_interpolate_position(
									_get_target_position_offset(),
									delta,
									_follow_spring_arm_node
								)
					else:
						set_global_position(_get_position_offset_distance())

	if _should_look_at:
		match look_at_mode_enum:
			LookAtMode.MIMIC:
				if _has_look_at_target:
					set_global_rotation(_look_at_target_node.get_global_rotation())
			LookAtMode.SIMPLE:
				if _has_look_at_target:
					look_at(_look_at_target_node.get_global_position() + look_at_target_offset)
			LookAtMode.GROUP:
				if _has_look_at_target_group:
					if _look_at_group_nodes.size() == 1:
						look_at(_look_at_group_nodes[0].get_global_position() + look_at_target_offset)
					elif _look_at_group_nodes.size() > 1:
						var bounds: AABB = AABB(_look_at_group_nodes[0].get_global_position(), Vector3.ZERO)
						for node in _look_at_group_nodes:
							bounds = bounds.expand(node.get_global_position())
						look_at(bounds.get_center() + look_at_target_offset)


func _get_target_position_offset() -> Vector3:
	return Properties.follow_target_node.get_global_position() + Properties.follow_target_offset_3D


func _get_position_offset_distance() -> Vector3:
	return _get_target_position_offset() + \
	get_transform().basis.z * Vector3(follow_distance, follow_distance, follow_distance)


func _interpolate_position(_global_position: Vector3, delta: float, target: Node3D = self) -> void:
	if Properties.follow_has_damping:
		target.set_global_position(
			target.get_global_position().lerp(
				_global_position,
				delta * Properties.follow_damping_value
			)
		)
	else:
		target.set_global_position(_global_position)


func _get_raw_unprojected_position() -> Vector2:
	return get_viewport().get_camera_3d().unproject_position(Properties.follow_target_node.get_global_position() + Properties.follow_target_offset_3D)


func _on_dead_zone_changed() -> void:
	set_global_position( _get_position_offset_distance() )


func _has_valid_pcam_owner() -> bool:
	if not is_instance_valid(get_pcam_host_owner()): return false
	if not is_instance_valid(get_pcam_host_owner().camera_3D): return false
	return true

#endregion

# TBD
#func get_unprojected_position() -> Vector2:
	#var unprojected_position: Vector2 = _get_raw_unprojected_position()
	#var viewport_width: float = get_viewport().size.x
	#var viewport_height: float = get_viewport().size.y
	#var camera_aspect: Camera3D.KeepAspect = get_viewport().get_camera_3d().keep_aspect
	#var visible_rect_size: Vector2 = get_viewport().size
#
	#unprojected_position = unprojected_position - visible_rect_size / 2
	#if camera_aspect == Camera3D.KeepAspect.KEEP_HEIGHT:
##	print("Landscape View")
		#var aspect_ratio_scale: float = viewport_width / viewport_height
		#unprojected_position.x = (unprojected_position.x / aspect_ratio_scale + 1) / 2
		#unprojected_position.y = (unprojected_position.y + 1) / 2
	#else:
##	print("Portrait View")
		#var aspect_ratio_scale: float = viewport_height / viewport_width
		#unprojected_position.x = (unprojected_position.x + 1) / 2
		#unprojected_position.y = (unprojected_position.y / aspect_ratio_scale + 1) / 2
#
	#return unprojected_position


#region Setter & Getter Functions

## Assigns the PhantomCamera3D to a new PhantomCameraHost.
func assign_pcam_host() -> void:
	Properties.assign_pcam_host(self)
## Gets the current PhantomCameraHost this PhantomCamera3D is assigned to.
func get_pcam_host_owner() -> PhantomCameraHost:
	return Properties.pcam_host_owner


## Assigns new Priority value.
func set_priority(value: int) -> void:
	Properties.set_priority(value, self)
## Gets current Priority value.
func get_priority() -> int:
	return Properties.priority


## Assigns a new PhantomCameraTween resource to the PhantomCamera3D
func set_tween_resource(value: PhantomCameraTween) -> void:
	Properties.tween_resource = value
## Gets the PhantomCameraTween resource assigned to the PhantomCamera3D
## Returns null if there's nothing assigned to it.
func get_tween_resource() -> PhantomCameraTween:
	return Properties.tween_resource

## Assigns a new Tween Duration value. The duration value is in seconds.
## Note: This will override and make the Tween Resource unique to this PhantomCamera3D.
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
	if Properties.tween_resource:
		return Properties.tween_resource.duration
	else:
		return Properties.tween_resource_default.duration

## Assigns a new Tween Transition value.
## Note: This will override and make the Tween Resource unique to this PhantomCamera3D.
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
		return Properties.tween_resource.transition
	else:
		return Properties.tween_resource_default.transition

## Assigns a new Tween Ease value.
## Note: This will override and make the Tween Resource unique to this PhantomCamera3D.
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
		return Properties.tween_resource.ease
	else:
		return Properties.tween_resource_default.ease


## Gets current active state of the PhantomCamera3D.
## If it returns true, it means the PhantomCamera3D is what the Camera2D is currently following.
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


## Assigns a new Node3D as the Follow Target.
func set_follow_target_node(value: Node3D) -> void:
	if Properties.follow_target_node == value:
		return
	Properties.follow_target_node = value
	Properties.should_follow = Properties.follow_target_node != null
	follow_target_changed.emit()
## Removes the current Node3D Follow Target.
func erase_follow_target_node() -> void:
	if Properties.follow_target_node == null:
		return
	Properties.follow_target_node = null
	Properties.should_follow = false
	follow_target_changed.emit()
## Gets the current Node3D target.
func get_follow_target_node():
	return Properties.follow_target_node


## Assigns a new Path3D to the Follow Path property.
func set_follow_path(value: Path3D) -> void:
	Properties.follow_path_node = value
## Erases the current Path3D frp, the Follow Target
func erase_follow_path() -> void:
	Properties.follow_path_node = null
## Gets the current Path2D from the Follow Path property.
func get_follow_path():
	if Properties.follow_path_node:
		return Properties.follow_path_node
	else:
		printerr("No Follow Path assigned")


## Assigns a new Vector3 for the Follow Target Offset property.
func set_follow_target_offset(value: Vector3) -> void:
	Properties.follow_target_offset_3D = value
## Gets the current Vector3 for the Follow Target Offset property.
func get_follow_target_offset() -> Vector3:
	return Properties.follow_target_offset_3D


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


## Assigns a new Follow Distance value.
func set_follow_distance(value: float) -> void:
	follow_distance = value
## Gets Follow Distance value.
func get_follow_distance() -> float:
	return follow_distance


## Adds a single Node3D to Follow Group array.
func append_follow_group_node(value: Node3D) -> void:
	if not Properties.follow_group_nodes_3D.has(value):
		Properties.follow_group_nodes_3D.append(value)
		Properties.should_follow = true
		Properties.has_follow_group = true
	else:
		printerr(value, " is already part of Follow Group")
## Adds an Array of type Node3D to Follow Group array.
func append_follow_group_node_array(value: Array[Node3D]) -> void:
	for val in value:
		if not Properties.follow_group_nodes_3D.has(val):
			Properties.follow_group_nodes_3D.append(val)
			Properties.should_follow = true
			Properties.has_follow_group = true
		else:
			printerr(value, " is already part of Follow Group")
## Removes Node3D from Follow Group array.
func erase_follow_group_node(value: Node3D) -> void:
	Properties.follow_group_nodes_3D.erase(value)
	if get_follow_group_nodes().size() < 1:
		Properties.should_follow = false
		Properties.has_follow_group = false
## Gets all Node3D from Follow Group array.
func get_follow_group_nodes() -> Array[Node3D]:
	return Properties.follow_group_nodes_3D

## Enables or disables Auto Follow Distance when using Group Follow.
func set_auto_follow_distance(value: bool) -> void:
	_follow_group_distance_auto = value
## Gets Auto Follow Distance state.
func get_auto_follow_distance() -> bool:
	return _follow_group_distance_auto

## Assigns new Min Auto Follow Distance value.
func set_min_auto_follow_distance(value: float) -> void:
	_follow_group_distance_auto_min = value
## Gets Min Auto Follow Distance value.
func get_min_auto_follow_distance() -> float:
	return _follow_group_distance_auto_min

## Assigns new Max Auto Follow Distance value.
func set_max_auto_follow_distance(value: float) -> void:
	_follow_group_distance_auto_max = value
## Gets Max Auto Follow Distance value.
func get_max_auto_follow_distance() -> float:
	return _follow_group_distance_auto_max

## Assigns new Auto Follow Distance Divisor value.
func set_auto_follow_distance_divisor(value: float) -> void:
	_follow_group_distance_auto_divisor = value
## Gets Auto Follow Divisor value.
func get_auto_follow_distance_divisor() -> float:
	return _follow_group_distance_auto_divisor

## Assigns new rotation (in radians) value to SpringArm for Third Person Follow mode.
func set_third_person_rotation(value: Vector3) -> void:
	_follow_spring_arm_node.rotation = value
## Gets the rotation value (in radians) from the SpringArm for Third Person Follow mode.
func get_third_person_rotation() -> Vector3:
	return _follow_spring_arm_node.rotation
## Assigns new rotation (in degrees) value to SpringArm for Third Person Follow mode.
func set_third_person_rotation_degrees(value: Vector3) -> void:
	_follow_spring_arm_node.rotation_degrees = value
## Gets the rotation value (in degrees) from the SpringArm for Third Person Follow mode.
func get_third_person_rotation_degrees() -> Vector3:
	return _follow_spring_arm_node.rotation_degrees

## Assigns a new Third Person SpringArm3D Length value.
func set_spring_arm_spring_length(value: float) -> void:
	follow_distance = value
	_follow_spring_arm_node.set_length(value)
## Gets Third Person SpringArm3D Length value.
func get_spring_arm_spring_length() -> float:
	return follow_distance

## Assigns a new Third Person SpringArm3D Collision Mask value.
func set_spring_arm_collision_mask(value: int) -> void:
	_follow_spring_arm_collision_mask = value
## Gets Third Person SpringArm3D Collision Mask value.
func get_spring_arm_collision_mask() -> int:
	return _follow_spring_arm_collision_mask

## Assigns a new Third Person SpringArm3D Shape value.
func set_spring_arm_shape(value: Shape3D) -> void:
	_follow_spring_arm_shape = value
## Gets Third Person SpringArm3D Shape value.
func get_spring_arm_shape() -> Shape3D:
	return _follow_spring_arm_shape

## Assigns a new Third Person SpringArm3D Margin value.
func set_spring_arm_margin(value: float) -> void:
	_follow_spring_arm_margin = value
## Gets Third Person SpringArm3D Margin value.
func get_spring_arm_margin() -> float:
	return _follow_spring_arm_margin


## Gets Look At Mode. Value is based on LookAtMode enum.
## Note: To set a new Look At Mode, a separate PhantomCamera3D should be used.
func get_look_at_mode() -> int:
	return look_at_mode_enum

## Assigns new Node3D as Look At Target.
func set_look_at_target(value: Node3D) -> void:
	_look_at_target_node = value
	_should_look_at = true
	_has_look_at_target = true
## Gets current Node3D from Look At Target property.
func get_look_at_target():
	if _look_at_target_node:
		return _look_at_target_node
	else:
		printerr("No Look At target node assigned")


## Assigns a new Vector3 to the Look At Target Offset value.
func set_look_at_target_offset(value: Vector3) -> void:
	look_at_target_offset = value
## Gets the current Look At Target Offset value.
func get_look_at_target_offset() -> Vector3:
	return look_at_target_offset

## Appends Node3D to Look At Group array.
func append_look_at_group_node(value: Node3D) -> void:
	if not _look_at_group_nodes.has(value):
		_look_at_group_nodes.append(value)
		_has_look_at_target_group = true
	else:
		printerr(value, " is already part of Look At Group")
## Appends array of type Node3D to Look At Group array.
func append_look_at_group_node_array(value: Array[Node3D]) -> void:
	for val in value:
		if not _look_at_group_nodes.has(val):
			_look_at_group_nodes.append(val)
			_has_look_at_target_group = true
		else:
			printerr(val, " is already part of Look At Group")
## Sets array of type Node3D to Look At Group array.
func set_look_at_group_node_array(value: Array[Node3D]) -> void:
	_look_at_group_nodes.clear()
	_look_at_group_nodes.append_array(value)
	_has_look_at_target_group = _look_at_group_nodes.size() > 0
## Removes Node3D from Look At Group array.
func erase_look_at_group_node(value: Node3D) -> void:
	_look_at_group_nodes.erase(value)
	if _look_at_group_nodes.size() < 1:
		_has_look_at_target_group = false
## Gets all the Node3D in Look At Group array.
func get_look_at_group_nodes() -> Array[Node3D]:
	return _look_at_group_nodes


## Gets Inactive Update Mode property.
func get_inactive_update_mode() -> String:
	return Constants.InactiveUpdateMode.keys()[Properties.inactive_update_mode].capitalize()


## Assogms a new Camera3D Resource to this PhantomCamera3D
func set_camera_3D_resource(value: Camera3DResource) -> void:
	_camera_3D_resouce = value
## Gets the Camera3D resource assigned to the PhantomCamera3D
## Returns null if there's nothing assigned to it.
func get_camera_3D_resource() -> Camera3DResource:
	return _camera_3D_resouce

## Assigns a new Camera3D Cull Mask value.
## Note: This will override and make the Camera3D Resource unique to this PhantomCamera3D.
func set_camera_cull_mask(value: int) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = value
		_camera_3D_resouce_default.h_offset = _camera_3D_resouce.h_offset
		_camera_3D_resouce_default.v_offset = _camera_3D_resouce.v_offset
		_camera_3D_resouce_default.fov = _camera_3D_resouce.fov
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.cull_mask = value
	if is_active(): get_pcam_host_owner().camera_3D.cull_mask = value
## Gets the Camera3D fov value assigned this PhantomCamera. The duration value is in seconds.
func get_camera_cull_mask() -> int:
	if get_camera_3D_resource():
		return _camera_3D_resouce.cull_mask
	else:
		return _camera_3D_resouce_default.cull_mask

## Assigns a new Camera3D H Offset value.
## Note: This will override and make the Camera3D Resource unique to this PhantomCamera3D.
func set_camera_h_offset(value: float) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = _camera_3D_resouce.cull_mask
		_camera_3D_resouce_default.h_offset = value
		_camera_3D_resouce_default.v_offset = _camera_3D_resouce.v_offset
		_camera_3D_resouce_default.fov = _camera_3D_resouce.fov
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.h_offset = value
	if is_active(): get_pcam_host_owner().camera_3D.h_offset = value
## Gets the Camera3D fov value assigned this PhantomCamera. The duration value is in seconds.
func get_camera_h_offset() -> float:
	if get_camera_3D_resource():
		return _camera_3D_resouce.h_offset
	else:
		return _camera_3D_resouce_default.h_offset

## Assigns a new Camera3D V Offset value.
## Note: This will override and make the Camera3D Resource unique to this PhantomCamera3D.
func set_camera_v_offset(value: float) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = _camera_3D_resouce.cull_mask
		_camera_3D_resouce_default.h_offset = _camera_3D_resouce.h_offset
		_camera_3D_resouce_default.v_offset = value
		_camera_3D_resouce_default.fov = _camera_3D_resouce.fov
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.v_offset = value
	if is_active(): get_pcam_host_owner().camera_3D.v_offset = value
## Gets the Camera3D fov value assigned this PhantomCamera. The duration value is in seconds.
func get_camera_v_offset() -> float:
	if get_camera_3D_resource():
		return _camera_3D_resouce.v_offset
	else:
		return _camera_3D_resouce_default.v_offset

## Assigns a new Camera3D FOV value.
## Note: This will override and make the Camera3D Resource unique to this PhantomCamera3D.
func set_camera_fov(value: float) -> void:
	if get_camera_3D_resource():
		_camera_3D_resouce_default.cull_mask = _camera_3D_resouce.cull_mask
		_camera_3D_resouce_default.h_offset = _camera_3D_resouce.h_offset
		_camera_3D_resouce_default.v_offset = _camera_3D_resouce.v_offset
		_camera_3D_resouce_default.fov = value
		set_camera_3D_resource(null) # Clears resource from PCam instance
	else:
		_camera_3D_resouce_default.fov = value
	if is_active(): get_pcam_host_owner().camera_3D.fov = value
## Gets the Camera3D fov value assigned this PhantomCamera. The duration value is in seconds.
func get_camera_fov() -> float:
	if get_camera_3D_resource():
		return _camera_3D_resouce.fov
	else:
		return _camera_3D_resouce_default.fov

#endregion
