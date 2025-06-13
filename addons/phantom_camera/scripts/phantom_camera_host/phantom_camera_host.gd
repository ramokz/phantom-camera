@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_host.svg")
class_name PhantomCameraHost
extends Node

## Controls a scene's [Camera2D] (2D scenes) and [Camera3D] (3D scenes).
##
## All instantiated [param PhantomCameras] in a scene are assigned to a specific layer, where a
## PhantomCameraHost will react to those that corresponds. It is what determines which [param PhantomCamera] should
## be active.

#region Constants

const _constants := preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#endregion


#region Signals

## Updates the viewfinder [param dead zones] sizes.[br]
## [b]Note:[/b] This is only being used in the editor viewfinder UI.
#signal update_editor_viewfinder
signal viewfinder_update(check_framed_view: bool)
signal viewfinder_disable_dead_zone

## Used internally to check if the [param PhantomCameraHost] is valid.
## The result will be visible in the viewfinder when multiple instances are present.
signal has_error()

## Emitted when a new [param PhantomCamera] becomes active and assigned to this [param PhantomCameraHost].
signal pcam_became_active(pcam: Node)

## Emitted when the currently active [param PhantomCamera] goes from being active to inactive.
signal pcam_became_inactive(pcam: Node)

#endregion


#region Enums

## Dictates whether if [param PhantomCameraHost]'s logic should be called in the physics or idle (process) frames.
enum InterpolationMode {
	AUTO    = 0, ## Automatically sets the [param Camera]'s logic to run in either physics or idle (process) frames depending on its active [param PhantomCamera]'s [param Follow] / [param Look At] Target
	IDLE    = 1, ## Always run the [param Camera] logic in idle (process) frames
	PHYSICS = 2, ## Always run the [param Camera] logic in physics frames
}

#endregion


#region Public Variables

## Determines which [PhantomCamera2D] / [PhantomCamera3D] nodes this [param PhantomCameraHost] should recognise.
## At least one corresponding layer needs to be set on the [param PhantomCamera] for the [param PhantomCameraHost] node to work.
@export_flags_2d_render var host_layers: int = 1:
	set = set_host_layers,
	get = get_host_layers

## Determines whether the [PhantomCamera2D] / [PhantomCamera3D] nodes this [param PhantomCameraHost] controls should use physics interpolation or not.
@export var interpolation_mode: InterpolationMode = InterpolationMode.AUTO:
	set = set_interpolation_mode,
	get = get_interpolation_mode

#endregion


#region Private Variables

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
var _is_2d: bool = false

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
var _reset_noise_offset_2d: bool = false
var _noise_emitted_output_2d: Transform2D = Transform2D()
var _noise_emitted_output_3d: Transform3D = Transform3D()

#endregion

# NOTE - Temp solution until Godot has better plugin autoload recognition out-of-the-box.
var _phantom_camera_manager: Node = null

#region Public Variables

