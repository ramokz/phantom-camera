@tool

extends BaseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed", _mouse_pressed)

func _mouse_pressed() -> void:
	print("Locate button pressed")
