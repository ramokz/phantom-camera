extends CharacterBody2D

@onready var player_area2D = %PlayerArea2D
@onready var player_sprite: Sprite2D = %PlayerSprite

@onready var dark_overlay: ColorRect = %DarkOverlay


const KEY_STRINGNAME: StringName = "Key"
const ACTION_STRINGNAME: StringName = "Action"
const INPUT_MOVE_LEFT_STRINGNAME: StringName = "move_left"
const INPUT_MOVE_RIGHT_STRINGNAME: StringName = "move_right"

const SPEED = 350.0
const JUMP_VELOCITY = -750.0

var _physics_body_trans_last: Transform2D
var _physics_body_trans_current: Transform2D
var gravity: int = 2400 # Get the gravity from the project settings to be synced with RigidBody nodes.

enum InteractiveType {
	NONE = 0,
	ITEM = 1,
	INVENTORY = 2,
}

var InputMovementDic: Dictionary = {
	INPUT_MOVE_LEFT_STRINGNAME: {
		KEY_STRINGNAME: KEY_A,
		ACTION_STRINGNAME: INPUT_MOVE_LEFT_STRINGNAME
	},
	INPUT_MOVE_RIGHT_STRINGNAME: {
		KEY_STRINGNAME: KEY_D,
		ACTION_STRINGNAME: INPUT_MOVE_RIGHT_STRINGNAME
	},
}


func _ready() -> void:
	for input in InputMovementDic:
		var key_val = InputMovementDic[input].get(KEY_STRINGNAME)
		var action_val = InputMovementDic[input].get(ACTION_STRINGNAME)

		var movement_input = InputEventKey.new()
		movement_input.physical_keycode = key_val
		InputMap.add_action(action_val)
		InputMap.action_add_event(action_val, movement_input)


func _physics_process(delta: float) -> void:
	_physics_body_trans_last = _physics_body_trans_current
	_physics_body_trans_current = global_transform

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir: = Input.get_axis(
		INPUT_MOVE_LEFT_STRINGNAME,
		INPUT_MOVE_RIGHT_STRINGNAME
	)

	if input_dir:
		velocity.x = input_dir * SPEED
		if input_dir > 0:
			player_sprite.set_flip_h(false)
		elif input_dir < 0:
			player_sprite.set_flip_h(true)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _process(_delta: float) -> void:
	player_sprite.global_transform = _physics_body_trans_last.interpolate_with(
		_physics_body_trans_current,
		Engine.get_physics_interpolation_fraction()
	)
