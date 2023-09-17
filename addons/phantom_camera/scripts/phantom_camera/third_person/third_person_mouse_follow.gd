extends SpringArm3D

var mouse_sensitivity: float = 0.1

var foo: String = "Set locally"

func _init():
	_ready()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print(InputMap.get_actions()[0])
	set_process_unhandled_input(true)
	
	print(foo)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -89.9, 50)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)
