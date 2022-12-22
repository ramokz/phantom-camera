extends Area3D

@export var area_pcam: PhantomCamera3D
@onready var fixed_camera_label: Label3D = %FixedCameraLabel

var initial_camera_position: Vector3
var initial_camera_rotation: Vector3

var tween: Tween
var tween_duration: float = 0.9

func _ready() -> void:
	connect("area_entered", _entered_area)
	connect("area_exited", _exited_area)

	initial_camera_position = fixed_camera_label.get_global_position()
	initial_camera_rotation = fixed_camera_label.get_global_rotation()


func _entered_area(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		area_pcam.set_priority(20)

		var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUART).set_parallel(true)
		tween.tween_property(fixed_camera_label, "position", Vector3(5, 3.5, 3), tween_duration)
		tween.tween_property(fixed_camera_label, "rotation", Vector3(deg_to_rad(-45), deg_to_rad(-90), 0), tween_duration)

func _exited_area(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		area_pcam.set_priority(0)

		var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC).set_parallel(true)
		tween.tween_property(fixed_camera_label, "position", initial_camera_position, tween_duration / 2)
		tween.tween_property(fixed_camera_label, "rotation", initial_camera_rotation, tween_duration / 2)


