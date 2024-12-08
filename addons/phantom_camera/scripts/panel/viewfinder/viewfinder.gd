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
@onready var _framed_viewfinder: Control = %FramedViewfinder
@onready var _dead_zone_h_box_container: Control = %DeadZoneHBoxContainer
@onready var sub_viewport: SubViewport = %SubViewport

@onready var _empty_state_control: Control = %EmptyStateControl
@onready var _empty_state_icon: Control = %EmptyStateIcon
@onready var _empty_state_text: RichTextLabel = %EmptyStateText
@onready var _add_node_button: Button = %AddNodeButton
@onready var _add_node_button_text: RichTextLabel = %AddNodeTypeText

@onready var _priority_override_button: Button = %PriorityOverrideButton
@onready var _priority_override_name_label: Label = %PriorityOverrideNameLabel

@onready var _camera_2d: Camera2D = %Camera2D

#endregion

#region Private Variables
var _no_open_scene_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/SceneTypesIcon.svg")
var _no_open_scene_string: String = "[b]2D[/b] or [b]3D[/b] scene open"

var _selected_camera: Node
var _active_pcam: Node

var _is_2d: bool

var root_node: Node

#endregion

#region Public variables

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

	root_node = get_tree().current_scene

	if root_node is Node2D || root_node is Node3D:
		%SubViewportContainer.set_visible(false)
		if root_node is Node2D:
			_is_2d = true
		else:
			_is_2d = false

		_set_viewfinder(root_node, false)

	if Engine.is_editor_hint():
		# BUG - Both signals below are called whenever a noe is selected in the scenetree
		# Should only be triggered whenever a node is added or removed.
		get_tree().node_added.connect(_node_added_or_removed)
		get_tree().node_removed.connect(_node_added_or_removed)
	else:
		_empty_state_control.set_visible(false)

	_priority_override_button.set_visible(false)

	# Triggered when viewport size is changed in Project Settings
	ProjectSettings.settings_changed.connect(_settings_changed)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		if get_tree().node_added.is_connected(_node_added_or_removed):
			get_tree().node_added.disconnect(_node_added_or_removed)
			get_tree().node_removed.disconnect(_node_added_or_removed)

	if aspect_ratio_container.resized.is_connected(_resized):
		aspect_ratio_container.resized.disconnect(_resized)

	if _add_node_button.pressed.is_connected(visibility_check):
		_add_node_button.pressed.disconnect(visibility_check)

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

	if _is_2d:
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

	## Applies Project Settings to Viewport
	sub_viewport.canvas_item_default_texture_filter = ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter")

	# TODO - Add resizer for Framed Viewfinder


func _node_added_or_removed(_node: Node) -> void:
	visibility_check()


func visibility_check() -> void:
	if not viewfinder_visible: return

	var phantom_camera_host: PhantomCameraHost
	var has_camera: bool = false
	if not get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME).get_phantom_camera_hosts().is_empty():
		has_camera = true
		phantom_camera_host = get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME).get_phantom_camera_hosts()[0]

	var root: Node = EditorInterface.get_edited_scene_root()

	if root is Node2D:
		var camera_2d: Camera2D

		if has_camera:
			camera_2d = phantom_camera_host.camera_2d
		else:
			camera_2d = _get_camera_2d()

		_is_2d = true
		is_scene = true
		_add_node_button.set_visible(true)
		_check_camera(root, camera_2d, true)
	elif root is Node3D:
		var camera_3d: Camera3D
		if has_camera:
			camera_3d = phantom_camera_host.camera_3d
		elif root.get_viewport() != null:
			if root.get_viewport().get_camera_3d() != null:
				camera_3d = root.get_viewport().get_camera_3d()

		_is_2d = false
		is_scene = true
		_add_node_button.set_visible(true)
		_check_camera(root, camera_3d, false)
	else:
		is_scene = false
#		Is not a 2D or 3D scene
		_set_empty_viewfinder_state(_no_open_scene_string, _no_open_scene_icon)
		_add_node_button.set_visible(false)

	if not _priority_override_button.pressed.is_connected(_select_override_pcam):
		_priority_override_button.pressed.connect(_select_override_pcam)


