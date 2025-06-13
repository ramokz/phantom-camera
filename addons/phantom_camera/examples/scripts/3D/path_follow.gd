extends Node

@export var path_pcam: PhantomCamera3D

func _ready() -> void:
	connect("area_entered", _entered_area)
	connect("area_exited", _exited_area)


func _entered_area(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		path_pcam.set_priority(20)


func _exited_area(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		path_pcam.set_priority(0)
