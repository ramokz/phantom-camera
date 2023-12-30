extends Node2D

@onready var pcam_room_left: PhantomCamera2D = %RoomLeftPhantomCamera2D
@onready var pcam_room_right: PhantomCamera2D = %RoomRightPhantomCamera2D

@onready var player: CharacterBody2D = %CharacterBody2D

@onready var area_2d_room_left: Area2D = %RoomLeftArea2D
@onready var area_2d_room_right: Area2D = %RoomRightArea2D


func _ready():
	pcam_room_left.set_follow_target_offset(Vector2(0, -120))
	pcam_room_right.set_follow_target_offset(Vector2(0, -120))
	
	area_2d_room_left.body_entered.connect(_on_body_entered.bind(pcam_room_left))
	area_2d_room_right.body_entered.connect(_on_body_entered.bind(pcam_room_right))
	
	area_2d_room_left.body_exited.connect(_on_body_exited.bind(pcam_room_left))
	area_2d_room_right.body_exited.connect(_on_body_exited.bind(pcam_room_right))


func _on_body_entered(body: Node2D, pcam: PhantomCamera2D) -> void:
	if body == player:
		pcam.set_follow_target_node(player)
		pcam.set_follow_target_offset(Vector2(0, -120))
		pcam.set_priority(20)


func _on_body_exited(body: Node2D, pcam: PhantomCamera2D) -> void:
	if body == player:
		pcam.set_priority(0)
		pcam.set_follow_target_node(null)
