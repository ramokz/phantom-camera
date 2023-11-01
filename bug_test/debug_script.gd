extends Node3D

var pcam_scene: PhantomCamera3D = preload("res://phantom_camera_3d_Packed.tscn").instantiate()

@export var target_1: Node3D
@export var target_2: Node3D
@export var target_3: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(pcam_scene)
	pcam_scene.append_follow_group_node(target_1)
	pcam_scene.append_follow_group_node(target_2)
	pcam_scene.append_follow_group_node(target_3)
