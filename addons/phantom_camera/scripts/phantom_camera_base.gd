@tool
class_name PhantomCameraBase
extends Node

##################
# Variables
##################
#  General Variables
var _camera_3D: Camera3D
var _active_phantom_camera: PhantomCamera3D
var _phantom_camera_list_3D: Array[PhantomCamera3D]
var _active_phantom_camera_priority: int
var _active_cam_missing: bool

# Tweening Variables
var _phantom_camera_tween: Tween
var _tween_default_ease: Tween.EaseType
var _easing: Tween.TransitionType

# Phantom Camera Variables
var _phantom_camera_initial_position: Vector3
var _previous_phantom_camera_initial_position: Vector3
var _phantom_camera_initial_rotation: Vector3
var _previous_phantom_camera_initial_rotation: Vector3
var _phantom_camera_tween_complete: bool
var _phantom_camera_changed_midtween: bool
var _phantom_camera_tween_elasped_time_duration: float

const PHANTOM_CAMERA_GROUP_NAME: StringName = "phantom_camera_group"
const PHANTOM_CAMERA_BASE_GROUP_NAME: StringName = "phantom_camera_base_group"


var should_tween: bool
var tween_duration: float

##############
# Initializers
##############
func _enter_tree() -> void:
	add_to_group(PHANTOM_CAMERA_BASE_GROUP_NAME)
	_camera_3D = get_parent()

	var phantom_camera_group_nodes := get_tree().get_nodes_in_group(PHANTOM_CAMERA_GROUP_NAME)

	for phantom_camera in phantom_camera_group_nodes:
		_phantom_camera_list_3D.append(phantom_camera)


func _exit_tree() -> void:
	remove_from_group(PHANTOM_CAMERA_BASE_GROUP_NAME)


###########
# Functions
###########
func phantom_camera_added_to_scene(phantom_camera: PhantomCamera3D) -> void:
	_phantom_camera_list_3D.append(phantom_camera)
	find_phantom_camera_with_highest_priority(false)


func phantom_camera_removed_from_scene(phantom_camera: PhantomCamera3D) -> void:
	_phantom_camera_list_3D.erase(phantom_camera)
	if phantom_camera == _active_phantom_camera:
		_active_cam_missing = true
		_active_phantom_camera_priority = 0
		find_phantom_camera_with_highest_priority()


################
# Tweening Logic
################
func phantom_camera_priority_updated(phantom_camera: PhantomCamera3D) -> void:
	if phantom_camera.get_priority() >= _active_phantom_camera_priority and phantom_camera != _active_phantom_camera:
		_active_phantom_camera = phantom_camera
		_active_phantom_camera_priority = phantom_camera.get_priority()
		_phantom_camera_tween_complete = false
		_phantom_camera_tween_transition(_active_phantom_camera.tween_duration)
	elif phantom_camera == _active_phantom_camera:
		if phantom_camera.get_priority() <= _active_phantom_camera_priority:
			_active_phantom_camera_priority = phantom_camera.get_priority()
			_phantom_camera_tween_complete = false
			find_phantom_camera_with_highest_priority()
		else:
			_active_phantom_camera_priority = phantom_camera.get_priority()


func find_phantom_camera_with_highest_priority(should_animate: bool = true) -> void:
	for phantom_camera_item in _phantom_camera_list_3D:
		if phantom_camera_item.get_priority() > _active_phantom_camera_priority:
			_active_phantom_camera = phantom_camera_item
			_active_phantom_camera_priority = phantom_camera_item.get_priority()
#			_phantom_camera_tween_transition(_active_phantom_camera.tween_duration, should_animate)

#			 ###### NEW TWEEN TEST
			_phantom_camera_initial_position = _active_phantom_camera.get_position()
			_phantom_camera_initial_rotation = _active_phantom_camera.get_rotation()
			tween_duration = _active_phantom_camera.tween_duration
			should_tween = true

		_active_cam_missing = false


