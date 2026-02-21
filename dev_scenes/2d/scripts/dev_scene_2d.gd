extends Node2D

@onready var player_pcam: PhantomCamera2D = %PlayerPhantomCamera2D
@onready var second_pcam: PhantomCamera2D = %SecondPhantomCamera2D
@onready var player: CharacterBody2D = %PlayerCharacterBody2D

@onready var teleport_left: Button = %TeleportLeft
@onready var teleport_right: Button = %TeleportRight

@onready var left_point: Marker2D = %LeftPoint
@onready var right_point: Marker2D = %RightPoint

var phantom_camera_host: PhantomCameraHost

func _ready() -> void:
	teleport_left.pressed.connect(_teleport_left)
	teleport_right.pressed.connect(_teleport_right)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	var event_key: InputEventKey = event as InputEventKey
	if not event_key.pressed: return
	if event_key.keycode == KEY_R:
		if second_pcam.priority < 30:
			second_pcam.priority = 31
		else:
			second_pcam.priority = 0


func _teleport_left() -> void:
	player.global_position = left_point.global_position


func _teleport_right() -> void:
	player.global_position = right_point.global_position
