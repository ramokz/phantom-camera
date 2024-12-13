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

#region

## TBD - For when Godot 4.3 becomes the minimum version
#@export var interpolation_mode: InterpolationMode = InterpolationMode.AUTO:
	#set = set_interpolation_mode,
	#get = get_interpolation_mode

#endregion

#region Signals

## Updates the viewfinder [param dead zones] sizes.[br]
## [b]Note:[/b] This is only being used in the editor viewfinder UI.
signal update_editor_viewfinder

#endregion

#region Variables

enum InterpolationMode {
	AUTO    = 0,
	IDLE    = 1,
	PHYSICS = 2,
}

#endregion

#region Private Variables

var _pcam_list: Array[Node] = []

var _active_pcam_2d: PhantomCamera2D = null
var _active_pcam_3d: Node = null ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
var _active_pcam_priority: int = -1
var _active_pcam_missing: bool = true
var _active_pcam_has_damping: bool = false
var _follow_target_physics_based: bool = false

var _prev_active_pcam_2d_transform: Transform2D = Transform2D()
var _prev_active_pcam_3d_transform: Transform3D = Transform3D()

var _trigger_pcam_tween: bool = false
var _tween_elapsed_time: float = 0
var _tween_duration: float = 0
var _tween_is_instant: bool = false

var _multiple_pcam_hosts: bool = false

var _is_child_of_camera: bool = false
var _is_2D: bool = false

var _viewfinder_node: Control = null
var _viewfinder_needed_check: bool = true

var _camera_zoom: Vector2 = Vector2.ONE

#region Camera3DResource

var _prev_cam_attributes: CameraAttributes = null
var _cam_attribute_type: int = 0 # 0 = CameraAttributesPractical, 1 = CameraAttributesPhysical
var _cam_attribute_changed: bool = false
var _cam_attribute_assigned: bool = false

#region CameraAttributes
var _prev_cam_auto_exposure_scale: float = 0.4
var _cam_auto_exposure_scale_changed: bool = false

var _prev_cam_auto_exposure_speed: float = 0.5
var _cam_auto_exposure_speed_changed: bool = false

var _prev_cam_exposure_multiplier: float = 1.0
var _cam_exposure_multiplier_changed: bool = false

var _prev_cam_exposure_sensitivity: float = 100.0
var _cam_exposure_sensitivity_changed: bool = false

#region CameraAttributesPractical
var _prev_cam_exposure_min_sensitivity: float = 0.0
var _cam_exposure_min_sensitivity_changed: bool = false

var _prev_cam_exposure_max_sensitivity: float = 800.0
var _cam_exposure_max_sensitivity_changed: bool = false

var _prev_cam_dof_blur_amount: float = 0.1
var _cam_dof_blur_amount_changed: bool = false

var _cam_dof_blur_far_distance_default: float = 10
var _prev_cam_dof_blur_far_distance: float = _cam_dof_blur_far_distance_default
var _cam_dof_blur_far_distance_changed: bool = false

var _cam_dof_blur_far_transition_default: float = 5
var _prev_cam_dof_blur_far_transition: float = _cam_dof_blur_far_transition_default
var _cam_dof_blur_far_transition_changed: bool = false

var _cam_dof_blur_near_distance_default: float = 2
var _prev_cam_dof_blur_near_distance: float = _cam_dof_blur_near_distance_default
var _cam_dof_blur_near_distance_changed: bool = false

var _cam_dof_blur_near_transition_default: float = 1
var _prev_cam_dof_blur_near_transition: float = _cam_dof_blur_near_transition_default
var _cam_dof_blur_near_transition_changed: bool = false
#endregion

#region CameraAttributesPhysical
var _prev_cam_exposure_min_exposure_value: float = 10.0
var _cam_exposure_min_exposure_value_changed: bool = false

var _prev_cam_exposure_max_exposure_value: float = -8.0
var _cam_exposure_max_exposure_value_changed: bool = false

var _prev_cam_exposure_aperture: float = 16.0
var _cam_exposure_aperture_changed: bool = false

var _prev_cam_exposure_shutter_speed: float = 100.0
var _cam_exposure_shutter_speed_changed: bool = false

var _prev_cam_frustum_far: float = 4000.0
var _cam_frustum_far_changed: bool = false

var _prev_cam_frustum_focal_length: float = 35.0
var _cam_frustum_focal_length_changed: bool = false

var _prev_cam_frustum_near: float = 0.05
var _cam_frustum_near_changed: bool = false

var _prev_cam_frustum_focus_distance: float = 10.0
var _cam_frustum_focus_distance_changed: bool = false

#endregion

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

