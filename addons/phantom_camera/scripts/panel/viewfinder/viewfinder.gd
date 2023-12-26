@tool
extends Control

#region Constants

const PcamGroupNames = preload("res://addons/phantom_camera/scripts/group_names.gd")
const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

# TODO - Should be in a central location
const _camera_2d_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/Camera2DIcon.svg")
const _camera_3d_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/Camera3DIcon.svg")
const _pcam_host_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/PhantomCameraHostIcon.svg")
const _pcam_2D_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/PhantomCameraGizmoIcon2D.svg")
const _pcam_3D_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/PhantomCameraGizmoIcon3D.svg")

const _overlay_color_alpha: float = 0.3

#endregion


#region Variables

var _selected_camera: Node
var _active_pcam_camera
var pcam_host_group: Array[Node]

var editor_interface: EditorInterface

#endregion


#region @onready

@onready var dead_zone_center_hbox: VBoxContainer = %DeadZoneCenterHBoxContainer
@onready var dead_zone_center_center_panel: Panel = %DeadZoneCenterCenterPanel
@onready var dead_zone_left_center_panel: Panel = %DeadZoneLeftCenterPanel
@onready var dead_zone_right_center_panel: Panel = %DeadZoneRightCenterPanel
@onready var target_point: Panel = %TargetPoint

var aspect_ratio_container: AspectRatioContainer
@onready var aspect_ratio_containers: AspectRatioContainer = %AspectRatioContainer
@onready var camera_viewport_panel: Panel = aspect_ratio_containers.get_child(0)
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

#endregion


#region Variables

var _no_open_scene_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/SceneTypesIcon.svg")
var _no_open_scene_string: String = "[b]2D[/b] or [b]3D[/b] scene open"

var is_2D: bool
var is_scene: bool

var has_camera_viewport_panel_size: bool = true

var min_horizontal: float
var max_horizontal: float
var min_vertical: float
var max_vertical: float

#endregion


#region Private Functions

func _ready():
	visibility_changed.connect(_visibility_check)
	set_process(false)
	
	aspect_ratio_containers.set_ratio(get_viewport_rect().size.x / get_viewport_rect().size.y)

#	TODO - Don't think this is needed / does anything?
	var root_node = get_tree().get_root().get_child(0)
	if root_node is Node3D || root_node is Node2D:
		%SubViewportContainer.set_visible(false)

		if root_node is Node2D:
			is_2D = true
		else:
			is_2D = false
			
		_set_viewfinder(root_node, false)

	if Engine.is_editor_hint():
		get_tree().node_added.connect(_node_added)
		get_tree().node_removed.connect(_node_added)
	else:
		_empty_state_control.set_visible(false)

	_priority_override_button.set_visible(false)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		if get_tree().node_added.is_connected(_node_added):
			get_tree().node_added.disconnect(_node_added)
			get_tree().node_removed.disconnect(_node_added)

	if aspect_ratio_containers.resized.is_connected(_resized):
		aspect_ratio_containers.resized.disconnect(_resized)

	if _add_node_button.pressed.is_connected(_add_node):
		_add_node_button.pressed.disconnect(_add_node)

	if is_instance_valid(_active_pcam_camera):
		if _active_pcam_camera.Properties.is_connected(Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed):
			_active_pcam_camera.Properties.disconnect(Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed)
	
	if _priority_override_button.pressed.is_connected(_select_override_pcam):
		_priority_override_button.pressed.disconnect(_select_override_pcam)


func _process(_delta: float):
	if not visible or not is_instance_valid(_active_pcam_camera): return

	var unprojected_position_clamped: Vector2 = Vector2(
		clamp(_active_pcam_camera.Properties.viewport_position.x, min_horizontal, max_horizontal),
		clamp(_active_pcam_camera.Properties.viewport_position.y, min_vertical, max_vertical)
	)
	target_point.position = camera_viewport_panel.size * unprojected_position_clamped - target_point.size / 2
	
	if not has_camera_viewport_panel_size:
		_on_dead_zone_changed()


