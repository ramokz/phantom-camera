extends Node3D

@onready var pcam_3d: PhantomCamera3D = %PhantomCamera3D 
@onready var pcam_2_3d: PhantomCamera3D = %PhantomCamera3D2


func _ready():
	#pcam_2_3d.set_camera_fov(10)
	#print(pcam_2_3d.get_camera_fov())
	pass


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			if pcam_2_3d.get_priority() < 30 and pcam_3d.is_active():
				pcam_2_3d.set_priority(30)
			else:
				pcam_2_3d.set_priority(0)
