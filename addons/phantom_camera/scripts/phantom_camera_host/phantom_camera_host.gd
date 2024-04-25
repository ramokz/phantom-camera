@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_host.svg")
class_name PhantomCameraHost
extends Node

## Controls a scene's [Camera2D] (2D scenes) and [Camera3D] (3D scenes).
##
## All instantiated [param PhantomCameras] in a scene are assign to and managed by a
## PhantomCameraHost. It is what determines which [param PhantomCamera] should
## be active.

#region Constants

const _constants := preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#endregion


#region Signals

## Updates the viewfinder [param dead zones] sizes.[br]
## [b]Note:[/b] This is only being used in the editor viewfinder UI.
signal update_editor_viewfinder

#endregion


#region Variables

## For 2D scenes, is the [Camera2D] instance the [param PhantomCameraHost] controls.
var camera_2d: Camera2D = null
## For 3D scenes, is the [Camera3D] instance the [param PhantomCameraHost] controls.
var camera_3d: Camera3D = null

var _pcam_list: Array[Node] = []

var _active_pcam: Node = null
var _active_pcam_priority: int = -1
var _active_pcam_missing: bool = true
var _active_pcam_has_damping: bool = false

var _prev_active_pcam_2d_transform: Transform2D = Transform2D()
var _prev_active_pcam_3d_transform: Transform3D = Transform3D()

var _trigger_pcam_tween: bool = false
var _tween_duration: float = false

var _multiple_pcam_hosts: bool = false

var _is_child_of_camera: bool = false
var _is_2D: bool = false


var _viewfinder_node: Control = null
var _viewfinder_needed_check: bool = true

var _camera_zoom: Vector2 = Vector2.ONE

var _prev_camera_h_offset: float = 0
var _prev_camera_v_offset: float = 0
var _prev_camera_fov: float = 75

var _active_pcam_2d_glob_transform: Transform2D = Transform2D()
var _active_pcam_3d_glob_transform: Transform3D = Transform3D()

#endregion


#region Private Functions

func _enter_tree() -> void:
#	camera = get_parent()
	var parent = get_parent()

	if parent is Camera2D or parent is Camera3D:
		_is_child_of_camera = true
		if parent is Camera2D:
			_is_2D = true
			camera_2d = parent
			# Force applies position smoothing to be disabled
			# This is to prevent overlap with the interpolation of the PCam2D.
			camera_2d.set_position_smoothing_enabled(false)
		else:
			_is_2D = false
			camera_3d = parent

		add_to_group(_constants.PCAM_HOST_GROUP_NAME)
#		var already_multi_hosts: bool = multiple_pcam_hosts

		_check_camera_host_amount()

		if _multiple_pcam_hosts:
			printerr(
				"Only one PhantomCameraHost can exist in a scene",
				"\n",
				"Multiple PhantomCameraHosts will be supported in https://github.com/MarcusSkov/phantom-camera/issues/26"
			)
			queue_free()

		for pcam in _get_pcam_node_group():
			if not _multiple_pcam_hosts:
				pcam_added_to_scene(pcam)
				pcam.set_pcam_host_owner(self)
	else:
		printerr(name, " is not a child of a Camera2D or Camera3D")


func _exit_tree() -> void:
	remove_from_group(_constants.PCAM_HOST_GROUP_NAME)
	_check_camera_host_amount()


func _ready() -> void:
	if not is_instance_valid(_active_pcam): return
	if _is_2D:
		_active_pcam_2d_glob_transform = _active_pcam.get_global_transform()
	else:
		_active_pcam_3d_glob_transform = _active_pcam.get_global_transform()


func _check_camera_host_amount() -> void:
	if _get_pcam_host_group().size() > 1:
		_multiple_pcam_hosts = true
	else:
		_multiple_pcam_hosts = false


func _assign_new_active_pcam(pcam: Node) -> void:
	var no_previous_pcam: bool

	if _active_pcam:
		if _is_2D:
			_prev_active_pcam_2d_transform = camera_2d.get_global_transform()
			_active_pcam.queue_redraw()
		else:
			_prev_active_pcam_3d_transform = camera_3d.get_global_transform()
			_prev_camera_fov = camera_3d.get_fov()
			_prev_camera_h_offset = camera_3d.get_h_offset()
			_prev_camera_v_offset = camera_3d.get_v_offset()

		_active_pcam.set_is_active(self, false)
		_active_pcam.became_inactive.emit()

		if _trigger_pcam_tween:
			_active_pcam.tween_interrupted.emit(pcam)
	else:
		no_previous_pcam = true

	_active_pcam = pcam
	_active_pcam_priority = pcam.get_priority()
	_active_pcam_has_damping = pcam.follow_damping

	if _active_pcam.show_viewfinder_in_play:
		_viewfinder_needed_check = true

	_active_pcam.set_is_active(self, true)
	_active_pcam.became_active.emit()

	if _is_2D:
		_camera_zoom = camera_2d.get_zoom()
	else:
		if _active_pcam.get_camera_3d_resource():
			camera_3d.cull_mask = _active_pcam.get_cull_mask()

	if no_previous_pcam:
		if _is_2D:
			_prev_active_pcam_2d_transform = _active_pcam.get_global_transform()
		else:
			_prev_active_pcam_3d_transform = _active_pcam.get_global_transform()

	_tween_duration = 0

	if pcam.tween_on_load or not pcam.get_has_tweened():
		_trigger_pcam_tween = true


