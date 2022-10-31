@tool

extends Node

var _look_at_target
var _follow_target
var _priority: int
var _preview: bool

@export var _phantom_camera_hbox: NodePath
@export var _follow_target_hbox: NodePath
@export var _look_at_target_hbox: NodePath
@export var _priority_line_edit: NodePath
@export var preview_check_button: NodePath

func _enter_tree() -> void:
	pass