func _get_camera_2d() -> Camera2D:
	var edited_scene_root = EditorInterface.get_edited_scene_root()

	if edited_scene_root == null: return null

	var viewport = edited_scene_root.get_viewport()
	if viewport == null: return null

	var viewport_rid = viewport.get_viewport_rid()
	if viewport_rid == null: return null

	var camerasGroupName = "__cameras_%d" % viewport_rid.get_id()
	var cameras = get_tree().get_nodes_in_group(camerasGroupName)

	for camera in cameras:
		if camera is Camera2D and camera.is_current:
			return camera

	return null


func _check_camera(root: Node, camera: Node, is_2D: bool) -> void:
	var camera_string: String
	var pcam_string: String
	var color: Color
	var color_alpha: Color
	var camera_icon: CompressedTexture2D
	var pcam_icon: CompressedTexture2D

	if is_2D:
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
#							if pcam_host.get_active_pcam().get_get_follow_mode():
#								_on_dead_zone_changed()

						_set_viewfinder_state()

						%NoSupportMsg.set_visible(false)

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
	_empty_state_control.set_visible(false)

	_framed_viewfinder.set_visible(true)

	if is_instance_valid(_active_pcam):
		if _active_pcam.get_follow_mode() == _active_pcam.FollowMode.FRAMED:
			_dead_zone_h_box_container.set_visible(true)
			target_point.set_visible(true)
		else:
			_dead_zone_h_box_container.set_visible(false)
			target_point.set_visible(false)


func _set_empty_viewfinder_state(text: String, icon: CompressedTexture2D) -> void:
	_framed_viewfinder.set_visible(false)
	target_point.set_visible(false)

	_empty_state_control.set_visible(true)
	_empty_state_icon.set_texture(icon)
	if icon == _no_open_scene_icon:
		_empty_state_text.set_text("[center]No " + text + "[/center]")
	else:
		_empty_state_text.set_text("[center]No [b]" + text + "[/b] in scene[/center]")

	if _add_node_button.pressed.is_connected(_add_node):
		_add_node_button.pressed.disconnect(_add_node)

	_add_node_button.pressed.connect(_add_node.bind(text))


func _add_node(node_type: String) -> void:
	var root: Node = EditorInterface.get_edited_scene_root()

	match node_type:
		_no_open_scene_string:
			pass
		_constants.CAMERA_2D_NODE_NAME:
			var camera: Camera2D = Camera2D.new()
			_instantiate_node(root, camera, _constants.CAMERA_2D_NODE_NAME)
		_constants.CAMERA_3D_NODE_NAME:
			var camera: Camera3D = Camera3D.new()
			_instantiate_node(root, camera, _constants.CAMERA_3D_NODE_NAME)
		_constants.PCAM_HOST_NODE_NAME:
			var pcam_host: PhantomCameraHost = PhantomCameraHost.new()
			pcam_host.set_name(_constants.PCAM_HOST_NODE_NAME)
			if _is_2d:
#				get_tree().get_edited_scene_root().get_viewport().get_camera_2d().add_child(pcam_host)
				_get_camera_2d().add_child(pcam_host)
				pcam_host.set_owner(get_tree().get_edited_scene_root())
			else:
#				var pcam_3D := get_tree().get_edited_scene_root().get_viewport().get_camera_3d()
				get_tree().get_edited_scene_root().get_viewport().get_camera_3d().add_child(pcam_host)
				pcam_host.set_owner(get_tree().get_edited_scene_root())
		_constants.PCAM_2D_NODE_NAME:
			var pcam_2D: PhantomCamera2D = PhantomCamera2D.new()
			_instantiate_node(root, pcam_2D, _constants.PCAM_2D_NODE_NAME)
		_constants.PCAM_3D_NODE_NAME:
			var pcam_3D: PhantomCamera3D = PhantomCamera3D.new()
			_instantiate_node(root, pcam_3D, _constants.PCAM_3D_NODE_NAME)


func _instantiate_node(root: Node, node: Node, name: String) -> void:
	node.set_name(name)
	root.add_child(node)
	node.set_owner(get_tree().get_edited_scene_root())