var show_warning: bool = false

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
	var first_pcam_host_child: PhantomCameraHost

	if _is_2d:
		if not parent is Camera2D:
			show_warning = true
			has_error.emit()
			return["Needs to be a child of a Camera2D in order to work."]
	else:
		if not parent.is_class("Camera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
			show_warning = true
			has_error.emit()
			return["Needs to be a child of a Camera3D in order to work."]

	for child in parent.get_children():
		if not child is PhantomCameraHost: continue
		if not is_instance_valid(first_pcam_host_child):
			first_pcam_host_child = child
			continue
		elif not first_pcam_host_child == self:
			show_warning = true
			has_error.emit()
			return["Only the first PhantomCameraHost child will be used."]
		child.update_configuration_warnings()

	show_warning = false
	has_error.emit()
	return[]


func _enter_tree() -> void:
	var parent: Node = get_parent()
	if parent is Camera2D or parent.is_class("Camera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		_phantom_camera_manager = get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME)
		_phantom_camera_manager.pcam_host_added(self)

		_is_child_of_camera = true
		if parent is Camera2D:
			_is_2d = true
			camera_2d = parent
			## Force applies position smoothing to be disabled
			## This is to prevent overlap with the interpolation of the PCam2D.
			camera_2d.set_position_smoothing_enabled(false)
		else:
			_is_2d = false
			camera_3d = parent

		if _is_2d:
			if not _phantom_camera_manager.get_phantom_camera_2ds().is_empty():
				for pcam in _phantom_camera_manager.get_phantom_camera_2ds():
					_pcam_added_to_scene(pcam)

			if not _phantom_camera_manager.limit_2d_changed.is_connected(_update_limit_2d):
				_phantom_camera_manager.limit_2d_changed.connect(_update_limit_2d)
			if not _phantom_camera_manager.draw_limit_2d.is_connected(_draw_limit_2d):
				_phantom_camera_manager.draw_limit_2d.connect(_draw_limit_2d)

		else:
			if not _phantom_camera_manager.get_phantom_camera_3ds().is_empty():
				for pcam in _phantom_camera_manager.get_phantom_camera_3ds():
					_pcam_added_to_scene(pcam)


func _exit_tree() -> void:
	if is_instance_valid(_phantom_camera_manager):
		_phantom_camera_manager.pcam_host_removed(self)


func _ready() -> void:
	# Waits for the first process tick to finish before initializing any logic
	# This should help with avoiding ocassional erratic camera movement upon running a scene
	await get_tree().process_frame

	process_priority = 300
	process_physics_priority = 300

	# PCam Host Signals
	if Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME):
		_phantom_camera_manager = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME)
		_phantom_camera_manager.pcam_host_layer_changed.connect(_pcam_host_layer_changed)

		# PCam Signals
		_phantom_camera_manager.pcam_added_to_scene.connect(_pcam_added_to_scene)
		_phantom_camera_manager.pcam_removed_from_scene.connect(_pcam_removed_from_scene)

		_phantom_camera_manager.pcam_priority_changed.connect(pcam_priority_updated)
		_phantom_camera_manager.pcam_priority_override.connect(_pcam_priority_override)

		_phantom_camera_manager.pcam_visibility_changed.connect(_pcam_visibility_changed)

		_phantom_camera_manager.pcam_teleport.connect(_pcam_teleported)

		if _is_2d:
			if not _phantom_camera_manager.limit_2d_changed.is_connected(_update_limit_2d):
				_phantom_camera_manager.limit_2d_changed.connect(_update_limit_2d)
			if not _phantom_camera_manager.draw_limit_2d.is_connected(_draw_limit_2d):
				_phantom_camera_manager.draw_limit_2d.connect(_draw_limit_2d)
	else:
		printerr("Could not find Phantom Camera Manager singleton")
		printerr("Make sure the addon is enable or that the singleton hasn't been disabled inside Project Settings / Globals")

	_find_pcam_with_highest_priority()

	if _is_2d:
		camera_2d.offset = Vector2.ZERO
		if not is_instance_valid(_active_pcam_2d): return
		_active_pcam_2d_glob_transform = _active_pcam_2d.get_transform_output()
	else:
		if not is_instance_valid(_active_pcam_3d): return
		_active_pcam_3d_glob_transform = _active_pcam_3d.get_transform_output()


func _pcam_host_layer_changed(pcam: Node) -> void:
	if _pcam_is_in_host_layer(pcam):
		_check_pcam_priority(pcam)
	else:
		if _is_2d:
			if _active_pcam_2d == pcam:
				_active_pcam_missing = true
				_active_pcam_2d = null
				_active_pcam_priority = -1
				pcam.set_is_active(self, false)
		else:
			if _active_pcam_3d == pcam:
				_active_pcam_missing = true
				_active_pcam_3d = null
				_active_pcam_priority = -1
				pcam.set_is_active(self, false)
		_find_pcam_with_highest_priority()


func _pcam_is_in_host_layer(pcam: Node) -> bool:
	if pcam.host_layers & host_layers != 0: return true
	return false


