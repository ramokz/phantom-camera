extends Node

var test_scripts: Array[Script] = [
	load("res://tests/scripts/test_phantom_camera.gd"),
	load("res://tests/scripts/TestPhantomCameraWrapper.cs"),
]

func _ready() -> void:
	for script: Script in test_scripts:
		var test: Object = script.new()
		if test.has_method("Test"):
			add_child(test)
			test.Test()
			remove_child(test)
	get_tree().quit()
