#######################################################################
# Credit goes to the Dialogue Manager plugin for this script
# Check it out at: https://github.com/nathanhoad/godot_dialogue_manager
#######################################################################

@tool
extends Button

#const DialogueConstants = preload("../constants.gd")

const REMOTE_RELEASE_URL: StringName = "https://api.github.com/repos/ramokz/phantom-camera/releases"

#@onready var _download_button_bg: Rec

@onready var http_request: HTTPRequest = %HTTPRequest
@onready var download_dialog: AcceptDialog = %DownloadDialog
@onready var download_update_panel = %DownloadUpdatePanel
@onready var needs_reload_dialog: AcceptDialog = %NeedsReloadDialog
@onready var update_failed_dialog: AcceptDialog = %UpdateFailedDialog

# The main editor plugin
var editor_plugin: EditorPlugin

var needs_reload: bool = false

# A lambda that gets called just before refreshing the plugin. Return false to stop the reload.
var on_before_refresh: Callable = func(): return true


func _ready() -> void:
	hide()
	apply_theme()

	# Check for updates on GitHub
	check_for_update()
	
	self.pressed.connect(_on_update_button_pressed)
	http_request.request_completed.connect(_request_request_completed)


# Convert a version number to an actually comparable number
func version_to_number(version: String) -> int:
	var bits = version.split(".")
	var version_bit: int
	var multiplier: int = 10000
	for i in bits.size():
		version_bit += bits[i].to_int() * multiplier / (10 ** (i))
	
	return version_bit


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
		download_update_panel.next_version_release = versions[0]
#		text = "update.available"
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
