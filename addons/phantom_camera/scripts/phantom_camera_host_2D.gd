@tool
class_name PhantomCameraHost2D
extends Node

##################
# Variables
##################
#  General Variables
var _camera_2D: Camera2D
var _active_phantom_camera: PhantomCamera2D
var _phantom_camera_list_2D: Array[PhantomCamera2D]
var _active_phantom_camera_priority: int
var _active_cam_missing: bool

# Tweening Variables
var _phantom_camera_tween: Tween
var _tween_default_ease: Tween.EaseType
var _easing: Tween.TransitionType

# Phantom Camera Variables
var _previous_active_phantom_camera_position: Vector2
var _previous_active_phantom_camera_rotation: float

const PHANTOM_CAMERA_GROUP_NAME: StringName = "phantom_camera_group"
const PHANTOM_CAMERA_HOST_GROUP_NAME: StringName = "phantom_camera_host_group"


var should_tween: bool
var tween_duration: float

###################
# Private Functions
###################
func _enter_tree() -> void:
	add_to_group(PHANTOM_CAMERA_HOST_GROUP_NAME)
	_camera_2D = get_parent()

	var phantom_camera_group_nodes := get_tree().get_nodes_in_group(PHANTOM_CAMERA_GROUP_NAME)

	for phantom_camera in phantom_camera_group_nodes:
		_phantom_camera_list_2D.append(phantom_camera)


func _exit_tree() -> void:
	remove_from_group(PHANTOM_CAMERA_HOST_GROUP_NAME)


func _move_target(delta: float) -> void:
	tween_duration += delta
	_camera_2D.set_position(
		Tween.interpolate_value(
			_previous_active_phantom_camera_position, \
			_active_phantom_camera.get_position() - _previous_active_phantom_camera_position,
			tween_duration, \
			_active_phantom_camera.tween_duration, \
			_active_phantom_camera.tween_transition,
			Tween.EASE_IN_OUT
		)
	)
	_camera_2D.set_rotation(
		Tween.interpolate_value(
			_previous_active_phantom_camera_rotation, \
			_active_phantom_camera.get_rotation() - _previous_active_phantom_camera_rotation,
			tween_duration, \
			_active_phantom_camera.tween_duration, \
			_active_phantom_camera.tween_transition,
			Tween.EASE_IN_OUT
		)
	)


func _find_phantom_camera_with_highest_priority(should_animate: bool = true) -> void:
	for phantom_camera in _phantom_camera_list_2D:
		if phantom_camera.get_priority() > _active_phantom_camera_priority:
			_assign_new_active_phantom_camera(phantom_camera)

		_active_cam_missing = false


func _assign_new_active_phantom_camera(phantom_camera: PhantomCamera2D) -> void:
	var no_previous_pcam: bool

	if _active_phantom_camera:
		_previous_active_phantom_camera_position = _camera_2D.get_position()
		_previous_active_phantom_camera_rotation = _camera_2D.get_rotation()
	else:
		no_previous_pcam = true

	_active_phantom_camera = phantom_camera
	_active_phantom_camera_priority = phantom_camera.get_priority()

	if no_previous_pcam:
		_previous_active_phantom_camera_position = _active_phantom_camera.get_position()
		_previous_active_phantom_camera_rotation = _active_phantom_camera.get_rotation()

	tween_duration = 0
	should_tween = true


func _process(delta: float) -> void:
	if _active_cam_missing: return
	if not should_tween:
		_camera_2D.set_position(_active_phantom_camera.get_position())
		_camera_2D.set_rotation(_active_phantom_camera.get_rotation())
	else:
		if tween_duration < _active_phantom_camera.tween_duration:
			_move_target(delta)
		else:
#			TODO Logic for having different follow / look at options
			tween_duration = 0
			should_tween = false


##################
# Public Functions
##################
func phantom_camera_added_to_scene(phantom_camera: PhantomCamera2D) -> void:
	_phantom_camera_list_2D.append(phantom_camera)
	_find_phantom_camera_with_highest_priority(false)


func phantom_camera_removed_from_scene(phantom_camera: PhantomCamera2D) -> void:
	_phantom_camera_list_2D.erase(phantom_camera)
	if phantom_camera == _active_phantom_camera:
		_active_cam_missing = true
		_active_phantom_camera_priority = 0
		_find_phantom_camera_with_highest_priority()


func phantom_camera_priority_updated(phantom_camera: PhantomCamera2D) -> void:
	if phantom_camera.get_priority() >= _active_phantom_camera_priority and phantom_camera != _active_phantom_camera:
		_assign_new_active_phantom_camera(phantom_camera)
	elif phantom_camera == _active_phantom_camera:
		if phantom_camera.get_priority() <= _active_phantom_camera_priority:
			_active_phantom_camera_priority = phantom_camera.get_priority()
			_find_phantom_camera_with_highest_priority()
		else:
			_active_phantom_camera_priority = phantom_camera.get_priority()