var _has_noise_emitted: bool = false
var _noise_emitted_output_2d: Transform2D = Transform2D()
var _noise_emitted_output_3d: Transform3D = Transform3D()

#endregion

# NOTE - Temp solution until Godot has better plugin autoload recognition out-of-the-box.
var _phantom_camera_manager: Node

#region Public Variables

## For 2D scenes, is the [Camera2D] instance the [param PhantomCameraHost] controls.
var camera_2d: Camera2D = null
## For 3D scenes, is the [Camera3D] instance the [param PhantomCameraHost] controls.
var camera_3d: Node = null ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.

#endregion

#region Private Functions

## TBD - For when Godot 4.3 becomes a minimum version
#func _validate_property(property: Dictionary) -> void:
	#if property.name == "interpolation_mode" and get_parent() is Node3D:
		#property.usage = PROPERTY_USAGE_NO_EDITOR


func _get_configuration_warnings() -> PackedStringArray:
	var parent: Node = get_parent()

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

	var parent: Node = get_parent()

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
	process_priority = 300
	process_physics_priority = 300

	if _is_2D:
		camera_2d.offset = Vector2.ZERO
		if not is_instance_valid(_active_pcam_2d): return
		_active_pcam_2d_glob_transform = _active_pcam_2d.get_transform_output()
	else:
		if not is_instance_valid(_active_pcam_3d): return
		_active_pcam_3d_glob_transform = _active_pcam_3d.get_transform_output()


func _check_camera_host_amount() -> void:
	if _phantom_camera_manager.get_phantom_camera_hosts().size() > 1:
		_multiple_pcam_hosts = true
	else:
		_multiple_pcam_hosts = false