func _find_pcam_with_highest_priority() -> void:
	var pcam_list: Array
	if _is_2d:
		pcam_list = _phantom_camera_manager.phantom_camera_2ds
	else:
		pcam_list = _phantom_camera_manager.phantom_camera_3ds

	for pcam in pcam_list:
		_check_pcam_priority(pcam)


func _check_pcam_priority(pcam: Node) -> void:
	if not _pcam_is_in_host_layer(pcam): return
	if not pcam.visible: return # Prevents hidden PCams from becoming active
	if pcam.get_priority() > _active_pcam_priority:
		_assign_new_active_pcam(pcam)
		_active_pcam_missing = false
	else:
		pcam.set_tween_skip(self, false)


func _assign_new_active_pcam(pcam: Node) -> void:
	# Only checks if the scene tree is still present.
	# Prevents a few errors and checks from happening if the scene is exited.
	if not is_inside_tree(): return
	var no_previous_pcam: bool
	if is_instance_valid(_active_pcam_2d) or is_instance_valid(_active_pcam_3d):
		if OS.has_feature("debug"):
			viewfinder_disable_dead_zone.emit()

		if _is_2d:
			_prev_active_pcam_2d_transform = camera_2d.global_transform
			_active_pcam_2d.queue_redraw()
			_active_pcam_2d.set_is_active(self, false)
			_active_pcam_2d.became_inactive.emit()
			pcam_became_inactive.emit(_active_pcam_2d)

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
			pcam_became_inactive.emit(_active_pcam_3d)

			if _active_pcam_3d.physics_target_changed.is_connected(_check_pcam_physics):
				_active_pcam_3d.physics_target_changed.disconnect(_check_pcam_physics)

			if _active_pcam_3d.noise_emitted.is_connected(_noise_emitted_3d):
				_active_pcam_3d.noise_emitted.disconnect(_noise_emitted_3d)

			if _active_pcam_3d.camera_3d_resource_changed.is_connected(_camera_3d_resource_changed):
				_active_pcam_3d.camera_3d_resource_changed.disconnect(_camera_3d_resource_changed)

			if _active_pcam_3d.camera_3d_resource_property_changed.is_connected(_camera_3d_resource_property_changed):
				_active_pcam_3d.camera_3d_resource_property_changed.disconnect(_camera_3d_resource_property_changed)

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
	if _is_2d:
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

		if not Engine.is_editor_hint():
			# Assigns a default shape to SpringArm3D node is none is supplied
			if _active_pcam_3d.follow_mode == _active_pcam_3d.FollowMode.THIRD_PERSON:
				if not _active_pcam_3d.shape:

					var pyramid_shape_data = Engine.get_singleton("PhysicsServer3D").call("shape_get_data",
						camera_3d.get_pyramid_shape_rid()
					)
					var shape = ClassDB.instantiate("ConvexPolygonShape3D")
					shape.points = pyramid_shape_data
					_active_pcam_3d.shape = shape

		if not _active_pcam_3d.physics_target_changed.is_connected(_check_pcam_physics):
			_active_pcam_3d.physics_target_changed.connect(_check_pcam_physics)

		if not _active_pcam_3d.noise_emitted.is_connected(_noise_emitted_3d):
			_active_pcam_3d.noise_emitted.connect(_noise_emitted_3d)

		if not _active_pcam_3d.camera_3d_resource_changed.is_connected(_camera_3d_resource_changed):
			_active_pcam_3d.camera_3d_resource_changed.connect(_camera_3d_resource_changed)

		if not _active_pcam_3d.camera_3d_resource_property_changed.is_connected(_camera_3d_resource_property_changed):
			_active_pcam_3d.camera_3d_resource_property_changed.connect(_camera_3d_resource_property_changed)

		# Checks if the Camera3DResource has changed from the previous active PCam3D
		if _active_pcam_3d.camera_3d_resource:
			# Signal to detect if the Camera3D properties are being changed in the inspector
			# This is to prevent accidential misalignment between the Camera3D and Camera3DResource
			if Engine.is_editor_hint():
				if not Engine.get_singleton(&"EditorInterface").get_inspector().property_edited.is_connected(_camera_3d_edited):
					Engine.get_singleton(&"EditorInterface").get_inspector().property_edited.connect(_camera_3d_edited)
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
		else:
			_cam_h_offset_changed = false
			_cam_v_offset_changed = false
			_cam_fov_changed = false
			_cam_size_changed = false
			_cam_frustum_offset_changed = false
			_cam_near_changed = false
			_cam_far_changed = false
			_cam_attribute_changed = false
			if Engine.is_editor_hint():
				if Engine.get_singleton(&"EditorInterface").get_inspector().property_edited.is_connected(_camera_3d_edited):
					Engine.get_singleton(&"EditorInterface").get_inspector().property_edited.disconnect(_camera_3d_edited)

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

	if OS.has_feature("debug"):
		viewfinder_update.emit(false)

	if _is_2d:
		if _active_pcam_2d.show_viewfinder_in_play:
			_viewfinder_needed_check = true

		_active_pcam_2d.set_is_active(self, true)
		_active_pcam_2d.became_active.emit()
		pcam_became_active.emit(_active_pcam_2d)
		_camera_zoom = camera_2d.zoom
	else:
		if _active_pcam_3d.show_viewfinder_in_play:
			_viewfinder_needed_check = true

		_active_pcam_3d.set_is_active(self, true)
		_active_pcam_3d.became_active.emit()
		pcam_became_active.emit(_active_pcam_3d)
		if _active_pcam_3d.camera_3d_resource:
			camera_3d.keep_aspect = _active_pcam_3d.keep_aspect
			camera_3d.cull_mask = _active_pcam_3d.cull_mask
			camera_3d.projection = _active_pcam_3d.projection

	if no_previous_pcam:
		if _is_2d:
			_prev_active_pcam_2d_transform = _active_pcam_2d.get_transform_output()
		else:
			_prev_active_pcam_3d_transform = _active_pcam_3d.get_transform_output()

	if pcam.get_tween_skip() or pcam.tween_duration == 0:
		_tween_elapsed_time = pcam.tween_duration
		if Engine.get_version_info().major == 4 and \
		Engine.get_version_info().minor >= 3:
			_tween_is_instant = true
	else:
		_tween_elapsed_time = 0

	_check_pcam_physics()

	_trigger_pcam_tween = true


