extends EditorNode3DGizmoPlugin
class_name CustomPluginGizmo

var _gizmo_name
var gizmo_name: String: set = set_gizmo_name

var _gizmo_icon: Texture2D
var gizmo_icon: Texture2D: set = set_gizmo_icon

var _gizmo_spatial_script: Script
var gizmo_spatial_script: Script: set = set_gizmo_spatial_script

var _gizmo_scale: float = 0.035


func set_gizmo_name(name: String) -> void:
	_gizmo_name = name


func set_gizmo_icon(icon: Texture2D) -> void:
	_gizmo_icon = icon


func set_gizmo_spatial_script(script: Script) -> void:
	_gizmo_spatial_script = script


func _get_gizmo_name() -> String:
	return _gizmo_name

func _has_gizmo(spatial: Node3D):
	return spatial.get_script() == _gizmo_spatial_script


func _init() -> void:
	create_icon_material(_gizmo_name, _gizmo_icon, false, Color.WHITE)
	create_material("main", Color8(252, 127, 127, 255))


func _draw_frustum() -> PackedVector3Array:
	var lines = PackedVector3Array()
	
	var dis: float 		= 0.25
	var width: float 	= dis * 1.25
	var len: float 		= dis * 1.5

	# Straight line
#	lines.push_back(Vector3(0, 0, 0))
#	lines.push_back(Vector3(0, 0, -len))


	# Trapezoid
	lines.push_back(Vector3(0, 0, 0))
	lines.push_back(Vector3(-width, dis, -len))
	
	lines.push_back(Vector3(0, 0, 0))
	lines.push_back(Vector3(width, dis, -len))
	
	lines.push_back(Vector3(0, 0, 0))
	lines.push_back(Vector3(-width, -dis, -len))
	
	lines.push_back(Vector3(0, 0, 0))
	lines.push_back(Vector3(width, -dis, -len))
	
	
	# Square
	## Left
	lines.push_back(Vector3(-width, dis, -len))
	lines.push_back(Vector3(-width, -dis, -len))
	
	## Bottom
	lines.push_back(Vector3(-width, -dis, -len))
	lines.push_back(Vector3(width, -dis, -len))
	
	## Right
	lines.push_back(Vector3(width, -dis, -len))
	lines.push_back(Vector3(width, dis, -len))
	
	## Top
	lines.push_back(Vector3(width, dis, -len))
	lines.push_back(Vector3(-width, dis, -len))
	
	return lines


func _redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()

	var icon: Material = get_material(_gizmo_name, gizmo)
	gizmo.add_unscaled_billboard(icon, _gizmo_scale)
	
	var material = get_material("main", gizmo)
	gizmo.add_lines(_draw_frustum(), material)
