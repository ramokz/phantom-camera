@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_noise_resource.svg")
class_name PhantomCameraNoise2D
extends Resource

## A resource type used to apply noise, or shake, to [Camera2D]s that have a [PhantomCameraHost] as a child.
##
## Is a resource type that defines, calculates and outputs the noise values to a [Camera2D] through active
## [PhantomCamera3D].[br]
## It can be applied to either [PhantomCameraNoiseEmitter2D] or a [PhantomCamera2D] noise property directly

#region Exported Properties

## Defines the size of the noise pattern.[br]
## Higher values will increase the range the noise can reach.
@export_range(0, 1000, 0.001, "or_greater") var amplitude: float = 10:
	set = set_amplitude,
	get = get_amplitude

## Sets the density of the noise pattern.[br]
## Higher values will result in more erratic noise.
@export_range(0, 10, 0.001, "or_greater") var frequency: float = 0.5:
	set = set_frequency,
	get = get_frequency

## If true, randomizes the noise pattern every time the noise is run.[br]
## If disabled, [member seed] can be used to define a fixed noise pattern.
@export var randomize_noise_seed: bool = true:
	set = set_randomize_noise_seed,
	get = get_randomize_noise_seed

## Sets a predetermined seed noise value.[br]
## Useful if wanting to achieve a persistent noise pattern every time the noise is emitted.
@export var noise_seed: int = 0:
	set = set_noise_seed,
	get = get_noise_seed

## Enables noise changes to the [member Camera2D.offset] position.
@export var positional_noise: bool = true:
	set = set_positional_noise,
	get = get_positional_noise

## Enables noise changes to the [Camera2D]'s rotation.
@export var rotational_noise: bool = false:
	set = set_rotational_noise,
	get = get_rotational_noise

@export_group("Positional Multiplier")
## Multiplies positional noise amount in the X-axis.[br]
## Set the value to [param 0] to disable noise in the axis.
@export_range(0, 1, 0.001, "or_greater") var positional_multiplier_x: float = 1:
	set = set_positional_multiplier_x,
	get = get_positional_multiplier_x

## Multiplies positional noise amount in the Y-axis.[br]
## Set the value to [param 0] to disable noise in the axis.
@export_range(0, 1, 0.001, "or_greater") var positional_multiplier_y: float = 1:
	set = set_positional_multiplier_y,
	get = get_positional_multiplier_y

@export_group("Rotational Multiplier")
## Multiplies rotational noise amount.
@export_range(0, 1, 0.001, "or_greater") var rotational_multiplier: float = 1:
	set = set_rotational_multiplier,
	get = get_rotational_multiplier

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
	if randomize_noise_seed: _noise_algorithm.seed = randi()
	_noise_algorithm.frequency = frequency


func _validate_property(property: Dictionary) -> void:
	if randomize_noise_seed and property.name == "noise_seed":
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if not rotational_noise and property.name == "rotational_multiplier":
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if not positional_noise:
		match property.name:
			"positional_multiplier_x", \
			"positional_multiplier_y":
				property.usage = PROPERTY_USAGE_NO_EDITOR


func _get_noise_from_seed(noise_seed: int) -> float:
	return _noise_algorithm.get_noise_2d(noise_seed, _noise_time) * amplitude


func set_trauma(value: float) -> void:
	_trauma = value

#endregion

#region Public Functions

func get_noise_transform(delta: float) -> Transform2D:
	var output_position: Vector2 = Vector2.ZERO
	var output_rotation: float = 0.0
	_noise_time += delta
	_trauma = maxf(_trauma, 0.0)

	if positional_noise:
		for i in 2:
			output_position[i] = _noise_positional_multiplier[i] * pow(_trauma, 2) * _get_noise_from_seed(i + noise_seed)
	if rotational_noise:
		output_rotation = rotational_multiplier / 100 * pow(_trauma, 2) * _get_noise_from_seed(noise_seed)

	return Transform2D(output_rotation, output_position)


func reset_noise_time() -> void:
	_noise_time = 0

#endregion

#region Setters & Getters

## Sets the [member amplitude] value.
func set_amplitude(value: float) -> void:
	amplitude =value

## Returns the [member amplitude] value.
func get_amplitude() -> float:
	return amplitude


## Sets the [member frequency] value.
func set_frequency(value: float) -> void:
	frequency = value
	_noise_algorithm.frequency = value

## Returns the [member frequency] value.
func get_frequency() -> float:
	return frequency


## Sets the [member randomize_seed] value.
func set_randomize_noise_seed(value: int) -> void:
	randomize_noise_seed = value
	if value: _noise_algorithm.seed = randi()
	notify_property_list_changed()

## Returns the [member randomize_seed] value.
func get_randomize_noise_seed() -> int:
	return randomize_noise_seed


## Sets the [member randomize_seed] value.
func set_noise_seed(value: int) -> void:
	noise_seed = value

## Returns the [member seed] value.
func get_noise_seed() -> int:
	return noise_seed


## Sets the [member positional_noise] value.
func set_positional_noise(value: bool) -> void:
	positional_noise = value
	notify_property_list_changed()

## Returns the [member positional_noise] value.
func get_positional_noise() -> bool:
	return positional_noise


## Sets the [member rotational_noise] value.
func set_rotational_noise(value: bool) -> void:
	rotational_noise = value
	notify_property_list_changed()

## Returns the [member rotational_noise] value.
func get_rotational_noise() -> bool:
	return rotational_noise


## Sets the [member positional_multiplier_x] value.
func set_positional_multiplier_x(value: float) -> void:
	positional_multiplier_x = value
	_noise_positional_multiplier.x = value

## Returns the [member positional_multiplier_x] value.
func get_positional_multiplier_x() -> float:
	return positional_multiplier_x


## Sets the [member positional_multiplier_y] value.
func set_positional_multiplier_y(value: float) -> void:
	positional_multiplier_y = value
	_noise_positional_multiplier.y = value

## Returns the [member positional_multiplier_y] value.
func get_positional_multiplier_y() -> float:
	return positional_multiplier_y


## Sets the [member rotational_multiplier] value.
func set_rotational_multiplier(value: float) -> void:
	rotational_multiplier = value

## Returns the [member rotational_multiplier] value.
func get_rotational_multiplier() -> float:
	return rotational_multiplier

#endregion
