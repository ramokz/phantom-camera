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

			_pcam_tween_transition(5)


func pcam_priority_updated(pcam) -> void:
	if pcam.priority > _active_pcam_priority and pcam != _active_pcam:
		_active_pcam = pcam
		_active_pcam_priority = pcam.priority
		_pcam_tween_complete = false

		_active_pcam_has_changed = true
		_pcam_tween_transition(5)


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
		_pcam_tween.tween_property(camera_base_3D, "position", _active_pcam.get_position(), duration)
		_pcam_tween.tween_callback(pcam_tween_complete)
	else:
#		print("Target move during tween")
		_pcam_tween_elasped_time_duration -= _pcam_tween.get_total_elapsed_time()
		_pcam_tween.kill()
		_pcam_tween = get_tree().create_tween()
		_pcam_tween.tween_property(camera_base_3D, "position", _active_pcam.get_position(), _pcam_tween_elasped_time_duration)
		_pcam_tween.tween_callback(pcam_tween_complete)

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
#		New Tweening
#		if _active_pcam_has_changed && not _pcam_tween.is_running():
#	#		print(_active_pcam_has_changed)
#	#		print("Changing to different pcam")
#			_pcam_tween_transition(_active_pcam, 5)
#		elif _active_pcam_has_changed && _pcam_tween.is_running():
#			_pcam_tween_transition(_active_pcam, 5, true)
#		else:
#			print("Fixed on pcam")
		if _pcam_tween_complete:
			camera_base_3D.position = _active_pcam.get_position()
		elif not _pcam_tween_complete and _pcam_initial_position != _active_pcam.get_position():
#			print("Position has changed")
			_pcam_position_changed = true
			_pcam_tween_transition(5)


#	if _active_pcam_has_changed:
#		_pcam_transition(camera_base_3D, _active_pcam.get_position())

#		print("Has camera 3D")

#func set_active_cam(phan_cam: Node3D) -> void:
##	print(_active_phan_cam_list)
##	_active_phan_cam_list.
#	var phan_cam_id: int = phan_cam.get_instance_id()
#
#	if not _active_phan_cam_list.has(phan_cam_id):
#		_active_phan_cam_list.append(phan_cam_id)
#	else:
#		_active_phan_cam_list.pop_at(_active_phan_cam_list.find(phan_cam_id))
#		_active_phan_cam_list.append(phan_cam_id)
#
#	_active_camera = phan_cam
##	print(phan_cam.name)
#
##	print("Current cam list after adding of cam is:", _active_phan_cam_list)
#
#
#func remove_phan_cam_from_list(phan_cam: Node3D) -> void:
#
#	var phan_cam_id: int = phan_cam.get_instance_id()
#
#	if _active_camera == phan_cam:
#		_active_phan_cam_list.pop_at(_active_phan_cam_list.find(phan_cam_id))
#	else:
#		_active_phan_cam_list.pop_at(_active_phan_cam_list.find(phan_cam_id))
#
##	print("Current cam list after removal of cam is:", _active_phan_cam_list)
