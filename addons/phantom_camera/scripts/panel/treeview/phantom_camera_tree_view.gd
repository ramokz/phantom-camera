@tool
extends Control
class_name PhantomCameraTreeView

#region Constants

const _constants := preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

const _pcam_host_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/phantom_camera_host.svg")
const _pcam_2d_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/phantom_camera_2d.svg")
const _pcam_3d_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/phantom_camera_3d.svg")

const _tree_icon_size: int = 16
const _tree_collapsed_width: int = 0
const _tree_default_width: int = 360

#endregion

#region Onready

@export var toggle_button_path: NodePath

@onready var _main_split: HSplitContainer = %MainSplit
@onready var _toggle_tree_button: Button = _resolve_toggle_button()
@onready var _tree: Tree = %PhantomCameraTree

#endregion

#region Private Variables

var _pcam_manager: Node
var _root_item: TreeItem
var _selected_pcam: Node
var _tree_item_by_pcam: Dictionary = {}
var _tree_last_width: int = _tree_default_width

#endregion

#region Private Functions

func _resolve_toggle_button() -> Button:
	if toggle_button_path != NodePath():
		var node: Node = get_node_or_null(toggle_button_path)
		if node is Button:
			return node
	return null


func _ready() -> void:
	if not is_instance_valid(_tree): return
	_tree.hide_root = true
	_tree.item_selected.connect(_on_tree_item_selected)

	if is_instance_valid(_toggle_tree_button):
		_toggle_tree_button.toggled.connect(_on_toggle_tree_toggled)
		_set_button_pressed_no_signal(_toggle_tree_button, false)
		_set_tree_collapsed(true, true)

	_assign_manager()
	_set_selected_pcam(null)
	_rebuild_tree()


func _on_toggle_tree_toggled(pressed: bool) -> void:
	_set_tree_collapsed(not pressed)


func _set_tree_collapsed(collapsed: bool, skip_button: bool = false) -> void:
	if is_instance_valid(_main_split):
		_main_split.visible = not collapsed

	var split_parent: HSplitContainer = get_parent() as HSplitContainer
	if is_instance_valid(split_parent):
		if collapsed:
			if split_parent.split_offset > _tree_collapsed_width:
				_tree_last_width = split_parent.split_offset
			split_parent.split_offset = _tree_collapsed_width
		else:
			var target_width: int = max(_tree_last_width, _tree_default_width)
			split_parent.split_offset = target_width

	if not skip_button and is_instance_valid(_toggle_tree_button):
		_set_button_pressed_no_signal(_toggle_tree_button, not collapsed)


func _exit_tree() -> void:
	if not is_instance_valid(_pcam_manager): return

	if _pcam_manager.pcam_host_added_to_scene.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_host_added_to_scene.disconnect(_on_pcam_changed)
	if _pcam_manager.pcam_host_removed_from_scene.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_host_removed_from_scene.disconnect(_on_pcam_changed)
	if _pcam_manager.pcam_added_to_scene.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_added_to_scene.disconnect(_on_pcam_changed)
	if _pcam_manager.pcam_removed_from_scene.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_removed_from_scene.disconnect(_on_pcam_changed)
	if _pcam_manager.pcam_host_layer_changed.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_host_layer_changed.disconnect(_on_pcam_changed)
	if _pcam_manager.pcam_host_layers_changed.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_host_layers_changed.disconnect(_on_pcam_changed)


func _assign_manager() -> void:
	if is_instance_valid(_pcam_manager): return
	if not Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME): return

	_pcam_manager = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME)

	if not _pcam_manager.pcam_host_added_to_scene.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_host_added_to_scene.connect(_on_pcam_changed)
	if not _pcam_manager.pcam_host_removed_from_scene.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_host_removed_from_scene.connect(_on_pcam_changed)
	if not _pcam_manager.pcam_added_to_scene.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_added_to_scene.connect(_on_pcam_changed)
	if not _pcam_manager.pcam_removed_from_scene.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_removed_from_scene.connect(_on_pcam_changed)
	if not _pcam_manager.pcam_host_layer_changed.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_host_layer_changed.connect(_on_pcam_changed)
	if not _pcam_manager.pcam_host_layers_changed.is_connected(_on_pcam_changed):
		_pcam_manager.pcam_host_layers_changed.connect(_on_pcam_changed)


