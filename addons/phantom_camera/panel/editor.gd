@tool
extends VBoxContainer

var editor_plugin: EditorPlugin

@onready var updater: Control = %UpdateButton
@onready var viewfinder: Control = %ViewfinderPanel


func _ready():
	updater.editor_plugin = editor_plugin
