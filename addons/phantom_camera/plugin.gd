@tool
extends EditorPlugin

#region Constants

const PCAM_HOST: String = "PhantomCameraHost"
const PCAM_2D: String = "PhantomCamera2D"
const PCAM_3D: String = "PhantomCamera3D"
const PCAM_NOISE_EMITTER_2D: String = "PhantomCameraNoiseEmitter2D"
const PCAM_NOISE_EMITTER_3D: String = "PhantomCameraNoiseEmitter3D"

const PCam3DPlugin: Script = preload("res://addons/phantom_camera/gizmos/phantom_camera_gizmo_plugin_3d.gd")
const PCam3DNoiseEmitterPlugin: Script = preload("res://addons/phantom_camera/gizmos/phantom_camera_noise_emitter_gizmo_plugin_3d.gd")
const EditorPanel: PackedScene = preload("res://addons/phantom_camera/panel/editor.tscn")
const updater_constants: Script = preload("res://addons/phantom_camera/scripts/panel/updater/updater_constants.gd")
const PHANTOM_CAMERA_MANAGER: StringName = "PhantomCameraManager"

#endregion


#region Variables

var pcam_3d_gizmo_plugin = PCam3DPlugin.new()
var pcam_3d_noise_emitter_gizmo_plugin = PCam3DNoiseEmitterPlugin.new()

var editor_panel_instance: Control
var panel_button: Button
#var viewfinder_panel_instance

#endregion


#region Private Functions

func _enter_tree() -> void:
	if not get_tree().root.get_node_or_null(String(PHANTOM_CAMERA_MANAGER)):
		add_autoload_singleton(PHANTOM_CAMERA_MANAGER, "res://addons/phantom_camera/scripts/managers/phantom_camera_manager.gd")

	# Phantom Camera Nodes
	add_custom_type(PCAM_2D, "Node2D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_2d.gd"), preload("res://addons/phantom_camera/icons/phantom_camera_2d.svg"))
	add_custom_type(PCAM_3D, "Node3D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_3d.gd"), preload("res://addons/phantom_camera/icons/phantom_camera_2d.svg"))
	add_custom_type(PCAM_HOST, "Node", preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd"), preload("res://addons/phantom_camera/icons/phantom_camera_2d.svg"))
	add_custom_type(PCAM_NOISE_EMITTER_2D, "Node2D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_noise_emitter_2d.gd"),  preload("res://addons/phantom_camera/icons/phantom_camera_noise_emitter_2d.svg"))
	add_custom_type(PCAM_NOISE_EMITTER_3D, "Node3D", preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_noise_emitter_3d.gd"),  preload("res://addons/phantom_camera/icons/phantom_camera_noise_emitter_3d.svg"))

	# Phantom Camera 3D Gizmo
	add_node_3d_gizmo_plugin(pcam_3d_gizmo_plugin)
	add_node_3d_gizmo_plugin(pcam_3d_noise_emitter_gizmo_plugin)

	# TODO - Should be disabled unless in editor
	# Viewfinder
	editor_panel_instance = EditorPanel.instantiate()
	editor_panel_instance.editor_plugin = self
	panel_button = add_control_to_bottom_panel(editor_panel_instance, "Phantom Camera")

	# Trigger events in the viewfinder whenever
	panel_button.toggled.connect(_btn_toggled)

	scene_changed.connect(editor_panel_instance.viewfinder.scene_changed)

	scene_changed.connect(_scene_changed)

	## Sets Updater Disabling option for non-forked projects
	if not FileAccess.file_exists("res://dev_scenes/3d/dev_scene_3d.tscn"):
		if not ProjectSettings.has_setting(updater_constants.setting_updater_enabled):
			ProjectSettings.set_setting(updater_constants.setting_updater_enabled, true)
		ProjectSettings.set_initial_value(updater_constants.setting_updater_enabled, true)

	## Adds Release console log disabler
	if not ProjectSettings.has_setting(updater_constants.setting_updater_notify_release):
		ProjectSettings.set_setting(updater_constants.setting_updater_notify_release, true)
	ProjectSettings.set_initial_value(updater_constants.setting_updater_notify_release, true)

	## Enables or disable
	if not ProjectSettings.has_setting("phantom_camera/tips/show_jitter_tips"):
		ProjectSettings.set_setting("phantom_camera/tips/show_jitter_tips", true)
	ProjectSettings.set_initial_value("phantom_camera/tips/show_jitter_tips", true)


func _btn_toggled(toggled_on: bool):
	if toggled_on:
		editor_panel_instance.viewfinder.viewfinder_visible = true
		editor_panel_instance.viewfinder.visibility_check()
	else:
		editor_panel_instance.viewfinder.viewfinder_visible = false


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

	if get_tree().root.get_node_or_null(String(PHANTOM_CAMERA_MANAGER)):
		remove_autoload_singleton(PHANTOM_CAMERA_MANAGER)


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