func _assign_new_active_pcam(pcam: Node) -> void:
	var no_previous_pcam: bool
	if is_instance_valid(_active_pcam_2d) or is_instance_valid(_active_pcam_3d):
		if _is_2D:
			_prev_active_pcam_2d_transform = camera_2d.global_transform
			_active_pcam_2d.queue_redraw()
			_active_pcam_2d.set_is_active(self, false)
			_active_pcam_2d.became_inactive.emit()

			if _active_pcam_2d.physics_target_changed.is_connected(_check_pcam_physics):
				_active_pcam_2d.physics_target_changed.disconnect(_check_pcam_physics)

			if _active_pcam_2d.noise_emitted.is_connected(_noise_emitted_2d):
				_active_pcam_2d.noise_emitted.disconnect(_noise_emitted_2d)

			if _trigger_pcam_tween:
				_active_pcam_2d.tween_interrupted.emit(pcam)
		else:
			_prev_active_pcam_3d_transform = camera_3d.global_transform
			_active_pcam_3d.set_is_active(self, false)
			_active_pcam_3d.became_inactive.emit()

			if _active_pcam_3d.physics_target_changed.is_connected(_check_pcam_physics):
				_active_pcam_3d.physics_target_changed.disconnect(_check_pcam_physics)

			if _active_pcam_3d.noise_emitted.is_connected(_noise_emitted_3d):
				_active_pcam_3d.noise_emitted.disconnect(_noise_emitted_3d)

			if _trigger_pcam_tween:
				_active_pcam_3d.tween_interrupted.emit(pcam)

			if camera_3d.attributes != null:
				var _attributes: CameraAttributes = camera_3d.attributes

				_prev_cam_exposure_multiplier = _attributes.exposure_multiplier
				_prev_cam_auto_exposure_scale = _attributes.auto_exposure_scale
				_prev_cam_auto_exposure_speed = _attributes.auto_exposure_speed

				if camera_3d.attributes is CameraAttributesPractical:
					_attributes = _attributes as CameraAttributesPractical

					_prev_cam_dof_blur_amount = _attributes.dof_blur_amount

					if _attributes.dof_blur_far_enabled:
						_prev_cam_dof_blur_far_distance = _attributes.dof_blur_far_distance
						_prev_cam_dof_blur_far_transition = _attributes.dof_blur_far_transition
					else:
						_prev_cam_dof_blur_far_distance = _cam_dof_blur_far_distance_default
						_prev_cam_dof_blur_far_transition = _cam_dof_blur_far_transition_default

					if _attributes.dof_blur_near_enabled:
						_prev_cam_dof_blur_near_distance = _attributes.dof_blur_near_distance
						_prev_cam_dof_blur_near_transition = _attributes.dof_blur_near_transition
					else:
						_prev_cam_dof_blur_near_distance = _cam_dof_blur_near_distance_default
						_prev_cam_dof_blur_near_transition = _cam_dof_blur_near_transition_default

					if _attributes.auto_exposure_enabled:
						_prev_cam_exposure_max_sensitivity = _attributes.auto_exposure_max_sensitivity
						_prev_cam_exposure_min_sensitivity = _attributes.auto_exposure_min_sensitivity

				elif camera_3d.attributes is CameraAttributesPhysical:
					_attributes = _attributes as CameraAttributesPhysical

					_prev_cam_frustum_focus_distance = _attributes.frustum_focus_distance
					_prev_cam_frustum_focal_length = _attributes.frustum_focal_length
					_prev_cam_frustum_far = _attributes.frustum_far
					_prev_cam_frustum_near = _attributes.frustum_near
					_prev_cam_exposure_aperture = _attributes.exposure_aperture
					_prev_cam_exposure_shutter_speed = _attributes.exposure_shutter_speed

					if _attributes.auto_exposure_enabled:
						_prev_cam_exposure_min_exposure_value = _attributes.auto_exposure_min_exposure_value
						_prev_cam_exposure_max_exposure_value = _attributes.auto_exposure_max_exposure_value

			_prev_cam_h_offset = camera_3d.h_offset
			_prev_cam_v_offset = camera_3d.v_offset
			_prev_cam_fov = camera_3d.fov
			_prev_cam_size = camera_3d.size
			_prev_cam_frustum_offset = camera_3d.frustum_offset
			_prev_cam_near = camera_3d.near
			_prev_cam_far = camera_3d.far

	else:
		no_previous_pcam = true

	## Assign newly active pcam
	if _is_2D:
		_active_pcam_2d = pcam
		_active_pcam_priority = _active_pcam_2d.priority
		_active_pcam_has_damping = _active_pcam_2d.follow_damping
		_tween_duration = _active_pcam_2d.tween_duration

		if not _active_pcam_2d.physics_target_changed.is_connected(_check_pcam_physics):
			_active_pcam_2d.physics_target_changed.connect(_check_pcam_physics)

		if not _active_pcam_2d.noise_emitted.is_connected(_noise_emitted_2d):
			_active_pcam_2d.noise_emitted.connect(_noise_emitted_2d)
	else:
		_active_pcam_3d = pcam
		_active_pcam_priority = _active_pcam_3d.priority
		_active_pcam_has_damping = _active_pcam_3d.follow_damping
		_tween_duration = _active_pcam_3d.tween_duration

		if not _active_pcam_3d.physics_target_changed.is_connected(_check_pcam_physics):
			_active_pcam_3d.physics_target_changed.connect(_check_pcam_physics)

		if not _active_pcam_3d.noise_emitted.is_connected(_noise_emitted_3d):
			_active_pcam_3d.noise_emitted.connect(_noise_emitted_3d)

		# Checks if the Camera3DResource has changed from the previous active PCam3D
		if _active_pcam_3d.camera_3d_resource:
			if _prev_cam_h_offset != _active_pcam_3d.h_offset:
				_cam_h_offset_changed = true
			if _prev_cam_v_offset != _active_pcam_3d.v_offset:
				_cam_v_offset_changed = true
			if _prev_cam_fov != _active_pcam_3d.fov:
				_cam_fov_changed = true
			if _prev_cam_size != _active_pcam_3d.size:
				_cam_size_changed = true
			if _prev_cam_frustum_offset != _active_pcam_3d.frustum_offset:
				_cam_frustum_offset_changed = true
			if _prev_cam_near != _active_pcam_3d.near:
				_cam_near_changed = true
			if _prev_cam_far != _active_pcam_3d.far:
				_cam_far_changed = true

		if _active_pcam_3d.attributes == null:
			_cam_attribute_changed = false
		else:
			if _prev_cam_attributes != _active_pcam_3d.attributes:
				_prev_cam_attributes = _active_pcam_3d.attributes
				_cam_attribute_changed = true
				var _attributes: CameraAttributes = _active_pcam_3d.attributes

				if _prev_cam_auto_exposure_scale != _attributes.auto_exposure_scale:
					_cam_auto_exposure_scale_changed = true
				if _prev_cam_auto_exposure_speed != _attributes.auto_exposure_speed:
					_cam_auto_exposure_speed_changed = true
				if _prev_cam_exposure_multiplier != _attributes.exposure_multiplier:
					_cam_exposure_multiplier_changed = true
				if _prev_cam_exposure_sensitivity != _attributes.exposure_sensitivity:
					_cam_exposure_sensitivity_changed = true

				if _attributes is CameraAttributesPractical:
					_cam_attribute_type = 0

					if camera_3d.attributes == null:
						camera_3d.attributes = CameraAttributesPractical.new()
						camera_3d.attributes = _active_pcam_3d.attributes.duplicate()
						_cam_attribute_assigned = true

					if _prev_cam_exposure_min_sensitivity != _attributes.auto_exposure_min_sensitivity:
						_cam_exposure_min_sensitivity_changed = true
					if _prev_cam_exposure_max_sensitivity != _attributes.auto_exposure_max_sensitivity:
						_cam_exposure_max_sensitivity_changed = true

					if _prev_cam_dof_blur_amount != _attributes.dof_blur_amount:
						_cam_dof_blur_amount_changed = true

					if _prev_cam_dof_blur_far_distance != _attributes.dof_blur_far_distance:
						_cam_dof_blur_far_distance_changed = true
						camera_3d.attributes.dof_blur_far_enabled = true
					if _prev_cam_dof_blur_far_transition != _attributes.dof_blur_far_transition:
						_cam_dof_blur_far_transition_changed = true
						camera_3d.attributes.dof_blur_far_enabled = true

					if _prev_cam_dof_blur_near_distance != _attributes.dof_blur_near_distance:
						_cam_dof_blur_near_distance_changed = true
						camera_3d.attributes.dof_blur_near_enabled = true
					if _prev_cam_dof_blur_near_transition != _attributes.dof_blur_near_transition:
						_cam_dof_blur_near_transition_changed = true
						camera_3d.attributes.dof_blur_near_enabled = true
				elif _attributes is CameraAttributesPhysical:
					_cam_attribute_type = 1

					if camera_3d.attributes == null:
						camera_3d.attributes = CameraAttributesPhysical.new()
						camera_3d.attributes = _active_pcam_3d.attributes.duplicate()

					if _prev_cam_exposure_min_exposure_value != _attributes.auto_exposure_min_exposure_value:
						_cam_exposure_min_exposure_value_changed = true
					if _prev_cam_exposure_max_exposure_value != _attributes.auto_exposure_max_exposure_value:
						_cam_exposure_max_exposure_value_changed = true

					if _prev_cam_exposure_aperture != _attributes.exposure_aperture:
						_cam_exposure_aperture_changed = true
					if _prev_cam_exposure_shutter_speed != _attributes.exposure_shutter_speed:
						_cam_exposure_shutter_speed_changed = true

					if _prev_cam_frustum_far != _attributes.frustum_far:
						_cam_frustum_far_changed = true

					if _prev_cam_frustum_focal_length != _attributes.frustum_focal_length:
						_cam_frustum_focal_length_changed = true

					if _prev_cam_frustum_focus_distance != _attributes.frustum_focus_distance:
						_cam_frustum_focus_distance_changed = true

					if _prev_cam_frustum_near != _attributes.frustum_near:
						_cam_frustum_near_changed = true

	if _is_2D:
		if _active_pcam_2d.show_viewfinder_in_play:
			_viewfinder_needed_check = true

		_active_pcam_2d.set_is_active(self, true)
		_active_pcam_2d.became_active.emit()
		_camera_zoom = camera_2d.zoom
	else:
		if _active_pcam_3d.show_viewfinder_in_play:
			_viewfinder_needed_check = true

		_active_pcam_3d.set_is_active(self, true)
		_active_pcam_3d.became_active.emit()
		if _active_pcam_3d.camera_3d_resource:
			camera_3d.cull_mask = _active_pcam_3d.cull_mask
			camera_3d.projection = _active_pcam_3d.projection

	if no_previous_pcam:
		if _is_2D:
			_prev_active_pcam_2d_transform = _active_pcam_2d.get_transform_output()
		else:
			_prev_active_pcam_3d_transform = _active_pcam_3d.get_transform_output()

	if pcam.get_tween_skip():
		_tween_elapsed_time = pcam.tween_duration
	else:
		_tween_elapsed_time = 0

	if pcam.tween_duration == 0:
		if Engine.get_version_info().major == 4 and \
		Engine.get_version_info().minor >= 3:
			_tween_is_instant = true

	_check_pcam_physics()

	_trigger_pcam_tween = true


