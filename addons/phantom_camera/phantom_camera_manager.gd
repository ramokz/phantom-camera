extends Node

var _active_camera: Node3D
var _active_phan_cam_list: Array[int]

func set_active_cam(phan_cam: Node3D) -> void:
#	print(_active_phan_cam_list)
#	_active_phan_cam_list.
	var phan_cam_id: int = phan_cam.get_instance_id()

	if not _active_phan_cam_list.has(phan_cam_id):
		_active_phan_cam_list.append(phan_cam_id)
	else:
		_active_phan_cam_list.pop_at(_active_phan_cam_list.find(phan_cam_id))
		_active_phan_cam_list.append(phan_cam_id)

	_active_camera = phan_cam
#	print(phan_cam.name)

#	print("Current cam list after adding of cam is:", _active_phan_cam_list)


func remove_phan_cam_from_list(phan_cam: Node3D) -> void:

	var phan_cam_id: int = phan_cam.get_instance_id()

	if _active_camera == phan_cam:
		_active_phan_cam_list.pop_at(_active_phan_cam_list.find(phan_cam_id))
	else:
		_active_phan_cam_list.pop_at(_active_phan_cam_list.find(phan_cam_id))

#	print("Current cam list after removal of cam is:", _active_phan_cam_list)
