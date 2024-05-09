extends "player_controller.gd"

@onready var _player_pcam: PhantomCamera3D = %PlayerPhantomCamera3D

@onready var _player_character: CharacterBody3D = %PlayerCharacterBody3D

@onready var _noise_resource: PhantomCameraNoiseEmitter3D = %PhantomCameraNoiseEmitter3D

@export var mouse_sensitivity: float = 0.05

@export var min_pitch: float = -89.9
@export var max_pitch: float = 50

@export var min_yaw: float = 0
@export var max_yaw: float = 360

@export var run_noise: PhantomCameraNoise3D

func _ready() -> void:
	super()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	super(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if velocity != Vector3.ZERO:
			if event.keycode == KEY_SHIFT:
				if event.is_pressed():
					SPEED = 5
					#_player_pcam.noise.intensity = 50
					#_player_pcam.noise.max_x = 15
					#_player_pcam.noise.max_y = 15

				elif event.is_released():
					SPEED = 3
					#_player_pcam.noise.intensity = 75
					#_player_pcam.noise.max_x = 5
					#_player_pcam.noise.max_y = 5

		if event.keycode == KEY_SPACE and event.is_pressed():
			#_player_pcam.add_noise_trauma(0.1, run_noise)
			#_player_pcam.get_noise_active()
			#_player_pcam.
			pass

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
