@tool
extends EditorNode3DGizmoPlugin

const PhantomCamera3DNode: Script = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_3d.gd")
const PhantomCamera3DGizmo: Script = preload("res://addons/phantom_camera/scripts/gizmos/phantom_camera_3d_gizmo.gd")
const _icon_texture: Texture2D = preload("res://addons/phantom_camera/icons/phantom_camera_gizmo.svg")
var _gizmo_name: String = "PhantomCamera3D"

var gizmo_name: String: set = set_gizmo_name
var _gizmo_icon: Texture2D
var _gizmo_spatial_script: Script = PhantomCamera3DNode


func set_gizmo_name(name: String) -> void:
	_gizmo_name = name


func _get_gizmo_name() -> String:
	return _gizmo_name


func _has_gizmo(spatial: Node3D) -> bool:
	return spatial is PhantomCamera3D


func _init() -> void:
	create_icon_material(gizmo_name, _icon_texture, false, Color.WHITE)
	create_material("frustum", Color8(252, 127, 127, 255))
	create_material("follow_target", Color8(185, 58, 89))
	create_material("look_at_target", Color8(61, 207, 225))


func _create_gizmo(for_node_3d: Node3D) -> EditorNode3DGizmo:
	if for_node_3d is PhantomCamera3DNode:
		return PhantomCamera3DGizmo.new()
	else:
		return null
