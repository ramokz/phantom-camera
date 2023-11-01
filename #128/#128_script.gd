extends Node2D

var pcam_scene: PhantomCamera2D = preload("res://#128/phantom_camera_2d_packed.tscn").instantiate()

@export var target_1: Node2D
@export var target_2: Node2D
@export var target_3: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var arr: Array[Node2D] = [target_1, target_2, target_3]
	add_child(pcam_scene)
	pcam_scene.append_follow_group_node_array(arr)
