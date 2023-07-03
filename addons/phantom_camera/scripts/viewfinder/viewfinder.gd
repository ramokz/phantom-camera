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

# Options to enable or disable

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
		$SubViewportContainer.set_visible(false)
		_set_viewfinder(root_node, false)

#	get_viewport().set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)

#	await get_tree().physics_frame
#	editor_interface.get_edited_scene_root()


func _visibility_check():
	var root: Node = editor_interface.get_edited_scene_root()
	
	if visible == false and not root:
		return

	if root is Node3D:
#		print("Is a 3D scene")
		is_3D = true
		is_scene = true
	elif root is Node2D:
#		print("Is a 2D scene")
		is_3D = false
		is_scene = true
	else:
#		print("Is not a 2D or 3D scene")
		is_scene = false

	_set_viewfinder(root, true)
	_on_dead_zone_changed()
	
	# Auto-selects the currently active PhantomCamera when opening panel
	editor_interface.get_selection().clear()
	editor_interface.get_selection().add_node(pcam_host_group[0].get_active_pcam())


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

			if not _active_pcam_camera.Properties.is_connected("dead_zone_changed", _on_dead_zone_changed):
				_active_pcam_camera.Properties.connect("dead_zone_changed", _on_dead_zone_changed)

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
