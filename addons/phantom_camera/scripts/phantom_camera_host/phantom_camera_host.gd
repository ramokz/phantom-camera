@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraHostIcon.svg")
class_name PhantomCameraHost
extends Node

const PcamGroupNames = preload("res://addons/phantom_camera/scripts/group_names.gd")

var _pcam_tween: Tween
var _tween_default_ease: Tween.EaseType
var _easing: Tween.TransitionType

var camera_2D: Camera2D
var camera_3D: Camera3D
var _pcam_list: Array[Node]

var _active_pcam: Node
var _active_pcam_priority: int = -1
var _active_pcam_missing: bool = true
var _active_pcam_has_damping: bool

var _prev_active_pcam_2D_transform: Transform2D
var _prev_active_pcam_3D_transform: Transform3D

var trigger_pcam_tween: bool
var tween_duration: float

var multiple_pcam_hosts: bool

var is_child_of_camera: bool = false
var _is_2D: bool

signal update_editor_viewfinder

var framed_viewfinder_scene = load("res://addons/phantom_camera/framed_viewfinder/framed_viewfinder_panel.tscn")
var framed_viewfinder_node: Control
var viewfinder_needed_check: bool = true

var camera_zoom: Vector2

var _prev_camera_h_offset: float
var _prev_camera_v_offset: float
var _prev_camera_fov: float

var _should_refresh_transform: bool
var _active_pcam_2D_glob_transform: Transform2D
var _active_pcam_3D_glob_transform: Transform3D

###################
# Private Functions
###################
func _enter_tree() -> void:
#	camera = get_parent()
	var parent = get_parent()

	if parent is Camera2D or parent is Camera3D:
		is_child_of_camera = true
		if parent is Camera2D:
			_is_2D = true
			camera_2D = parent
		else:
			_is_2D = false
			camera_3D = parent

		add_to_group(PcamGroupNames.PCAM_HOST_GROUP_NAME)
#		var already_multi_hosts: bool = multiple_pcam_hosts

		_check_camera_host_amount()

		if multiple_pcam_hosts:
			printerr(
				"Only one PhantomCameraHost can exist in a scene",
				"\n",
				"Multiple PhantomCameraHosts will be supported in https://github.com/MarcusSkov/phantom-camera/issues/26"
			)
			queue_free()

		for pcam in _get_pcam_node_group():
			if not multiple_pcam_hosts:
				pcam_added_to_scene(pcam)
				pcam.assign_pcam_host()
#			else:
#				pcam.Properties.check_multiple_pcam_host_property(pcam, pca,_host_group, true)
	else:
		printerr(name, " is not a child of a Camera2D or Camera3D")


func _exit_tree() -> void:
	remove_from_group(PcamGroupNames.PCAM_HOST_GROUP_NAME)
	_check_camera_host_amount()

	for pcam in _get_pcam_node_group():
		if not multiple_pcam_hosts:
			pcam.Properties.check_multiple_pcam_host_property(pcam)


func _ready() -> void:
	if not is_instance_valid(_active_pcam): return
	
	if _is_2D:
		_active_pcam_2D_glob_transform = _active_pcam.get_global_transform()
	else:
		_active_pcam_3D_glob_transform = _active_pcam.get_global_transform()


func _check_camera_host_amount():
	if _get_pcam_host_group().size() > 1:
		multiple_pcam_hosts = true
	else:
		multiple_pcam_hosts = false


