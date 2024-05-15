@tool
extends Node

const PHANTOM_CAMERA_CONSTS = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

var _phantom_camera_host_list: Array[PhantomCameraHost]
var _phantom_camera_2d_list: Array[PhantomCamera2D]
var _phantom_camera_3d_list: Array[PhantomCamera3D]

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


func pcam_added(caller: Node, host_slot: int = 0) -> void:
	if is_instance_of(caller, PhantomCamera2D):
		_phantom_camera_2d_list.append(caller)
		#print("Added PCam2D to PCamManager")
	elif is_instance_of(caller, PhantomCamera3D):
		_phantom_camera_3d_list.append(caller)
		#print("Added PCam3D to PCamManager")

	if not _phantom_camera_host_list.is_empty():
		_phantom_camera_host_list[host_slot].pcam_added_to_scene(caller)

func pcam_removed(caller: Node) -> void:
	if is_instance_of(caller, PhantomCamera2D):
		_phantom_camera_2d_list.erase(caller)
	elif is_instance_of(caller, PhantomCamera3D):
		_phantom_camera_3d_list.erase(caller)
	else:
		printerr("This method can only be called from a PhantomCamera node")


func get_phantom_camera_hosts() -> Array[PhantomCameraHost]:
	return _phantom_camera_host_list

func get_phantom_camera_2ds() -> Array[PhantomCamera2D]:
	return _phantom_camera_2d_list

func get_phantom_camera_3ds() -> Array[PhantomCamera3D]:
	return _phantom_camera_3d_list


func scene_changed() -> void:
	_phantom_camera_2d_list.clear()
	_phantom_camera_3d_list.clear()
	_phantom_camera_host_list.clear()
