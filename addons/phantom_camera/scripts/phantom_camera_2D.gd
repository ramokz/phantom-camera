@tool
class_name PhantomCamera2D
extends Node2D
@icon("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg")

#const PhantomCameraConstants = preload("phantom_camera/_constants.gd")
#
###############
## Phantom Host
###############
#var camera_host_group: Array
#var phantom_camera_host_owner: PhantomCameraHost2D
#var scene_has_multiple_phantom_camera_hosts: bool
#
#
###################
## General - Variables
###################
#
#var priority: int = 1
#
###################
## Follow - Variables
###################
#var _FOLLOW_TARGET_PROPERTY_NAME: StringName = "Follow Target"
#var follow_target_node: Node
#var _follow_target_path: NodePath
#var has_follow_target: bool = false
#
#var _FOLLOW_TARGET_OFFSET_PROPERTY_NAME: StringName = "Follow Parameters/Follow Target Offset"
#var follow_target_offset: Vector2 = Vector2(0, 0)
#
#var _look_at_target_offset_property_name: StringName = "Look At Parameters/Look At Target Offset"
#var look_at_target_offset: Vector2
#
##################
## Tween - Variables
##################
#var TWEEN_EASE_PROPERTY_NAME: StringName = "Tween Properties / Ease"
#var tween_ease: Tween.EaseType
#
#var _TWEEN_TRANSITION_PROPERTY_NAME: StringName = "Tween Properties / Transition"
#var tween_transition: Tween.TransitionType
#
#var TWEEN_DURATION_PROPERTY_NAME: StringName = "Tween Properties / Duration"
#var tween_duration: float = 1
#
#
#func _get_property_list() -> Array:
#	var property_list: Array
#
#	######################
#	# General - Properties
#	######################
#	property_list.append({
#		"name": PhantomCameraConstants.PRIORITY_PROPERTY_NAME,
#		"type": TYPE_INT,
#		"hint": PROPERTY_HINT_NONE,
#		"usage": PROPERTY_USAGE_DEFAULT
#	})
#
#	#####################
#	# Follow - Properties
#	#####################
#	property_list.append({
#		"name": _FOLLOW_TARGET_PROPERTY_NAME,
#		"type": TYPE_NODE_PATH,
#		"hint": PROPERTY_HINT_NONE,
#		"usage": PROPERTY_USAGE_DEFAULT
#	})
#
#	if has_follow_target:
#		property_list.append({
#			"name": _FOLLOW_TARGET_OFFSET_PROPERTY_NAME,
#			"type": TYPE_VECTOR2,
#			"hint": PROPERTY_HINT_NONE,
#			"usage": PROPERTY_USAGE_DEFAULT
#		})
#
#
#	####################
#	# Tween - Properties
#	####################
#	property_list.append({
#		"name": TWEEN_DURATION_PROPERTY_NAME,
#		"type": TYPE_FLOAT,
#		"hint": PROPERTY_HINT_NONE,
#		"usage": PROPERTY_USAGE_DEFAULT
#	})
##	property_listappend({
##		"name": _TWEEN_TRANSITION_PROPERTY_NAME,
##		"type": TYPE_STRING,
##		"hint": PROPERTY_HINT_ENUM,
##		"usage": PROPERTY_USAGE_DEFAULT
##	})
##	property_listappend({
##		"name": TWEEN_EASE_PROPERTY_NAME,
##		"type": TYPE_INT,
##		"hint": PROPERTY_HINT_ENUM,
##		"hint_string": tween_ease,
##		"usage": PROPERTY_USAGE_DEFAULT
##	})
#
#	return property_list
#
#
#func _set(property: StringName, value) -> bool:
#
#	######################
#	# General - Properties
#	######################
#	if property == PhantomCameraConstants.PRIORITY_PROPERTY_NAME:
#		if value < 1:
#			priority = 1
#		else:
#			priority = value
#
#		if phantom_camera_host_owner:
#			phantom_camera_host_owner.phantom_camera_priority_updated(self)
#
#	#####################
#	# Follow - Properties
#	#####################
#	if property == _FOLLOW_TARGET_PROPERTY_NAME:
#		_follow_target_path = value
#		var valueNodePath: NodePath = value as NodePath
#		if not valueNodePath.is_empty():
#			has_follow_target = true
#			if has_node(_follow_target_path):
#				follow_target_node = get_node(_follow_target_path)
#		else:
#			has_follow_target = false
#			follow_target_node = null
#
#		notify_property_list_changed()
#	if property == _FOLLOW_TARGET_OFFSET_PROPERTY_NAME:
#		if value == Vector2.ZERO:
#			follow_target_offset = Vector2(0,0)
#		else:
#			follow_target_offset = value
#
#		notify_property_list_changed()
#	if property == _look_at_target_offset_property_name:
#		look_at_target_offset = value
#
#	####################
#	# Tween - Properties
#	####################
#	if property == TWEEN_DURATION_PROPERTY_NAME:
#		tween_duration = value
##	if property == _TWEEN_TRANSITION_PROPERTY_NAME:
##		tween_transition = value
##	if property == TWEEN_EASE_PROPERTY_NAME:
##		tween_ease = value
#
#	return false
#
#
#func _get(property: StringName):
#
#	######################
#	# General - Properties
#	######################
#	if property == PhantomCameraConstants.PRIORITY_PROPERTY_NAME: return priority
#
#	#####################
#	# Follow - Properties
#	#####################
#	if property == _FOLLOW_TARGET_PROPERTY_NAME: return _follow_target_path
#	if property == _FOLLOW_TARGET_OFFSET_PROPERTY_NAME: return follow_target_offset
#
#	####################
#	# Tween - Properties
#	####################
#	if property == TWEEN_DURATION_PROPERTY_NAME: return tween_duration
##	if property == _TWEEN_TRANSITION_PROPERTY_NAME: return tween_transition
##	if property == TWEEN_EASE_PROPERTY_NAME: return tween_ease
#
#
###############
## Private Functions
###############
#func _enter_tree() -> void:
#	add_to_group("phantom_camera_group")
#
##	camera_host_group = get_tree().get_nodes_in_group(PHANTOM_CAMERA_HOST_GROUP_NAME)
#
#	if camera_host_group.size() > 0:
#		if camera_host_group.size() == 1:
#			phantom_camera_host_owner = camera_host_group[0]
#			phantom_camera_host_owner.phantom_camera_added_to_scene(self)
#			pass
#		else:
#			for camera_host in camera_host_group:
#				print("Multiple PhantomCameraBases in scene")
#	else:
#		print("No camera base added")
#
#	phantom_camera_host_owner.phantom_camera_added_to_scene(self)
#
##	if _look_at_target_path:
##		look_at_target_node = get_node(_look_at_target_path)
#
#	if _follow_target_path:
#		follow_target_node = get_node(_follow_target_path)
#
#
#func _exit_tree() -> void:
#	PhantomCameraManager.phantom_camera_removed_from_scene(self)
#
#
#func _physics_process(delta: float) -> void:
#	if follow_target_node:
#			set_position(
#				follow_target_node.position + follow_target_offset
#			)
