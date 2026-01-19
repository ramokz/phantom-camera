@tool
extends EditorPlugin

#region Constants

const PCAM_HOST: String = "PhantomCameraHost"
const PCAM_2D: String = "PhantomCamera2D"
const PCAM_3D: String = "PhantomCamera3D"
const PCAM_NOISE_EMITTER_2D: String = "PhantomCameraNoiseEmitter2D"
const PCAM_NOISE_EMITTER_3D: String = "PhantomCameraNoiseEmitter3D"
const PCAM_TWEEN_DIRECTOR: String = "PhantomCameraTweenDirector"

const PCam3DPlugin: Script = preload("res://addons/phantom_camera/scripts/gizmos/phantom_camera_3d_gizmo_plugin.gd")
const PCam3DNoiseEmitterPlugin: Script = preload("res://addons/phantom_camera/scripts/gizmos/phantom_camera_noise_emitter_gizmo_plugin_3d.gd")
const EditorPanel: PackedScene = preload("res://addons/phantom_camera/panel/editor.tscn")
const updater_constants: Script = preload("res://addons/phantom_camera/scripts/panel/updater/updater_constants.gd")
const PHANTOM_CAMERA_MANAGER: StringName = "PhantomCameraManager"

#endregion

#region Private Variables

var _settings_show_jitter_tips: String = "phantom_camera/tips/show_jitter_tips"
var _settings_enable_editor_shortcut: String = "phantom_camera/general/enable_editor_shortcut"
var _settings_editor_shortcut: String = "phantom_camera/general/editor_shortcut"

# 	TODO - Pending merge of https://github.com/godotengine/godot/pull/102889 - Should only support Godot version after the release that is featured in
#var _editor_shortcut: Shortcut = Shortcut.new()
#var _editor_shortcut_input: InputEventKey
#endregion

#region Public Variables

var pcam_3d_gizmo_plugin = PCam3DPlugin.new()
var pcam_3d_noise_emitter_gizmo_plugin = PCam3DNoiseEmitterPlugin.new()

var editor_panel_instance: Control
var panel_button: Button
#var viewfinder_panel_instance


#endregion

#region Private Functions

func _enable_plugin() -> void:
	print_rich("Phantom Camera documentation can be found at: [url=https://phantom-camera.dev]https://phantom-camera.dev[/url]")
	if not Engine.has_singleton(PHANTOM_CAMERA_MANAGER):
		add_autoload_singleton(PHANTOM_CAMERA_MANAGER, "res://addons/phantom_camera/scripts/managers/phantom_camera_manager.gd")


func _disable_plugin() -> void:
	if Engine.has_singleton(PHANTOM_CAMERA_MANAGER):
		remove_autoload_singleton(PHANTOM_CAMERA_MANAGER)


