extends "player_controller_4.4.gd"

@onready var _player_pcam: PhantomCamera3D = %PlayerPhantomCamera3D

@onready var _player_character: CharacterBody3D = %PlayerCharacterBody3D

@export var mouse_sensitivity: float = 0.05

@export var min_pitch: float = -89.9
@export var max_pitch: float = 50

@export var min_yaw: float = 0
@export var max_yaw: float = 360

@export var run_noise: PhantomCameraNoise3D

func _ready() -> void:
	super()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if get_node_or_null("%PlayerPhantomCameraNoiseEmitter3D"):
		%EmitterTip.visible = true


func _physics_process(delta: float) -> void:
	super(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if get_node_or_null("%PlayerPhantomCameraNoiseEmitter3D"):
			if event.keycode == KEY_Q and event.is_pressed():
				%PlayerPhantomCameraNoiseEmitter3D.emit()

	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3

		# Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor
		pcam_rotation_degrees = _player_pcam.rotation_degrees

		# Change the X rotation
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity

		# Clamp the rotation in the X axis so it go over or under the target
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)

		# Change the Y rotation value
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity

		# Sets the rotation to fully loop around its target, but witout going below or exceeding 0 and 360 degrees respectively
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)

		# Change the SpringArm3D node's rotation and rotate around its target
		_player_pcam.rotation_degrees = pcam_rotation_degrees
