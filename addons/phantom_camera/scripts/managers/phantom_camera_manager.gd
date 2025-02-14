@tool
extends Node

const _CONSTANTS = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#region Signals

signal noise_2d_emitted(noise_output: Transform2D, emitter_layer: int)
signal noise_3d_emitted(noise_output: Transform3D, emitter_layer: int)

signal pcam_host_added_to_scene(pcam_host: PhantomCameraHost)
signal pcam_host_removed_from_scene(pcam_host: PhantomCameraHost)

signal pcam_added_to_scene(pcam: Node)
signal pcam_removed_from_scene(pcam: Node)

# PCam Viewfinder Signals
signal viewfinder_pcam_host_switch(pcam_host: PhantomCameraHost)
signal pcam_priority_override(pcam: Node)
signal pcam_dead_zone_changed(pcam: Node)
signal pcam_host_layer_changed(pcam: Node)

#endregion

#region Variables

var phantom_camera_hosts: Array[PhantomCameraHost]:
	get:
		return _phantom_camera_host_list
var _phantom_camera_host_list: Array[PhantomCameraHost]

var phantom_camera_2ds: Array[PhantomCamera2D]:
	get:
		return _phantom_camera_2d_list
var _phantom_camera_2d_list: Array[PhantomCamera2D]

var phantom_camera_3ds: Array[Node]: ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
	get:
		return _phantom_camera_3d_list
var _phantom_camera_3d_list: Array[Node] ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.

#endregion

#var _viewfinder: Control


func _enter_tree() -> void:
	Engine.physics_jitter_fix = 0

	if not Engine.has_singleton(_CONSTANTS.PCAM_MANAGER_NODE_NAME):
		Engine.register_singleton(_CONSTANTS.PCAM_MANAGER_NODE_NAME, self)

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


func pcam_added(caller, host_slot: int = 0) -> void:
	if is_instance_of(caller, PhantomCamera2D):
		_phantom_camera_2d_list.append(caller)
		pcam_added_to_scene.emit(caller)
	elif caller.is_class("PhantomCamera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		_phantom_camera_3d_list.append(caller)
		pcam_added_to_scene.emit(caller)

	if not _phantom_camera_host_list.is_empty():
		_phantom_camera_host_list[host_slot].pcam_added_to_scene(caller)

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
