@tool
extends Node3D

var _active_camera: Node3D
var _active_phan_cam_list: Array[int]

var _camera

func _enter_tree() -> void:
	_camera = get_parent()
#	if _camera is Camera3D:
#		print("Camera is Camera3D")
#	elif _camera is Camera2D:
#		print("Camera is Camera2D")
#	else:
#		printerr("Is not a child of a Camera")

	add_to_group(PhantomCameraManager.PHANTOM_CAMERA_BASE_GROUP_NAME)


func _exit_tree() -> void:
	remove_from_group(PhantomCameraManager.PHANTOM_CAMERA_BASE_GROUP_NAME)


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
