extends Node3D

@onready var player_pcam: PhantomCamera3D = %PlayerPhantomCamera3D


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			if player_pcam.priority < 30:
				player_pcam.priority = 30
			else:
				player_pcam.priority = 0
