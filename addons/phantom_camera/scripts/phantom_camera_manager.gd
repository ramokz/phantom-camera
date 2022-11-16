@tool
extends Node

var _active_pcam
var _active_pcam_priority: int = 0
var pcam_list: Array
var pcam_base_list: Array

var camera_base_2D: Camera2D
var camera_base_3D: Camera3D

var _active_pcam_has_changed: bool = false

##################
# Tween Variables
##################
var _pcam_tween: Tween

# Custom Tweening should be either of these two
var _tween_default_ease: Tween.EaseType
var _easing: Tween.TransitionType

var _pcam_initial_position
var _pcam_tween_complete: bool
var _pcam_position_changed: bool
var _pcam_tween_elasped_time_duration: float

func _enter_tree() -> void:
	print("Pcam Editor has entered the tree")


func phantom_camera_added_to_scene(pcam) -> void:
	pcam_list.append(pcam)
#	_check_active_camera_from_list(pcam)
	find_pcam_with_highest_priority()
#	 TODO - Add Camera to Editor with ID


func phantom_camera_removed_from_scene(pcam) -> void:
#	TODO - Could use some performance enhancements in case there are many Phantom Cameras
	pcam_list.erase(pcam)
	print("Removed: ", pcam, " from scene")

	if pcam == _active_pcam:
		print("Active camera removed from scene")
		_active_pcam_priority = 0
		find_pcam_with_highest_priority()


func find_pcam_with_highest_priority() -> void:
	for pcam_item in pcam_list:
#		TODO - Should also check whether if the existing active cam
		if pcam_item.priority > _active_pcam_priority:
			_active_pcam = pcam_item
			_active_pcam_priority = pcam_item.priority

			_pcam_tween_transition(_active_pcam.transition_duration)


func pcam_priority_updated(pcam) -> void:
	if pcam.priority > _active_pcam_priority and pcam != _active_pcam:
		_active_pcam = pcam
		_active_pcam_priority = pcam.priority
		_pcam_tween_complete = false

		_active_pcam_has_changed = true
		_pcam_tween_transition(_active_pcam.transition_duration)


	elif pcam == _active_pcam:
		if pcam.priority < _active_pcam_priority:
			_active_pcam_priority = pcam.priority
			_pcam_tween_complete = false
			find_pcam_with_highest_priority()
		else:
			_active_pcam_priority = pcam.priority


func _pcam_tween_transition(duration: float, pcam_changed_mid_tween: bool = false) -> void:
	_pcam_initial_position = _active_pcam.get_position()

	if not _pcam_position_changed:
		_pcam_tween = get_tree().create_tween()
		_pcam_tween_elasped_time_duration = duration
		_pcam_tween_property(duration)
		_pcam_tween.tween_callback(pcam_tween_complete)
	else:
#		print("Target move during tween")
		_pcam_tween_elasped_time_duration -= _pcam_tween.get_total_elapsed_time()
		_pcam_tween.kill()
		_pcam_tween = get_tree().create_tween()
		_pcam_tween_property(_pcam_tween_elasped_time_duration)
		_pcam_tween.tween_callback(pcam_tween_complete)

func _pcam_tween_property(duration: float) -> void:
	if _active_pcam._follow_target_offset:
		_pcam_tween.parallel().tween_property(camera_base_3D, "position", _active_pcam.get_position(), duration)

	if _active_pcam.has_look_at_target:
		print("Starting look_at tween")
		_pcam_tween.parallel().tween_method(camera_base_3D.look_at.bind(Vector3.UP), Vector3(0,0,0), Vector3(0,0,0), duration)


func pcam_tween_complete() -> void:
	print("Tween complete")
	_active_pcam_has_changed = false

	_pcam_tween_complete = true

	_pcam_position_changed = false


func _process(delta: float) -> void:
#	if camera_base_2D:
#		print("Has camera 2D")
#		TODO - Assign 2D camera to _active_pcam

#	_active_pcam_has_changed = false
#	if camera_base_3D && not _active_pcam_has_changed:

	if camera_base_3D:
		if _pcam_tween_complete:
			if _active_pcam.has_follow_target:
				camera_base_3D.position = _active_pcam.get_position()
			if _active_pcam.has_look_at_target:
				camera_base_3D.look_at(
					_active_pcam.look_at_target_node.get_position() + \
					Vector3(_active_pcam.look_at_target_offset.x, _active_pcam.look_at_target_offset.y, 0))
		elif not _pcam_tween_complete and _pcam_initial_position != _active_pcam.get_position():
			_pcam_position_changed = true
			_pcam_tween_transition(_active_pcam.transition_duration)

#		if _active_pcam.has_look_at_target:
#			if _pcam_tween_complete:
#				camera_base_3D.look_at(
#					_active_pcam.look_at_target_node.get_position() + \
#					Vector3(_active_pcam.look_at_target_offset.x, _active_pcam.look_at_target_offset.y, 0))
#			elif not _pcam_tween_complete and _pcam_initial_position != _active_pcam.get_position():
#				pass