func _set_viewfinder(root: Node, editor: bool) -> void:
	pcam_host_group = get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME).get_phantom_camera_hosts()
	if pcam_host_group.size() != 0:
		if pcam_host_group.size() == 1:
			var pcam_host: PhantomCameraHost = pcam_host_group[0]
			if _is_2d:
				_selected_camera = pcam_host.camera_2d
				_active_pcam = pcam_host.get_active_pcam() as PhantomCamera2D
				if editor:
					var camera_2d_rid: RID = _selected_camera.get_canvas()
					sub_viewport.disable_3d = true
					_camera_2d.zoom = pcam_host.camera_2d.zoom
					_camera_2d.offset = pcam_host.camera_2d.offset
					_camera_2d.ignore_rotation = pcam_host.camera_2d.ignore_rotation

					sub_viewport.world_2d = pcam_host.camera_2d.get_world_2d()
					sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
					sub_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
					sub_viewport.size_2d_override_stretch = true
			else:
				_selected_camera = pcam_host.camera_3d
				_active_pcam = pcam_host.get_active_pcam() as PhantomCamera3D
				if editor:
					var camera_3d_rid: RID = _selected_camera.get_camera_rid()
					sub_viewport.disable_3d = false
					sub_viewport.world_3d = pcam_host.camera_3d.get_world_3d()
					RenderingServer.viewport_attach_camera(sub_viewport.get_viewport_rid(), camera_3d_rid)

				if _selected_camera.keep_aspect == Camera3D.KeepAspect.KEEP_HEIGHT:
					aspect_ratio_container.set_stretch_mode(AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH)
				else:
					aspect_ratio_container.set_stretch_mode(AspectRatioContainer.STRETCH_WIDTH_CONTROLS_HEIGHT)

			_on_dead_zone_changed()
			set_process(true)

			if not pcam_host.update_editor_viewfinder.is_connected(_on_update_editor_viewfinder):
				pcam_host.update_editor_viewfinder.connect(_on_update_editor_viewfinder.bind(pcam_host))

			if not aspect_ratio_container.resized.is_connected(_resized):
				aspect_ratio_container.resized.connect(_resized)

			if not _active_pcam.dead_zone_changed.is_connected(_on_dead_zone_changed):
				_active_pcam.dead_zone_changed.connect(_on_dead_zone_changed)


func _resized() -> void:
	_on_dead_zone_changed()


func _on_dead_zone_changed() -> void:
	if not is_instance_valid(_active_pcam): return
	if not _active_pcam.follow_mode == _active_pcam.FollowMode.FRAMED: return

	# Waits until the camera_viewport_panel has been resized when launching the game
	if camera_viewport_panel.size.x == 0:
		await camera_viewport_panel.resized

	#print(_active_pcam.get_pcam_host_owner())
	if is_instance_valid(_active_pcam.get_pcam_host_owner()):
		pcam_host = _active_pcam.get_pcam_host_owner()
		if not _active_pcam == pcam_host.get_active_pcam():
			_active_pcam == pcam_host.get_active_pcam()
			print("Active pcam in viewfinder: ", _active_pcam)

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


####################
## Priority Override
####################
func _on_update_editor_viewfinder(pcam_host: PhantomCameraHost) -> void:
	if pcam_host.get_active_pcam().priority_override:
		_active_pcam = pcam_host.get_active_pcam()
		_priority_override_button.set_visible(true)
		_priority_override_name_label.set_text(_active_pcam.name)
		_priority_override_button.set_tooltip_text(_active_pcam.name)
	else:
		_priority_override_button.set_visible(false)

func _select_override_pcam() -> void:
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(_active_pcam)

#endregion


#region Public Functions

func update_dead_zone() -> void:
	_set_viewfinder(root_node, true)


func scene_changed(scene_root: Node) -> void:
	if not scene_root is Node2D and not scene_root is Node3D:
		is_scene = false
		_set_empty_viewfinder_state(_no_open_scene_string, _no_open_scene_icon)
		_add_node_button.set_visible(false)

#endregion