func _on_pcam_changed(_node: Node = null) -> void:
	_rebuild_tree()


func _rebuild_tree() -> void:
	if not is_instance_valid(_tree): return

	_tree.clear()
	_tree_item_by_pcam.clear()
	_root_item = _tree.create_item()

	_assign_manager()
	if not is_instance_valid(_pcam_manager):
		_add_info_item("PhantomCameraManager not found")
		_set_selected_pcam(null)
		return

	var hosts: Array[PhantomCameraHost] = _pcam_manager.get_phantom_camera_hosts()

	if hosts.is_empty():
		_add_info_item("No PhantomCameraHost in scene")
		_set_selected_pcam(null)
		return

	var pcams_2d: Array[PhantomCamera2D] = _pcam_manager.get_phantom_camera_2ds()
	var pcams_3d: Array = _pcam_manager.get_phantom_camera_3ds()

	for host in hosts:
		if not is_instance_valid(host): continue
		_add_host_section(host, pcams_2d, pcams_3d)

	_restore_selection()


func _add_info_item(text: String) -> void:
	var info_item: TreeItem = _tree.create_item(_root_item)
	info_item.set_text(0, text)
	info_item.set_selectable(0, false)


func _add_host_section(host: PhantomCameraHost, pcams_2d: Array[PhantomCamera2D], pcams_3d: Array) -> void:
	var host_item: TreeItem = _tree.create_item(_root_item)
	host_item.set_text(0, "Host: %s" % host.name)
	host_item.set_selectable(0, false)
	host_item.set_custom_color(0, _constants.PCAM_HOST_COLOR)
	_set_item_icon(host_item, _pcam_host_icon)

	var host_layers: int = host.get_host_layers() if host.has_method("get_host_layers") else host.host_layers
	var has_pcam: bool = false

	if is_instance_valid(host.camera_2d):
		for pcam in pcams_2d:
			if not is_instance_valid(pcam): continue
			if not _pcam_matches_host_layers(pcam, host_layers): continue
			_add_pcam_item(pcam, host_item, true)
			has_pcam = true
	if is_instance_valid(host.camera_3d):
		for pcam in pcams_3d:
			if not is_instance_valid(pcam): continue
			if not pcam.has_method("get_priority"): continue
			if not _pcam_matches_host_layers(pcam, host_layers): continue
			_add_pcam_item(pcam, host_item, false)
			has_pcam = true

	if not is_instance_valid(host.camera_2d) and not is_instance_valid(host.camera_3d):
		var missing_item: TreeItem = _tree.create_item(host_item)
		missing_item.set_text(0, "No Camera")
		missing_item.set_selectable(0, false)
		return

	if not has_pcam:
		var none_item: TreeItem = _tree.create_item(host_item)
		none_item.set_text(0, "No PhantomCamera")
		none_item.set_selectable(0, false)


func _add_pcam_item(pcam: Node, parent: TreeItem, is_2d: bool) -> void:
	var pcam_item: TreeItem = _tree.create_item(parent)
	pcam_item.set_text(0, pcam.name)
	_set_item_icon(pcam_item, _pcam_2d_icon if is_2d else _pcam_3d_icon)
	pcam_item.set_custom_color(0, _constants.COLOR_PCAM)
	pcam_item.set_metadata(0, pcam)
	if not _tree_item_by_pcam.has(pcam):
		_tree_item_by_pcam[pcam] = []
	_tree_item_by_pcam[pcam].append(pcam_item)

	if not pcam.renamed.is_connected(_on_pcam_changed):
		pcam.renamed.connect(_on_pcam_changed)


func _restore_selection() -> void:
	if not is_instance_valid(_selected_pcam):
		_set_selected_pcam(null)
		return

	if _tree_item_by_pcam.has(_selected_pcam):
		var items: Variant = _tree_item_by_pcam[_selected_pcam]
		if items is Array and not items.is_empty():
			items[0].select(0)
		elif items is TreeItem:
			items.select(0)
	else:
		_set_selected_pcam(null)


func _on_tree_item_selected() -> void:
	if not is_instance_valid(_tree): return
	var selected: TreeItem = _tree.get_selected()
	if selected == null: return

	var node: Variant = selected.get_metadata(0)
	if not (node is Node):
		_set_selected_pcam(null)
		return

	if not is_instance_valid(node):
		_set_selected_pcam(null)
		return

	_set_selected_pcam(node)


