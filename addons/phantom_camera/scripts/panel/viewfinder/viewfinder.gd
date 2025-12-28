@tool
extends Control

#region Constants

const _constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

# TODO - Should be in a central location
const _camera_2d_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/Camera2DIcon.svg")
const _camera_3d_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/Camera3DIcon.svg")
const _pcam_host_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/phantom_camera_host.svg")
const _pcam_2D_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/phantom_camera_2d.svg")
const _pcam_3D_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/phantom_camera_3d.svg")

const _overlay_color_alpha: float = 0.3

#endregion

#region @onready

@onready var dead_zone_center_hbox: VBoxContainer = %DeadZoneCenterHBoxContainer
@onready var dead_zone_center_center_panel: Panel = %DeadZoneCenterCenterPanel
@onready var dead_zone_left_center_panel: Panel = %DeadZoneLeftCenterPanel
@onready var dead_zone_right_center_panel: Panel = %DeadZoneRightCenterPanel
@onready var target_point: Panel = %TargetPoint

@onready var aspect_ratio_container: AspectRatioContainer = %AspectRatioContainer
@onready var camera_viewport_panel: Panel = aspect_ratio_container.get_child(0)
@onready var _viewfinder: Control = %Viewfinder
@onready var _dead_zone_h_box_container: Control = %DeadZoneHBoxContainer
@onready var sub_viewport: SubViewport = %SubViewport

@onready var _empty_state_control: Control = %EmptyStateControl
@onready var _empty_state_icon: TextureRect = %EmptyStateIcon
@onready var _empty_state_text: RichTextLabel = %EmptyStateText
@onready var _add_node_button: Button = %AddNodeButton
@onready var _add_node_button_text: RichTextLabel = %AddNodeTypeText

@onready var _priority_override_button: Button = %PriorityOverrideButton
@onready var _priority_override_name_label: Label = %PriorityOverrideNameLabel

@onready var _camera_2d: Camera2D = %Camera2D

@onready var _pcam_host_list: VBoxContainer = %PCamHostList

#endregion

#region Private Variables

var _no_open_scene_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/SceneTypesIcon.svg")
var _no_open_scene_string: String = "[b]2D[/b] or [b]3D[/b] scene open"

var _selected_camera: Node
var _active_pcam: Node

var _is_2d: bool

var _pcam_manager: Node

var _root_node: Node

#endregion

#region Public Variables

var pcam_host_group: Array[PhantomCameraHost]

var is_scene: bool

var viewfinder_visible: bool

var min_horizontal: float
var max_horizontal: float
var min_vertical: float
var max_vertical: float

var pcam_host: PhantomCameraHost

#endregion


#region Private Functions

func _ready() -> void:
	if not Engine.is_editor_hint():
		set_process(true)
		camera_viewport_panel.self_modulate.a = 0

	_root_node = get_tree().current_scene

	if _root_node is Node2D || _root_node is Node3D:
		%SubViewportContainer.visible = false
		if _root_node is Node2D:
			_is_2d = true
		else:
			_is_2d = false

		_set_viewfinder(_root_node, false)

	if not Engine.is_editor_hint():
		_empty_state_control.visible = false

	_priority_override_button.visible = false

	# Triggered when viewport size is changed in Project Settings
	ProjectSettings.settings_changed.connect(_settings_changed)

	# PCam Host List
	_pcam_host_list.visible = false
	_assign_manager()
	_visibility_check()


func _pcam_host_switch(new_pcam_host: PhantomCameraHost) -> void:
	_set_viewfinder_camera(new_pcam_host, true)