func _check_pcam_physics() -> void:
	if _is_2d:
		if _active_pcam_2d.get_follow_target_physics_based() and interpolation_mode != InterpolationMode.IDLE:
			_follow_target_physics_based = true
			camera_2d.reset_physics_interpolation()
			camera_2d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
			if ProjectSettings.get_setting("physics/common/physics_interpolation"):
				camera_2d.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS # Prevents a warning
			else:
				camera_2d.process_callback = Camera2D.CAMERA2D_PROCESS_IDLE
		else:
			_follow_target_physics_based = false
			camera_2d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT
			if get_tree().physics_interpolation:
				camera_2d.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS # Prevents a warning
			else:
				camera_2d.process_callback = Camera2D.CAMERA2D_PROCESS_IDLE
	else:
		## NOTE - Only supported in Godot 4.4 or later
		if Engine.get_version_info().major == 4 and \
		Engine.get_version_info().minor >= 4:
			if (get_tree().physics_interpolation or _active_pcam_3d.get_follow_target_physics_based()) and interpolation_mode != InterpolationMode.IDLE:
				#if get_tree().physics_interpolation or _active_pcam_3d.get_follow_target_physics_based():
				_follow_target_physics_based = true
				camera_3d.reset_physics_interpolation()
				camera_3d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
			else:
				_follow_target_physics_based = false
				camera_3d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT


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


func _physics_process(delta: float) -> void:
	if _active_pcam_missing or not _follow_target_physics_based: return
	_tween_follow_checker(delta)


