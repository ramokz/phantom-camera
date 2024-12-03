@tool
extends Node

const PHANTOM_CAMERA_CONSTS = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")


signal noise_2d_emitted(noise_output: Transform2D, emitter_layer: int)
signal noise_3d_emitted(noise_output: Transform3D, emitter_layer: int)


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


func _enter_tree():
	Engine.physics_jitter_fix = 0


func pcam_host_added(caller: Node) -> void:
	if is_instance_of(caller, PhantomCameraHost):
		_phantom_camera_host_list.append(caller)
	else:
		printerr("This method can only be called from a PhantomCameraHost node")

func pcam_host_removed(caller: Node) -> void:
	if is_instance_of(caller, PhantomCameraHost):
		_phantom_camera_host_list.erase(caller)
	else:
		printerr("This method can only be called from a PhantomCameraHost node")


func pcam_added(caller, host_slot: int = 0) -> void:
	if is_instance_of(caller, PhantomCamera2D):
		_phantom_camera_2d_list.append(caller)
	elif caller.is_class("PhantomCamera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		_phantom_camera_3d_list.append(caller)

	if not _phantom_camera_host_list.is_empty():
		_phantom_camera_host_list[host_slot].pcam_added_to_scene(caller)

func pcam_removed(caller) -> void:
	if is_instance_of(caller, PhantomCamera2D):
		_phantom_camera_2d_list.erase(caller)
	elif caller.is_class("PhantomCamera3D"): ## Note: To support disable_3d export templates for 2D projects, this is purposely not strongly typed.
		_phantom_camera_3d_list.erase(caller)
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
