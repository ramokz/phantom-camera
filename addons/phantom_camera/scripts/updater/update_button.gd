#@tool
#extends Button
#
#const REMOTE_RELEASE_URL: StringName = "https://github.com/ramokz/phantom-camera/releases"
#const LOCAL_CONFIG_PATH: StringName = "res://addons/phantom_camera/plugin.cfg"
#
#@onready var http_request: HTTPRequest = %HTTPREQUEST
##@onready var version_on_load: String = get_version()
#@onready var download_dialog: AcceptDialog = %DownloadDialog
#@onready var update_failed_dialog: AcceptDialog = %UpdateFailedDialog
#
#var editor_plugin: EditorPlugin
#
#var on_before_refres: Callable = func(): return true
#
#func _ready():
#	hide()
#
#	http_request.request(REMOTE_RELEASE_URL)
#
#
##func _get_version() -> String:
##	var config: ConfigFile = ConfigFile.new()
##	config.load(LOCAL_CONFIG_PATH)
##	return config
#
#func _on

@tool
extends Button

#const DialogueConstants = preload("../constants.gd")

const REMOTE_RELEASE_URL: StringName = "https://github.com/ramokz/phantom-camera/releases"


@onready var http_request: HTTPRequest = %HTTPRequest
@onready var download_dialog: AcceptDialog = %DownloadDialog
@onready var download_update_panel = %DownloadUpdatePanel
@onready var needs_reload_dialog: AcceptDialog = $NeedsReloadDialog
@onready var update_failed_dialog: AcceptDialog = $UpdateFailedDialog

# The main editor plugin
var editor_plugin: EditorPlugin

var needs_reload: bool = false

# A lambda that gets called just before refreshing the plugin. Return false to stop the reload.
var on_before_refresh: Callable = func(): return true


func _ready() -> void:
#	hide()
	apply_theme()

	# Check for updates on GitHub
	check_for_update()
	
	http_request.request_completed.connect(_request_request_completed)


# Convert a version number to an actually comparable number
func version_to_number(version: String) -> int:
	var bits = version.split(".")
	return bits[0].to_int() * 1000000 + bits[1].to_int() * 1000 + bits[2].to_int()


func apply_theme() -> void:
	var color: Color = get_theme_color("success_color", "Editor")

	if needs_reload:
		color = get_theme_color("error_color", "Editor")
		icon = get_theme_icon("Reload", "EditorIcons")
		add_theme_color_override("icon_normal_color", color)
		add_theme_color_override("icon_focus_color", color)
		add_theme_color_override("icon_hover_color", color)

	add_theme_color_override("font_color", color)
	add_theme_color_override("font_focus_color", color)
	add_theme_color_override("font_hover_color", color)


func check_for_update() -> void:
	http_request.request(REMOTE_RELEASE_URL)


### Signals


func _request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS: return
	print(body)

	var current_version: String = editor_plugin.get_version()

	# Work out the next version from the releases information on GitHub
	var response = JSON.parse_string(body.get_string_from_utf8())
	if typeof(response) != TYPE_ARRAY: return

	# GitHub releases are in order of creation, not order of version
	var versions = (response as Array).filter(func(release):
		var version: String = release.tag_name.substr(1)
		return version_to_number(version) > version_to_number(current_version)
	)
	if versions.size() > 0:
		download_update_panel.next_version_release = versions[0]
		text = "update.available"
		show()


func _on_update_button_pressed() -> void:
	if needs_reload:
		var will_refresh = on_before_refresh.call()
		if will_refresh:
			editor_plugin.get_editor_interface().restart_editor(true)
	else:
		var scale: float = editor_plugin.get_editor_interface().get_editor_scale()
		download_dialog.min_size = Vector2(300, 250) * scale
		download_dialog.popup_centered()


func _on_download_dialog_close_requested() -> void:
	download_dialog.hide()


func _on_download_update_panel_updated(updated_to_version: String) -> void:
	download_dialog.hide()

	needs_reload_dialog.dialog_text = "update.needs_reload"
	needs_reload_dialog.ok_button_text = "update.reload_ok_button"
	needs_reload_dialog.cancel_button_text = "update.reload_cancel_button"
	needs_reload_dialog.popup_centered()

	needs_reload = true
	text = "update.reload_project"
	apply_theme()


func _on_download_update_panel_failed() -> void:
	download_dialog.hide()
	update_failed_dialog.dialog_text = "update.failed"
	update_failed_dialog.popup_centered()


func _on_needs_reload_dialog_confirmed() -> void:
	editor_plugin.get_editor_interface().restart_editor(true)


func _on_timer_timeout() -> void:
	if not needs_reload:
		check_for_update()