func _assign_new_active_pcam(pcam: Node) -> void:
	var no_previous_pcam: bool

	if _active_pcam:
		if _is_2D:
			_prev_active_pcam_2D_transform = camera_2D.get_transform()
		else:
			_prev_active_pcam_3D_transform = camera_3D.get_transform()
			_prev_camera_fov = camera_3D.get_fov()
			_prev_camera_h_offset = camera_3D.get_h_offset()
			_prev_camera_v_offset = camera_3D.get_v_offset()

		_active_pcam.Properties.is_active = false
	else:
		no_previous_pcam = true

	_active_pcam = pcam
	_active_pcam_priority = pcam.get_priority()
	_active_pcam_has_damping = pcam.Properties.follow_has_damping

	_active_pcam.Properties.is_active = true

	if _is_2D:
		camera_zoom = camera_2D.get_zoom()
	else:
		if _active_pcam.get_camera_3D_resource():
			camera_3D.set_cull_mask(_active_pcam.get_camera_cull_mask())
			
	if no_previous_pcam:
		if _is_2D:
			_prev_active_pcam_2D_transform = _active_pcam.get_transform()
		else:
			_prev_active_pcam_3D_transform = _active_pcam.get_transform()

	tween_duration = 0
	trigger_pcam_tween = true


func _find_pcam_with_highest_priority() -> void:
	for pcam in _pcam_list:
		if pcam.get_priority() > _active_pcam_priority:
			_assign_new_active_pcam(pcam)

		_active_pcam_missing = false


func _tween_pcam(delta: float) -> void:
	if _active_pcam.Properties.tween_onload == false && _active_pcam.Properties.has_tweened_onload == false:
		trigger_pcam_tween = false
		_reset_tween_on_load()
		return
	else:
		_reset_tween_on_load()

	tween_duration += delta

	if _is_2D:
		camera_2D.set_global_position(
			_tween_interpolate_value(_prev_active_pcam_2D_transform.origin, _active_pcam_2D_glob_transform.origin)
		)

		camera_2D.set_zoom(
			_tween_interpolate_value(camera_zoom, _active_pcam.Properties.zoom)
		)
	else:
		camera_3D.set_global_position(
			_tween_interpolate_value(_prev_active_pcam_3D_transform.origin, _active_pcam_3D_glob_transform.origin)
		)

		var prev_active_pcam_3D_basis = Quaternion(_prev_active_pcam_3D_transform.basis.orthonormalized())
		camera_3D.set_quaternion(
			Tween.interpolate_value(
				prev_active_pcam_3D_basis, \
				prev_active_pcam_3D_basis.inverse() * Quaternion(_active_pcam_3D_glob_transform.basis.orthonormalized()),
				tween_duration, \
				_active_pcam.get_tween_duration(), \
				_active_pcam.get_tween_transition(),
				_active_pcam.get_tween_ease(),
			)
		)
	
		if _prev_camera_fov != _active_pcam.get_camera_fov() and _active_pcam.get_camera_3D_resource():
			camera_3D.set_fov(
				_tween_interpolate_value(_prev_camera_fov, _active_pcam.get_camera_fov())
			)

		if _prev_camera_h_offset != _active_pcam.get_camera_h_offset() and _active_pcam.get_camera_3D_resource():
			camera_3D.set_h_offset(
				_tween_interpolate_value(_prev_camera_h_offset, _active_pcam.get_camera_h_offset())
			)

		if _prev_camera_v_offset != _active_pcam.get_camera_v_offset() and _active_pcam.get_camera_3D_resource():
			camera_3D.set_v_offset(
				_tween_interpolate_value(_prev_camera_v_offset, _active_pcam.get_camera_v_offset())
			)


func _tween_interpolate_value(from: Variant, to: Variant) -> Variant:
	return Tween.interpolate_value(
		from, \
		to - from,
		tween_duration, \
		_active_pcam.get_tween_duration(), \
		_active_pcam.get_tween_transition(),
		_active_pcam.get_tween_ease(),
	)


func _reset_tween_on_load() -> void:
	for pcam in _get_pcam_node_group():
		pcam.Properties.has_tweened_onload  = true
	
	if not _is_2D:
		if _active_pcam.get_camera_3D_resource():
			camera_3D.set_fov(_active_pcam.get_camera_fov())
			camera_3D.set_h_offset(_active_pcam.get_camera_h_offset())
			camera_3D.set_v_offset(_active_pcam.get_camera_v_offset())


