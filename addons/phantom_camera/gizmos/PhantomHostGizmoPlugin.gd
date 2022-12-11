extends CustomPluginGizmo

var _spatial_script: Script = preload("res://addons/phantom_camera/scripts/phantom_camera_host_3D.gd")
var _icon: Texture2D = preload("res://addons/phantom_camera/icons/PhantomBaseGizmoIcon.svg")


func _init() -> void:
	set_gizmo_name("PhantomBase")
	set_gizmo_spatial_script(_spatial_script)
	set_gizmo_icon(_icon)
	super()