func _exit_tree() -> void:
	if aspect_ratio_container.resized.is_connected(_resized):
		aspect_ratio_container.resized.disconnect(_resized)

	if _add_node_button.pressed.is_connected(_visibility_check):
		_add_node_button.pressed.disconnect(_visibility_check)

	if is_instance_valid(_active_pcam):
		if _active_pcam.dead_zone_changed.is_connected(_on_dead_zone_changed):
			_active_pcam.dead_zone_changed.disconnect(_on_dead_zone_changed)

	if _priority_override_button.pressed.is_connected(_select_override_pcam):
		_priority_override_button.pressed.disconnect(_select_override_pcam)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and not viewfinder_visible: return
	if not is_instance_valid(_active_pcam): return

	var unprojected_position_clamped: Vector2 = Vector2(
		clamp(_active_pcam.viewport_position.x, min_horizontal, max_horizontal),
		clamp(_active_pcam.viewport_position.y, min_vertical, max_vertical)
	)

	if not Engine.is_editor_hint():
		target_point.position = camera_viewport_panel.size * unprojected_position_clamped - target_point.size / 2

	if not _is_2d: return
	if not is_instance_valid(pcam_host): return
	if not is_instance_valid(pcam_host.camera_2d): return

	var window_size_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
	sub_viewport.size_2d_override = sub_viewport.size * (window_size_height / sub_viewport.size.y)

	_camera_2d.global_transform = pcam_host.camera_2d.global_transform
	_camera_2d.offset = pcam_host.camera_2d.offset
	_camera_2d.zoom = pcam_host.camera_2d.zoom
	_camera_2d.ignore_rotation = pcam_host.camera_2d.ignore_rotation
	_camera_2d.anchor_mode = pcam_host.camera_2d.anchor_mode
	_camera_2d.limit_left = pcam_host.camera_2d.limit_left
	_camera_2d.limit_top = pcam_host.camera_2d.limit_top
	_camera_2d.limit_right = pcam_host.camera_2d.limit_right
	_camera_2d.limit_bottom = pcam_host.camera_2d.limit_bottom


func _settings_changed() -> void:
	var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
	var ratio: float = viewport_width / viewport_height
	aspect_ratio_container.set_ratio(ratio)
	camera_viewport_panel.size.x = viewport_width / (viewport_height / sub_viewport.size.y)

	# Applies Project Settings to Viewport
	sub_viewport.canvas_item_default_texture_filter = ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter")

	# TODO - Add resizer for Framed Viewfinder


func _visibility_check() -> void:
	if not viewfinder_visible: return

	var pcam_host: PhantomCameraHost
	var has_camera: bool = false
	if not Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME): return

	if not Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME).get_phantom_camera_hosts().is_empty():
		has_camera = true
		pcam_host = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME).get_phantom_camera_hosts()[0]

	var root: Node = EditorInterface.get_edited_scene_root()
	if root is Node2D:
		var camera_2d: Camera2D

		if has_camera:
			camera_2d = pcam_host.camera_2d
		else:
			camera_2d = _get_camera_2d()

		_is_2d = true
		is_scene = true
		_add_node_button.visible = true
		_check_camera(root, camera_2d)
	elif root is Node3D:
		var camera_3d: Camera3D
		if has_camera:
			camera_3d = pcam_host.camera_3d
		elif root.get_viewport() != null:
			if root.get_viewport().get_camera_3d() != null:
				camera_3d = root.get_viewport().get_camera_3d()

		_is_2d = false
		is_scene = true
		_add_node_button.visible = true
		_check_camera(root, camera_3d)
	else:
		# Is not a 2D or 3D scene
		is_scene = false
		_set_empty_viewfinder_state(_no_open_scene_string, _no_open_scene_icon)
		_add_node_button.visible = false

		# Checks if a new scene is created and changes viewfinder accordingly
		if not get_tree().node_added.is_connected(_node_added_to_scene):
			get_tree().node_added.connect(_node_added_to_scene)

	if not _priority_override_button.pressed.is_connected(_select_override_pcam):
		_priority_override_button.pressed.connect(_select_override_pcam)


func _node_added_to_scene(node: Node) -> void:
	if node is Node2D or node is Node3D:
		get_tree().node_added.disconnect(_node_added_to_scene)
		_visibility_check()


func _get_camera_2d() -> Camera2D:
	var edited_scene_root: Node = EditorInterface.get_edited_scene_root()

	if edited_scene_root == null: return null

	var viewport: Viewport = edited_scene_root.get_viewport()
	if viewport == null: return null

	var viewport_rid: RID = viewport.get_viewport_rid()
	if viewport_rid == null: return null

	var camerasGroupName: String = "__cameras_%d" % viewport_rid.get_id()
	var cameras: Array[Node] = get_tree().get_nodes_in_group(camerasGroupName)

	for camera in cameras:
		if camera is Camera2D and camera.is_current:
			return camera

	return null


func _check_camera(root: Node, camera: Node) -> void:
	var camera_string: String
	var pcam_string: String
	var color: Color
	var camera_icon: CompressedTexture2D
	var pcam_icon: CompressedTexture2D

	if _is_2d:
		camera_string = _constants.CAMERA_2D_NODE_NAME
		pcam_string = _constants.PCAM_2D_NODE_NAME
		color = _constants.COLOR_2D
		camera_icon = _camera_2d_icon
		pcam_icon = _pcam_2D_icon
	else:
		camera_string = _constants.CAMERA_3D_NODE_NAME
		pcam_string = _constants.PCAM_3D_NODE_NAME
		color = _constants.COLOR_3D
		camera_icon = _camera_3d_icon
		pcam_icon = _pcam_3D_icon

	if camera:
