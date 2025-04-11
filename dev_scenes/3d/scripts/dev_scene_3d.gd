extends Node3D

@onready var player_pcam: PhantomCamera3D = %PlayerPhantomCamera3D

func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if not event.pressed: return

	if event.keycode == KEY_SPACE:
		if player_pcam.priority < 30:
			player_pcam.priority = 30
		else:
			player_pcam.priority = 0
