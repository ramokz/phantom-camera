@tool
extends RefCounted

#region Constants

#const PhantomCameraHost: Script = preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")

const CAMERA_2D_NODE_NAME: StringName = "Camera2D"
const CAMERA_3D_NODE_NAME: StringName = "Camera3D"
const PCAM_HOST_NODE_NAME: StringName = "PhantomCameraHost"
const PCAM_MANAGER_NODE_NAME: String = "PhantomCameraManager" # TODO - Convert to StringName once https://github.com/godotengine/godot/pull/72702 is merged
const PCAM_2D_NODE_NAME: StringName = "PhantomCamera2D"
const PCAM_3D_NODE_NAME: StringName = "PhantomCamera3D"
const PCAM_HOST: StringName = "phantom_camera_host"

const COLOR_2D: Color = Color("8DA5F3")
const COLOR_3D: Color = Color("FC7F7F")
const COLOR_PCAM: Color = Color("3AB99A")
const COLOR_PCAM_33: Color = Color("3ab99a33")
const PCAM_HOST_COLOR: Color = Color("E0E0E0")

#endregion

#region Group Names

const PCAM_GROUP_NAME: StringName = "phantom_camera_group"
const PCAM_HOST_GROUP_NAME: StringName = "phantom_camera_host_group"

#endregion