func _find_pcam_with_highest_priority() -> void:
	for pcam in _pcam_list:
		if pcam.get_priority() > _active_pcam_priority:
			_assign_new_active_pcam(pcam)

		pcam.set_has_tweened(self, false)

		_active_pcam_missing = false


func _pcam_tween(delta: float) -> void:
	# Run at the first tween frame
	if _tween_duration == 0:
		_active_pcam.tween_started.emit()

		if _is_2D:
			_active_pcam.reset_limit()

	_tween_duration += delta
	_active_pcam.is_tweening.emit()

	if _is_2D:
		var interpolation_destination: Vector2 = _tween_interpolate_value(_prev_active_pcam_2d_transform.origin, _active_pcam_2d_glob_transform.origin)

		if _active_pcam.snap_to_pixel:
			camera_2d.global_position = interpolation_destination.round()
		else:
			camera_2d.global_position = interpolation_destination

		camera_2d.rotation = _tween_interpolate_value(_prev_active_pcam_2d_transform.get_rotation(), _active_pcam_2d_glob_transform.get_rotation())
		camera_2d.zoom = _tween_interpolate_value(_camera_zoom, _active_pcam.zoom)
	else:
		camera_3d.global_position = \
			_tween_interpolate_value(_prev_active_pcam_3d_transform.origin, _active_pcam_3d_glob_transform.origin)

		var prev_active_pcam_3d_quat: Quaternion = Quaternion(_prev_active_pcam_3d_transform.basis.orthonormalized())
		camera_3d.quaternion = \
			Tween.interpolate_value(
				prev_active_pcam_3d_quat, \
				prev_active_pcam_3d_quat.inverse() * Quaternion(_active_pcam_3d_glob_transform.basis.orthonormalized()),
				_tween_duration, \
				_active_pcam.get_tween_duration(), \
				_active_pcam.get_tween_transition(),
				_active_pcam.get_tween_ease(),
			)

		if _prev_camera_fov != _active_pcam.get_fov():
			camera_3d.set_fov(
				_tween_interpolate_value(_prev_camera_fov, _active_pcam.get_fov())
			)

		if _prev_camera_h_offset != _active_pcam.get_h_offset():
			camera_3d.set_h_offset(
				_tween_interpolate_value(_prev_camera_h_offset, _active_pcam.get_h_offset())
			)

		if _prev_camera_v_offset != _active_pcam.get_v_offset():
			camera_3d.set_v_offset(
				_tween_interpolate_value(_prev_camera_v_offset, _active_pcam.get_v_offset())
			)


func _tween_interpolate_value(from: Variant, to: Variant) -> Variant:
	return Tween.interpolate_value(
		from, \
		to - from,
		_tween_duration, \
		_active_pcam.get_tween_duration(), \
		_active_pcam.get_tween_transition(),
		_active_pcam.get_tween_ease(),
	)


func _pcam_follow(delta: float) -> void:
	if not _active_pcam: return

	if _is_2D:
		if _active_pcam.snap_to_pixel:
			var snap_to_pixel_glob_transform := _active_pcam_2d_glob_transform
			snap_to_pixel_glob_transform.origin = snap_to_pixel_glob_transform.origin.round()
			camera_2d.global_transform = snap_to_pixel_glob_transform
		else:
			camera_2d.global_transform =_active_pcam_2d_glob_transform
		camera_2d.zoom = _active_pcam.zoom
	else:
		camera_3d.global_transform = _active_pcam_3d_glob_transform


func _process_pcam(delta: float) -> void:
	if _active_pcam_missing or not _is_child_of_camera: return
	# When following
	if not _trigger_pcam_tween:
		_pcam_follow(delta)

		if _viewfinder_needed_check:
			_show_viewfinder_in_play()
			_viewfinder_needed_check = false

		# TODO - Should be able to find a more efficient way
		if Engine.is_editor_hint():
			if not _is_2D:
				if _active_pcam.get_camera_3d_resource():
					camera_3d.cull_mask = _active_pcam.get_cull_mask()
					camera_3d.fov = _active_pcam.get_fov()
					camera_3d.h_offset =_active_pcam.get_h_offset()
					camera_3d.v_offset = _active_pcam.get_v_offset()

	# When tweening
	else:
		if _tween_duration + delta <= _active_pcam.get_tween_duration():
			_pcam_tween(delta)
		else: # First frame when tweening completes
			_tween_duration = 0
			_trigger_pcam_tween = false

			#_show_viewfinder_in_play() # NOTE - Likely not needed
			_pcam_follow(delta)
			_active_pcam.tween_completed.emit()

			if _is_2D:
				_active_pcam.update_limit_all_sides()

				if Engine.is_editor_hint():
					_active_pcam.queue_redraw()


