extends CharacterBody2D

@onready var player_area2D = %PlayerArea2D

const SPEED = 120.0
const JUMP_VELOCITY = -250.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = 820

const KEY_STRINGNAME: StringName = "Key"
const ACTION_STRINGNAME: StringName = "Action"

const INPUT_MOVE_LEFT_STRINGNAME: StringName = "move_left"
const INPUT_MOVE_RIGHT_STRINGNAME: StringName = "move_right"

@onready var player_sprite: Sprite2D = %Player

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
	player_area2D.connect("body_shape_entered", _show_prompt)

	for input in InputMovementDic:
		var key_val = InputMovementDic[input].get(KEY_STRINGNAME)
		var action_val = InputMovementDic[input].get(ACTION_STRINGNAME)

		var movement_input = InputEventKey.new()
		movement_input.physical_keycode = key_val
		InputMap.add_action(action_val)
		InputMap.action_add_event(action_val, movement_input)


func _physics_process(delta: float) -> void:
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


func _show_prompt(body_rid: RID, body: Node2D, body_shape_index: int, local_shape: int) -> void:
	if body is TileMap:
		var tile_map: TileMap = body
		var tile_coords: Vector2i = tile_map.get_coords_for_body_rid(body_rid)
		var cell_data: TileData = tile_map.get_cell_tile_data(1, tile_coords)
		var cell_global_pos: Vector2 = tile_map.to_global(tile_map.map_to_local(tile_coords))

		print(cell_data.get_custom_data("SignText"))
		print(cell_global_pos)


func _hide_prompt(body_rid: RID, body: Node2D, body_shape_index: int, local_shape: int) -> void:
	pass
