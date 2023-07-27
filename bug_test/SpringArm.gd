extends SpringArm3D

@export var mouse_sensitivity: float = 0.05

@onready var pcam: PhantomCamera3D = $"PhantomCamera3D-1"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 30)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)
	
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			if pcam.get_priority() != 0:
				pcam.set_priority(0)
			else:
				pcam.set_priority(10)
			
		
