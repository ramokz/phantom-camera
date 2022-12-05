@tool
extends Node

const PHANTOM_CAMERA_GROUP_NAME: StringName = "phantom_camera_group"
const PHANTOM_CAMERA_BASE_GROUP_NAME: StringName = "phantom_camera_base_group"



var _active_phantom_camera
var _active_phantom_camera_priority: int = 0
var phantom_camera_list: Array
var phantom_camera_base_list: Array

var camera_base_2D: Camera2D
var camera_base_3D: Camera3D
var camera_base = preload("res://addons/phantom_camera/scripts/phantom_camera_base.gd")

var _active_phantom_camera_has_changed: bool = false

##################
# Tween Variables
##################
var _phantom_camera_tween: Tween
var _tween_default_ease: Tween.EaseType
var _easing: Tween.TransitionType

var _phantom_camera_initial_position
var _phantom_camera_tween_complete: bool
var _phantom_camera_position_changed: bool
var _phantom_camera_tween_elasped_time_duration: float



#func phantom_camera_added_to_scene_2(phantom_camera) -> void:
#	pass
#
#
#
#
#
#
#
#
#
#
#func phantom_camera_added_to_scene(phantom_camera) -> void:
#	phantom_camera_list.append(phantom_camera)
#	find_phantom_camera_with_highest_priority()
#
#
#func phantom_camera_removed_from_scene(phantom_camera) -> void:
##	TODO - Could use some performance enhancements in case there are many Phantom Cameras
#	phantom_camera_list.erase(phantom_camera)
##	print("Removed: ", phantom_camera, " from scene")
#
#	if phantom_camera == _active_phantom_camera:
##		print("Active camera removed from scene")
#		_active_phantom_camera_priority = 0
#		find_phantom_camera_with_highest_priority()
#
#
#func find_phantom_camera_with_highest_priority() -> void:
#	for phantom_camera_item in phantom_camera_list:
#		if phantom_camera_item.priority > _active_phantom_camera_priority:
#			_active_phantom_camera = phantom_camera_item
#			_active_phantom_camera_priority = phantom_camera_item.priority
#
#			_phantom_camera_tween_transition(_active_phantom_camera.tween_duration)
#
#
#func phantom_camera_priority_updated(phantom_camera) -> void:
#	if phantom_camera.priority >= _active_phantom_camera_priority and phantom_camera != _active_phantom_camera:
#		_active_phantom_camera = phantom_camera
#		_active_phantom_camera_priority = phantom_camera.priority
#		_phantom_camera_tween_complete = false
#
#		_active_phantom_camera_has_changed = true
##		_phantom_camera_tween_transition(_active_phantom_camera.tween_duration)
#	elif phantom_camera == _active_phantom_camera:
#		if phantom_camera.priority <= _active_phantom_camera_priority:
#			_active_phantom_camera_priority = phantom_camera.priority
#			_phantom_camera_tween_complete = false
#			find_phantom_camera_with_highest_priority()
#		else:
#			_active_phantom_camera_priority = phantom_camera.priority
#
#
#func _phantom_camera_tween_transition(duration: float, phantom_camera_changed_mid_tween: bool = false) -> void:
#	_phantom_camera_initial_position = _active_phantom_camera.get_position()
#	print("Tweening: ", _active_phantom_camera)
#
#	if not _phantom_camera_position_changed:
#		_phantom_camera_tween = get_tree().create_tween()
#		_phantom_camera_tween_elasped_time_duration = duration
#		_phantom_camera_tween_property(duration)
#		_phantom_camera_tween.tween_callback(phantom_camera_tween_complete)
#	elif _phantom_camera_tween:
#		print(_phantom_camera_tween)
#		_phantom_camera_tween_elasped_time_duration -= _phantom_camera_tween.get_total_elapsed_time()
#		_phantom_camera_tween.kill()
#		_phantom_camera_tween = get_tree().create_tween()
#		_phantom_camera_tween_property(_phantom_camera_tween_elasped_time_duration)
#		_phantom_camera_tween.tween_callback(phantom_camera_tween_complete)
#
#
#func _phantom_camera_tween_property(duration: float) -> void:
#	if _active_phantom_camera.follow_target_offset:
#		_phantom_camera_tween.parallel().tween_property(camera_base, "position", _active_phantom_camera.get_position(), duration)
#
#	if _active_phantom_camera is PhantomCamera3D:
#		if _active_phantom_camera.has_look_at_target:
#			var _new_phantom_camera_position: Vector3 = _active_phantom_camera.get_position()
#			_phantom_camera_tween.parallel().tween_property(camera_base, "rotation", _active_phantom_camera.get_rotation(), duration)
#
#func phantom_camera_tween_complete() -> void:
#	_active_phantom_camera_has_changed = false
#	_phantom_camera_tween_complete = true
#	_phantom_camera_position_changed = false
#
#
#func _physics_process(delta: float) -> void:
#	pass
#	if camera_base:
#		if _phantom_camera_tween_complete:
#			if _active_phantom_camera.has_follow_target:
#				camera_base.position = _active_phantom_camera.get_position()
#			if _active_phantom_camera is PhantomCamera3D:
#				if _active_phantom_camera.has_look_at_target:
#					camera_base.look_at(
#						_active_phantom_camera.look_at_target_node.get_position() + \
#						Vector3(_active_phantom_camera.look_at_target_offset.x, _active_phantom_camera.look_at_target_offset.y, 0))



#		elif not _phantom_camera_tween_complete and _phantom_camera_initial_position != _active_phantom_camera.get_position():
#			_phantom_camera_position_changed = true
#			_phantom_camera_tween_transition(_active_phantom_camera.tween_duration)

#		if _active_phantom_camera.has_look_at_target:
#			if _phantom_camera_tween_complete:
#				camera_base_3D.look_at(
#					_active_phantom_camera.look_at_target_node.get_position() + \
#					Vector3(_active_phantom_camera.look_at_target_offset.x, _active_phantom_camera.look_at_target_offset.y, 0))
#			elif not _phantom_camera_tween_complete and _phantom_camera_initial_position != _active_phantom_camera.get_position():
#				pass
