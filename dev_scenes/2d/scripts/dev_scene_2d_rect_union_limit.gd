extends Node2D

## Dev scene for a [PhantomCamera2D] limited to an [Area2D] made of rectangles.
## The limit area is drawn as the level; anything red is outside it.

const SPEED: float = 1200.0

@onready var target: Node2D = %Target
@onready var pcam: PhantomCamera2D = %PhantomCamera2D
@onready var limit_area: Area2D = %LimitArea
@onready var help: Label = %Help

var _start_position: Vector2
var _corner_damping: float


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("bf616a"))
	_start_position = target.position
	_corner_damping = pcam.limit_corner_damping
	_update_help()


func _process(delta: float) -> void:
	var direction: Vector2 = Vector2(
		float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
		float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	)
	target.position += direction.normalized() * SPEED * delta
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		if motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			target.position += motion.relative / pcam.zoom
	elif event is InputEventMouseButton:
		var button: InputEventMouseButton = event
		if not button.pressed: return
		match button.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				pcam.zoom *= 1.1
			MOUSE_BUTTON_WHEEL_DOWN:
				pcam.zoom /= 1.1
		_update_help()
	elif event is InputEventKey:
		var key: InputEventKey = event
		if not key.pressed or key.echo: return
		match key.keycode:
			KEY_C:
				pcam.limit_corner_damping = 0.0 if pcam.limit_corner_damping > 0 else _corner_damping
			KEY_T:
				target.position = _start_position
				pcam.teleport_position()
		_update_help()


func _draw() -> void:
	for child in limit_area.get_children():
		if child is CollisionShape2D:
			var shape_node: CollisionShape2D = child
			if shape_node.shape is RectangleShape2D:
				draw_rect(shape_node.global_transform * shape_node.shape.get_rect(), Color("4c566a"))
	draw_circle(target.position, 24, Color("ebcb8b"))


func _update_help() -> void:
	var damping: String = "%.2f s" % pcam.limit_corner_damping if pcam.limit_corner_damping > 0 else "off"
	help.text = "WASD / arrows or left-drag: move target\nMouse wheel: zoom (%.2f)\nC: corner damping (%s)\nT: back to start\nRed = outside the limit" % [pcam.zoom.x, damping]