func _check_pcam_physics() -> void:
	if _is_2D:
		## NOTE - Only supported in Godot 4.3 or later
		if Engine.get_version_info().major == 4 and \
		Engine.get_version_info().minor >= 3:
			if _active_pcam_2d.get_follow_target_physics_based():
				_follow_target_physics_based = true
				## TODO - Temporary solution to support Godot 4.2
				## Remove line below and uncomment the following once Godot 4.3 is min verison.
				camera_2d.call("reset_physics_interpolation")
				camera_2d.set("physics_interpolation_mode", 1)
				#camera_2d.reset_physics_interpolation()
				#camera_2d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
				if ProjectSettings.get_setting("physics/common/physics_interpolation"):
					camera_2d.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS # Prevents a warning
				else:
					camera_2d.process_callback = Camera2D.CAMERA2D_PROCESS_IDLE
			else:
				_follow_target_physics_based = false
				## TODO - Temporary solution to support Godot 4.2
				## Remove line below and uncomment the following once Godot 4.3 is min verison.
				camera_2d.set("physics_interpolation_mode", 0)
				#camera_2d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT
				if get_tree().physics_interpolation:
					camera_2d.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS # Prevents a warning
				else:
					camera_2d.process_callback = Camera2D.CAMERA2D_PROCESS_IDLE
	else:
		## NOTE - Only supported in Godot 4.4 or later
		if Engine.get_version_info().major == 4 and \
		Engine.get_version_info().minor >= 4:
			if get_tree().physics_interpolation or _active_pcam_3d.get_follow_target_physics_based():
				#if get_tree().physics_interpolation or _active_pcam_3d.get_follow_target_physics_based():
				_follow_target_physics_based = true
				## TODO - Temporary solution to support Godot 4.2
				## Remove line below and uncomment the following once Godot 4.3 is min verison.
				camera_3d.call("reset_physics_interpolation")
				camera_3d.set("physics_interpolation_mode", 1)
				#camera_3d.reset_physics_interpolation()
				#camera_3d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
			else:
				_follow_target_physics_based = false
				## TODO - Temporary solution to support Godot 4.2
				## Remove line below and uncomment the following once Godot 4.3 is min verison.
				camera_3d.set("physics_interpolation_mode", 0)


