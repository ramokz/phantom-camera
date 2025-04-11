extends EditorNode3DGizmoPlugin

var _spatial_script: Script = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_noise_emitter_3d.gd")
var _gizmo_icon: Texture2D = preload("res://addons/phantom_camera/icons/phantom_camera_noise_emitter_gizmo.svg")

var _gizmo_name: StringName = "PhantomCameraNoiseEmitter"

func _init() -> void:
	create_material("main", Color8(252, 127, 127, 255))
	create_handle_material("handles")
	create_icon_material(_gizmo_name, _gizmo_icon, false, Color.WHITE)


func _has_gizmo(node: Node3D):
	return node.get_script() == _spatial_script


func _get_gizmo_name() -> String:
	return _gizmo_name


func _redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()

	var icon: Material = get_material(_gizmo_name, gizmo)
	gizmo.add_unscaled_billboard(icon, 0.035)

	#var material = get_material("main", gizmo)
	#gizmo.add_lines(_draw_frustum(), material)
