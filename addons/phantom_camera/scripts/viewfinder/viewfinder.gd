@tool
extends Control

const PcamGroupNames = preload("res://addons/phantom_camera/scripts/group_names.gd")

var _selected_camera
var _active_pcam_camera
var pcam_host_group: Array[Node]

@onready var dead_zone_center_hbox: VBoxContainer = %DeadZoneCenterHBoxContainer
@onready var dead_zone_center_center_panel: Panel = %DeadZoneCenterCenterPanel
@onready var dead_zone_left_center_panel: Panel = %DeadZoneLeftCenterPanel
@onready var dead_zone_right_center_panel: Panel = %DeadZoneRightCenterPanel
@onready var target_point: Panel = %TargetPoint

var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

var aspect_ratio_container: AspectRatioContainer
@onready var aspect_ratio_containers: AspectRatioContainer = %AspectRatioContainer
@onready var camera_viewport_panel: Panel = aspect_ratio_containers.get_child(0)

var editor_interface: EditorInterface

@onready var sub_viewport: SubViewport = %SubViewport

########################
# Viewfinder Empty State
########################
@onready var _empty_state_control: Control = %EmptyStateControl
@onready var _empty_state_icon: Control = %EmptyStateIcon
@onready var _empty_state_text: RichTextLabel = %EmptyStateText
@onready var _overlay_color_rect: ColorRect = %OverlayColorRect
@onready var _add_node_button: Button = %AddNodeButton
var _overlay_color_alpha: float = 0.3

var _no_open_scene_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/SceneTypesIcon.svg")
var _no_open_scene_string: String = "No [b]2D[/b] or [b]3D[/b] scene open"
var _no_open_scene_color: Color = Color("3AB99A", 1)

var _no_camera_2d_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/Camera2DIcon.svg")
var _no_camera_2D_string: String = "No [b]Camera2D[/b] in scene"
var _no_2D_color: Color = Color("8DA5F3", _overlay_color_alpha)

var _no_camera_3d_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/viewfinder/Camera3DIcon.svg")
var _no_camera_3D_string: String = "No [b]Camera3D[/b] in scene"
var _no_3D_color: Color = Color("FC7F7F", _overlay_color_alpha)

var _no_pcam_host_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/PhantomCameraHostIcon.svg")
var _no_pcam_host_string: String = "No [b]PhantomCameraHost[/b] in scene"
var _no_pcam_host_color: Color = Color("E0E0E0", _overlay_color_alpha)
var _no_pcam_2D_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/PhantomCameraGizmoIcon2D.svg")
var _no_pcam_2D_string: String = "No [b]PhantomCamera2D[/b] in scene"

var _no_pcam_3D_icon: CompressedTexture2D = preload("res://addons/phantom_camera/icons/PhantomCameraGizmoIcon3D.svg")
var _no_pcam_3D_string: String = "No [b]PhantomCamera3D[/b] in scene"



var is_3D: bool
var is_scene: bool

var has_camera_viewport_panel_size: bool = true

var min_horizontal: float
var max_horizontal: float
var min_vertical: float
var max_vertical: float

func _ready():
	connect("visibility_changed", _visibility_check)
	set_process(false)

#	viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
#	viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	aspect_ratio_containers.set_ratio(viewport_width / viewport_height)

	var root_node = get_tree().get_root().get_child(0)

	if root_node is Node3D:
		is_3D = true
	elif root_node is Node2D:
		is_3D = false

	if root_node is Node3D || root_node is Node2D:
		%SubViewportContainer.set_visible(false)
		_set_viewfinder(root_node, false)
	
	if Engine.is_editor_hint():
		get_tree().connect("node_added", _node_added)
	
#	get_viewport().set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)

#	await get_tree().physics_frame
#	editor_interface.get_edited_scene_root()


func _node_added(node: Node) -> void:
#	print("Editor interface is: ", editor_interface)
#	print("Node added is: ", node)
#	pass
	if editor_interface == null: return
	var root: Node = editor_interface.get_edited_scene_root()
	if root == null: return
	_visibility_check()


func _visibility_check():
	if not editor_interface: return
	
	var root: Node = editor_interface.get_edited_scene_root()
	
	if not visible and not root:
		return

	if root is Node2D:
#		print("Is a 2D scene")
		is_3D = false
		is_scene = true
	elif root is Node3D:
#		print("Is a 3D scene")
		is_3D = true
		is_scene = true
	else:
#		print("Is not a 2D or 3D scene")
		is_scene = false
	
	if not is_scene:
#		Is not a 2D or 3D scene
#		print("Is not a scene")
		_set_empty_viewfinder_state(_no_open_scene_string, _no_open_scene_icon, _no_open_scene_color)
	elif not is_3D:
		print("Is 2D scene")
		print(root.get_viewport())
		var camera_2D: Camera2D = root.get_viewport().get_camera_2d()
		print(camera_2D)
		if camera_2D:
			_check_camera(root, camera_2D, _no_pcam_2D_string, _no_pcam_2D_icon, _no_2D_color)
		else:
