@tool
extends VBoxContainer

#region Constants

const _constants := preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
const _host_list_item: PackedScene = preload("res://addons/phantom_camera/panel/viewfinder/host_list/host_list_item.tscn")

#endregion

signal pcam_host_removed(pcam_host: PhantomCameraHost)

@onready var _host_list_button: Button = %HostListButton
@onready var _host_list_container: VBoxContainer = %HostListContainer

var _host_list_open: bool = false

var _bottom_offset_value: float

var _pcam_host_list: Array[PhantomCameraHost]
var _pcam_manager: Node

func _ready() -> void:
	_host_list_button.pressed.connect(_host_list_button_pressed)

	_bottom_offset_value = offset_bottom

	if Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME):
		_pcam_manager = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME)
		_pcam_manager.pcam_host_removed_from_scene.connect(_remove_pcam_host)

#	if not is_instance_valid(get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME)): return

#	print(Engine.has_singleton("PhantomCameraManager"))

	# Assigns pressed signal to default button list items
	#for pcam_host_instance_default in _host_list_container.get_children():
		#pcam_host_instance_default = pcam_host_instance_default as Button
		#pcam_host_instance_default.pcam_scene_id =
		#pcam_host_instance_default.pressed.connect(_pcam_host_list_item_pressed.bind(pcam_host_instance_default.get_instance_id()))


func _host_list_button_pressed() -> void:
	_host_list_open = !_host_list_open

	var tween: Tween = create_tween()
	var tween_value: float
	var tween_ease: Tween.EaseType = Tween.EASE_OUT
	var tween_trans: Tween.TransitionType = Tween.TRANS_QUINT

	if _host_list_open:
		tween_value = 0
	else:
		tween_value = _bottom_offset_value

	tween.tween_property(self, "offset_bottom", tween_value, 0.3)\
	.set_ease(tween_ease)\
	.set_trans(tween_trans)


func add_pcam_host(pcam_host: PhantomCameraHost, is_default: bool) -> void:
	if _pcam_host_list.has(pcam_host): return

	_pcam_host_list.append(pcam_host)

	var host_list_item_instance: HBoxContainer = _host_list_item.instantiate()
	var switch_pcam_host_button: Button = host_list_item_instance.get_node("%SwitchPCamHost")

	#	var locate_button: Button = host_list_item_instance.get_node("%Locate")

	if is_default: switch_pcam_host_button.button_pressed = true

	host_list_item_instance.pcam_host = pcam_host

#	switch_pcam_host_button.pressed.connect(_pcam_host_list_item_pressed.bind(pcam_host))
#	locate_button.pressed.connect(_locate_pcam_host.bind(pcam_host))

	switch_pcam_host_button.text = pcam_host.name
	pcam_host.renamed.connect(func(): switch_pcam_host_button.text = pcam_host.name)

	_host_list_container.add_child(host_list_item_instance)


func _remove_pcam_host(pcam_host: PhantomCameraHost) -> void:
	if _pcam_host_list.has(pcam_host):
		_pcam_host_list.erase(pcam_host)

	print("Removing pcam host")
	print(_host_list_container)
	for host_list_item_instance in _host_list_container.get_children():
		print(host_list_item_instance.pcam_host)
		print(pcam_host)
		if not host_list_item_instance.pcam_host == pcam_host: continue

		host_list_item_instance.queue_free()
		print("queuing free")


#func _pcam_host_list_item_pressed(pcam_host: PhantomCameraHost) -> void:
##	pcam_host_changed.emit(pcam_host)
#	print(_pcam_manager)
#	_pcam_manager.viewfinder_pcam_host_switch.emit(pcam_host)
