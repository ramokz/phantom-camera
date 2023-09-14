@tool
extends Node3D

@onready var player: Node3D = %PlayerCharacterBody3D

func _input(event: InputEvent):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			print("Is space")