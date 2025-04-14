@tool
extends Node

const _CONSTANTS = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#region Signals

# Noise
signal noise_2d_emitted(noise_output: Transform2D, emitter_layer: int)
signal noise_3d_emitted(noise_output: Transform3D, emitter_layer: int)

# PCam Host
signal pcam_host_added_to_scene(pcam_host: PhantomCameraHost)
signal pcam_host_removed_from_scene(pcam_host: PhantomCameraHost)

# PCam
signal pcam_added_to_scene(pcam: Node)
signal pcam_removed_from_scene(pcam: Node)

# Priority
signal pcam_priority_changed(pcam: Node)
signal pcam_visibility_changed(pcam: Node)

signal pcam_teleport(pcam: Node)

# Limit (2D)
signal limit_2d_changed(side: int, limit: int)
signal draw_limit_2d(enabled: bool)

# Camera3DResource (3D)
signal camera_3d_resource_changed(property: String, value: Variant)

# Viewfinder Signals
signal viewfinder_pcam_host_switch(pcam_host: PhantomCameraHost)
signal pcam_priority_override(pcam: Node, shouldOverride: bool)
signal pcam_dead_zone_changed(pcam: Node)
signal pcam_host_layer_changed(pcam: Node)

#endregion

#region Private Variables

var _phantom_camera_host_list: Array[PhantomCameraHost]
var _phantom_camera_2d_list: Array[PhantomCamera2D]
var _phantom_camera_3d_list: Array[Node] ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.

#endregion

#region Public Variables

var phantom_camera_hosts: Array[PhantomCameraHost]:
	get:
		return _phantom_camera_host_list

var phantom_camera_2ds: Array[PhantomCamera2D]:
	get:
		return _phantom_camera_2d_list

var phantom_camera_3ds: Array[Node]: ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
	get:
		return _phantom_camera_3d_list


var screen_size: Vector2i

#endregion

#region Private Functions

func _enter_tree() -> void:
	if not Engine.has_singleton(_CONSTANTS.PCAM_MANAGER_NODE_NAME):
		Engine.register_singleton(_CONSTANTS.PCAM_MANAGER_NODE_NAME, self)
	Engine.physics_jitter_fix = 0


func _ready() -> void:
	# Setting default screensize
	screen_size = Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)

	# For editor
	if Engine.is_editor_hint():
		ProjectSettings.settings_changed.connect(func():
			screen_size = Vector2i(
				ProjectSettings.get_setting("display/window/size/viewport_width"),
				ProjectSettings.get_setting("display/window/size/viewport_height")
			)
		)
	# For runtime
	else:
		get_tree().get_root().size_changed.connect(func():
			screen_size = get_viewport().get_visible_rect().size
		)

#endregion

#region Public Functions

func pcam_host_added(caller: Node) -> void:
	if is_instance_of(caller, PhantomCameraHost):
		_phantom_camera_host_list.append(caller)
		pcam_host_added_to_scene.emit(caller)
	else:
		printerr("This method can only be called from a PhantomCameraHost node")

func pcam_host_removed(caller: Node) -> void:
	if is_instance_of(caller, PhantomCameraHost):
		_phantom_camera_host_list.erase(caller)
		pcam_host_removed_from_scene.emit(caller)
	else:
		printerr("This method can only be called from a PhantomCameraHost node")


func pcam_added(caller) -> void:
	if is_instance_of(caller, PhantomCamera2D):
		_phantom_camera_2d_list.append(caller)
		pcam_added_to_scene.emit(caller)
	elif caller.is_class("PhantomCamera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		_phantom_camera_3d_list.append(caller)
		pcam_added_to_scene.emit(caller)

func pcam_removed(caller) -> void:
	if is_instance_of(caller, PhantomCamera2D):
		_phantom_camera_2d_list.erase(caller)
		pcam_removed_from_scene.emit(caller)
	elif caller.is_class("PhantomCamera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		_phantom_camera_3d_list.erase(caller)
		pcam_removed_from_scene.emit(caller)
	else:
		printerr("This method can only be called from a PhantomCamera node")


func get_phantom_camera_hosts() -> Array[PhantomCameraHost]:
	return _phantom_camera_host_list

func get_phantom_camera_2ds() -> Array[PhantomCamera2D]:
	return _phantom_camera_2d_list

func get_phantom_camera_3ds() -> Array: ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
	return _phantom_camera_3d_list


func scene_changed() -> void:
	_phantom_camera_2d_list.clear()
	_phantom_camera_3d_list.clear()
	_phantom_camera_host_list.clear()

#endregion