func _phantom_camera_tween_transition(duration: float, should_animate: bool = true) -> void:
	_phantom_camera_initial_position = _active_phantom_camera.get_position()
	_phantom_camera_initial_rotation = _active_phantom_camera.get_rotation()

	if should_animate:
		if not _phantom_camera_changed_midtween:
			_phantom_camera_tween = create_tween()
			_phantom_camera_tween_elasped_time_duration = duration
			_phantom_camera_tween_property(duration)
			_phantom_camera_tween.tween_callback(_phantom_camera_tween_resetter)
		else:
			print("Target has changed position")
			_phantom_camera_tween_elasped_time_duration -= _phantom_camera_tween.get_total_elapsed_time()
			_phantom_camera_tween.kill()
			_phantom_camera_tween = create_tween()
			_phantom_camera_tween_property(_phantom_camera_tween_elasped_time_duration, _phantom_camera_tween_elasped_time_duration)
			_phantom_camera_tween.tween_callback(_phantom_camera_tween_resetter)
	else:
		_phantom_camera_tween_complete = true
		_phantom_camera_tween_resetter()


func _phantom_camera_tween_property(duration: float, elapsed_time: float = 0.0) -> void:
	_phantom_camera_tween_complete = false
	_phantom_camera_tween.parallel().tween_property(_camera_3D, "position", _active_phantom_camera.get_position(), duration) \
		.set_trans(_active_phantom_camera.tween_transition)
#			.set_ease(_active_phantom_camera.tween_ease)
	_phantom_camera_tween.parallel().tween_property(_camera_3D, "rotation", _active_phantom_camera.get_rotation(), duration) \
		.set_trans(_active_phantom_camera.tween_transition)


func _phantom_camera_tween_resetter() -> void:
	print("Tween Reset")
	_phantom_camera_tween_complete = true
	_phantom_camera_changed_midtween = false
	_previous_phantom_camera_initial_position = _active_phantom_camera.get_position()
	_previous_phantom_camera_initial_rotation = _active_phantom_camera.get_rotation()


func _target_changed() -> bool:
	if _phantom_camera_initial_position != _active_phantom_camera.get_position():
		print("Updating to a new positional target")
		return true
	elif _phantom_camera_initial_rotation != _active_phantom_camera.get_rotation():
		print("Updating to a new rotational target")
		return true
	else:
		return false

func move_target(delta: float) -> void:
	_camera_3D.set_position(
		Tween.interpolate_value(
			_previous_phantom_camera_initial_position, \
			_active_phantom_camera.get_position() - _previous_phantom_camera_initial_position,
			delta, \
			_active_phantom_camera.tween_duration, \
			_active_phantom_camera.tween_transition,
			Tween.EASE_IN_OUT
		)
	)

	_camera_3D.set_rotation(
		Tween.interpolate_value(
			_previous_phantom_camera_initial_rotation, \
			_active_phantom_camera.get_rotation() - _previous_phantom_camera_initial_rotation,
			delta, \
			_active_phantom_camera.tween_duration, \
			_active_phantom_camera.tween_transition,
			Tween.EASE_IN_OUT
		)
	)

func _process(delta: float) -> void:
	if _active_cam_missing: return
	if should_tween:
		move_target(delta)
#		pass


#	if _phantom_camera_tween_complete:
#		_camera_3D.set_position(_active_phantom_camera.get_position())
#		_camera_3D.set_rotation(_active_phantom_camera.get_rotation())
#	elif _target_changed():
#		_phantom_camera_tween.kill()
#		print(_previous_phantom_camera_initial_position)
#		_phantom_camera_changed_midtween = true
##		_phantom_camera_tween_transition(_active_phantom_camera.tween_duration)
#		_camera_3D.set_position(
#			Tween.interpolate_value(
#				_previous_phantom_camera_initial_position, \
#				_active_phantom_camera.get_position() - _previous_phantom_camera_initial_position,
#				delta, \
#				_active_phantom_camera.tween_duration - _phantom_camera_tween.get_total_elapsed_time(), \
#				_active_phantom_camera.tween_transition,
#				Tween.EASE_IN_OUT
#			)
#		)

#	if _target_changed():
#		print("Target has changed")

