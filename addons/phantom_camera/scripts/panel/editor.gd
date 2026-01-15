@tool
extends VBoxContainer

#region Onready

@onready var updater: UpdaterButton = %UpdateButton
@onready var viewfinder: ViewFinderPanel = %ViewfinderPanel
@onready var tree_view: PhantomCameraTreeView = %PhantomCameraTreeView

#endregion

#region Public Variables

var editor_plugin: EditorPlugin

#endregion


#region Private Functions

func _ready() -> void:
	updater.editor_plugin = editor_plugin

#endregion
