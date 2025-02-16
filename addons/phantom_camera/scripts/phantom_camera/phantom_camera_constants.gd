@tool
extends RefCounted

#region Constants

#const PhantomCameraHost: Script = preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")

const CAMERA_2D_NODE_NAME: StringName = "Camera2D"
const CAMERA_3D_NODE_NAME: StringName = "Camera3D"
const PCAM_HOST_NODE_NAME: StringName = "PhantomCameraHost"
const PCAM_MANAGER_NODE_NAME: String = "PhantomCameraManager" # TODO - Convert to StringName once https://github.com/godotengine/godot/pull/72702 is merged
const PCAM_2D_NODE_NAME: StringName = "PhantomCamera2D"
const PCAM_3D_NODE_NAME: StringName = "PhantomCamera3D"
const PCAM_HOST: StringName = "phantom_camera_host"

const COLOR_2D: Color = Color("8DA5F3")
const COLOR_3D: Color = Color("FC7F7F")
const COLOR_PCAM: Color = Color("3AB99A")
const COLOR_PCAM_33: Color = Color("3ab99a33")
const PCAM_HOST_COLOR: Color = Color("E0E0E0")

#endregion

#region Group Names

const PCAM_GROUP_NAME: StringName = "phantom_camera_group"
const PCAM_HOST_GROUP_NAME: StringName = "phantom_camera_host_group"

#endregion

#region Misc

static func get_ui_scale() -> float:
	var editor_setting: EditorSettings = EditorInterface.get_editor_settings()
	var display_scale: int = editor_setting.get_setting("interface/editor/display_scale")
	match display_scale:
		0: # Auto
			var screen: int = DisplayServer.window_get_current_screen()
			if DisplayServer.screen_get_dpi(screen) >= 192 && DisplayServer.screen_get_size(screen).x > 2000:
				return 2.0
			else:
				return 1.0
		7: # Custom
			return editor_setting.get_setting("interface/editor/custom_display_scale")
		_: # 0 = Auto, 1 = 75%, 2 = 100%, 3 = 125%, 4 = 150%, 5 = 175%, 6 = 200%,
			return (display_scale + 2) * 0.25

#endregion
