extends CustomPluginGizmo

var _spatial_script: Script = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_3D.gd")
var _icon: Texture2D = preload("res://addons/phantom_camera/icons/PhantomCameraGizmoIcon.svg")


func _init() -> void:
	set_gizmo_name("PhantomCamera")
	set_gizmo_spatial_script(_spatial_script)
	set_gizmo_icon(_icon)
	super()
