@tool
extends Control

const button_group_resource: ButtonGroup = preload("res://addons/phantom_camera/panel/viewfinder/host_list/host_list_item_group.tres")
const _constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

@onready var select_pcam_host: Button = %SelectPCamHost
@onready var switch_pcam_host: Button = %SwitchPCamHost

var pcam_host: PhantomCameraHost:
	set(value):
		pcam_host = value
		if not is_instance_valid(value): return
		if not pcam_host.renamed.is_connected(_rename_pcam_host):
			pcam_host.renamed.connect(_rename_pcam_host)
			pcam_host.has_error.connect(_pcam_host_has_error)
	get:
		return pcam_host

var _pcam_manager: Node

#region Private fucntions

func _ready() -> void:
	switch_pcam_host.button_group = button_group_resource
	select_pcam_host.pressed.connect(_select_pcam)
	switch_pcam_host.pressed.connect(_switch_pcam_host)

	if not is_instance_valid(pcam_host): return
	switch_pcam_host.text = pcam_host.name

	_pcam_host_has_error()


func _pcam_host_has_error() -> void:
	if pcam_host.show_warning:
		%ErrorPCamHost.visible = true
	else:
		%ErrorPCamHost.visible = false


func _rename_pcam_host() -> void:
	switch_pcam_host.text = pcam_host.name


func _select_pcam() -> void:
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(pcam_host)


func _switch_pcam_host() -> void:
	if not Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME): return
	if not is_instance_valid(_pcam_manager):
		_pcam_manager = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME)

	_pcam_manager.viewfinder_pcam_host_switch.emit(pcam_host)

#endregion
