@tool
extends Panel

#region Enums

enum Placement {
	LEFT =      0,
	TOP =       1,
	RIGHT =     2,
	BOTTOM =    3,
}

#endregion


#region Exported Properties

@export var horizontal_drag: bool
@export var placement: Placement

#endregion


#region Public Variables

var screen_position: Vector2

#endregion


#region Private Variables

var _inactive_alpha: float = 0.3
var _individual_dead_zone_change: bool
var _is_draggable: bool
var _is_released: bool
var _commit_save: bool
var _offset: Vector2
var _mouse_screen_position: Vector2
#endregion


#region Signals

signal dragging(position)

#endregion


#region Private Functions

func _ready() -> void:
	modulate.a = _inactive_alpha
	mouse_entered.connect(_dead_zone_dragger_mouse_entered)
	mouse_exited.connect(_dead_zone_dragger_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _is_draggable:
		var viewport_size_halved: Vector2 = get_viewport().get_visible_rect().size / 2

		_offset = event.relative * Vector2(1, 0) if horizontal_drag else event.relative * Vector2(0, 1)
		dragging.emit(placement, _offset, _individual_dead_zone_change, false, false)

	if event is InputEventMouseButton and event.is_pressed():
		_is_draggable = true
		_is_released = false
		dragging.emit(placement, _offset, _individual_dead_zone_change, true, false)

	if event is InputEventMouseButton and event.is_released() and _is_draggable:
		_is_draggable = false
		_is_released = true
		mouse_default_cursor_shape = CURSOR_ARROW
		modulate.a = _inactive_alpha
		dragging.emit(placement, _offset, _individual_dead_zone_change, false, true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_screen_position = event.position
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_CTRL:
			_individual_dead_zone_change = true
			return
	if event.is_released():
		_individual_dead_zone_change = false


func _dead_zone_dragger_mouse_entered() -> void:
	modulate.a = 1
	mouse_default_cursor_shape = CURSOR_HSIZE if horizontal_drag else CURSOR_VSIZE


func _dead_zone_dragger_mouse_exited() -> void:
	modulate.a = _inactive_alpha
	if _is_released:
		_is_draggable = false
	_commit_save = true

#endregion