func _find_pcam_with_highest_priority() -> void:
	for pcam in _pcam_list:
		if not pcam.visible: continue # Prevents hidden PCams from becoming active
		if pcam.get_priority() > _active_pcam_priority:
			_assign_new_active_pcam(pcam)
		pcam.set_tween_skip(self, false)
		_active_pcam_missing = false


## TODO - For 0.8 release
#func _find_pcam_with_highest_priority() -> void:
	#var highest_priority_pcam: Node
	#for pcam in _pcam_list:
		#if not pcam.visible: continue # Prevents hidden PCams from becoming active
		#if pcam.priority > _active_pcam_priority:
			#_active_pcam_priority = pcam.priority
			#highest_priority_pcam = pcam
		#pcam.set_has_tweened(self, false)
#
		#_active_pcam_missing = false
#
	#if is_instance_valid(highest_priority_pcam):
		#_assign_new_active_pcam(highest_priority_pcam)
	#else:
		#_active_pcam_missing = true


func _process(delta: float) -> void:
	if _active_pcam_missing: return

	if not _follow_target_physics_based: _tween_follow_checker(delta)

	if not _has_noise_emitted: return
	if _is_2D:
		camera_2d.offset += _noise_emitted_output_2d.origin
		camera_2d.rotation += _noise_emitted_output_2d.get_rotation() # + _noise_emitted_output_2d.get_rotation()
	else:
		camera_3d.global_transform *= _noise_emitted_output_3d
	_has_noise_emitted = false


func _physics_process(delta: float) -> void:
	if _active_pcam_missing or not _follow_target_physics_based: return
	_tween_follow_checker(delta)


func _tween_follow_checker(delta: float) -> void:
	if _is_2D:
		_active_pcam_2d.process_logic(delta)
		_active_pcam_2d_glob_transform = _active_pcam_2d.get_transform_output()
	else:
		_active_pcam_3d.process_logic(delta)
		_active_pcam_3d_glob_transform = _active_pcam_3d.get_transform_output()

	if not _trigger_pcam_tween:
		# Rechecks physics target if PCam transitioned with an isntant tween
		if _tween_is_instant:
			_check_pcam_physics()
			_tween_is_instant = false
		_pcam_follow(delta)
	else:
		_pcam_tween(delta)

	if _is_2D:
		camera_2d.offset = Vector2.ZERO
		camera_2d.offset = _active_pcam_2d.get_noise_transform().origin # + _noise_emitted_output_2d.origin
		camera_2d.rotation += _active_pcam_2d.get_noise_transform().get_rotation() # + _noise_emitted_output_2d.get_rotation()
	else:
		camera_3d.global_transform *= _active_pcam_3d.get_noise_transform()


