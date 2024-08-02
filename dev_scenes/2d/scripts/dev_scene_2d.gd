extends Node2D

@onready var pcam: PhantomCamera2D = %PlayerPhantomCamera2D
@onready var pcam_scene: PhantomCamera2D = %PhantomCamera2D


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_physical_key_pressed(KEY_F):
		if pcam_scene.priority < 10:
			pcam_scene.priority = 10
		else:
			pcam_scene.priority = 0