func _get_pcam_node_group() -> Array[Node]:
	return get_tree().get_nodes_in_group(_constants.PCAM_GROUP_NAME)


func _get_pcam_host_group() -> Array[Node]:
	return get_tree().get_nodes_in_group(_constants.PCAM_HOST_GROUP_NAME)


func _process(delta):
	if not is_instance_valid(_active_pcam): return

	if _is_2D:
		_active_pcam_2d_glob_transform = _active_pcam.get_global_transform()
	else:
		_active_pcam_3d_glob_transform = _active_pcam.get_global_transform()

	_process_pcam(delta)

#endregion


#region Public Functions

func _show_viewfinder_in_play() -> void:
	if _active_pcam.show_viewfinder_in_play:
		if not Engine.is_editor_hint() && OS.has_feature("editor"): # Only appears when running in the editor
			var canvas_layer: CanvasLayer = CanvasLayer.new()
			get_tree().get_root().get_child(0).add_child(canvas_layer)

			if not is_instance_valid(_viewfinder_node):
				var _viewfinder_scene := load("res://addons/phantom_camera/panel/viewfinder/viewfinder_panel.tscn")
				_viewfinder_node = _viewfinder_scene.instantiate()
				canvas_layer.add_child(_viewfinder_node)
			else:
				_viewfinder_node.visible = true
				_viewfinder_node.update_dead_zone()
	else:
		if is_instance_valid(_viewfinder_node):
			_viewfinder_node.visible = false


## Called when a [param PhantomCamera] is added to the scene.[br]
## [b]Note:[/b] This can only be called internally from a
## [param PhantomCamera] node.
func pcam_added_to_scene(pcam: Node) -> void:
	if is_instance_of(pcam, PhantomCamera2D) or is_instance_of(pcam, PhantomCamera3D):
		_pcam_list.append(pcam)

		if not pcam.tween_on_load:
			pcam.set_has_tweened(self, true) # Skips its tween if it has the highest priority on load

		_find_pcam_with_highest_priority()

	else:
		printerr("This function should only be called from PhantomCamera scripts")


## Called when a [param PhantomCamera] is removed from the scene.[br]
## [b]Note:[/b] This can only be called internally from a
## [param PhantomCamera] node.
func pcam_removed_from_scene(pcam: Node) -> void:
	if is_instance_of(pcam, PhantomCamera2D) or is_instance_of(pcam, PhantomCamera3D):
		_pcam_list.erase(pcam)
		if pcam == _active_pcam:
			_active_pcam_missing = true
			_active_pcam_priority = -1
			_find_pcam_with_highest_priority()
	else:
		printerr("This function should only be called from PhantomCamera scripts")

## Triggers a recalculation to determine which PhantomCamera has the highest
## priority.
func pcam_priority_updated(pcam: Node) -> void:
	if Engine.is_editor_hint() and _active_pcam.priority_override: return

	if not is_instance_valid(pcam): return

	var current_pcam_priority: int = pcam.get_priority()

	if current_pcam_priority >= _active_pcam_priority and pcam != _active_pcam:
		_assign_new_active_pcam(pcam)
	elif pcam == _active_pcam:
		if current_pcam_priority <= _active_pcam_priority:
			_active_pcam_priority = current_pcam_priority
			_find_pcam_with_highest_priority()
		else:
			_active_pcam_priority = current_pcam_priority


## Updates the viewfinder when a [param PhantomCamera] has its
## [param priority_ovrride] enabled.[br]
## [b]Note:[/b] This only affects the editor.
func pcam_priority_override(pcam: Node) -> void:
	if Engine.is_editor_hint() and _active_pcam.priority_override:
		_active_pcam.priority_override = false

	_assign_new_active_pcam(pcam)
	update_editor_viewfinder.emit()


## Updates the viewfinder when a [param PhantomCamera] has its
## [param priority_ovrride] disabled.[br]
## [b]Note:[/b] This only affects the editor.
func pcam_priority_override_disabled() -> void:
	update_editor_viewfinder.emit()


## Returns the currently active [param PhantomCamera]
func get_active_pcam() -> Node:
	return _active_pcam

## Returns whether if a [param PhantomCamera] should tween when it becomes
## active. If it's already active, the value will always be false.
## [b]Note:[/b] This can only be called internally from a
## [param PhantomCamera] node.
func get_trigger_pcam_tween() -> bool:
	return _trigger_pcam_tween

#endregion
