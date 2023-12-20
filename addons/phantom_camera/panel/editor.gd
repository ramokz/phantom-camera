@tool
extends VBoxContainer

var editor_interface: EditorInterface
var editor_plugin: EditorPlugin

@onready var updater: Control = %UpdateButton
@onready var viewfinder: Control = %ViewfinderPanel


func _ready():
	viewfinder.editor_interface = editor_interface
	updater.editor_plugin = editor_plugin