func _tween_follow_checker(delta: float) -> void:
	if _is_2d:
		if not is_instance_valid(_active_pcam_2d):
			_active_pcam_missing = true
			return

		_active_pcam_2d.process_logic(delta)
		_active_pcam_2d_glob_transform = _active_pcam_2d.get_transform_output()

		if _reset_noise_offset_2d:
			camera_2d.offset = Vector2.ZERO # Resets noise position
			_reset_noise_offset_2d = false
	else:
		if not is_instance_valid(_active_pcam_3d):
			_active_pcam_missing = true
			return

		_active_pcam_3d.process_logic(delta)
		_active_pcam_3d_glob_transform = _active_pcam_3d.get_transform_output()

	if not _trigger_pcam_tween:
		# Rechecks physics target if PCam transitioned with an instant tween
		if _tween_is_instant:
			_check_pcam_physics()
			_tween_is_instant = false
		_pcam_follow(delta)
	else:
		_pcam_tween(delta)

	# Camera Noise
	if _is_2d:
		if not _has_noise_emitted and not _active_pcam_2d.has_noise_resource(): return
		camera_2d.offset += _active_pcam_2d.get_noise_transform().origin + _noise_emitted_output_2d.origin
		if camera_2d.ignore_rotation and _noise_emitted_output_2d.get_rotation() != 0:
			push_warning(camera_2d.name, " has ignore_rotation enabled. Uncheck the property if you want to apply rotational noise.")
		else:
			camera_2d.rotation += _active_pcam_2d.get_noise_transform().get_rotation() + _noise_emitted_output_2d.get_rotation()
		_has_noise_emitted = false
		_reset_noise_offset_2d = true
	else:
		if not _has_noise_emitted and not _active_pcam_3d.has_noise_resource(): return
		camera_3d.global_transform *= _active_pcam_3d.get_noise_transform() * _noise_emitted_output_3d
		_has_noise_emitted = false


func _pcam_follow(_delta: float) -> void:
	if _active_pcam_missing or not _is_child_of_camera: return

	if _is_2d:
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

	if Engine.is_editor_hint():
		if not _is_2d:
			# TODO - Signal-based solution pending merge of: https://github.com/godotengine/godot/pull/99729
			if _active_pcam_3d.attributes != null:
				camera_3d.attributes = _active_pcam_3d.attributes.duplicate()

			# TODO - Signal-based solution pending merge of: https://github.com/godotengine/godot/pull/99873
			if _active_pcam_3d.environment != null:
				camera_3d.environment = _active_pcam_3d.environment.duplicate()


func _noise_emitted_2d(noise_output: Transform2D) -> void:
	_noise_emitted_output_2d = noise_output
	_has_noise_emitted = true


func _noise_emitted_3d(noise_output: Transform3D) -> void:
	_noise_emitted_output_3d = noise_output
	_has_noise_emitted = true


func _camera_3d_resource_changed() -> void:
	if _active_pcam_3d.camera_3d_resource:
		if Engine.is_editor_hint():
			if not Engine.get_singleton(&"EditorInterface").get_inspector().property_edited.is_connected(_camera_3d_edited):
				Engine.get_singleton(&"EditorInterface").get_inspector().property_edited.connect(_camera_3d_edited)
		camera_3d.keep_aspect = _active_pcam_3d.keep_aspect
		camera_3d.cull_mask = _active_pcam_3d.cull_mask
		camera_3d.h_offset = _active_pcam_3d.h_offset
		camera_3d.v_offset = _active_pcam_3d.v_offset
		camera_3d.projection = _active_pcam_3d.projection
		camera_3d.fov = _active_pcam_3d.fov
		camera_3d.size = _active_pcam_3d.size
		camera_3d.frustum_offset = _active_pcam_3d.frustum_offset
		camera_3d.near = _active_pcam_3d.near
		camera_3d.far = _active_pcam_3d.far
	else:
		if Engine.is_editor_hint():
			if Engine.get_singleton(&"EditorInterface").get_inspector().property_edited.is_connected(_camera_3d_edited):
				Engine.get_singleton(&"EditorInterface").get_inspector().property_edited.disconnect(_camera_3d_edited)

