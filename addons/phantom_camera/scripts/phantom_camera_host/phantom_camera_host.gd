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

enum InterpolationMode {
	AUTO = 0,
	IDLE = 1,
	PHYSICS = 2,
}

## TBD - For when Godot 4.3 becomes the minimum version
#@export var interpolation_mode: InterpolationMode = InterpolationMode.AUTO:
	#set = set_interpolation_mode,
	#get = get_interpolation_mode


## For 2D scenes, is the [Camera2D] instance the [param PhantomCameraHost] controls.
var camera_2d: Camera2D = null
## For 3D scenes, is the [Camera3D] instance the [param PhantomCameraHost] controls.
var camera_3d = null ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.

var _pcam_list: Array[Node] = []

var _active_pcam_2d: PhantomCamera2D = null
var _active_pcam_3d = null ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
var _active_pcam_priority: int = -1
var _active_pcam_missing: bool = true
var _active_pcam_has_damping: bool = false
var _follow_target_physics_based: bool = false

var _prev_active_pcam_2d_transform: Transform2D = Transform2D()
var _prev_active_pcam_3d_transform: Transform3D = Transform3D()

var _trigger_pcam_tween: bool = false
var _tween_elapsed_time: float = 0
var _tween_duration: float = 0

var _multiple_pcam_hosts: bool = false

var _is_child_of_camera: bool = false
var _is_2D: bool = false


var _viewfinder_node: Control = null
var _viewfinder_needed_check: bool = true

var _camera_zoom: Vector2 = Vector2.ONE

#region Camera3DResource
var _prev_cam_h_offset: float = 0
var _cam_h_offset_changed: bool = false

var _prev_cam_v_offset: float = 0
var _cam_v_offset_changed: bool = false

var _prev_cam_fov: float = 75
var _cam_fov_changed: bool = false

var _prev_cam_size: float = 1
var _cam_size_changed: bool = false

var _prev_cam_frustum_offset: Vector2 = Vector2.ZERO
var _cam_frustum_offset_changed: bool = false

var _prev_cam_near: float = 0.05
var _cam_near_changed: bool = false

var _prev_cam_far: float = 4000
var _cam_far_changed: bool = false
#endregion

var _active_pcam_2d_glob_transform: Transform2D = Transform2D()
var _active_pcam_3d_glob_transform: Transform3D = Transform3D()

#endregion

# NOTE - Temp solution until Godot has better plugin autoload recognition out-of-the-box.
var _phantom_camera_manager: Node

#region Private Functions

## TBD - For when Godot 4.3 becomes a minimum version
#func _validate_property(property: Dictionary) -> void:
	#if property.name == "interpolation_mode" and get_parent() is Node3D:
		#property.usage = PROPERTY_USAGE_NO_EDITOR


