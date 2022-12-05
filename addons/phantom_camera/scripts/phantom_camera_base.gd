@tool
class_name PhantomCameraBase
extends Node

##################
# Variables
##################
#  General Variables
var _camera_3D: Camera3D
var _active_phantom_camera
var phantom_camera_list_3D: Array[PhantomCamera3D]
var _active_phantom_camera_priority: int
var _active_phantom_camera_has_changed: bool
var _active_cam_missing: bool

# Tweening Variables
var _phantom_camera_tween: Tween
var _tween_default_ease: Tween.EaseType
var _easing: Tween.TransitionType

# Phantom Camera Variables
var _phantom_camera_initial_position
var _phantom_camera_tween_complete: bool
var _phantom_camera_position_changed: bool
var _phantom_camera_tween_elasped_time_duration: float

const PHANTOM_CAMERA_GROUP_NAME: StringName = "phantom_camera_group"
const PHANTOM_CAMERA_BASE_GROUP_NAME: StringName = "phantom_camera_base_group"

##############
# Initializers
##############
func _enter_tree() -> void:
	add_to_group(PHANTOM_CAMERA_BASE_GROUP_NAME)
	_camera_3D = get_parent()

	var phantom_camera_group_nodes := get_tree().get_nodes_in_group(PHANTOM_CAMERA_GROUP_NAME)

	for phantom_camera in phantom_camera_group_nodes:
		phantom_camera_list_3D.append(phantom_camera)


func _exit_tree() -> void:
	remove_from_group(PHANTOM_CAMERA_BASE_GROUP_NAME)


###########
# Functions
###########
func phantom_camera_added_to_scene(phantom_camera: PhantomCamera3D) -> void:
	phantom_camera_list_3D.append(phantom_camera)
	find_phantom_camera_with_highest_priority()


func phantom_camera_removed_from_scene(phantom_camera: PhantomCamera3D) -> void:
	phantom_camera_list_3D.erase(phantom_camera)
	if phantom_camera == _active_phantom_camera:
		_active_cam_missing = true
		_active_phantom_camera_priority = 0
		find_phantom_camera_with_highest_priority()


################
# Tweening Logic
################
func phantom_camera_priority_updated(phantom_camera: PhantomCamera3D) -> void:
	if phantom_camera.priority >= _active_phantom_camera_priority and phantom_camera != _active_phantom_camera:
		_active_phantom_camera = phantom_camera
		_active_phantom_camera_priority = phantom_camera.priority
		_phantom_camera_tween_complete = false
		_active_phantom_camera_has_changed = true
		_phantom_camera_tween_transition(_active_phantom_camera.tween_duration)
	elif phantom_camera == _active_phantom_camera:
		if phantom_camera.priority <= _active_phantom_camera_priority:
			_active_phantom_camera_priority = phantom_camera.priority
			_phantom_camera_tween_complete = false
			find_phantom_camera_with_highest_priority()
		else:
			_active_phantom_camera_priority = phantom_camera.priority


func find_phantom_camera_with_highest_priority() -> void:
	for phantom_camera_item in phantom_camera_list_3D:
		if phantom_camera_item.priority > _active_phantom_camera_priority:
			_active_phantom_camera = phantom_camera_item
			_active_phantom_camera_priority = phantom_camera_item.priority
			_phantom_camera_tween_transition(_active_phantom_camera.tween_duration)
		_active_cam_missing = false


func _phantom_camera_tween_transition(duration: float) -> void:
	_phantom_camera_initial_position = _active_phantom_camera.get_position()

	if not _phantom_camera_position_changed:
		_phantom_camera_tween = get_tree().create_tween()
		_phantom_camera_tween_elasped_time_duration = duration
		_phantom_camera_tween_property(duration)
		_phantom_camera_tween.tween_callback(phantom_camera_tween_resetter)
	elif _phantom_camera_tween:
		_phantom_camera_tween_elasped_time_duration -= _phantom_camera_tween.get_total_elapsed_time()
		_phantom_camera_tween.kill()
		_phantom_camera_tween = get_tree().create_tween()
		_phantom_camera_tween_property(_phantom_camera_tween_elasped_time_duration)
		_phantom_camera_tween.tween_callback(phantom_camera_tween_resetter)


func _phantom_camera_tween_property(duration: float) -> void:
		_phantom_camera_tween.parallel().tween_property(_camera_3D, "position", _active_phantom_camera.get_position(), duration) \
			.set_trans(_active_phantom_camera.tween_transition) \
			.set_ease(_active_phantom_camera.tween_ease)
		_phantom_camera_tween.parallel().tween_property(_camera_3D, "rotation", _active_phantom_camera.get_rotation(), duration)


func phantom_camera_tween_resetter() -> void:
	_active_phantom_camera_has_changed = false
	_phantom_camera_tween_complete = true
	_phantom_camera_position_changed = false


func _physics_process(delta: float) -> void:
	if not _active_cam_missing and _phantom_camera_tween_complete:
		_camera_3D.set_position(_active_phantom_camera.get_position())
		_camera_3D.set_rotation(_active_phantom_camera.get_rotation())
