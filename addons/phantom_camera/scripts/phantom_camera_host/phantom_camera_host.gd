@tool
@icon("res://addons/phantom_camera/icons/PhantomCameraHostIcon.svg")
class_name PhantomCameraHost
extends Node

const PcamGroupNames = preload("res://addons/phantom_camera/scripts/group_names.gd")

var _damping: float

var _pcam_tween: Tween
var _tween_default_ease: Tween.EaseType
var _easing: Tween.TransitionType

var camera: Node
var _pcam_list: Array[Node]

var _active_pcam: Node
var _active_pcam_priority: int = -1
var _active_pcam_missing: bool = true
var _active_pcam_has_damping: bool

var _previous_active_pcam_position
var _previous_active_pcam_rotation

var trigger_pcam_tween: bool
var tween_duration: float

var multiple_pcam_hosts: bool

var is_child_of_camera: bool = false
var _is_3D: bool

var framed_viewfinder_scene = load("res://addons/phantom_camera/framed_viewfinder/framed_viewfinder_panel.tscn")
var framed_viewfinder_node: Control
var viewfinder_needed_check: bool = true

var camera_zoom

###################
# Private Functions
###################
func _enter_tree() -> void:
	camera = get_parent()

	if camera is Camera2D or camera is Camera3D:
		is_child_of_camera = true
		if camera is Camera2D:
			_is_3D = false
		else:
			_is_3D = true

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


func _check_camera_host_amount():
	if _get_pcam_host_group().size() > 1:
		multiple_pcam_hosts = true
	else:
		multiple_pcam_hosts = false


func _assign_new_active_pcam(pcam: Node) -> void:
	var no_previous_pcam: bool

	if _active_pcam:
		_previous_active_pcam_position = camera.get_position()
		_previous_active_pcam_rotation = camera.get_rotation()
	else:
		no_previous_pcam = true

	if _active_pcam:
		_active_pcam.Properties.is_active = false

	_active_pcam = pcam
	_active_pcam_priority = pcam.get_priority()
	_active_pcam_has_damping = pcam.Properties.follow_has_damping

	_active_pcam.Properties.is_active = true

	if camera is Camera2D:
		camera_zoom = camera.get_zoom()

	if no_previous_pcam:
		_previous_active_pcam_position = _active_pcam.get_position()
		_previous_active_pcam_rotation = _active_pcam.get_rotation()

	tween_duration = 0
	trigger_pcam_tween = true

#	if _active_pcam.follow_mode == _active_pcam.Constants.FollowMode.FRAMED:
#		print("Is framed camera")

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
	camera.set_position(
		Tween.interpolate_value(
			_previous_active_pcam_position,
			_active_pcam.get_global_position() - _previous_active_pcam_position,
			tween_duration,
			_active_pcam.get_tween_duration(),
			_active_pcam.get_tween_transition(),
			_active_pcam.get_tween_ease(),
		)
	)
	camera.set_rotation(
		Tween.interpolate_value(
			_previous_active_pcam_rotation, \
			_active_pcam.get_global_rotation() - _previous_active_pcam_rotation,
			tween_duration, \
			_active_pcam.get_tween_duration(), \
			_active_pcam.get_tween_transition(),
			_active_pcam.get_tween_ease(),
		)
	)

	if not _is_3D:
		camera.set_zoom(
			Tween.interpolate_value(
				camera_zoom, \
				_active_pcam.Properties.zoom - camera_zoom,
				tween_duration, \
				_active_pcam.get_tween_duration(), \
				_active_pcam.get_tween_transition(),
				_active_pcam.get_tween_ease(),
			)
		)


func _reset_tween_on_load() -> void:
	for pcam in _get_pcam_node_group():
			pcam.Properties.has_tweened_onload  = true


func _pcam_follow(delta: float) -> void:
	if not _active_pcam: return

	if _active_pcam.Properties.follow_has_damping:
		camera.set_position(
			camera.get_position().lerp(
				_active_pcam.get_global_position(),
				delta * _active_pcam.Properties.follow_damping_value
			)
		)
	else:
		camera.set_position(_active_pcam.get_global_position())

	if not _is_3D:
		if _active_pcam.Properties.has_follow_group:
			if _active_pcam.Properties.follow_has_damping:
				camera.zoom = camera.zoom.lerp(_active_pcam.Properties.zoom, delta * _active_pcam.Properties.follow_damping_value)
			else:
				camera.set_zoom(_active_pcam.zoom)
		else:
			camera.set_zoom(_active_pcam.Properties.zoom)

	camera.set_rotation(_active_pcam.get_global_rotation())

func _process_pcam(delta: float) -> void:
	if _active_pcam_missing or not is_child_of_camera: return

	if not trigger_pcam_tween:
		# Camera follows the PhantomCamera
		_pcam_follow(delta)

		if viewfinder_needed_check:
			show_viewfinder_in_play()
			viewfinder_needed_check = false

	else:
		# Camera transitions to another PhantomCamera
		if tween_duration < _active_pcam.get_tween_duration():
			_tween_pcam(delta)
		else:
			tween_duration = 0
			trigger_pcam_tween = false
			show_viewfinder_in_play()


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


func _process(delta: float) -> void:
	_process_pcam(delta)


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
	var current_pcam_priority: int = pcam.get_priority()

	if current_pcam_priority >= _active_pcam_priority and pcam != _active_pcam:
		_assign_new_active_pcam(pcam)
	elif pcam == _active_pcam:
		if current_pcam_priority <= _active_pcam_priority:
			_active_pcam_priority = current_pcam_priority
			_find_pcam_with_highest_priority()
		else:
			_active_pcam_priority = current_pcam_priority


func get_active_pcam() -> Node:
	return _active_pcam
