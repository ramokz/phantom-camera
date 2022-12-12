@tool
extends Node

##################
# Variables
##################
#  General Variables
var _active_phantom_camera_priority: int
var _active_cam_missing: bool

# Tweening Variables
var _phantom_camera_tween: Tween
var _tween_default_ease: Tween.EaseType
var _easing: Tween.TransitionType

const PHANTOM_CAMERA_GROUP_NAME: StringName = "phantom_camera_group"
const PHANTOM_CAMERA_HOST_GROUP_NAME: StringName = "phantom_camera_host_group"


#func _exit_tree() -> void:
#	remove_from_group(PHANTOM_CAMERA_HOST_GROUP_NAME)