#		Has Camera
		if camera.get_children().size() > 0:
			for cam_child in camera.get_children():
				if cam_child is PhantomCameraHost:
					pcam_host = cam_child

				if pcam_host:
					if get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME).get_phantom_camera_2ds() or \
					get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME).get_phantom_camera_3ds():
						# Pcam exists in tree
						_set_viewfinder(root, true)
						_set_viewfinder_state()
						%NoSupportMsg.visible = false
					else:
#						No PCam in scene
						_update_button(pcam_string, pcam_icon, color)
						_set_empty_viewfinder_state(pcam_string, pcam_icon)
				else:
#					No PCamHost in scene
					_update_button(_constants.PCAM_HOST_NODE_NAME, _pcam_host_icon, _constants.PCAM_HOST_COLOR)
					_set_empty_viewfinder_state(_constants.PCAM_HOST_NODE_NAME, _pcam_host_icon)
		else:
#			No PCamHost in scene
			_update_button(_constants.PCAM_HOST_NODE_NAME, _pcam_host_icon, _constants.PCAM_HOST_COLOR)
			_set_empty_viewfinder_state(_constants.PCAM_HOST_NODE_NAME, _pcam_host_icon)
	else:
#		No Camera
		_update_button(camera_string, camera_icon, color)
		_set_empty_viewfinder_state(camera_string, camera_icon)


func _update_button(text: String, icon: CompressedTexture2D, color: Color) -> void:
	_add_node_button_text.set_text("[center]Add [img=32]" + icon.resource_path + "[/img] [b]"+ text + "[/b][/center]");
	var button_theme_hover: StyleBoxFlat = _add_node_button.get_theme_stylebox("hover")
	button_theme_hover.border_color = color
	_add_node_button.add_theme_stylebox_override("hover", button_theme_hover)


func _set_viewfinder_state() -> void:
	_empty_state_control.visible = false
	_viewfinder.visible = true

	if is_instance_valid(_active_pcam):
		if _active_pcam.get_follow_mode() == _active_pcam.FollowMode.FRAMED:
			_dead_zone_h_box_container.visible = true
			target_point.visible = true
		else:
			_dead_zone_h_box_container.visible = false
			target_point.visible = false


func _set_empty_viewfinder_state(text: String, icon: CompressedTexture2D) -> void:
	_viewfinder.visible = false
	_framed_view_visible(false)

	_empty_state_control.visible = true
	_empty_state_icon.texture = icon
	if icon == _no_open_scene_icon:
		_empty_state_text.set_text("[center]No " + text + "[/center]")
	else:
		_empty_state_text.set_text("[center]No [b]" + text + "[/b] in scene[/center]")

	if _add_node_button.pressed.is_connected(_add_node):
		_add_node_button.pressed.disconnect(_add_node)

	_add_node_button.pressed.connect(_add_node.bind(text))


func _add_node(node_type: String) -> void:
	var scene_root: Node = EditorInterface.get_edited_scene_root()

	match node_type:
		_no_open_scene_string:
			pass
		_constants.CAMERA_2D_NODE_NAME:
			var camera: Camera2D = Camera2D.new()
			_instantiate_node(scene_root, camera, _constants.CAMERA_2D_NODE_NAME)
		_constants.CAMERA_3D_NODE_NAME:
			var camera: Camera3D = Camera3D.new()
			_instantiate_node(scene_root, camera, _constants.CAMERA_3D_NODE_NAME)
		_constants.PCAM_HOST_NODE_NAME:
			var pcam_host: PhantomCameraHost = PhantomCameraHost.new()
			var camera_owner: Node
			if _is_2d:
				camera_owner = _get_camera_2d()
			else:
				camera_owner = get_tree().get_edited_scene_root().get_viewport().get_camera_3d()
			_instantiate_node(
				scene_root,
				pcam_host,
				_constants.PCAM_HOST_NODE_NAME,
				camera_owner
			)
		_constants.PCAM_2D_NODE_NAME:
			var pcam_2D: PhantomCamera2D = PhantomCamera2D.new()
			_instantiate_node(scene_root, pcam_2D, _constants.PCAM_2D_NODE_NAME)
		_constants.PCAM_3D_NODE_NAME:
			var pcam_3D: PhantomCamera3D = PhantomCamera3D.new()
			_instantiate_node(scene_root, pcam_3D, _constants.PCAM_3D_NODE_NAME)

	_visibility_check()