func _pcam_follow(delta: float) -> void:
	if not _active_pcam: return
		
	if _is_2D:
		camera_2D.set_global_transform(_active_pcam_2D_glob_transform)
		if _active_pcam.Properties.has_follow_group:
			if _active_pcam.Properties.follow_has_damping:
				camera_2D.zoom = camera_2D.zoom.lerp(_active_pcam.Properties.zoom, delta * _active_pcam.Properties.follow_damping_value)
			else:
				camera_2D.set_zoom(_active_pcam.zoom)
		else:
			camera_2D.set_zoom(_active_pcam.Properties.zoom)
	else:
		camera_3D.set_global_transform(_active_pcam_3D_glob_transform)


func _refresh_transform() -> void:
	if _is_2D:
		_active_pcam_2D_glob_transform = _active_pcam.get_global_transform()
	else:
		_active_pcam_3D_glob_transform = _active_pcam.get_global_transform()


func _process_pcam(delta: float) -> void:
	if _active_pcam_missing or not is_child_of_camera: return

	if not trigger_pcam_tween:
		_pcam_follow(delta)

		if viewfinder_needed_check:
			show_viewfinder_in_play()
			viewfinder_needed_check = false
			
		if Engine.is_editor_hint():
			if not _is_2D:
				if _active_pcam.get_camera_3D_resource():
					camera_3D.set_fov(_active_pcam.get_camera_fov())
					camera_3D.set_h_offset(_active_pcam.get_camera_h_offset())
					camera_3D.set_v_offset(_active_pcam.get_camera_v_offset())

	else:
		if tween_duration < _active_pcam.get_tween_duration():
			_tween_pcam(delta)
		else:
			tween_duration = 0
			trigger_pcam_tween = false
			show_viewfinder_in_play()
			_pcam_follow(delta)


func show_viewfinder_in_play() -> void:
	if _active_pcam.Properties.show_viewfinder_in_play:
		if not Engine.is_editor_hint() && OS.has_feature("editor"): # Only appears when running in the editor
			var canvas_layer: CanvasLayer = CanvasLayer.new()
			get_tree().get_root().get_child(0).add_child(canvas_layer)
			
			framed_viewfinder_node = framed_viewfinder_scene.instantiate()
			canvas_layer.add_child(framed_viewfinder_node)
	else:
		if framed_viewfinder_node:
			framed_viewfinder_node.queue_free()


func _get_pcam_node_group() -> Array[Node]:
	return get_tree().get_nodes_in_group(PcamGroupNames.PCAM_GROUP_NAME)


func _get_pcam_host_group() -> Array[Node]:
	return get_tree().get_nodes_in_group(PcamGroupNames.PCAM_HOST_GROUP_NAME)


func _process(delta):
	if not is_instance_valid(_active_pcam): return
	
	if _should_refresh_transform:
#		_refresh_transform()
		if _is_2D:
			_active_pcam_2D_glob_transform = _active_pcam.get_global_transform()
		else:
			_active_pcam_3D_glob_transform = _active_pcam.get_global_transform()
			
		_should_refresh_transform = false

	_process_pcam(delta)


func _physics_process(delta: float) -> void:
	_should_refresh_transform = true


##################
# Public Functions
##################
func pcam_added_to_scene(pcam: Node) -> void:
	_pcam_list.append(pcam)
	_find_pcam_with_highest_priority()


func pcam_removed_from_scene(pcam) -> void:
	_pcam_list.erase(pcam)
	if pcam == _active_pcam:
		_active_pcam_missing = true
		_active_pcam_priority = -1
		_find_pcam_with_highest_priority()


func pcam_priority_updated(pcam: Node) -> void:
	if Engine.is_editor_hint() and _active_pcam.Properties.priority_override: return
	
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


func pcam_priority_override(pcam: Node) -> void:
	if Engine.is_editor_hint() and _active_pcam.Properties.priority_override:
		_active_pcam.Properties.priority_override = false

	_assign_new_active_pcam(pcam)
	update_editor_viewfinder.emit()

func pcam_priority_override_disabled() -> void:
	update_editor_viewfinder.emit()


func get_active_pcam() -> Node:
	return _active_pcam
