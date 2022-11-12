@tool
extends Node

var _active_camera: Node3D
var _active_phan_cam_list: Array[int]

var _camera

func _enter_tree() -> void:
	_camera = get_parent()
	if _camera is Camera3D:
		print("Camera is Camera3D")
		PhantomCameraManager.camera_base_3D = _camera
	elif _camera is Camera2D:
		print("Camera is Camera2D")
		PhantomCameraManager.camera_base_2D = _camera
	else:
		printerr("Is not a child of a Camera")



func _exit_tree() -> void:
#	TODO - Needs proper implementation when having multiple cameras
	if PhantomCameraManager.camera_base_2D == _camera:
		PhantomCameraManager.camera_base_2D = null
	elif PhantomCameraManager.camera_base_3D == _camera:
		PhantomCameraManager.camera_base_3D = null


#func _process(delta: float) -> void:
#	if (_active_phan_cam_list.size() > 0 && _camera):
#		pass
#		print(main_camera)
#		_camera.set_position(_active_camera.position)
#		_camera.set_rotation(_active_camera.get_rotation())

#		print(_active_camera.position)
#		print(_active_camera.name)
#		camera.position = _active_camera.position
#		print(_active_camera.is_camera_active)