func _camera_3d_edited(value: String) -> void:
	if not Engine.get_singleton(&"EditorInterface").get_inspector().get_edited_object() == camera_3d: return
	camera_3d.set(value, _active_pcam_3d.camera_3d_resource.get(value))
	push_warning("Camera3D properties are being overridden by ", _active_pcam_3d.name, "'s Camera3DResource")

func _camera_3d_resource_property_changed(property: StringName, value: Variant) -> void:
	camera_3d.set(property, value)


func _pcam_tween(delta: float) -> void:
	# TODO - Should be optimised
	# Run at the first tween frame
	if _tween_elapsed_time == 0:
		if _is_2d:
			_active_pcam_2d.tween_started.emit()
			_active_pcam_2d.reset_limit()
		else:
			_active_pcam_3d.tween_started.emit()

	_tween_elapsed_time = min(_tween_duration, _tween_elapsed_time + delta)

	if _is_2d:
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

	# Forcefully disables physics interpolation when tweens are instant
	if _tween_is_instant:
			if _is_2d:
				camera_2d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
				camera_2d.reset_physics_interpolation()
			else:
				if Engine.get_version_info().major == 4 and \
				Engine.get_version_info().minor >= 4:
					camera_3d.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
					camera_3d.reset_physics_interpolation()

	if _tween_elapsed_time < _tween_duration: return

	_trigger_pcam_tween = false
	_tween_elapsed_time = 0
	viewfinder_update.emit(true)

	if _is_2d:
		_active_pcam_2d.update_limit_all_sides()
		_active_pcam_2d.tween_completed.emit()
		_active_pcam_2d.set_tween_skip(self, false)
		if Engine.is_editor_hint():
			_active_pcam_2d.queue_redraw()
	else:
		if _active_pcam_3d.camera_3d_resource and _active_pcam_3d.attributes != null:
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

		_active_pcam_3d.set_tween_skip(self, false)
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

	# Default the viewfinder node to be hidden
	if is_instance_valid(_viewfinder_node):
		_viewfinder_node.visible = false

	if _is_2d:
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


func _update_limit_2d(side: int, limit: int) -> void:
	if is_instance_valid(camera_2d):
		camera_2d.set_limit(side, limit)

func _draw_limit_2d(enabled: bool) -> void:
	camera_2d.set_limit_drawing_enabled(enabled)


## Called when a [param PhantomCamera] is added to the scene.[br]
## [b]Note:[/b] This can only be called internally from a [param PhantomCamera] node.
func _pcam_added_to_scene(pcam: Node) -> void:
	if not pcam.is_node_ready(): await pcam.ready
	_check_pcam_priority(pcam)


## Called when a [param PhantomCamera] is removed from the scene.[br]
## [b]Note:[/b] This can only be called internally from a
## [param PhantomCamera] node.
func _pcam_removed_from_scene(pcam: Node) -> void:
	if _is_2d:
		if pcam == _active_pcam_2d:
			_active_pcam_2d = null
			_active_pcam_missing = true
			_active_pcam_priority = -1
			_find_pcam_with_highest_priority()
	else:
		if pcam == _active_pcam_3d:
			_active_pcam_3d = null
			_active_pcam_missing = true
			_active_pcam_priority = -1
			_find_pcam_with_highest_priority()


func _pcam_visibility_changed(pcam: Node) -> void:
	if pcam == _active_pcam_2d or pcam == _active_pcam_3d:
		_active_pcam_priority = -1
		_find_pcam_with_highest_priority()
		return
	_check_pcam_priority(pcam)


func _pcam_teleported(pcam: Node) -> void:
	if _is_2d:
		if not pcam == _active_pcam_2d: return
		if not is_instance_valid(camera_2d): return
		camera_2d.global_position = _active_pcam_2d.get_transform_output().origin
		camera_2d.reset_physics_interpolation()
	else:
		if not pcam == _active_pcam_3d: return
		if not is_instance_valid(camera_3d): return
		camera_3d.global_position = _active_pcam_3d.get_transform_output().origin
		camera_3d.reset_physics_interpolation()


