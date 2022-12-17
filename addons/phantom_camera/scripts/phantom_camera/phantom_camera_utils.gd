@tool
extends RefCounted

const PhantomCameraGroupNames = preload("res://addons/phantom_camera/scripts/group_names.gd")

static func set_priority(value: int, phantom_camera, phantom_camera_host: PhantomCameraHost) -> void:
	if value < 1:
		phantom_camera.Properties.priority = 1
	else:
		phantom_camera.Properties.priority = value

	if phantom_camera_host:
		phantom_camera_host.phantom_camera_priority_updated(phantom_camera)
	else:
#			TODO - Add logic to handle Phantom Camera Host in scene
		pass


static func enter_tree(phantom_camera: Node):
	phantom_camera.add_to_group(PhantomCameraGroupNames.PHANTOM_CAMERA_GROUP_NAME)
	if phantom_camera.Properties.follow_target_path:
		phantom_camera.Properties.follow_target_node = phantom_camera.get_node(phantom_camera.Properties.follow_target_path)


static func assign_phantom_camera_host(phantom_camera: Node) -> Node:
	var _phantom_camera_host: PhantomCameraHost

	phantom_camera.Properties.camera_host_group = phantom_camera.get_tree().get_nodes_in_group(PhantomCameraGroupNames.PHANTOM_CAMERA_HOST_GROUP_NAME)

	if phantom_camera.Properties.camera_host_group.size() > 0:
		if phantom_camera.Properties.camera_host_group.size() == 1:
			_phantom_camera_host = phantom_camera.Properties.camera_host_group[0]
			_phantom_camera_host.phantom_camera_added_to_scene(phantom_camera)
			return _phantom_camera_host
		else:
			for camera_host in phantom_camera.Properties.camera_host_group:
				print("Multiple PhantomCameraBases in scene")
				return null
	return null
