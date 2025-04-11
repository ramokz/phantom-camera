@tool
extends VBoxContainer

#region Onready

@onready var updater: Control = %UpdateButton
@onready var viewfinder: Control = %ViewfinderPanel

#endregion

#region Public Variables

var editor_plugin: EditorPlugin

#endregion


#region Private Functions

func _ready():
	updater.editor_plugin = editor_plugin

#endregion
