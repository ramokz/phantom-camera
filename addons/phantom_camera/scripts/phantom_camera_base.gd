@tool
extends Node

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