func _enter_tree() -> void:
	add_autoload_singleton(PHANTOM_CAMERA_MANAGER, "res://addons/phantom_camera/scripts/managers/phantom_camera_manager.gd")

	# Phantom Camera Nodes
	add_custom_type(PCAM_2D, "Node2D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_2d.gd"), preload("res://addons/phantom_camera/icons/phantom_camera_2d.svg"))
	add_custom_type(PCAM_3D, "Node3D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_3d.gd"), preload("res://addons/phantom_camera/icons/phantom_camera_2d.svg"))
	add_custom_type(PCAM_HOST, "Node", preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd"), preload("res://addons/phantom_camera/icons/phantom_camera_2d.svg"))
	add_custom_type(PCAM_NOISE_EMITTER_2D, "Node2D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_noise_emitter_2d.gd"),  preload("res://addons/phantom_camera/icons/phantom_camera_noise_emitter_2d.svg"))
	add_custom_type(PCAM_NOISE_EMITTER_3D, "Node3D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_noise_emitter_3d.gd"),  preload("res://addons/phantom_camera/icons/phantom_camera_noise_emitter_3d.svg"))
	add_custom_type(PCAM_TWEEN_DIRECTOR, "Node", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_tween_director.gd"),  preload("res://addons/phantom_camera/icons/phantom_camera_tween_director.svg"))

	# Phantom Camera 3D Gizmo
	add_node_3d_gizmo_plugin(pcam_3d_gizmo_plugin)
	add_node_3d_gizmo_plugin(pcam_3d_noise_emitter_gizmo_plugin)

	var setting_updater_mode: String
	var setting_updater_mode_default: int
	if FileAccess.file_exists("res://dev_scenes/3d/dev_scene_3d.tscn"): # For forks
		setting_updater_mode = "Off, Console Output"
		setting_updater_mode_default = 1
	else: # For end-users
		setting_updater_mode = "Off, Console Output, Updater Window"
		setting_updater_mode_default = 2

	if not ProjectSettings.has_setting(updater_constants.setting_updater_mode):
		ProjectSettings.set_setting(updater_constants.setting_updater_mode, setting_updater_mode_default)
	ProjectSettings.add_property_info({
		"name": updater_constants.setting_updater_mode,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": setting_updater_mode,
	})
	ProjectSettings.set_initial_value(updater_constants.setting_updater_mode, setting_updater_mode_default)
	ProjectSettings.set_as_basic(updater_constants.setting_updater_mode, true)


	## Setting for enabling / disabling Jitter tips in the Output
	if not ProjectSettings.has_setting(_settings_show_jitter_tips):
		ProjectSettings.set_setting(_settings_show_jitter_tips, true)
	ProjectSettings.add_property_info({
		"name": _settings_show_jitter_tips,
		"type": TYPE_BOOL,
	})
	ProjectSettings.set_initial_value(_settings_show_jitter_tips, true)
	ProjectSettings.set_as_basic(_settings_show_jitter_tips, true)


# 	TODO - Pending merge of https://github.com/godotengine/godot/pull/102889 - Should only support Godot version after this release
#	if not ProjectSettings.has_setting(_settings_enable_editor_shortcut):
#		ProjectSettings.set_setting(_settings_enable_editor_shortcut, false)
#	ProjectSettings.set_initial_value(_settings_enable_editor_shortcut, false)

# 	TODO - Pending merge of https://github.com/godotengine/godot/pull/102889 - Should only support Godot version after this release
#	_viewfinder_shortcut_default.events = [editor_shortcut]
#	if ProjectSettings.get_setting(_settings_enable_editor_shortcut):
#	if not ProjectSettings.has_setting(_settings_editor_shortcut):
#		ProjectSettings.set_setting(_settings_editor_shortcut, _editor_shortcut)
#	ProjectSettings.set_initial_value(_settings_editor_shortcut, _editor_shortcut)


	# TODO - Should be disabled unless in editor
	# Viewfinder
	editor_panel_instance = EditorPanel.instantiate()
	editor_panel_instance.editor_plugin = self
	panel_button = add_control_to_bottom_panel(editor_panel_instance, "Phantom Camera")
	panel_button.toggled.connect(_btn_toggled)
	if panel_button.toggle_mode: _btn_toggled(true)

	scene_changed.connect(editor_panel_instance.viewfinder.scene_changed)
	scene_changed.connect(_scene_changed)


func _exit_tree() -> void:
	panel_button.toggled.disconnect(_btn_toggled)
	scene_changed.disconnect(editor_panel_instance.viewfinder.scene_changed)
	scene_changed.disconnect(_scene_changed)

	remove_control_from_bottom_panel(editor_panel_instance)
	editor_panel_instance.queue_free()

	remove_node_3d_gizmo_plugin(pcam_3d_gizmo_plugin)
	remove_node_3d_gizmo_plugin(pcam_3d_noise_emitter_gizmo_plugin)

	remove_custom_type(PCAM_2D)
	remove_custom_type(PCAM_3D)
	remove_custom_type(PCAM_HOST)
	remove_custom_type(PCAM_NOISE_EMITTER_2D)
	remove_custom_type(PCAM_NOISE_EMITTER_3D)
	remove_custom_type(PCAM_TWEEN_DIRECTOR)

	remove_autoload_singleton(PHANTOM_CAMERA_MANAGER)
#	if get_tree().root.get_node_or_null(String(PHANTOM_CAMERA_MANAGER)):
#		remove_autoload_singleton(PHANTOM_CAMERA_MANAGER)


func _btn_toggled(toggled_on: bool):
	editor_panel_instance.viewfinder.set_visibility(toggled_on)
#	if toggled_on:
#		editor_panel_instance.viewfinder.viewfinder_visible = true
#		editor_panel_instance.viewfinder.visibility_check()
#	else:
#		editor_panel_instance.viewfinder.viewfinder_visible = false

func _make_visible(visible):
	if editor_panel_instance:
		editor_panel_instance.set_visible(visible)

## TODO - Signal can be added directly to the editor_panel with the changes in Godot 4.5 (https://github.com/godotengine/godot/pull/102986)
func _scene_changed(scene_root: Node) -> void:
	editor_panel_instance.viewfinder.scene_changed(scene_root)

#	TODO - Pending merge of https://github.com/godotengine/godot/pull/102889 - Should only support Godot version after this release
#func _set_editor_shortcut() -> InputEventKey:
#	var shortcut: InputEventKey = InputEventKey.new()
#	shortcut.keycode = 67 # Key =  C
#	shortcut.alt_pressed = true
#	return shortcut

#endregion


#region Public Functions

func get_version() -> String:
	var config: ConfigFile = ConfigFile.new()
	config.load(get_script().resource_path.get_base_dir() + "/plugin.cfg")
	return config.get_value("plugin", "version")

#endregion
