@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_noise_resource.svg")
class_name PhantomCameraNoise2D
extends Resource

#region Exported Properties

## Defines the size of the noise pattern.[br]
## Higher values will increase the range the noise can reach.
@export_range(0, 1000, 0.001, "or_greater") var amplitude: float = 10

## Sets the density of the noise pattern.[br]
## Higher values will result in more erratic noise.
@export_range(0, 10, 0.001, "or_greater") var frequency: float = 0.5:
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

## Enables noise changes to the [member Camera2D.offset] position.[br]
@export var positional_noise: bool = true:
	set(value):
		positional_noise = value
		notify_property_list_changed()
	get:
		return positional_noise

## Enables noise changes to the [Camera2D]'s rotation.
@export var rotational_noise: bool = false:
	set(value):
		rotational_noise = value
		notify_property_list_changed()
	get:
		return rotational_noise

@export_group("Positional Multiplier")
## Multiplies positional noise amount in the X-axis.[br]
## Set the value to [param 0] to disable noise in the axis.
@export_range(0, 1, 0.001, "or_greater") var positional_multiplier_x: float = 1:
	set(value):
		positional_multiplier_x = value
		_noise_positional_multiplier.x = value
	get:
		return positional_multiplier_x

## Multiplies positional noise amount in the Y-axis.[br]
## Set the value to [param 0] to disable noise in the axis.
@export_range(0, 1, 0.001, "or_greater") var positional_multiplier_y: float = 1:
		set(value):
			positional_multiplier_y = value
			_noise_positional_multiplier.y = value
		get:
			return positional_multiplier_y

@export_group("Rotational Multiplier")
## Multiplies rotational noise amount.
@export_range(0, 1, 0.001, "or_greater") var rotational_multiplier: float = 1

#endregion

#region Private Variables

var _noise_algorithm: FastNoiseLite = FastNoiseLite.new()

var _noise_positional_multiplier: Vector2 = Vector2(
	positional_multiplier_x,
	positional_multiplier_y
)

var _trauma: float = 0.0:
	set(value):
		_trauma = value

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

	if not rotational_noise and property.name == "rotational_multiplier":
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if not positional_noise:
		match property.name:
			"positional_multiplier_x", \
			"positional_multiplier_y":
				property.usage = PROPERTY_USAGE_NO_EDITOR


func _get_noise_from_seed(seed: int) -> float:
	return _noise_algorithm.get_noise_2d(seed, _noise_time) * amplitude


func set_trauma(value: float) -> void:
	_trauma = value

#endregion

#region Public Functions

func get_noise_transform(delta: float) -> Transform2D:
	var output_rotation: float
	var output_position: Vector2
	_noise_time += delta
	_trauma = maxf(_trauma, 0.0)

	if positional_noise:
		for i in 2:
			output_position[i] = _noise_positional_multiplier[i] * pow(_trauma, 2) * _get_noise_from_seed(i + seed)

	if rotational_noise:
		output_rotation = rotational_multiplier / 100 * pow(_trauma, 2) * _get_noise_from_seed(seed)

	return Transform2D(output_rotation, output_position)


func reset_noise_time() -> void:
	_noise_time = 0

#endregion
