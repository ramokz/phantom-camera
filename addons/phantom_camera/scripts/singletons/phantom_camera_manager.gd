@tool 
extends Node

const PHANTOM_CAMERA_CONSTS = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

var _phantom_camera_host_in_scene: Array[PhantomCameraHost]
var _phantom_camera_2d_in_scene: Array[PhantomCamera2D]
var _phantom_camera_3d_in_scene: Array[PhantomCamera3D]


func add_pcam_host_to_list(caller: Node) -> void:
	if is_instance_of(caller, PhantomCameraHost): 
		_phantom_camera_host_in_scene.append(caller)
	else:
		printerr("This method can only be called from a PhantomCameraHost node")
func remove_pcam_host_from_list(caller: Node) -> void:
	if is_instance_of(caller, PhantomCameraHost): 
		_phantom_camera_host_in_scene.erase(caller)
	else:
		printerr("This method can only be called from a PhantomCameraHost node")

func add_pcam_to_list(caller: Node) -> void:
	if is_instance_of(caller, PhantomCamera2D):
		_phantom_camera_2d_in_scene.append(caller)
	elif is_instance_of(caller, PhantomCamera3D):
		_phantom_camera_3d_in_scene.append(caller)
		print("Addedint to array")
	else:
		printerr("This method can only be called from a PhantomCamera node")
func remove_pcam_from_list(caller: Node) -> void:
	if is_instance_of(caller, PhantomCamera2D): 
		_phantom_camera_2d_in_scene.erase(caller)
	elif is_instance_of(caller, PhantomCamera3D):
		_phantom_camera_3d_in_scene.erase(caller)
	else:
		printerr("This method can only be called from a PhantomCamera node")


func get_all_phantom_camera_hosts() -> Array[PhantomCameraHost]:
	return _phantom_camera_host_in_scene
func get_all_phantom_camera_2d() -> Array[PhantomCamera2D]:
	return _phantom_camera_2d_in_scene
func get_all_phantom_camera_3d() -> Array[PhantomCamera3D]:
	return _phantom_camera_3d_in_scene