func _set_layer(current_layers: int, layer_number: int, value: bool) -> int:
	var mask: int = current_layers

	# From https://github.com/godotengine/godot/blob/51991e20143a39e9ef0107163eaf283ca0a761ea/scene/3d/camera_3d.cpp#L638
	if layer_number < 1 or layer_number > 20:
		printerr("Render layer must be between 1 and 20.")
	else:
		if value:
			mask |= 1 << (layer_number - 1)
		else:
			mask &= ~(1 << (layer_number - 1))

	return mask

#endregion

#region Public Functions

## Triggers a recalculation to determine which PhantomCamera has the highest priority.
func pcam_priority_updated(pcam: Node) -> void:
	if not is_instance_valid(pcam): return
	if not _pcam_is_in_host_layer(pcam): return

	if pcam == _active_pcam_2d or pcam == _active_pcam_3d:
		if not pcam.visible:
			refresh_pcam_list_priorty()

	if Engine.is_editor_hint():
		if _is_2d:
			if not is_instance_valid(_active_pcam_2d): return
			if _active_pcam_2d.priority_override: return
		else:
			if not is_instance_valid(_active_pcam_3d): return
			if _active_pcam_3d.priority_override: return

	var current_pcam_priority: int = pcam.priority

	if current_pcam_priority >= _active_pcam_priority:
		if _is_2d:
			if pcam != _active_pcam_2d:
				_assign_new_active_pcam(pcam)
		else:
			if pcam != _active_pcam_3d:
				_assign_new_active_pcam(pcam)
		pcam.set_tween_skip(self, false)
		_active_pcam_missing = false

	if pcam == _active_pcam_2d or pcam == _active_pcam_3d:
		if current_pcam_priority <= _active_pcam_priority:
			_active_pcam_priority = current_pcam_priority
			_find_pcam_with_highest_priority()
		else:
			_active_pcam_priority = current_pcam_priority


## Updates the viewfinder when a [param PhantomCamera] has its
## [param priority_ovrride] enabled.[br]
## [b]Note:[/b] This only affects the editor.
func _pcam_priority_override(pcam: Node, should_override: bool) -> void:
	if not Engine.is_editor_hint(): return
	if not _pcam_is_in_host_layer(pcam): return
	if should_override:
		if _is_2d:
			if is_instance_valid(_active_pcam_2d):
				if _active_pcam_2d.priority_override:
					_active_pcam_2d.priority_override = false
		else:
			if is_instance_valid(_active_pcam_3d):
				if _active_pcam_3d.priority_override:
					_active_pcam_3d.priority_override = false
		_assign_new_active_pcam(pcam)
	else:
		_find_pcam_with_highest_priority()

	viewfinder_update.emit(false)


## Updates the viewfinder when a [param PhantomCamera] has its
## [param priority_ovrride] disabled.[br]
## [b]Note:[/b] This only affects the editor.
func pcam_priority_override_disabled() -> void:
	viewfinder_update.emit(false)


## Returns the currently active [param PhantomCamera]
func get_active_pcam() -> Node:
	if _is_2d:
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

#endregion

#region Setters / Getters

func set_interpolation_mode(value: int) -> void:
	interpolation_mode = value
	if is_inside_tree():
		_check_pcam_physics()
func get_interpolation_mode() -> int:
	return interpolation_mode

## Sets the [member host_layers] value.
func set_host_layers(value: int) -> void:
	host_layers = value

	if not _is_child_of_camera: return

	if not _active_pcam_missing:
		if _is_2d:
			_pcam_host_layer_changed(_active_pcam_2d)
		else:
			_pcam_host_layer_changed(_active_pcam_3d)
	else:
		_find_pcam_with_highest_priority()

## Enables or disables a given layer of [member host_layers].
func set_host_layers_value(layer: int, value: bool) -> void:
	host_layers = _set_layer(host_layers, layer, value)

## Returns the [member host_layers] value.
func get_host_layers() -> int:
	return host_layers

#endregion
