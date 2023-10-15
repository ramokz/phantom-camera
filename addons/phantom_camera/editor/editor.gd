@tool
extends VBoxContainer

var editor_interface: EditorInterface

@onready var updater: Control = %UpdateButton
@onready var viewfinder: Control = %ViewfinderPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	viewfinder.editor_interface = editor_interface
	updater.editor_interface = editor_interface


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
