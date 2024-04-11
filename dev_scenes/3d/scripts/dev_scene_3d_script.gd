extends Node3D

@onready var pcam: PhantomCamera3D = %ScenePhantomCamera3D
@onready var player: CharacterBody3D = %PlayerCharacterBody3D2
@onready var player_pcam: PhantomCamera3D = %PlayerPhantomCamera3D


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			if player_pcam.get_priority() < 30:
				player_pcam.set_priority(30)
			else:
				player_pcam.set_priority(0)