func _node_added(node: Node) -> void:
	if editor_interface == null: return
	_visibility_check()


func _visibility_check():
	if not editor_interface or not visible: return

	if not is_instance_valid(editor_interface):
		is_scene = false
#		Is not a 2D or 3D scene
		_set_empty_viewfinder_state(_no_open_scene_string, _no_open_scene_icon)
		_add_node_button.set_visible(false)
		return

	var root: Node = editor_interface.get_edited_scene_root()
	if root is Node2D:
#		print("Is a 2D scene")
		is_2D = true
		is_scene = true

		_add_node_button.set_visible(true)
#		TODO: Figure out why the line below doesn't work...
#		var camera: Camera2D = root.get_viewport().get_camera_2d()

		var camera: Camera2D = _get_camera_2D()
		_check_camera(root, camera, true)
	elif root is Node3D:
#		Is 3D scene
		is_2D = false
		is_scene = true

		_add_node_button.set_visible(true)
		var camera: Camera3D = root.get_viewport().get_camera_3d()
		_check_camera(root, camera, false)
#		editor_interface.get_selection().clear()
#		editor_interface.get_selection().add_node(pcam_host_group[0].get_active_pcam())
	else:
		is_scene = false
#		Is not a 2D or 3D scene
		_set_empty_viewfinder_state(_no_open_scene_string, _no_open_scene_icon)
		_add_node_button.set_visible(false)

	if not _priority_override_button.pressed.is_connected(_select_override_pcam):
		_priority_override_button.pressed.connect(_select_override_pcam)


func _get_camera_2D() -> Camera2D:
	var camerasGroupName = "__cameras_%d" % editor_interface.get_edited_scene_root().get_viewport().get_viewport_rid().get_id()
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
		camera_string = Constants.CAMERA_2D_NODE_NAME
		pcam_string = Constants.PCAM_2D_NODE_NAME
		color = Constants.COLOR_2D
		camera_icon = _camera_2d_icon
		pcam_icon = _pcam_2D_icon
	else:
		camera_string = Constants.CAMERA_3D_NODE_NAME
		pcam_string = Constants.PCAM_3D_NODE_NAME
		color = Constants.COLOR_3D
		camera_icon = _camera_3d_icon
		pcam_icon = _pcam_3D_icon

	if camera:
#		Has Camera
		var pcam_host: PhantomCameraHost
		if camera.get_children().size() > 0:
			for cam_child in camera.get_children():
				if cam_child is PhantomCameraHost:
					pcam_host = cam_child

				if pcam_host:
					if get_tree().get_nodes_in_group(PcamGroupNames.PCAM_GROUP_NAME):
#						Pcam exists in tree
						_set_viewfinder(root, true)
#							if pcam_host.get_active_pcam().get_get_follow_mode():
#								_on_dead_zone_changed()

						_set_viewfinder_state()

						# Related to: https://github.com/ramokz/phantom-camera/issues/105
						# REMOVE BELOW WHEN 2D VIEWFINDER IS SUPPORTED
						if not is_2D:
							%NoSupportMsg.set_visible(false)
						elif is_2D:
							%NoSupportMsg.set_visible(true)
						### REMOVAL END

					else:
#						No PCam in scene
						_update_button(pcam_string, pcam_icon, color)
						_set_empty_viewfinder_state(pcam_string, pcam_icon)
				else:
#					No PCamHost in scene
					_update_button(Constants.PCAM_HOST_NODE_NAME, _pcam_host_icon, Constants.PCAM_HOST_COLOR)
					_set_empty_viewfinder_state(Constants.PCAM_HOST_NODE_NAME, _pcam_host_icon)
		else:
#			No PCamHost in scene
			_update_button(Constants.PCAM_HOST_NODE_NAME, _pcam_host_icon, Constants.PCAM_HOST_COLOR)
			_set_empty_viewfinder_state(Constants.PCAM_HOST_NODE_NAME, _pcam_host_icon)
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
	target_point.set_visible(true)

	if is_instance_valid(_active_pcam_camera):
		if _active_pcam_camera.get_follow_mode() == Constants.FollowMode.FRAMED:
			_dead_zone_h_box_container.set_visible(true)
		else:
			_dead_zone_h_box_container.set_visible(false)


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
	if not editor_interface: return

	var root: Node = editor_interface.get_edited_scene_root()

	match node_type:
		_no_open_scene_string:
			pass
		Constants.CAMERA_2D_NODE_NAME:
			var camera: Camera2D = Camera2D.new()
			_instantiate_node(root, camera, Constants.CAMERA_2D_NODE_NAME)
		Constants.CAMERA_3D_NODE_NAME:
			var camera: Camera3D = Camera3D.new()
			_instantiate_node(root, camera, Constants.CAMERA_3D_NODE_NAME)
		Constants.PCAM_HOST_NODE_NAME:
			var pcam_host: PhantomCameraHost = PhantomCameraHost.new()
			pcam_host.set_name(Constants.PCAM_HOST_NODE_NAME)
			if is_2D:
#				get_tree().get_edited_scene_root().get_viewport().get_camera_2d().add_child(pcam_host)
				_get_camera_2D().add_child(pcam_host)
				pcam_host.set_owner(get_tree().get_edited_scene_root())
			else:
#				var pcam_3D := get_tree().get_edited_scene_root().get_viewport().get_camera_3d()
				get_tree().get_edited_scene_root().get_viewport().get_camera_3d().add_child(pcam_host)
				pcam_host.set_owner(get_tree().get_edited_scene_root())
		Constants.PCAM_2D_NODE_NAME:
			var pcam_2D: PhantomCamera2D = PhantomCamera2D.new()
			_instantiate_node(root, pcam_2D, Constants.PCAM_2D_NODE_NAME)
		Constants.PCAM_3D_NODE_NAME:
			var pcam_3D: PhantomCamera3D = PhantomCamera3D.new()
			_instantiate_node(root, pcam_3D, Constants.PCAM_3D_NODE_NAME)


func _instantiate_node(root: Node, node: Node, name: String) -> void:
	node.set_name(name)
	root.add_child(node)
	node.set_owner(get_tree().get_edited_scene_root())


func _set_viewfinder(root: Node, editor: bool):
	pcam_host_group = root.get_tree().get_nodes_in_group(PcamGroupNames.PCAM_HOST_GROUP_NAME)
	if pcam_host_group.size() != 0:
		if pcam_host_group.size() == 1:
			var pcam_host: PhantomCameraHost = pcam_host_group[0]
			if is_2D:
				_selected_camera = pcam_host.camera_2D
				_active_pcam_camera = _selected_camera.get_child(0).get_active_pcam() as PhantomCamera2D
				if editor:
					var camera_2D_rid: RID = _selected_camera.get_canvas_item()
					# TODO - Missing 2D viewport support - https://github.com/ramokz/phantom-camera/issues/105 
					RenderingServer.viewport_attach_camera(sub_viewport.get_viewport_rid(), camera_2D_rid)
			else:
				_selected_camera = pcam_host.camera_3D
				_active_pcam_camera = _selected_camera.get_child(0).get_active_pcam() as PhantomCamera3D
				if editor:
					var camera_3D_rid: RID = _selected_camera.get_camera_rid()
					RenderingServer.viewport_attach_camera(sub_viewport.get_viewport_rid(), camera_3D_rid)

				if _selected_camera.keep_aspect == Camera3D.KeepAspect.KEEP_HEIGHT:
					aspect_ratio_containers.set_stretch_mode(AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH)
				else:
					aspect_ratio_containers.set_stretch_mode(AspectRatioContainer.STRETCH_WIDTH_CONTROLS_HEIGHT)

			_on_dead_zone_changed()
			set_process(true)

			if not pcam_host.update_editor_viewfinder.is_connected(_on_update_editor_viewfinder):
				pcam_host.update_editor_viewfinder.connect(_on_update_editor_viewfinder.bind(pcam_host))

			if not aspect_ratio_containers.resized.is_connected(_resized):
				aspect_ratio_containers.resized.connect(_resized)

			if not _active_pcam_camera.Properties.is_connected(_active_pcam_camera.Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed):
				_active_pcam_camera.Properties.connect(_active_pcam_camera.Constants.DEAD_ZONE_CHANGED_SIGNAL, _on_dead_zone_changed)

				#			aspect_ratio_container
				#			TODO - Might not be needed
				#			_active_pcam_camera.Properties.disconnect(_on_dead_zone_changed)
		else:
			for pcam_host in pcam_host_group:
				print(pcam_host, " is in a scene")