func _instantiate_node(scene_root: Node, node: Node, name: String, parent: Node = scene_root) -> void:
	node.set_name(name)
	parent.add_child(node)
	node.owner = scene_root


func _set_viewfinder(root: Node, editor: bool) -> void:
	pcam_host_group = get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME).get_phantom_camera_hosts()
	if pcam_host_group.size() != 0:
		if pcam_host_group.size() == 1:
			_pcam_host_list.visible = false
			_set_viewfinder_camera(pcam_host_group[0], editor)
		else:
			_pcam_host_list.visible = true
			_set_viewfinder_camera(pcam_host_group[0], editor)
			for i in pcam_host_group.size():
				var is_default: bool = false
				if i == 0:
					is_default = true
				_pcam_host_list.add_pcam_host(pcam_host_group[i], is_default)


func _set_viewfinder_camera(new_pcam_host: PhantomCameraHost, editor: bool) -> void:
	pcam_host = new_pcam_host

	if _is_2d:
		_selected_camera = pcam_host.camera_2d

		if editor:
			sub_viewport.disable_3d = true
			pcam_host = pcam_host
			_camera_2d.zoom = pcam_host.camera_2d.zoom
			_camera_2d.offset = pcam_host.camera_2d.offset
			_camera_2d.ignore_rotation = pcam_host.camera_2d.ignore_rotation

			sub_viewport.world_2d = pcam_host.camera_2d.get_world_2d()
			sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			sub_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
			sub_viewport.size_2d_override_stretch = true
	else:
		_selected_camera = pcam_host.camera_3d
		if editor:
			var camera_3d_rid: RID = _selected_camera.get_camera_rid()
			sub_viewport.disable_3d = false
			sub_viewport.world_3d = pcam_host.camera_3d.get_world_3d()
			RenderingServer.viewport_attach_camera(sub_viewport.get_viewport_rid(), camera_3d_rid)

		if _selected_camera.keep_aspect == Camera3D.KeepAspect.KEEP_HEIGHT:
			aspect_ratio_container.set_stretch_mode(AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH)
		else:
			aspect_ratio_container.set_stretch_mode(AspectRatioContainer.STRETCH_WIDTH_CONTROLS_HEIGHT)

	set_process(true)

	if not pcam_host.viewfinder_update.is_connected(_on_update_editor_viewfinder):
		pcam_host.viewfinder_update.connect(_on_update_editor_viewfinder)

	if not pcam_host.viewfinder_disable_dead_zone.is_connected(_disconnect_dead_zone):
		pcam_host.viewfinder_disable_dead_zone.connect(_disconnect_dead_zone)

	if not aspect_ratio_container.resized.is_connected(_resized):
		aspect_ratio_container.resized.connect(_resized)

	if is_instance_valid(pcam_host.get_active_pcam()):
		_active_pcam = pcam_host.get_active_pcam()
	else:
		_framed_view_visible(false)
		_active_pcam = null
		return

	if not _active_pcam.follow_mode == PhantomCamera2D.FollowMode.FRAMED: return

	_framed_view_visible(true)
	_on_dead_zone_changed()
	_connect_dead_zone()


func _connect_dead_zone() -> void:
	if not _active_pcam and is_instance_valid(pcam_host.get_active_pcam()):
		_active_pcam = pcam_host.get_active_pcam()

	if not _active_pcam.dead_zone_changed.is_connected(_on_dead_zone_changed):
		_active_pcam.dead_zone_changed.connect(_on_dead_zone_changed)

		_framed_view_visible(true)
		_viewfinder.visible = true
		_on_dead_zone_changed()

func _disconnect_dead_zone() -> void:
	if not is_instance_valid(_active_pcam): return
	_framed_view_visible(_is_framed_pcam())

	if _active_pcam.follow_mode_changed.is_connected(_check_follow_mode):
		_active_pcam.follow_mode_changed.disconnect(_check_follow_mode)

	if _active_pcam.dead_zone_changed.is_connected(_on_dead_zone_changed):
		_active_pcam.dead_zone_changed.disconnect(_on_dead_zone_changed)


func _resized() -> void:
	_on_dead_zone_changed()


