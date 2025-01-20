@tool
extends Control

const button_group_resource = preload("res://addons/phantom_camera/panel/viewfinder/host_list/host_list_item_group.tres")
const _constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

var id: int
var pcam_host: PhantomCameraHost

var _pcam_manager: Node

@onready var select_pcam_host: Button = %SelectPCamHost
@onready var switch_pcam_host: Button = %SwitchPCamHost


func _ready() -> void:
	_pcam_manager = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME)
	_pcam_manager.pcam_host_removed_from_scene.connect(_pcam_host_removed_from_scene)

#	pcam_host.renamed.connect(_renamed_pcam_host)

	switch_pcam_host.button_group = button_group_resource

	select_pcam_host.pressed.connect(_select_pcam)
	switch_pcam_host.pressed.connect(_switch_pcam_host)


func _select_pcam() -> void:
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(pcam_host)


func _switch_pcam_host() -> void:
	_pcam_manager.viewfinder_pcam_host_switch.emit(pcam_host)


## Removes this PCam Host list item if the PCam Host node is deleted
func _pcam_host_removed_from_scene(pcam_host_freed: PhantomCameraHost) -> void:
	if not pcam_host == pcam_host_freed: return
	queue_free()

#func _renamed_pcam_host() -> void:
#	select_pcam_host.text = pcam_host.name