func _pcam_follow(_delta: float) -> void:
	if _is_2D:
		if not is_instance_valid(_active_pcam_2d): return
	else:
		if not is_instance_valid(_active_pcam_3d): return

	if _active_pcam_missing or not _is_child_of_camera: return

	if _is_2D:
		if _active_pcam_2d.snap_to_pixel:
			var snap_to_pixel_glob_transform: Transform2D = _active_pcam_2d_glob_transform
			snap_to_pixel_glob_transform.origin = snap_to_pixel_glob_transform.origin.round()
			camera_2d.global_transform = snap_to_pixel_glob_transform
		else:
			camera_2d.global_transform = _active_pcam_2d_glob_transform
		camera_2d.zoom = _active_pcam_2d.zoom
	else:
		camera_3d.global_transform = _active_pcam_3d_glob_transform

	if _viewfinder_needed_check:
		_show_viewfinder_in_play()
		_viewfinder_needed_check = false

	# TODO - Should be able to find a more efficient way using signals
	if Engine.is_editor_hint():
		if not _is_2D:
			if _active_pcam_3d.camera_3d_resource != null:
				camera_3d.cull_mask = _active_pcam_3d.cull_mask
				camera_3d.h_offset = _active_pcam_3d.h_offset
				camera_3d.v_offset = _active_pcam_3d.v_offset
				camera_3d.projection = _active_pcam_3d.projection
				camera_3d.fov = _active_pcam_3d.fov
				camera_3d.size = _active_pcam_3d.size
				camera_3d.frustum_offset = _active_pcam_3d.frustum_offset
				camera_3d.near = _active_pcam_3d.near
				camera_3d.far = _active_pcam_3d.far

			if _active_pcam_3d.attributes != null:
				camera_3d.attributes = _active_pcam_3d.attributes.duplicate()

			if _active_pcam_3d.environment != null:
				camera_3d.environment = _active_pcam_3d.environment.duplicate()


func _noise_emitted_2d(noise_output: Transform2D) -> void:
	_noise_emitted_output_2d = noise_output
	_has_noise_emitted = true


func _noise_emitted_3d(noise_output: Transform3D) -> void:
	_noise_emitted_output_3d = noise_output
	_has_noise_emitted = true


