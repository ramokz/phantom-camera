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
@onready var _download_verion: Label = %DownloadVersionLabel
@onready var _download_http_request: HTTPRequest = %DownloadHTTPRequest
@onready var _download_button: Button = %DownloadButton
@onready var _download_button_bg: NinePatchRect = %DownloadButtonBG
@onready var _download_label: Label = %UpdateLabel

@onready var _breaking_label: Label = %BreakingLabel
@onready var _breaking_margin_container: MarginContainer = %BreakingMarginContainer
@onready var _breaking_options_button: OptionButton = %BreakingOptionButton
#@onready var current_version_label: Label = %CurrentVersionLabel

#endregion


#region Variables

# Todo - For 4.2 upgrade - Shows current version
var _download_dialogue: AcceptDialog
var _button_texture_default: Texture2D = load("res://addons/phantom_camera/assets/PhantomCameraBtnPrimaryDefault.png")
var _button_texture_hover: Texture2D = load("res://addons/phantom_camera/assets/PhantomCameraBtnPrimaryHover.png")

var next_version_release: Dictionary:
	set(value):
		next_version_release = value
		_download_verion.text = "%s update is available for download" % value.tag_name.substr(1)
		# Todo - For 4.2 upgrade
		#current_version_label.text = "Current version is " + editor_plugin.get_version()
	get:
		return next_version_release

var _breaking_window_height: float = 520
var _breaking_window_height_update: float = 600

#endregion


#region Private Functions

func _ready() -> void:
	_download_http_request.request_completed.connect(_on_http_request_request_completed)
	_download_button.pressed.connect(_on_download_button_pressed)
	_download_button.mouse_entered.connect(_on_mouse_entered)
	_download_button.mouse_exited.connect(_on_mouse_exited)

	_breaking_label.hide()
	_breaking_margin_container.hide()
	_breaking_options_button.hide()

	_breaking_options_button.item_selected.connect(_on_item_selected)


func _on_item_selected(index: int) -> void:
	if index == 1:
		_download_button.show()
		_download_dialogue.size = Vector2(_download_dialogue.size.x, _breaking_window_height_update)
	else:
		_download_button.hide()
		_download_dialogue.size = Vector2(_download_dialogue.size.x, _breaking_window_height)


func _on_download_button_pressed() -> void:
	_download_http_request.request(next_version_release.zipball_url)
	_download_button.disabled = true
	_download_label.text = "Downloading..."
	_download_button_bg.hide()


func _on_mouse_entered() -> void:
	_download_button_bg.set_texture(_button_texture_hover)


func _on_mouse_exited() -> void:
	_download_button_bg.set_texture(_button_texture_default)


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

#region Public Functions

func show_updater_warning(next_version_number: Array, current_version_number: Array) -> void:
	var current_version_number_0: int = current_version_number[0] as int
	var current_version_number_1: int = current_version_number[1] as int

	var next_version_number_0: int = next_version_number[0] as int # Major release number in the new release
	var next_version_number_1: int = next_version_number[1] as int # Minor release number in the new release

	if next_version_number_0 > current_version_number_0 or \
	next_version_number_1 > current_version_number_1:
		_breaking_label.show()
		_breaking_margin_container.show()
		_breaking_options_button.show()
		_download_button.hide()

		_download_dialogue = get_parent()
		_download_dialogue.size = Vector2(_download_dialogue.size.x, _breaking_window_height)

#endregion