func _resized() -> void:
	_on_dead_zone_changed()


func _on_dead_zone_changed() -> void:
	if not is_instance_valid(_active_pcam_camera): return
	
	if camera_viewport_panel.size == Vector2.ZERO:
		has_camera_viewport_panel_size = false
		return
	else:
		has_camera_viewport_panel_size = true

	var dead_zone_width: float = _active_pcam_camera.Properties.follow_framed_dead_zone_width * camera_viewport_panel.size.x
	var dead_zone_height: float = _active_pcam_camera.Properties.follow_framed_dead_zone_height * camera_viewport_panel.size.y
	dead_zone_center_hbox.set_custom_minimum_size(Vector2(dead_zone_width, 0))
	dead_zone_center_center_panel.set_custom_minimum_size(Vector2(0, dead_zone_height))
	dead_zone_left_center_panel.set_custom_minimum_size(Vector2(0, dead_zone_height))
	dead_zone_right_center_panel.set_custom_minimum_size(Vector2(0, dead_zone_height))

	min_horizontal = 0.5 - _active_pcam_camera.Properties.follow_framed_dead_zone_width / 2
	max_horizontal = 0.5 + _active_pcam_camera.Properties.follow_framed_dead_zone_width / 2
	min_vertical = 0.5 - _active_pcam_camera.Properties.follow_framed_dead_zone_height / 2
	max_vertical = 0.5 + _active_pcam_camera.Properties.follow_framed_dead_zone_height / 2
	
#	target_point.position = Vector2(viewport_width / 2, viewport_height /  2)

####################
## Priority Override
####################
func _on_update_editor_viewfinder(pcam_host: PhantomCameraHost) -> void:
	if pcam_host.get_active_pcam().Properties.priority_override:
		_active_pcam_camera = pcam_host.get_active_pcam()
		_priority_override_button.set_visible(true)
		_priority_override_name_label.set_text(_active_pcam_camera.name)
		_priority_override_button.set_tooltip_text(_active_pcam_camera.name)
	else:
		_priority_override_button.set_visible(false)

func _select_override_pcam() -> void:
	editor_interface.get_selection().clear()
	editor_interface.get_selection().add_node(_active_pcam_camera)

#endregion


#region Public Functions

func scene_changed(scene_root: Node) -> void:
	if scene_root is Node2D:
#		print("Is 2D node")
		is_2D = true
		is_scene = true

		_add_node_button.set_visible(true)
#		var camera: Camera2D = scene_root.get_viewport().get_camera_2d()
		var camera: Camera2D = _get_camera_2D()

		_check_camera(scene_root, camera, true)
	elif scene_root is Node3D:
#		print("Is 3D node")
#		Is 3D scene
		is_2D = false
		is_scene = true

		_add_node_button.set_visible(true)
		var camera: Camera3D = scene_root.get_viewport().get_camera_3d()
		_check_camera(scene_root, camera, false)
	else:
#		print("Not a 2D or 3D scene")
		is_scene = false
#		Is not a 2D or 3D scene
		_set_empty_viewfinder_state(_no_open_scene_string, _no_open_scene_icon)
		_add_node_button.set_visible(false)

#endregion