#			Has Camera2D
			_set_empty_viewfinder_state(_no_camera_2D_string, _no_camera_2d_icon, _no_2D_color)
#		if camera_2D:
##			Has Camera3D
##			print("Has Camera3D")
#			var pcam_host: PhantomCameraHost
#			if camera_2D.get_children().size() > 0:
#				for cam_child in camera_2D.get_children():
#					if cam_child is PhantomCameraHost:
#						pcam_host = cam_child
#
#					if pcam_host:
##						print("Has pcam host")
#						if get_tree().get_nodes_in_group(PcamGroupNames.PCAM_GROUP_NAME):
##							Pcam exists in tree
##							print("PCam in scene exists")
#							_set_viewfinder_state()
#							_set_viewfinder(root, true)
##							if pcam_host.get_active_pcam().get_get_follow_mode():
##								_on_dead_zone_changed()
#						else:
#	#						No PCam3D in scene
#							_set_empty_viewfinder_state(_no_pcam_3D_string, _no_pcam_3D_icon, _no_3D_color)
#					else:
##						No PCamHost in scene
#						_set_empty_viewfinder_state(_no_pcam_host_string, _no_pcam_host_icon, _no_pcam_host_color)
#			else:
##				No PCamHost in scene
#				_set_empty_viewfinder_state(_no_pcam_host_string, _no_pcam_host_icon, _no_pcam_host_color)
#
#		else:
##			Has Camera2D
##			print("No Camera2D")
#			_set_empty_viewfinder_state(_no_camera_2D_string, _no_camera_2d_icon, _no_2D_color)
	else:
#		Is 3D scene
#		print("Is 3D scene")
		var camera_3D: Camera3D = root.get_viewport().get_camera_3d()
		if camera_3D:
#			Has Camera3D
#			print("Has Camera3D")
			var pcam_host: PhantomCameraHost
			if camera_3D.get_children().size() > 0:
				for cam_child in camera_3D.get_children():
					if cam_child is PhantomCameraHost:
						pcam_host = cam_child
					
					if pcam_host:
#						print("Has pcam host")
						if get_tree().get_nodes_in_group(PcamGroupNames.PCAM_GROUP_NAME):
#							Pcam exists in tree
#							print("PCam in scene exists")
							_set_viewfinder_state()
							_set_viewfinder(root, true)
#							if pcam_host.get_active_pcam().get_get_follow_mode():
#								_on_dead_zone_changed()
						else:
	#						No PCam3D in scene
							_set_empty_viewfinder_state(_no_pcam_3D_string, _no_pcam_3D_icon, _no_3D_color)
					else:
#						No PCamHost in scene
						_set_empty_viewfinder_state(_no_pcam_host_string, _no_pcam_host_icon, _no_pcam_host_color)
			else:
#				No PCamHost in scene
				_set_empty_viewfinder_state(_no_pcam_host_string, _no_pcam_host_icon, _no_pcam_host_color)
			
		else:
#			No Camera3D
#			print("No Camera3D")
			_set_empty_viewfinder_state(_no_camera_3D_string, _no_camera_3d_icon, _no_3D_color)
	
#	_set_viewfinder(root, true)
#	_on_dead_zone_changed()
	
#	if visible:
#		# Auto-selects the currently active PhantomCamera when opening panel
#		editor_interface.get_selection().clear()
#		editor_interface.get_selection().add_node(pcam_host_group[0].get_active_pcam())

func _check_camera(root: Node, camera: Node, no_pcam_string: String, no_pcam_icon: CompressedTexture2D, no_pcam_color: Color) -> void:
#	Has Camera3D
	var pcam_host: PhantomCameraHost
	if camera.get_children().size() > 0:
		for cam_child in camera.get_children():
			if cam_child is PhantomCameraHost:
				pcam_host = cam_child
			
			if pcam_host:
				if get_tree().get_nodes_in_group(PcamGroupNames.PCAM_GROUP_NAME):
#					Pcam exists in tree
					_set_viewfinder_state()
					_set_viewfinder(root, true)
				else:
#					No PCam3D in scene
					_set_empty_viewfinder_state(no_pcam_string, no_pcam_icon, no_pcam_color)
			else:
#				No PCamHost in scene
				_set_empty_viewfinder_state(_no_pcam_host_string, _no_pcam_host_icon, _no_pcam_host_color)
	else:
#		No PCamHost in scene
		_set_empty_viewfinder_state(_no_pcam_host_string, _no_pcam_host_icon, _no_pcam_host_color)

