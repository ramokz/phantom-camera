@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_noise_resource.svg")
class_name PhantomCameraNoise3D
extends Resource

#region Exported Properties

## Defines the size of the noise pattern.[br]
## Higher values will increase the range the noise can reach.
@export_range(0, 100, 0.001, "or_greater") var amplitude: float = 10

## Sets the density of the noise pattern.[br]
## Higher values will result in more erratic noise.
@export_range(0, 10, 0.001, "or_greater") var frequency: float = 0.2:
	set(value):
		frequency = value
		_noise_algorithm.frequency = value
	get:
		return frequency

## If enabled, randomizes the noise pattern every time the noise is run.[br]
## If disabled, [member seed] can be used to define a fixed noise pattern.
@export var randomize_seed: bool = true:
	set(value):
		randomize_seed = value
		if value: _noise_algorithm.seed = randi()
		notify_property_list_changed()
	get:
		return randomize_seed

## Sets a predetermined seed noise value.[br]
## Useful if wanting to achieve a persistent noise pattern every time the noise is re-emitted.
@export var seed: int = 0

## Enables noise changes to the camera's rotation.
@export var has_rotational_noise: bool = true:
	set(value):
		has_rotational_noise = value
		notify_property_list_changed()
	get:
		return has_rotational_noise

## Enables noise changes to the camera's position.[br][br]
## [b]Important[/b][br]This can cause geometry clipping if the camera gets too close while this is active.
@export var has_positional_noise: bool = false:
	set(value):
		has_positional_noise = value
		notify_property_list_changed()
	get:
		return has_positional_noise

@export_group("Rotational Multiplier")
## Defines the max rotational, in [param degrees], change in the X-axis when the noise is active.
@export_range(0, 1, 0.001, "or_greater") var rotational_multiplier_x: float = 1:
	set(value):
		rotational_multiplier_x = value
		_noise_rotational_multiplier.x = value
	get:
		return rotational_multiplier_x

## Defines the max rotational, in [param degrees], change in the y-axis when the noise is active.
@export_range(0, 1, 0.001, "or_greater") var rotational_multiplier_y: float = 1:
	set(value):
		rotational_multiplier_y = value
		_noise_rotational_multiplier.y = value
	get:
		return rotational_multiplier_y

## Defines the max rotational, in [param degrees], change in the z-axis when the noise is active.
@export_range(0, 1, 0.001, "or_greater") var rotational_multiplier_z: float = 0.1:
	set(value):
		rotational_multiplier_z = value
		_noise_rotational_multiplier.z = value
	get:
		return rotational_multiplier_z

@export_group("Positional Multiplier")
## Defines the max positional, in [param degrees], change in the X-axis when the noise is active.[br]
## [b]Note:[/b] Rotational Offset is recommended to avoid accidental camera clipping.
@export_range(0, 1, 0.001, "or_greater") var positional_multiplier_x: float = 0.1:
	set(value):
		positional_multiplier_x = value
		_noise_positional_multiplier.x = value
	get:
		return positional_multiplier_x

## Defines the max rotational, in [param degrees], change in the y-axis when the noise is active.
## [b]Note:[/b] Rotational Offset is recommended to avoid accidental camera clipping.
@export_range(0, 1, 0.001, "or_greater") var positional_multiplier_y: float = 0.1:
		set(value):
			positional_multiplier_y = value
			_noise_positional_multiplier.y = value
		get:
			return positional_multiplier_y
## Defines the max rotational, in [param degrees], change in the z-axis when the noise is active.
## [b]Note:[/b] Rotational Offset is recommended to avoid accidental camera clipping.
@export_range(0, 1, 0.001, "or_greater", ) var positional_multiplier_z: float = 0.1:
	set(value):
		positional_multiplier_z = value
		_noise_positional_multiplier.z = value
	get:
		return positional_multiplier_z

#endregion

#region Private Properties

var _noise_algorithm: FastNoiseLite = FastNoiseLite.new()

var _noise_rotational_multiplier: Vector3 = Vector3(
	rotational_multiplier_x,
	rotational_multiplier_y,
	rotational_multiplier_z,
)

var _noise_positional_multiplier: Vector3 = Vector3(
	positional_multiplier_x,
	positional_multiplier_y,
	positional_multiplier_z,
)

var _trauma: float = 0.0:
	set(value):
		_trauma = value
		if _trauma == 0.0:
			_noise_time = 0.0

var _noise_time: float = 0.0

#endregion

#region Private Functions

func _init():
	_noise_algorithm.noise_type = FastNoiseLite.TYPE_PERLIN

	if randomize_seed: _noise_algorithm.seed = randi()
	_noise_algorithm.frequency = frequency


func _validate_property(property: Dictionary) -> void:
	if randomize_seed and property.name == "seed":
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if not has_rotational_noise:
		match property.name:
			"rotational_multiplier_x", \
			"rotational_multiplier_y", \
			"rotational_multiplier_z":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if not has_positional_noise:
		match property.name:
			"positional_multiplier_x", \
			"positional_multiplier_y", \
			"positional_multiplier_z":
				property.usage = PROPERTY_USAGE_NO_EDITOR


func _get_noise_from_seed(seed: int) -> float:
	return _noise_algorithm.get_noise_2d(seed, _noise_time) * amplitude


func set_trauma(value: float) -> void:
	_trauma = value

#endregion

#region Public Functions

func get_noise_transform(delta: float) -> Transform3D:
	var output_rotation: Vector3
	var output_position: Vector3
	_noise_time += delta
	_trauma = maxf(_trauma, 0.0)

	for i in 3:
		if has_rotational_noise:
			output_rotation[i] = deg_to_rad(
				_noise_rotational_multiplier[i] * pow(_trauma, 2) * _get_noise_from_seed(i + seed)
			)

		if has_positional_noise:
			output_position[i] += _noise_positional_multiplier[i] * \
			pow(_trauma, 2) * _get_noise_from_seed(i + seed)

	return Transform3D(Quaternion.from_euler(output_rotation), output_position)


func reset_noise_time() -> void:
	_noise_time = 0

#endregion
