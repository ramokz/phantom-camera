@tool
extends EditorPlugin

const PHANTOM_CAMERA_HOST: String = "PhantomCameraHost"
const PHANTOM_CAMERA_2D: String = "PhantomCamera2D"
const PHANTOM_CAMERA_3D: String = "PhantomCamera3D"

const PhantomCamera2DPlugin = preload("res://addons/phantom_camera/gizmos/phantom_camera_gizmo_plugin_2D.gd")
const PhantomCamera3DPlugin = preload("res://addons/phantom_camera/gizmos/phantom_camera_gizmo_plugin_3D.gd")
var phantom_camera_2D_gizmo_plugin = PhantomCamera2DPlugin.new()
var phantom_camera_3D_gizmo_plugin = PhantomCamera3DPlugin.new()

var phantom_camera_inspector_plugin

# Dock
var dock: Control

func _enter_tree() -> void:

	add_custom_type(PHANTOM_CAMERA_2D, "Node2D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_2D.gd"), preload("res://addons/phantom_camera/icons/PhantomCameraIcon2D.svg"))
	add_custom_type(PHANTOM_CAMERA_3D, "Node3D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_3D.gd"), preload("res://addons/phantom_camera/icons/PhantomCameraIcon3D.svg"))

	add_custom_type(PHANTOM_CAMERA_HOST, "Node", preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd"), preload("res://addons/phantom_camera/icons/PhantomBaseIcon.svg"))

	add_node_3d_gizmo_plugin(phantom_camera_2D_gizmo_plugin)
	add_node_3d_gizmo_plugin(phantom_camera_3D_gizmo_plugin)

#	phantom_camera_inspector_plugin = preload("res://addons/phantom_camera/inspector/phantom_camera_inspector_plugin.gd")
#	phantom_camera_inspector_plugin = phantom_camera_inspector_plugin.new()
#	add_inspector_plugin(phantom_camera_inspector_plugin)

#	TODO - Future Update
#	dock = preload("res://addons/phantom_camera/editor/phantom_camera_editor.tscn").instantiate()
#	add_control_to_bottom_panel(dock, "Phantom Camera Editor")
#	dock.editor_interface = get_editor_interface()


func _exit_tree() -> void:
	remove_custom_type(PHANTOM_CAMERA_2D)
	remove_custom_type(PHANTOM_CAMERA_3D)

	remove_node_3d_gizmo_plugin(phantom_camera_2D_gizmo_plugin)
	remove_node_3d_gizmo_plugin(phantom_camera_3D_gizmo_plugin)

	# Inspector
	remove_inspector_plugin(phantom_camera_inspector_plugin)

#	TODO - Future Update
	# Dock
#	remove_control_from_bottom_panel(dock)
#	dock.free()