func _set_selected_pcam(new_pcam: Node) -> void:
	if _selected_pcam == new_pcam:
		_apply_selected_pcam_preview()
		if is_instance_valid(_selected_pcam) and Engine.is_editor_hint():
			_select_node_in_editor(_selected_pcam)
		return

	_disconnect_selected_pcam_signals()
	_selected_pcam = new_pcam
	_connect_selected_pcam_signals()
	_apply_selected_pcam_preview()
	if is_instance_valid(_selected_pcam) and Engine.is_editor_hint():
		_select_node_in_editor(_selected_pcam)


func _connect_selected_pcam_signals() -> void:
	if not is_instance_valid(_selected_pcam): return
	if not _selected_pcam.tree_exiting.is_connected(_on_selected_pcam_exiting):
		_selected_pcam.tree_exiting.connect(_on_selected_pcam_exiting)


func _disconnect_selected_pcam_signals() -> void:
	if not is_instance_valid(_selected_pcam): return
	if _selected_pcam.tree_exiting.is_connected(_on_selected_pcam_exiting):
		_selected_pcam.tree_exiting.disconnect(_on_selected_pcam_exiting)


func _on_selected_pcam_exiting() -> void:
	_set_selected_pcam(null)
	_rebuild_tree()


func _apply_selected_pcam_preview() -> void:
	if not Engine.is_editor_hint(): return

	_clear_priority_overrides(_selected_pcam)
	if not is_instance_valid(_selected_pcam): return

	_selected_pcam.priority_override = true
	_switch_viewfinder_host_for_pcam(_selected_pcam)


func _clear_priority_overrides(except: Node = null) -> void:
	if not is_instance_valid(_pcam_manager): return

	for pcam in _pcam_manager.get_phantom_camera_2ds():
		if not is_instance_valid(pcam): continue
		if is_instance_valid(except) and pcam == except: continue
		if pcam.priority_override:
			pcam.priority_override = false

	for pcam in _pcam_manager.get_phantom_camera_3ds():
		if not is_instance_valid(pcam): continue
		if is_instance_valid(except) and pcam == except: continue
		if pcam.priority_override:
			pcam.priority_override = false


func _switch_viewfinder_host_for_pcam(pcam: Node) -> void:
	if not is_instance_valid(_pcam_manager): return
	if not is_instance_valid(pcam): return

	var host: PhantomCameraHost = _find_host_for_pcam(pcam)
	if is_instance_valid(host):
		_pcam_manager.viewfinder_pcam_host_switch.emit(host)


func _find_host_for_pcam(pcam: Node) -> PhantomCameraHost:
	if not is_instance_valid(_pcam_manager): return null
	var hosts: Array[PhantomCameraHost] = _pcam_manager.get_phantom_camera_hosts()
	if hosts.is_empty(): return null

	var is_2d: bool = _is_pcam_2d(pcam)

	for host in hosts:
		if not is_instance_valid(host): continue
		if is_2d and not is_instance_valid(host.camera_2d): continue
		if not is_2d and not is_instance_valid(host.camera_3d): continue
		if pcam.has_method("get_host_layers") and host.has_method("get_host_layers"):
			if pcam.get_host_layers() & host.get_host_layers() == 0:
				continue
		return host

	return null

func _pcam_matches_host_layers(pcam: Node, host_layers: int) -> bool:
	if not pcam.has_method("get_host_layers"): return false
	return pcam.get_host_layers() & host_layers != 0

func _select_node_in_editor(node: Node) -> void:
	if not is_instance_valid(node): return
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(node)


func _is_pcam_2d(pcam: Node) -> bool:
	return pcam is PhantomCamera2D


func _is_pcam_3d(pcam: Node) -> bool:
	return pcam.is_class("PhantomCamera3D") or pcam is PhantomCamera3D


func _set_item_icon(item: TreeItem, icon: Texture2D) -> void:
	item.set_icon(0, icon)
	item.set_icon_max_width(0, _tree_icon_size)


func _set_button_pressed_no_signal(button: Button, pressed: bool) -> void:
	if button.has_method("set_pressed_no_signal"):
		button.set_pressed_no_signal(pressed)
	else:
		button.button_pressed = pressed

#endregion