func _is_framed_pcam() -> bool:
	if not is_instance_valid(pcam_host): return false
	_active_pcam = pcam_host.get_active_pcam()
	if not is_instance_valid(_active_pcam): return false
	if not _active_pcam.follow_mode == PhantomCamera2D.FollowMode.FRAMED: return false

	return true


func _framed_view_visible(should_show: bool) -> void:
	if should_show:
		target_point.visible = true
		_dead_zone_h_box_container.visible = true
	else:
		target_point.visible = false
		_dead_zone_h_box_container.visible = false


func _on_dead_zone_changed() -> void:
	if not is_instance_valid(_active_pcam): return
	if not _active_pcam.follow_mode == _active_pcam.FollowMode.FRAMED: return

	# Waits until the camera_viewport_panel has been resized when launching the game
	if camera_viewport_panel.size.x == 0:
		await camera_viewport_panel.resized

	if not _active_pcam == pcam_host.get_active_pcam():
		_active_pcam == pcam_host.get_active_pcam()

	var dead_zone_width: float = _active_pcam.dead_zone_width * camera_viewport_panel.size.x
	var dead_zone_height: float = _active_pcam.dead_zone_height * camera_viewport_panel.size.y
	dead_zone_center_hbox.set_custom_minimum_size(Vector2(dead_zone_width, 0))
	dead_zone_center_center_panel.set_custom_minimum_size(Vector2(0, dead_zone_height))
	dead_zone_left_center_panel.set_custom_minimum_size(Vector2(0, dead_zone_height))
	dead_zone_right_center_panel.set_custom_minimum_size(Vector2(0, dead_zone_height))

	min_horizontal = 0.5 - _active_pcam.dead_zone_width / 2
	max_horizontal = 0.5 + _active_pcam.dead_zone_width / 2
	min_vertical = 0.5 - _active_pcam.dead_zone_height / 2
	max_vertical = 0.5 + _active_pcam.dead_zone_height / 2


func _check_follow_mode() -> void:
	_framed_view_visible(_is_framed_pcam())


func _on_update_editor_viewfinder(check_framed_view: bool = false) -> void:
	_active_pcam = pcam_host.get_active_pcam()

	if not is_instance_valid(_active_pcam): return

	if not _active_pcam.follow_mode_changed.is_connected(_check_follow_mode):
		_active_pcam.follow_mode_changed.connect(_check_follow_mode)

	if _active_pcam.priority_override:
		_priority_override_button.visible = true
		_priority_override_name_label.set_text(_active_pcam.name)
		_priority_override_button.set_tooltip_text(_active_pcam.name)
	else:
		_priority_override_button.visible = false

	_framed_view_visible(false)
	if not check_framed_view: return
	if _is_framed_pcam(): _connect_dead_zone()


func _select_override_pcam() -> void:
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(_active_pcam)


func _assign_manager() -> void:
	if not is_instance_valid(_pcam_manager):
		if Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME):
			_pcam_manager = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME)
			_pcam_manager.pcam_host_added_to_scene.connect(_pcam_changed)
			_pcam_manager.pcam_host_removed_from_scene.connect(_pcam_host_removed_from_scene)

			_pcam_manager.pcam_added_to_scene.connect(_pcam_changed)
			_pcam_manager.pcam_removed_from_scene.connect(_pcam_changed)

			_pcam_manager.viewfinder_pcam_host_switch.connect(_pcam_host_switch)


func _pcam_host_removed_from_scene(pcam_host: PhantomCameraHost) -> void:
	if _pcam_manager.phantom_camera_hosts.size() < 2:
		_pcam_host_list.visible = false

	_visibility_check()


func _pcam_changed(pcam: Node) -> void:
	_visibility_check()

#endregion


#region Public Functions

func set_visibility(visible: bool) -> void:
	if visible:
		viewfinder_visible = true
		_visibility_check()
	else:
		viewfinder_visible = false


func update_dead_zone() -> void:
	_set_viewfinder(_root_node, true)


## TODO - Signal can be added directly to this file with the changes in Godot 4.5 (https://github.com/godotengine/godot/pull/102986)
func scene_changed(scene_root: Node) -> void:
	_assign_manager()
	_priority_override_button.visible = false
	_pcam_host_list.clear_pcam_host_list()

	if not scene_root is Node2D and not scene_root is Node3D:
		is_scene = false
		_pcam_host_list.visible = false
		_set_empty_viewfinder_state(_no_open_scene_string, _no_open_scene_icon)
		_add_node_button.visible = false
	else:
		_visibility_check()

#endregion
