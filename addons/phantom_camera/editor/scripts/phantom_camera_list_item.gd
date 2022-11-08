@tool
extends Node

var phantom_camera_name: String
var _phantom_camer_name_label: Label

var _look_at_target_label: Label

var follow_target_name: String
var _follow_target_Label: Label

var _priority: int
var _preview: bool

#@export var _phantom_camera_hbox: LineEdit
#@export var _follow_target_hbox: HBoxContainer
#@export var _look_at_target_hbox: NodePath
#@export var _priority_line_edit: NodePath
#@export var preview_check_button: NodePath

func init(pcam_name: String, pcam_follow_name: String) -> void:
	phantom_camera_name = pcam_name
	follow_target_name = pcam_follow_name

func _ready() -> void:
	_phantom_camer_name_label = %ListTargetPhantomCameraName.get_child(0).get_child(1) as Label
	_phantom_camer_name_label.text = phantom_camera_name

	if not follow_target_name.is_empty():
		_follow_target_Label = %ListTargetFollowTarget.get_child(0).get_child(1) as Label
		_follow_target_Label.text = follow_target_name
	else:
		%ListTargetFollowTarget.get_child(0).set_visible(false)

#	print("Phantom Camera name is: ", phantom_camera_name)
#	print("Can find Line Edit: ",%PriorityLineEdit)
