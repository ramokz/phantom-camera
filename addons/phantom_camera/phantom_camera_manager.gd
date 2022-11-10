@tool
extends Node

var _active_pcam: PhantomCamera3D
var _active_pcam_priority: int = 0
var pcam_list: Array[PhantomCamera3D]
var pcam_base_list: Array

const PHANTOM_CAMERA_GROUP_NAME: String = "phantom_camera"
const PHANTOM_CAMERA_BASE_GROUP_NAME: String = "phantom_camera_base"

func _enter_tree() -> void:
	print("Pcam Editor has entered the tree")


func phantom_camera_added_to_scene(pcam: PhantomCamera3D) -> void:
	pcam_list.append(pcam)
#	_check_active_camera_from_list(pcam)
	find_pcam_with_highest_priority()
#	 TODO - Add Camera to Editor with ID


func phantom_camera_removed_from_scene(pcam: PhantomCamera3D) -> void:
#	TODO - Could use some performance enhancements in case there are many Phantom Cameras
	pcam_list.erase(pcam)
	print("Removed: ", pcam, " from scene")

	if pcam == _active_pcam:
		print("Active camera removed from scene")
		_active_pcam_priority = 0
		find_pcam_with_highest_priority()


#func _check_active_camera_from_list(new_pcam: PhantomCamera3D) -> void:
#	find_pcam_with_highest_priority()
#
#	print("Active cam is: ", _active_pcam)
#	print("Highest priority is: ", _active_pcam_priority)


func find_pcam_with_highest_priority() -> void:
	for pcam_item in pcam_list:
#		TODO - Should also check whether if the existing active cam
		if pcam_item.priority > _active_pcam_priority:
			_active_pcam = pcam_item
			_active_pcam_priority = pcam_item.priority
			print("Changing new active cam to: ", _active_pcam)

func pcam_priority_updated(pcam: PhantomCamera3D) -> void:

#	TODO - Should also check whether if the existing active cam
	if pcam.priority > _active_pcam_priority:
		_active_pcam = pcam
		_active_pcam_priority = pcam.priority
		print("Changing new active cam to: ", _active_pcam)

	if pcam == _active_pcam:
		if pcam.priority < _active_pcam_priority:
			_active_pcam_priority = pcam.priority
			find_pcam_with_highest_priority()
		else:
			_active_pcam_priority = pcam.priority


func _process(delta: float) -> void:
	pass

#func set_active_cam(phan_cam: Node3D) -> void:
##	print(_active_phan_cam_list)
##	_active_phan_cam_list.
#	var phan_cam_id: int = phan_cam.get_instance_id()
#
#	if not _active_phan_cam_list.has(phan_cam_id):
#		_active_phan_cam_list.append(phan_cam_id)
#	else:
#		_active_phan_cam_list.pop_at(_active_phan_cam_list.find(phan_cam_id))
#		_active_phan_cam_list.append(phan_cam_id)
#
#	_active_camera = phan_cam
##	print(phan_cam.name)
#
##	print("Current cam list after adding of cam is:", _active_phan_cam_list)
#
#
#func remove_phan_cam_from_list(phan_cam: Node3D) -> void:
#
#	var phan_cam_id: int = phan_cam.get_instance_id()
#
#	if _active_camera == phan_cam:
#		_active_phan_cam_list.pop_at(_active_phan_cam_list.find(phan_cam_id))
#	else:
#		_active_phan_cam_list.pop_at(_active_phan_cam_list.find(phan_cam_id))
#
##	print("Current cam list after removal of cam is:", _active_phan_cam_list)
