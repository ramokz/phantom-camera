@tool
extends Control

const PcamGroupNames = preload("res://addons/phantom_camera/scripts/group_names.gd")

var _selected_camera
var _active_pcam_camera

var dead_zone_center_hbox: VBoxContainer
var dead_zone_center_center_panel: Panel
var dead_zone_left_center_panel: Panel
var dead_zone_right_center_panel: Panel
var target_position: Panel

var viewport_width: float
var viewport_height: float

var aspect_ratio_container: AspectRatioContainer
var camera_viewport_panel: Panel

var editor_interface: EditorInterface

var sub_viewport: SubViewport

# Options to enable or disable 

var is_3D: bool
var is_scene: bool

func _ready():
#	connect("visibility_changed", _visible_check)
	connect("visibility_changed", _visibility_check)
#	get_viewport().set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)

#	await get_tree().physics_frame
#	editor_interface.get_edited_scene_root()5

	


func _visibility_check():
	var root: Node = editor_interface.get_edited_scene_root()
	
	if visible == false and not root:
		print("No host in scene")
		return
	
	# Phantom Camera Host
	var pcam_host_group: Array[Node] = root.get_tree().get_nodes_in_group(PcamGroupNames.PCAM_HOST_GROUP_NAME)
	
	# Dead Zone
	dead_zone_center_hbox = %DeadZoneCenterHBoxContainer
	dead_zone_center_center_panel = %DeadZoneCenterCenterPanel
	dead_zone_left_center_panel = %DeadZoneLeftCenterPanel
	dead_zone_right_center_panel = %DeadZoneRightCenterPanel
	target_position = %TargetPoint
	
	# Renders
	sub_viewport = %SubViewport
	aspect_ratio_container = %AspectRatioContainer
	camera_viewport_panel = aspect_ratio_container.get_child(0)
	
	viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	aspect_ratio_container.set_ratio(viewport_width / viewport_height)
	
	if root is Node3D:
#			print("Is a 3D scene")
		is_3D = true
		is_scene = true
	elif root is Node2D:
#			print("Is a 2D scene")
		is_3D = false
		is_scene = true
	else:
#			print("Is not a 2D or 3D scene")
		is_scene = false
	
	if pcam_host_group.size() != 0 and is_scene:
		if pcam_host_group.size() == 1:
			var pcam_host: PhantomCameraHost = pcam_host_group[0]
			
			if is_3D:
#					get_viewport().get_camera_3d()
				_selected_camera = pcam_host.camera as Camera3D
				var camera_3D_rid: RID = _selected_camera.get_camera_rid()
				RenderingServer.viewport_attach_camera(sub_viewport.get_viewport_rid(), camera_3D_rid)
#					print("Camera size is: ", root.get_viewport().)
				_active_pcam_camera = _selected_camera.get_child(0).get_active_pcam() as PhantomCamera3D
				
				if _selected_camera.keep_aspect == Camera3D.KeepAspect.KEEP_HEIGHT:
					aspect_ratio_container.set_stretch_mode(AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH)
				else:
					aspect_ratio_container.set_stretch_mode(AspectRatioContainer.STRETCH_WIDTH_CONTROLS_HEIGHT)
			else:
				_selected_camera = pcam_host.camera as Camera2D
				var camera_2D_rid: RID = _selected_camera.get_camera_rid()
				RenderingServer.viewport_attach_camera(sub_viewport.get_viewport_rid(), camera_2D_rid)
				_active_pcam_camera = _selected_camera.get_child(0).get_active_pcam() as PhantomCamera2D
				
			if not _active_pcam_camera.Properties.is_connected("dead_zone_changed", _on_dead_zone_changed):
				_active_pcam_camera.Properties.connect("dead_zone_changed", _on_dead_zone_changed)
			
#			aspect_ratio_container
#			TODO - Might not be needed
#			_active_pcam_camera.Properties.disconnect(_on_dead_zone_changed)
		else:
			for pcam_host in pcam_host_group:
				print(pcam_host, " is in a scene")
		
#		print(editor_interface.get_viewport())

func _process(delta):
#	print("Ratio is: ", aspect_ratio_container.get_ratio())
	pass

func _on_dead_zone_changed() -> void:
#	print("Deadzone Width : ", _active_pcam_camera.Properties.follow_framed_dead_zone_width)
#	print("Deadzone Height: ", _active_pcam_camera.Properties.follow_framed_dead_zone_height)
	
	var dead_zone_width: float = _active_pcam_camera.Properties.follow_framed_dead_zone_width * camera_viewport_panel.size.x
	var dead_zone_height: float = _active_pcam_camera.Properties.follow_framed_dead_zone_height * camera_viewport_panel.size.y
	
#	print(dead_zone_width)
#	print(camera_viewport_panel.size)
	
	dead_zone_center_hbox.set_custom_minimum_size(Vector2(dead_zone_width, 0))
	dead_zone_center_center_panel.set_custom_minimum_size(Vector2(0, dead_zone_height))
	dead_zone_left_center_panel.set_custom_minimum_size(Vector2(0, dead_zone_height))
	dead_zone_right_center_panel.set_custom_minimum_size(Vector2(0, dead_zone_height))
	
	var unprojected_position: Vector2 = _selected_camera.unproject_position(_active_pcam_camera.Properties.follow_target_node.position)
	
	target_position.position.y = unprojected_position.y
	target_position.position.x = unprojected_position.x