func _set_viewfinder_state() -> void:
	_empty_state_control.set_visible(false)
	
	if visible:
		# Auto-selects the currently active PhantomCamera when opening panel
		editor_interface.get_selection().clear()
		editor_interface.get_selection().add_node(pcam_host_group[0].get_active_pcam())


func _set_empty_viewfinder_state(text: String, icon: CompressedTexture2D, color: Color) -> void:
	_empty_state_control.set_visible(true)
	
	_empty_state_icon.texture = icon
	_empty_state_text.text = "[center]" + text + "[/center]"
	
	_overlay_color_rect.color = color
	
	if _add_node_button.is_connected("pressed", _add_node):
		_add_node_button.disconnect("pressed", _add_node)
	
	_add_node_button.connect("pressed", Callable(_add_node).bind(text))


func _add_node(node_type: String) -> void:
	if not editor_interface: return
	
#	print("Adding node ", node_type)
	var root: Node = editor_interface.get_edited_scene_root()
#	print(get_tree())
	
	match node_type:
		_no_open_scene_string:
			print("Not a scene")
		_no_camera_2D_string:
			var cam_2D := Camera2D.new()
			_instantiate_node(root, cam_2D, "Camera2D")
		_no_camera_3D_string:
			print("No Cam 3D")
			var cam_3D := Camera3D.new()
			_instantiate_node(root, cam_3D, "Camera3D")
#			cam_3D.set_name("Camera3D")
#			root.add_child(cam_3D)
#			cam_3D.set_owner(root)
		_no_pcam_host_string:
			var pcam_host := PhantomCameraHost.new()
			pcam_host.set_name("PhantomCameraHost")
			if not is_3D:
				get_tree().get_edited_scene_root().get_viewport().get_camera_2d().add_child(pcam_host)
				pcam_host.set_owner(get_tree().get_edited_scene_root())
			else:
#				var pcam_3D := get_tree().get_edited_scene_root().get_viewport().get_camera_3d()
				get_tree().get_edited_scene_root().get_viewport().get_camera_3d().add_child(pcam_host)
				pcam_host.set_owner(get_tree().get_edited_scene_root())
		_no_pcam_2D_string:
			var pcam_2D := PhantomCamera2D.new()
			_instantiate_node(root, pcam_2D, "PhantomCameraHost")
		_no_pcam_3D_string:
			var pcam_3D := PhantomCamera3D.new()
			_instantiate_node(root, pcam_3D, "PhantomCameraHost")


func _instantiate_node(root: Node, node: Node, name: String) -> void:
	node.set_name(name)
	root.add_child(node)
	node.set_owner(get_tree().get_edited_scene_root())


func _set_viewfinder(root: Node, editor: bool):
	pcam_host_group = root.get_tree().get_nodes_in_group(PcamGroupNames.PCAM_HOST_GROUP_NAME)
	if pcam_host_group.size() != 0:
		if pcam_host_group.size() == 1:
			var pcam_host: PhantomCameraHost = pcam_host_group[0]
			if is_3D:
				_selected_camera = pcam_host.camera as Camera3D
				_active_pcam_camera = _selected_camera.get_child(0).get_active_pcam() as PhantomCamera3D
				if editor:
					var camera_3D_rid: RID = _selected_camera.get_camera_rid()
					RenderingServer.viewport_attach_camera(sub_viewport.get_viewport_rid(), camera_3D_rid)

				if _selected_camera.keep_aspect == Camera3D.KeepAspect.KEEP_HEIGHT:
					aspect_ratio_containers.set_stretch_mode(AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH)
				else:
					aspect_ratio_containers.set_stretch_mode(AspectRatioContainer.STRETCH_WIDTH_CONTROLS_HEIGHT)
			else:
				_selected_camera = pcam_host.camera as Camera2D
				_active_pcam_camera = _selected_camera.get_child(0).get_active_pcam() as PhantomCamera2D
				if editor:
					var camera_2D_rid: RID = _selected_camera.get_camera_rid()
					RenderingServer.viewport_attach_camera(sub_viewport.get_viewport_rid(), camera_2D_rid)


			_on_dead_zone_changed()
			set_process(true)

			if not aspect_ratio_containers.is_connected("resized", _resized):
				aspect_ratio_containers.connect("resized", _resized)

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


func _process(_delta: float):
	if visible:
		var unprojected_position_clamped: Vector2 = Vector2(
			clamp(_active_pcam_camera.Properties.unprojected_position.x, min_horizontal, max_horizontal),
			clamp(_active_pcam_camera.Properties.unprojected_position.y, min_vertical, max_vertical)
		)
		
		target_point.position = camera_viewport_panel.size * unprojected_position_clamped - target_point.size / 2

		if not has_camera_viewport_panel_size:
			_on_dead_zone_changed()


func _on_dead_zone_changed() -> void:
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
