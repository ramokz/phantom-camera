@tool
extends VBoxContainer

#region Constants

const _constants := preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
const _host_list_item: PackedScene = preload("res://addons/phantom_camera/panel/viewfinder/host_list/host_list_item.tscn")

#endregion

signal pcam_host_removed(pcam_host: PhantomCameraHost)

@onready var _host_list_button: Button = %HostListButton
@onready var _host_list_scroll_container: ScrollContainer = %ScrollContainer
@onready var _host_list_item_container: VBoxContainer = %HostListContainer

var _host_list_open: bool = false

var _bottom_offset_value: float

var _pcam_host_list: Array[PhantomCameraHost]
var _pcam_manager: Node

var _viewfinder_panel: Control

#region Private Functions

func _ready() -> void:
	_host_list_button.pressed.connect(_host_list_button_pressed)
	if Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME):
		_pcam_manager = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME)
		_pcam_manager.pcam_host_removed_from_scene.connect(_remove_pcam_host)

	if not get_parent() is Control: return # To prevent errors when opening the scene on its own
	_viewfinder_panel = get_parent()
	_viewfinder_panel.resized.connect(_set_offset_top)

	_host_list_item_container.resized.connect(_set_offset_top)


func _set_offset_top() -> void:
	offset_top = _set_host_list_size()


func _host_list_button_pressed() -> void:
	_host_list_open = !_host_list_open

	var tween: Tween = create_tween()
	var max_duration: float = 0.6

	# 300 being the minimum size of the viewfinder's height
	var duration: float = clampf(
		max_duration / (300 / _host_list_item_container.size.y),
		0.3,
		max_duration)

	tween.tween_property(self, "offset_top", _set_host_list_size(), duration)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_QUINT)


func _set_host_list_size() -> float:
	if not _host_list_open:
		return clampf(
			_viewfinder_panel.size.y - \
			_host_list_item_container.size.y - \
			_host_list_button.size.y - 20,
			0,
			INF
		)
	else:
		return (_viewfinder_panel.size.y - _host_list_button.size.y / 2)


func _remove_pcam_host(pcam_host: PhantomCameraHost) -> void:
	if _pcam_host_list.has(pcam_host):
		_pcam_host_list.erase(pcam_host)

	var freed_pcam_host: Control
	for host_list_item_instance in _host_list_item_container.get_children():
		if not host_list_item_instance.pcam_host == pcam_host: continue
		freed_pcam_host = host_list_item_instance
		host_list_item_instance.queue_free()

#endregion

#region Public Functions

func add_pcam_host(pcam_host: PhantomCameraHost, is_default: bool) -> void:
	if _pcam_host_list.has(pcam_host): return

	_pcam_host_list.append(pcam_host)

	var host_list_item_instance: PanelContainer = _host_list_item.instantiate()
	var switch_pcam_host_button: Button = host_list_item_instance.get_node("%SwitchPCamHost")
	if is_default: switch_pcam_host_button.button_pressed = true

	if not pcam_host.tree_exiting.is_connected(_remove_pcam_host):
		pcam_host.tree_exiting.connect(_remove_pcam_host.bind(pcam_host))

	host_list_item_instance.pcam_host = pcam_host

	_host_list_item_container.add_child(host_list_item_instance)


func clear_pcam_host_list() -> void:
	_pcam_host_list.clear()

	for host_list_item_instance in _host_list_item_container.get_children():
		host_list_item_instance.queue_free()

#endregion
