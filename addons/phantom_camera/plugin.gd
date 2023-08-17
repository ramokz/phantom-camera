@tool
extends EditorPlugin

const PCAM_HOST: String = "PhantomCameraHost"
const PCAM_2D: String = "PhantomCamera2D"
const PCAM_3D: String = "PhantomCamera3D"

const Pcam3DPlugin = preload("res://addons/phantom_camera/gizmos/phantom_camera_gizmo_plugin_3D.gd")
var pcam_3D_gizmo_plugin = Pcam3DPlugin.new()

const FramedViewPanel = preload("res://addons/phantom_camera/framed_viewfinder/framed_viewfinder_panel.tscn")
var framed_viewfinder_panel_instance


func _enter_tree() -> void:
	# Phantom Camera Nodes
	add_custom_type(PCAM_2D, "Node2D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_2D.gd"), preload("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg"))
	add_custom_type(PCAM_3D, "Node3D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_3D.gd"), preload("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg"))
	add_custom_type(PCAM_HOST, "Node", preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd"), preload("res://addons/phantom_camera/icons/PhantomCameraHostIcon.svg"))

	# Phantom Camera 3D Gizmo
	add_node_3d_gizmo_plugin(pcam_3D_gizmo_plugin)

	# Viewfinder
	framed_viewfinder_panel_instance = FramedViewPanel.instantiate()
	framed_viewfinder_panel_instance.editor_interface = get_editor_interface()
	add_control_to_bottom_panel(framed_viewfinder_panel_instance, "Phantom Camera")
	_make_visible(false)

	connect("scene_changed", _scene_changed)

func _exit_tree() -> void:
	remove_custom_type(PCAM_2D)
	remove_custom_type(PCAM_3D)

	remove_node_3d_gizmo_plugin(pcam_3D_gizmo_plugin)

	remove_control_from_bottom_panel(framed_viewfinder_panel_instance)
	framed_viewfinder_panel_instance.queue_free()
#	if framed_viewfinder_panel_instance:
	disconnect("scene_changed", _scene_changed)


#func _has_main_screen():
#	return true;


func _make_visible(visible):
	if framed_viewfinder_panel_instance:
		framed_viewfinder_panel_instance.set_visible(visible)

func _scene_changed(scene_root: Node) -> void:
#	print(scene_root)
	framed_viewfinder_panel_instance.scene_changed(scene_root)