func _pcam_tween(delta: float) -> void:
	# Run at the first tween frame
	if _tween_elapsed_time == 0:
		if _is_2D:
			_active_pcam_2d.tween_started.emit()
			_active_pcam_2d.reset_limit()
		else:
			_active_pcam_3d.tween_started.emit()

	# Forcefully disables physics interpolation when tweens are instant
	if _tween_is_instant:
		if _is_2D:
			camera_2d.set("physics_interpolation_mode", 2)
		else:
			camera_3d.set("physics_interpolation_mode", 2)

	_tween_elapsed_time = min(_tween_duration, _tween_elapsed_time + delta)

	if _is_2D:
		_active_pcam_2d.is_tweening.emit()
		var interpolation_destination: Vector2 = _tween_interpolate_value(
			_prev_active_pcam_2d_transform.origin,
			_active_pcam_2d_glob_transform.origin,
			_active_pcam_2d.tween_duration,
			_active_pcam_2d.tween_transition,
			_active_pcam_2d.tween_ease
		)

		if _active_pcam_2d.snap_to_pixel:
			camera_2d.global_position = interpolation_destination.round()
		else:
			camera_2d.global_position = interpolation_destination

		camera_2d.rotation = _tween_interpolate_value(
			_prev_active_pcam_2d_transform.get_rotation(),
			_active_pcam_2d_glob_transform.get_rotation(),
			_active_pcam_2d.tween_duration,
			_active_pcam_2d.tween_transition,
			_active_pcam_2d.tween_ease
		)
		camera_2d.zoom = _tween_interpolate_value(
			_camera_zoom,
			_active_pcam_2d.zoom,
			_active_pcam_2d.tween_duration,
			_active_pcam_2d.tween_transition,
			_active_pcam_2d.tween_ease
		)
	else:
		_active_pcam_3d.is_tweening.emit()
		camera_3d.global_position = _tween_interpolate_value(
			_prev_active_pcam_3d_transform.origin,
			_active_pcam_3d_glob_transform.origin,
			_active_pcam_3d.tween_duration,
			_active_pcam_3d.tween_transition,
			_active_pcam_3d.tween_ease
		)

		var prev_active_pcam_3d_quat: Quaternion = Quaternion(_prev_active_pcam_3d_transform.basis.orthonormalized())
		camera_3d.quaternion = \
			Tween.interpolate_value(
				prev_active_pcam_3d_quat, \
				prev_active_pcam_3d_quat.inverse() * Quaternion(_active_pcam_3d_glob_transform.basis.orthonormalized()),
				_tween_elapsed_time, \
				_active_pcam_3d.tween_duration, \
				_active_pcam_3d.tween_transition,
				_active_pcam_3d.tween_ease
			)

		if _cam_attribute_changed:
			if _active_pcam_3d.attributes.auto_exposure_enabled:
				if _cam_auto_exposure_scale_changed:
					camera_3d.attributes.auto_exposure_scale = \
						_tween_interpolate_value(
						_prev_cam_auto_exposure_scale,
						_active_pcam_3d.attributes.auto_exposure_scale,
						_active_pcam_3d.tween_duration,
						_active_pcam_3d.tween_transition,
						_active_pcam_3d.tween_ease
					)
				if _cam_auto_exposure_speed_changed:
					camera_3d.attributes.auto_exposure_speed = \
						_tween_interpolate_value(
						_prev_cam_auto_exposure_scale,
						_active_pcam_3d.attributes.auto_exposure_scale,
						_active_pcam_3d.tween_duration,
						_active_pcam_3d.tween_transition,
						_active_pcam_3d.tween_ease
					)

			if _cam_attribute_type == 0: # CameraAttributePractical
				if _active_pcam_3d.attributes.auto_exposure_enabled:
					if _cam_exposure_min_sensitivity_changed:
						camera_3d.attributes.auto_exposure_min_sensitivity = \
							_tween_interpolate_value(
							_prev_cam_exposure_min_sensitivity,
							_active_pcam_3d.attributes.auto_exposure_min_sensitivity,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
					if _cam_exposure_max_sensitivity_changed:
						camera_3d.attributes.auto_exposure_max_sensitivity = \
							_tween_interpolate_value(
							_prev_cam_exposure_max_sensitivity,
							_active_pcam_3d.attributes.auto_exposure_max_sensitivity,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_dof_blur_amount_changed:
					camera_3d.attributes.dof_blur_amount = \
						_tween_interpolate_value(
							_prev_cam_dof_blur_amount,
							_active_pcam_3d.attributes.dof_blur_amount,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_dof_blur_far_distance_changed:
					camera_3d.attributes.dof_blur_far_distance = \
						_tween_interpolate_value(
							_prev_cam_dof_blur_far_distance,
							_active_pcam_3d.attributes.dof_blur_far_distance,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_dof_blur_far_transition_changed:
					camera_3d.attributes.dof_blur_far_transition = \
						_tween_interpolate_value(
							_prev_cam_dof_blur_far_transition,
							_active_pcam_3d.attributes.dof_blur_far_transition,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_dof_blur_near_distance_changed:
					camera_3d.attributes.dof_blur_near_distance = \
						_tween_interpolate_value(
							_prev_cam_dof_blur_near_distance,
							_active_pcam_3d.attributes.dof_blur_near_distance,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_dof_blur_near_transition_changed:
					camera_3d.attributes.dof_blur_near_transition = \
						_tween_interpolate_value(
							_prev_cam_dof_blur_near_transition,
							_active_pcam_3d.attributes.dof_blur_near_transition,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
			elif _cam_attribute_type == 1: # CameraAttributePhysical
				if _cam_dof_blur_near_transition_changed:
					camera_3d.attributes.auto_exposure_max_exposure_value = \
						_tween_interpolate_value(
							_prev_cam_exposure_max_exposure_value,
							_active_pcam_3d.attributes.auto_exposure_max_exposure_value,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_exposure_min_exposure_value_changed:
					camera_3d.attributes.auto_exposure_min_exposure_value = \
						_tween_interpolate_value(
							_prev_cam_exposure_min_exposure_value,
							_active_pcam_3d.attributes.auto_exposure_min_exposure_value,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_exposure_aperture_changed:
					camera_3d.attributes.exposure_aperture = \
						_tween_interpolate_value(
							_prev_cam_exposure_aperture,
							_active_pcam_3d.attributes.exposure_aperture,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_exposure_shutter_speed_changed:
					camera_3d.attributes.exposure_shutter_speed = \
						_tween_interpolate_value(
							_prev_cam_exposure_shutter_speed,
							_active_pcam_3d.attributes.exposure_shutter_speed,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_frustum_far_changed:
					camera_3d.attributes.frustum_far = \
						_tween_interpolate_value(
							_prev_cam_frustum_far,
							_active_pcam_3d.attributes.frustum_far,
							_active_pcam_3d.tween_duration(),
							_active_pcam_3d.tween_transition(),
							_active_pcam_3d.tween_ease
						)
				if _cam_frustum_near_changed:
					camera_3d.attributes.frustum_near = \
						_tween_interpolate_value(
							_prev_cam_frustum_far,
							_active_pcam_3d.attributes.frustum_near,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_frustum_focal_length_changed:
					camera_3d.attributes.frustum_focal_length = \
						_tween_interpolate_value(
							_prev_cam_frustum_focal_length,
							_active_pcam_3d.attributes.frustum_focal_length,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)
				if _cam_frustum_focus_distance_changed:
					camera_3d.attributes.frustum_focus_distance = \
						_tween_interpolate_value(
							_prev_cam_frustum_focus_distance,
							_active_pcam_3d.attributes.frustum_focus_distance,
							_active_pcam_3d.tween_duration,
							_active_pcam_3d.tween_transition,
							_active_pcam_3d.tween_ease
						)

		if _cam_h_offset_changed:
			camera_3d.h_offset = \
				_tween_interpolate_value(
					_prev_cam_h_offset,
					_active_pcam_3d.h_offset,
					_active_pcam_3d.tween_duration,
					_active_pcam_3d.tween_transition,
					_active_pcam_3d.tween_ease
				)

		if _cam_v_offset_changed:
			camera_3d.v_offset = \
				_tween_interpolate_value(
					_prev_cam_v_offset,
					_active_pcam_3d.v_offset,
					_active_pcam_3d.tween_duration,
					_active_pcam_3d.tween_transition,
					_active_pcam_3d.tween_ease
				)

		if _cam_fov_changed:
			camera_3d.fov = \
				_tween_interpolate_value(
					_prev_cam_fov,
					_active_pcam_3d.fov,
					_active_pcam_3d.tween_duration,
					_active_pcam_3d.tween_transition,
					_active_pcam_3d.tween_ease
				)

		if _cam_size_changed:
			camera_3d.size = \
				_tween_interpolate_value(
					_prev_cam_size,
					_active_pcam_3d.size,
					_active_pcam_3d.tween_duration,
					_active_pcam_3d.tween_transition,
					_active_pcam_3d.tween_ease
				)

		if _cam_frustum_offset_changed:
			camera_3d.frustum_offset = \
				_tween_interpolate_value(
					_prev_cam_frustum_offset,
					_active_pcam_3d.frustum_offset,
					_active_pcam_3d.tween_duration,
					_active_pcam_3d.tween_transition,
					_active_pcam_3d.tween_ease
				)


		if _cam_near_changed:
			camera_3d.near = \
				_tween_interpolate_value(
					_prev_cam_near,
					_active_pcam_3d.near,
					_active_pcam_3d.tween_duration,
					_active_pcam_3d.tween_transition,
					_active_pcam_3d.tween_ease
				)

		if _cam_far_changed:
			camera_3d.far = \
				_tween_interpolate_value(
					_prev_cam_far,
					_active_pcam_3d.far,
					_active_pcam_3d.tween_duration,
					_active_pcam_3d.tween_transition,
					_active_pcam_3d.tween_ease
				)

	if _tween_elapsed_time < _tween_duration: return
	_trigger_pcam_tween = false
	_tween_elapsed_time = 0
	if _is_2D:
		_active_pcam_2d.update_limit_all_sides()
		_active_pcam_2d.tween_completed.emit()
		if Engine.is_editor_hint():
			_active_pcam_2d.queue_redraw()
	else:
		if _active_pcam_3d.attributes != null:
			if _cam_attribute_type == 0:
				if not _active_pcam_3d.attributes.dof_blur_far_enabled:
					camera_3d.attributes.dof_blur_far_enabled = false
				if not _active_pcam_3d.attributes.dof_blur_near_enabled:
					camera_3d.attributes.dof_blur_near_enabled = false
		_cam_h_offset_changed = false
		_cam_v_offset_changed = false
		_cam_fov_changed = false
		_cam_size_changed = false
		_cam_frustum_offset_changed = false
		_cam_near_changed = false
		_cam_far_changed = false
		_cam_attribute_changed = false

		_active_pcam_3d.tween_completed.emit()


func _tween_interpolate_value(from: Variant, to: Variant, duration: float, transition_type: int, ease_type: int) -> Variant:
	return Tween.interpolate_value(
		from, \
		to - from,
		_tween_elapsed_time, \
		duration, \
		transition_type,
		ease_type,
	)

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

#endregion

#region Public Functions

## Called when a [param PhantomCamera] is added to the scene.[br]
## [b]Note:[/b] This can only be called internally from a
## [param PhantomCamera] node.
func pcam_added_to_scene(pcam) -> void:
	if is_instance_of(pcam, PhantomCamera2D) or pcam.is_class("PhantomCamera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		if not _pcam_list.has(pcam):
			_pcam_list.append(pcam)
			if not pcam.tween_on_load:
				pcam.set_tween_skip(self, true) # Skips its tween if it has the highest priority on load
			if not pcam.is_node_ready(): await pcam.ready
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

	var current_pcam_priority: int = pcam.priority

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


## Refreshes the [param PhantomCamera] list and checks for the highest priority. [br]
## [b]Note:[/b] This should [b]not[/b] be necessary to call manually.
func refresh_pcam_list_priorty() -> void:
	_active_pcam_priority = -1
	_find_pcam_with_highest_priority()


#func set_interpolation_mode(value: int) -> void:
	#interpolation_mode = value
#func get_interpolation_mode() -> int:
	#return interpolation_mode

#endregion
