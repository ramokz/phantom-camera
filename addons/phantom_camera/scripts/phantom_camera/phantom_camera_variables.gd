extends RefCounted

var priority: int = 1

var camera_host_group: Array
var scene_has_multiple_phantom_camera_hosts: bool

var follow_target_node: Node
var follow_target_path: NodePath
var has_follow_target: bool = false


###################
# Tween - Variables
###################
var tween_transition: Tween.TransitionType
var tween_linear: bool

var tween_ease: Tween.EaseType

var tween_duration: float = 1
