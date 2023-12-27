#######################################################################
# Credit goes to the Dialogue Manager plugin for this script
# Check it out at: https://github.com/nathanhoad/godot_dialogue_manager
#######################################################################

@tool
extends Control

#region Constants

const TEMP_FILE_NAME = "user://temp.zip"

#endregion


#region Signals

signal failed()
signal updated(updated_to_version: String)

#endregion


#region @onready

#@onready var logo: TextureRect = %Logo
@onready var label: Label = %DownloadVersionLabel
@onready var download_http_request: HTTPRequest = %DownloadHTTPRequest
@onready var download_button: Button = %DownloadButton
@onready var download_button_bg: NinePatchRect = %DownloadButtonBG
@onready var download_label: Label = %UpdateLabel

#endregion


#region Variables

# Todo - For 4.2 upgrade - Shows current version
#@onready var current_version_label: Label = %CurrentVersionLabel
var _button_texture_default: Texture2D = load("res://addons/phantom_camera/assets/PhantomCameraBtnPrimaryDefault.png")
var _button_texture_hover: Texture2D = load("res://addons/phantom_camera/assets/PhantomCameraBtnPrimaryHover.png")

var next_version_release: Dictionary:
	set(value):
		next_version_release = value
		label.text = "%s update is available for download" % value.tag_name.substr(1)
		# Todo - For 4.2 upgrade
		#current_version_label.text = "Current version is " + editor_plugin.get_version()
	get:
		return next_version_release

#endregion


#region Private Functions

func _ready() -> void:
	download_http_request.request_completed.connect(_on_http_request_request_completed)
	download_button.pressed.connect(_on_download_button_pressed)
	download_button.mouse_entered.connect(_on_mouse_entered)
	download_button.mouse_exited.connect(_on_mouse_exited)


func _on_download_button_pressed() -> void:
	# Safeguard the actual dialogue manager repo from accidentally updating itself
	if FileAccess.file_exists("res://examples/test_scenes/test_scene.gd"):
		prints("You can't update the addon from within itself.")
		failed.emit()
		return

	download_http_request.request(next_version_release.zipball_url)
	download_button.disabled = true
	download_label.text = "Downloading..."
	download_button_bg.hide()


func _on_mouse_entered() -> void:
	download_button_bg.set_texture(_button_texture_hover)


func _on_mouse_exited() -> void:
	download_button_bg.set_texture(_button_texture_default)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		failed.emit()
		return

	# Save the downloaded zip
	var zip_file: FileAccess = FileAccess.open(TEMP_FILE_NAME, FileAccess.WRITE)
	zip_file.store_buffer(body)
	zip_file.close()

	OS.move_to_trash(ProjectSettings.globalize_path("res://addons/phantom_camera"))

	var zip_reader: ZIPReader = ZIPReader.new()
	zip_reader.open(TEMP_FILE_NAME)
	var files: PackedStringArray = zip_reader.get_files()

	var base_path = files[1]
	# Remove archive folder
	files.remove_at(0)
	# Remove assets folder
	files.remove_at(0)

	for path in files:
		var new_file_path: String = path.replace(base_path, "")
		if path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute("res://addons/%s" % new_file_path)
		else:
			var file: FileAccess = FileAccess.open("res://addons/%s" % new_file_path, FileAccess.WRITE)
			file.store_buffer(zip_reader.read_file(path))

	zip_reader.close()
	DirAccess.remove_absolute(TEMP_FILE_NAME)

	updated.emit(next_version_release.tag_name.substr(1))


func _on_notes_button_pressed() -> void:
	OS.shell_open(next_version_release.html_url)

#endregion
