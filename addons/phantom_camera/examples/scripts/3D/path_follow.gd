extends Area3D

@export var path_pcam: PhantomCamera3D

func _ready() -> void:
	area_shape_entered.connect(_area_shape_entered)
	area_shape_exited.connect(_area_shape_exited)


func _area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	path_pcam.set_priority(20)

func _area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	path_pcam.set_priority(0)
