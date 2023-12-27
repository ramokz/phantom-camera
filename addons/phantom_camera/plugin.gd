@tool
extends EditorPlugin

#region Constants

const PCAM_HOST: String = "PhantomCameraHost"
const PCAM_2D: String = "PhantomCamera2D"
const PCAM_3D: String = "PhantomCamera3D"

const Pcam3DPlugin = preload("res://addons/phantom_camera/gizmos/phantom_camera_gizmo_plugin_3D.gd")

const EditorPanel = preload("res://addons/phantom_camera/panel/editor.tscn")

#endregion


#region Variables

var pcam_3D_gizmo_plugin = Pcam3DPlugin.new()

var editor_panel_instance
#var viewfinder_panel_instance

#endregion


#region Private Functions

func _enter_tree() -> void:
	# Phantom Camera Nodes
	add_custom_type(PCAM_2D, "Node2D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_2D.gd"), preload("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg"))
	add_custom_type(PCAM_3D, "Node3D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_3D.gd"), preload("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg"))
	add_custom_type(PCAM_HOST, "Node", preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd"), preload("res://addons/phantom_camera/icons/PhantomCameraHostIcon.svg"))

	# Phantom Camera 3D Gizmo
	add_node_3d_gizmo_plugin(pcam_3D_gizmo_plugin)

	# Viewfinder
	editor_panel_instance = EditorPanel.instantiate()
	editor_panel_instance.editor_interface = get_editor_interface()
	editor_panel_instance.editor_plugin = self
	add_control_to_bottom_panel(editor_panel_instance, "Phantom Camera")
	_make_visible(false)

	connect("scene_changed", _scene_changed)


func _exit_tree() -> void:
	remove_custom_type(PCAM_2D)
	remove_custom_type(PCAM_3D)
	remove_custom_type(PCAM_HOST)

	remove_node_3d_gizmo_plugin(pcam_3D_gizmo_plugin)

	remove_control_from_bottom_panel(editor_panel_instance)
	editor_panel_instance.queue_free()
#	if framed_viewfinder_panel_instance:
	disconnect("scene_changed", _scene_changed)


#func _has_main_screen():
#	return true;


func _make_visible(visible):
	if editor_panel_instance:
		editor_panel_instance.set_visible(visible)


func _scene_changed(scene_root: Node) -> void:
	editor_panel_instance.viewfinder.scene_changed(scene_root)

#endregion


#region Public Functions

func get_version() -> String:
	var config: ConfigFile = ConfigFile.new()
	config.load(get_script().resource_path.get_base_dir() + "/plugin.cfg")
	return config.get_value("plugin", "version")

#endregion