func _get_configuration_warnings() -> PackedStringArray:
	var parent = get_parent()

	if _is_2D:
		if not parent is Camera2D:
			return ["Needs to be a child of a Camera2D in order to work."]
		else:
			return []
	else:
		if not parent.is_class("Camera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
			return ["Needs to be a child of a Camera3D in order to work."]
		else:
			return []


func _enter_tree() -> void:
	_phantom_camera_manager = get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME)

	var parent = get_parent()

	if parent is Camera2D or parent.is_class("Camera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		_is_child_of_camera = true
		if parent is Camera2D:
			_is_2D = true
			camera_2d = parent
			## Force applies position smoothing to be disabled
			## This is to prevent overlap with the interpolation of the PCam2D.
			camera_2d.set_position_smoothing_enabled(false)
		else:
			_is_2D = false
			camera_3d = parent

		_phantom_camera_manager.pcam_host_added(self)
#		var already_multi_hosts: bool = multiple_pcam_hosts

		_check_camera_host_amount()

		if _multiple_pcam_hosts:
			printerr(
				"Only one PhantomCameraHost can exist in a scene",
				"\n",
				"Multiple PhantomCameraHosts will be supported in https://github.com/ramokz/phantom-camera/issues/26"
			)
			queue_free()

		if _is_2D:
			if not _phantom_camera_manager.get_phantom_camera_2ds().is_empty():
				for pcam in _phantom_camera_manager.get_phantom_camera_2ds():
					pcam_added_to_scene(pcam)
					pcam.set_pcam_host_owner(self)
		else:
			if not _phantom_camera_manager.get_phantom_camera_3ds().is_empty():
				for pcam in _phantom_camera_manager.get_phantom_camera_3ds():
					pcam_added_to_scene(pcam)
					pcam.set_pcam_host_owner(self)


func _exit_tree() -> void:
	_phantom_camera_manager.pcam_host_removed(self)
	_check_camera_host_amount()


func _ready() -> void:
	if not is_instance_valid(_active_pcam_2d) or is_instance_valid(_active_pcam_3d): return
	if _is_2D:
		_active_pcam_2d_glob_transform = _active_pcam_2d.get_global_transform()
	else:
		_active_pcam_3d_glob_transform = _active_pcam_3d.get_global_transform()


func _check_camera_host_amount() -> void:
	if _phantom_camera_manager.get_phantom_camera_hosts().size() > 1:
		_multiple_pcam_hosts = true
	else:
		_multiple_pcam_hosts = false


func _assign_new_active_pcam(pcam: Node) -> void:
	var no_previous_pcam: bool

	if is_instance_valid(_active_pcam_2d) or is_instance_valid(_active_pcam_3d):
		if _is_2D:
			_prev_active_pcam_2d_transform = camera_2d.get_global_transform()
			_active_pcam_2d.queue_redraw()
			_active_pcam_2d.set_is_active(self, false)
			_active_pcam_2d.became_inactive.emit()

			if _trigger_pcam_tween:
				_active_pcam_2d.tween_interrupted.emit(pcam)
		else:
			_prev_active_pcam_3d_transform = camera_3d.get_global_transform()

			_prev_cam_h_offset = camera_3d.h_offset
			_prev_cam_v_offset = camera_3d.v_offset
			_prev_cam_fov = camera_3d.fov
			_prev_cam_size = camera_3d.size
			_prev_cam_frustum_offset = camera_3d.frustum_offset
			_prev_cam_near = camera_3d.near
			_prev_cam_far = camera_3d.far

			_active_pcam_3d.set_is_active(self, false)
			_active_pcam_3d.became_inactive.emit()

			if _trigger_pcam_tween:
				_active_pcam_3d.tween_interrupted.emit(pcam)
	else:
		no_previous_pcam = true

	## Assign newly active pcam
	if _is_2D:
		_active_pcam_2d = pcam
		_active_pcam_priority = _active_pcam_2d.priority
		_active_pcam_has_damping = _active_pcam_2d.follow_damping
		_tween_duration = _active_pcam_2d.get_tween_duration()
	else:
		_active_pcam_3d = pcam
		_active_pcam_priority = _active_pcam_3d.priority
		_active_pcam_has_damping = _active_pcam_3d.follow_damping
		_tween_duration = _active_pcam_3d.get_tween_duration()

		# Checks if the Camera3DResource has changed from previous Active PCam3D
		if _active_pcam_3d.get_camera_3d_resource():
			if _prev_cam_h_offset != _active_pcam_3d.get_h_offset():
				_cam_h_offset_changed = true
			if _prev_cam_v_offset != _active_pcam_3d.get_v_offset():
				_cam_v_offset_changed = true
			if _prev_cam_fov != _active_pcam_3d.get_fov():
				_cam_fov_changed = true
			if _prev_cam_size != _active_pcam_3d.get_size():
				_cam_size_changed = true
			if _prev_cam_frustum_offset != _active_pcam_3d.get_frustum_offset():
				_cam_frustum_offset_changed = true
			if _prev_cam_near != _active_pcam_3d.get_near():
				_cam_near_changed = true
			if _prev_cam_far != _active_pcam_3d.get_far():
				_cam_far_changed = true

	if _is_2D:
		if _active_pcam_2d.show_viewfinder_in_play:
			_viewfinder_needed_check = true

		_active_pcam_2d.set_is_active(self, true)
		_active_pcam_2d.became_active.emit()
		_camera_zoom = camera_2d.get_zoom()
		## TODO - Needs 3D variant once Godot supports physics_interpolation for 3D scenes.
		var _physics_based: bool

		## NOTE - Only supported in Godot 4.3 or above
		if Engine.get_version_info().major == 4 and \
		Engine.get_version_info().minor >= 3:
			## TBD - For when Godot 4.3 becomes the minimum version
			#if interpolation_mode == InterpolationMode.IDLE:
				#_physics_based = false
			#elif interpolation_mode == InterpolationMode.PHYSICS:
				#_physics_based = true
			#else:
				#_physics_based = _active_pcam.follow_target_physics_based

			# TBD - REMOVE this line once Godot 4.3 becomes the minimum version
			_physics_based = _active_pcam_2d.get_follow_target_physics_based()

			if _physics_based:
				_follow_target_physics_based = true
				_active_pcam_2d.set_follow_target_physics_based(true, self)
				## TODO - Temporary solution to support Godot 4.2
				## Remove line below and uncomment the following once Godot 4.3 is min verison.
				camera_2d.call("reset_physics_interpolation")
				camera_2d.set("physics_interpolation_mode", 1)
				#camera_2d.reset_physics_interpolation()
				#camera_2d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
			else:
				_follow_target_physics_based = false
				_active_pcam_2d.set_follow_target_physics_based(false, self)
				## TODO - Temporary solution to support Godot 4.2
				## Remove line below and uncomment the following once Godot 4.3 is min verison.
				camera_2d.set("physics_interpolation_mode", 2)
				#camera_2d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	else:
		_follow_target_physics_based = false
		if _active_pcam_3d.show_viewfinder_in_play:
			_viewfinder_needed_check = true

		_active_pcam_3d.set_is_active(self, true)
		_active_pcam_3d.became_active.emit()
		if _active_pcam_3d.get_camera_3d_resource():
			camera_3d.cull_mask = _active_pcam_3d.get_cull_mask()
			camera_3d.projection = _active_pcam_3d.get_projection()

	if no_previous_pcam:
		if _is_2D:
			_prev_active_pcam_2d_transform = _active_pcam_2d.get_global_transform()
		else:
			_prev_active_pcam_3d_transform = _active_pcam_3d.get_global_transform()

	_tween_elapsed_time = 0
	if not pcam.get_has_tweened():
		_trigger_pcam_tween = true
	else:
		_trigger_pcam_tween = false


func _find_pcam_with_highest_priority() -> void:
	for pcam in _pcam_list:
		if pcam.get_priority() > _active_pcam_priority:
			_assign_new_active_pcam(pcam)

		pcam.set_has_tweened(self, false)

		_active_pcam_missing = false


func _process(delta: float):
	if _follow_target_physics_based or _active_pcam_missing: return

	if _is_2D:
		_active_pcam_2d_glob_transform = _active_pcam_2d.get_global_transform()
	else:
		_active_pcam_3d_glob_transform = _active_pcam_3d.get_global_transform()

	if _trigger_pcam_tween:
		_pcam_tween(delta)
	else:
		_pcam_follow(delta)


func _physics_process(delta: float):
	if not _follow_target_physics_based or _active_pcam_missing: return

	if _is_2D:
		_active_pcam_2d_glob_transform = _active_pcam_2d.get_global_transform()
	else:
		_active_pcam_3d_glob_transform = _active_pcam_3d.get_global_transform()

	if _trigger_pcam_tween:
		_pcam_tween(delta)
	else:
		_pcam_follow(delta)


func _pcam_follow(delta: float) -> void:
	if _is_2D:
		if not is_instance_valid(_active_pcam_2d): return
	else:
		if not is_instance_valid(_active_pcam_3d): return

	if _active_pcam_missing or not _is_child_of_camera: return
	# When following
	_pcam_set_position(delta)

	if _viewfinder_needed_check:
		_show_viewfinder_in_play()
		_viewfinder_needed_check = false

	# TODO - Should be able to find a more efficient way using signals
	if Engine.is_editor_hint():
		if not _is_2D:
			if _active_pcam_3d.get_camera_3d_resource():
				camera_3d.cull_mask = _active_pcam_3d.get_cull_mask()
				camera_3d.h_offset = _active_pcam_3d.get_h_offset()
				camera_3d.v_offset = _active_pcam_3d.get_v_offset()
				camera_3d.projection = _active_pcam_3d.get_projection()
				camera_3d.fov = _active_pcam_3d.get_fov()
				camera_3d.size = _active_pcam_3d.get_size()
				camera_3d.frustum_offset = _active_pcam_3d.get_frustum_offset()
				camera_3d.near = _active_pcam_3d.get_near()
				camera_3d.far = _active_pcam_3d.get_far()


func _pcam_set_position(delta: float) -> void:
	if _is_2D:
		if _active_pcam_2d.snap_to_pixel:
			var snap_to_pixel_glob_transform: Transform2D = _active_pcam_2d_glob_transform
			snap_to_pixel_glob_transform.origin = snap_to_pixel_glob_transform.origin.round()
			camera_2d.global_transform = snap_to_pixel_glob_transform
		else:
			camera_2d.global_transform =_active_pcam_2d_glob_transform
		camera_2d.zoom = _active_pcam_2d.zoom
	else:
		camera_3d.global_transform = _active_pcam_3d_glob_transform


func _pcam_tween(delta: float) -> void:
	if _tween_elapsed_time < _tween_duration:
		_pcam_tween_properties(delta)
	else: # First frame when tweening completes
		_tween_elapsed_time = 0
		_trigger_pcam_tween = false
		#_show_viewfinder_in_play() # NOTE - Likely not needed
		_pcam_follow(delta)

		if _is_2D:
			_active_pcam_2d.update_limit_all_sides()
			_active_pcam_2d.tween_completed.emit()
			if Engine.is_editor_hint():
				_active_pcam_2d.queue_redraw()
		else:
			_cam_h_offset_changed = false
			_cam_v_offset_changed = false
			_cam_fov_changed = false
			_cam_size_changed = false
			_cam_frustum_offset_changed = false
			_cam_near_changed = false
			_cam_far_changed = false

			_active_pcam_3d.tween_completed.emit()


func _pcam_tween_properties(delta: float) -> void:
	# Run at the first tween frame
	if _tween_elapsed_time == 0:
		if _is_2D:
			_active_pcam_2d.tween_started.emit()
			_active_pcam_2d.reset_limit()
		else:
			_active_pcam_3d.tween_started.emit()

	_tween_elapsed_time = min(_tween_duration, _tween_elapsed_time + delta)

	if _is_2D:
		_active_pcam_2d.is_tweening.emit()
		var interpolation_destination: Vector2 = _tween_interpolate_value(
			_prev_active_pcam_2d_transform.origin,
			_active_pcam_2d_glob_transform.origin,
			_active_pcam_2d.get_tween_duration(),
			_active_pcam_2d.get_tween_transition(),
			_active_pcam_2d.get_tween_ease()
		)

		if _active_pcam_2d.snap_to_pixel:
			camera_2d.global_position = interpolation_destination.round()
		else:
			camera_2d.global_position = interpolation_destination

		camera_2d.rotation = _tween_interpolate_value(
			_prev_active_pcam_2d_transform.get_rotation(),
			_active_pcam_2d_glob_transform.get_rotation(),
			_active_pcam_2d.get_tween_duration(),
			_active_pcam_2d.get_tween_transition(),
			_active_pcam_2d.get_tween_ease()
		)
		camera_2d.zoom = _tween_interpolate_value(
			_camera_zoom,
			_active_pcam_2d.zoom,
			_active_pcam_2d.get_tween_duration(),
			_active_pcam_2d.get_tween_transition(),
			_active_pcam_2d.get_tween_ease()
		)
	else:
		_active_pcam_3d.is_tweening.emit()
		camera_3d.global_position = _tween_interpolate_value(
			_prev_active_pcam_3d_transform.origin,
			_active_pcam_3d_glob_transform.origin,
			_active_pcam_3d.get_tween_duration(),
			_active_pcam_3d.get_tween_transition(),
			_active_pcam_3d.get_tween_ease()
		)

		var prev_active_pcam_3d_quat: Quaternion = Quaternion(_prev_active_pcam_3d_transform.basis.orthonormalized())
		camera_3d.quaternion = \
			Tween.interpolate_value(
				prev_active_pcam_3d_quat, \
				prev_active_pcam_3d_quat.inverse() * Quaternion(_active_pcam_3d_glob_transform.basis.orthonormalized()),
				_tween_elapsed_time, \
				_active_pcam_3d.get_tween_duration(), \
				_active_pcam_3d.get_tween_transition(),
				_active_pcam_3d.get_tween_ease()
			)

		if _cam_fov_changed:
			camera_3d.fov = \
				_tween_interpolate_value(
					_prev_cam_fov,
					_active_pcam_3d.get_fov(),
					_active_pcam_3d.get_tween_duration(),
					_active_pcam_3d.get_tween_transition(),
					_active_pcam_3d.get_tween_ease()
				)

		if _cam_size_changed:
			camera_3d.size = \
				_tween_interpolate_value(
					_prev_cam_size,
					_active_pcam_3d.get_size(),
					_active_pcam_3d.get_tween_duration(),
					_active_pcam_3d.get_tween_transition(),
					_active_pcam_3d.get_tween_ease()
				)

		if _cam_frustum_offset_changed:
			camera_3d.frustum_offset = \
				_tween_interpolate_value(
					_prev_cam_frustum_offset,
					_active_pcam_3d.get_frustum_offset(),
					_active_pcam_3d.get_tween_duration(),
					_active_pcam_3d.get_tween_transition(),
					_active_pcam_3d.get_tween_ease()
				)

		if _cam_h_offset_changed:
			camera_3d.h_offset = \
				_tween_interpolate_value(
					_prev_cam_h_offset,
					_active_pcam_3d.get_h_offset(),
					_active_pcam_3d.get_tween_duration(),
					_active_pcam_3d.get_tween_transition(),
					_active_pcam_3d.get_tween_ease()
				)

		if _cam_v_offset_changed:
			camera_3d.v_offset = \
				_tween_interpolate_value(
					_prev_cam_v_offset,
					_active_pcam_3d.get_v_offset(),
					_active_pcam_3d.get_tween_duration(),
					_active_pcam_3d.get_tween_transition(),
					_active_pcam_3d.get_tween_ease()
				)

		if _cam_near_changed:
			camera_3d.near = \
				_tween_interpolate_value(
					_prev_cam_near,
					_active_pcam_3d.get_near(),
					_active_pcam_3d.get_tween_duration(),
					_active_pcam_3d.get_tween_transition(),
					_active_pcam_3d.get_tween_ease()
				)

		if _cam_far_changed:
			camera_3d.far = \
				_tween_interpolate_value(
					_prev_cam_far,
					_active_pcam_3d.get_far(),
					_active_pcam_3d.get_tween_duration(),
					_active_pcam_3d.get_tween_transition(),
					_active_pcam_3d.get_tween_ease()
				)


func _tween_interpolate_value(from: Variant, to: Variant, duration: float, transition_type: int, ease_type: int) -> Variant:
	return Tween.interpolate_value(
		from, \
		to - from,
		_tween_elapsed_time, \
		duration, \
		transition_type,
		ease_type,
	)

#endregion


#region Public Functions

func _show_viewfinder_in_play() -> void:
	# Don't show the viewfinder in the actual editor or project builds
	if Engine.is_editor_hint() or !OS.has_feature("editor"): return

	# We default the viewfinder node to hidden
	if is_instance_valid(_viewfinder_node):
		_viewfinder_node.visible = false

	if _is_2D:
		if not _active_pcam_2d.show_viewfinder_in_play: return
		if _active_pcam_2d.follow_mode != _active_pcam_2d.FollowMode.FRAMED: return
	else:
		if not _active_pcam_3d.show_viewfinder_in_play: return
		if _active_pcam_3d.follow_mode != _active_pcam_2d.FollowMode.FRAMED: return

	var canvas_layer: CanvasLayer = CanvasLayer.new()
	get_tree().get_root().add_child(canvas_layer)

	# Instantiate the viewfinder scene if it isn't already
	if not is_instance_valid(_viewfinder_node):
		var _viewfinder_scene := load("res://addons/phantom_camera/panel/viewfinder/viewfinder_panel.tscn")
		_viewfinder_node = _viewfinder_scene.instantiate()
		canvas_layer.add_child(_viewfinder_node)

	_viewfinder_node.visible = true
	_viewfinder_node.update_dead_zone()


## Called when a [param PhantomCamera] is added to the scene.[br]
## [b]Note:[/b] This can only be called internally from a
## [param PhantomCamera] node.
func pcam_added_to_scene(pcam) -> void:
	if is_instance_of(pcam, PhantomCamera2D) or pcam.is_class("PhantomCamera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		if not _pcam_list.has(pcam):
			_pcam_list.append(pcam)
			if not pcam.tween_on_load:
				pcam.set_has_tweened(self, true) # Skips its tween if it has the highest priority on load
			_find_pcam_with_highest_priority()
	else:
		printerr("This function should only be called from PhantomCamera scripts")


## Called when a [param PhantomCamera] is removed from the scene.[br]
## [b]Note:[/b] This can only be called internally from a
## [param PhantomCamera] node.
func pcam_removed_from_scene(pcam) -> void:
	if is_instance_of(pcam, PhantomCamera2D) or pcam.is_class("PhantomCamera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		_pcam_list.erase(pcam)
		if _is_2D:
			if pcam == _active_pcam_2d:
				_active_pcam_missing = true
				_active_pcam_priority = -1
				_find_pcam_with_highest_priority()
		else:
			if pcam == _active_pcam_3d:
				_active_pcam_missing = true
				_active_pcam_priority = -1
				_find_pcam_with_highest_priority()
	else:
		printerr("This function should only be called from PhantomCamera scripts")


## Triggers a recalculation to determine which PhantomCamera has the highest
## priority.
func pcam_priority_updated(pcam: Node) -> void:
	if Engine.is_editor_hint():
		if _is_2D:
			if _active_pcam_2d.priority_override: return
		else:
			if _active_pcam_3d.priority_override: return

	if not is_instance_valid(pcam): return

	var current_pcam_priority: int = pcam.get_priority()

	if current_pcam_priority >= _active_pcam_priority:
		if _is_2D:
			if pcam != _active_pcam_2d:
				_assign_new_active_pcam(pcam)
		else:
			if pcam != _active_pcam_3d:
				_assign_new_active_pcam(pcam)

	if pcam == _active_pcam_2d or pcam == _active_pcam_3d:
		if current_pcam_priority <= _active_pcam_priority:
			_active_pcam_priority = current_pcam_priority
			_find_pcam_with_highest_priority()
		else:
			_active_pcam_priority = current_pcam_priority


## Updates the viewfinder when a [param PhantomCamera] has its
## [param priority_ovrride] enabled.[br]
## [b]Note:[/b] This only affects the editor.
func pcam_priority_override(pcam: Node) -> void:
	if Engine.is_editor_hint():
		if _is_2D:
			if _active_pcam_2d.priority_override:
				_active_pcam_2d.priority_override = false
		else:
			if _active_pcam_3d.priority_override:
				_active_pcam_3d.priority_override = false

	_assign_new_active_pcam(pcam)
	update_editor_viewfinder.emit()


## Updates the viewfinder when a [param PhantomCamera] has its
## [param priority_ovrride] disabled.[br]
## [b]Note:[/b] This only affects the editor.
func pcam_priority_override_disabled() -> void:
	update_editor_viewfinder.emit()


## Returns the currently active [param PhantomCamera]
func get_active_pcam() -> Node:
	if _is_2D:
		return _active_pcam_2d
	else:
		return _active_pcam_3d


## Returns whether if a [param PhantomCamera] should tween when it becomes
## active. If it's already active, the value will always be false.
## [b]Note:[/b] This can only be called internally from a
## [param PhantomCamera] node.
func get_trigger_pcam_tween() -> bool:
	return _trigger_pcam_tween

#func set_interpolation_mode(value: int) -> void:
	#interpolation_mode = value
#func get_interpolation_mode() -> int:
	#return interpolation_mode

#endregion
