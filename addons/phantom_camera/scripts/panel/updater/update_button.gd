#######################################################################
# Credit goes to the Dialogue Manager plugin for this script
# Check it out at: https://github.com/nathanhoad/godot_dialogue_manager
#######################################################################

@tool
extends Button

#region Constants

const REMOTE_RELEASE_URL: StringName = "https://api.github.com/repos/ramokz/phantom-camera/releases"
const UPDATER_CONSTANTS := preload("res://addons/phantom_camera/scripts/panel/updater/updater_constants.gd")

#endregion


#region @onready

@onready var http_request: HTTPRequest = %HTTPRequest
@onready var download_dialog: AcceptDialog = %DownloadDialog
@onready var download_update_panel: Control = %DownloadUpdatePanel
@onready var needs_reload_dialog: AcceptDialog = %NeedsReloadDialog
@onready var update_failed_dialog: AcceptDialog = %UpdateFailedDialog

#endregion


#region Variables

# The main editor plugin
var editor_plugin: EditorPlugin

var needs_reload: bool = false

# A lambda that gets called just before refreshing the plugin. Return false to stop the reload.
var on_before_refresh: Callable = func(): return true

#endregion


#region Private Functions

func _ready() -> void:
	hide()

	# Check for updates on GitHub Releases
	check_for_update()

	pressed.connect(_on_update_button_pressed)
	http_request.request_completed.connect(_request_request_completed)
	download_update_panel.updated.connect(_on_download_update_panel_updated)
	needs_reload_dialog.confirmed.connect(_on_needs_reload_dialog_confirmed)


func _request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS: return

	if not editor_plugin: return
	var current_version: String = editor_plugin.get_version()

	# Work out the next version from the releases information on GitHub
	var response: Array = JSON.parse_string(body.get_string_from_utf8())
	if typeof(response) != TYPE_ARRAY: return

	# GitHub releases are in order of creation, not order of version
	var versions: Array = response.filter(func(release):
		var version: String = release.tag_name.substr(1)
		return version_to_number(version) > version_to_number(current_version)
	)

	if versions.size() > 0:
		# Safeguard forks from being updated itself
		if FileAccess.file_exists("res://dev_scenes/3d/dev_scene_3d.tscn") or \
			not ProjectSettings.get_setting(UPDATER_CONSTANTS.setting_updater_enabled):

			if not ProjectSettings.get_setting(UPDATER_CONSTANTS.setting_updater_notify_release): return

			print_rich("
[color=#3AB99A]   ********[/color]
[color=#3AB99A] ************[/color]
[color=#3AB99A]**************[/color]
[color=#3AB99A]******  ***  *[/color]
[color=#3AB99A]******  ***[/color]
[color=#3AB99A]**********      *****[/color]
[color=#3AB99A]********   ***********[/color]
[color=#3AB99A]********  ***********  **[/color]
[color=#3AB99A]*********  **************[/color]
[color=#3AB99A]**********  *************[/color]
[color=#3AB99A]**  **  **   *******   **[/color]
[font_size=18][b]New Phantom Camera version is available[/b][/font_size]")

			if FileAccess.file_exists("res://dev_scenes/3d/dev_scene_3d.tscn"):
				print_rich("[font_size=14][color=#EAA15E][b]As you're using a fork of the project, you will need to update it manually[/b][/color][/font_size]")

			print_rich("[font_size=12]If you don't want to see this message, then it can be disabled inside:\n[code]Project Settings/Phantom Camera/Updater/Show New Release Info on Editor Launch in Output[/code]")

			return

		download_update_panel.next_version_release = versions[0]
		download_update_panel.show_updater_warning(
			versions[0].tag_name.substr(1).split("."),
			current_version.split(".")
		)
		_set_scale()
		editor_plugin.panel_button.add_theme_color_override("font_color", Color("#3AB99A"))
		editor_plugin.panel_button.icon = load("res://addons/phantom_camera/icons/phantom_camera_updater_panel_icon.svg")
		editor_plugin.panel_button.add_theme_color_override("icon_normal_color", Color("#3AB99A"))
		show()


func _on_update_button_pressed() -> void:
	if needs_reload:
		var will_refresh = on_before_refresh.call()
		if will_refresh:
			EditorInterface.restart_editor(true)
	else:
		_set_scale()
		download_dialog.popup_centered()


func _set_scale() -> void:
	var scale: float = EditorInterface.get_editor_scale()
	download_dialog.min_size = Vector2(300, 250) * scale


func _on_download_dialog_close_requested() -> void:
	download_dialog.hide()


func _on_download_update_panel_updated(updated_to_version: String) -> void:
	download_dialog.hide()

	needs_reload_dialog.dialog_text = "Reload to finish update"
	needs_reload_dialog.ok_button_text = "Reload"
	needs_reload_dialog.cancel_button_text = "Cancel"
	needs_reload_dialog.popup_centered()

	needs_reload = true
	text = "Reload Project"


func _on_download_update_panel_failed() -> void:
	download_dialog.hide()
	update_failed_dialog.dialog_text = "Updated Failed"
	update_failed_dialog.popup_centered()


func _on_needs_reload_dialog_confirmed() -> void:
	EditorInterface.restart_editor(true)


func _on_timer_timeout() -> void:
	if not needs_reload:
		check_for_update()

#endregion


#region Public Functions

# Convert a version number to an actually comparable number
func version_to_number(version: String) -> int:
	var bits = version.split(".")
	var version_bit: int
	var multiplier: int = 10000
	for i in bits.size():
		version_bit += bits[i].to_int() * multiplier / (10 ** (i))

	return version_bit


func check_for_update() -> void:
	http_request.request(REMOTE_RELEASE_URL)

#endregion
