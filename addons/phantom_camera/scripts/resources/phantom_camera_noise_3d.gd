@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_noise_resource.svg")
class_name PhantomCameraNoise3D
extends Resource

## Sets the velocity of the noise.[br]
## Lower value = Slower movement[br]
## Higher value = Faster movement
@export_range(0, 100, 0.001, "or_greater") var intensity: float = 10

## Defines the noise pattern. By default, a Noise Type of Perlin is set.[br]
## [color=yellow]This property is mandatory.[/color]
var noise_algorithm: FastNoiseLite = FastNoiseLite.new()

## The seed within [member noise_algorithm] is automatically being overriden. To change the noise
## pattern seed, override this value.
@export var seed: int = 0

## Enables noise changes to the camera rotation.
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

@export_group("Max Rotational Offset")
## Defines the max rotational, in [param degrees], change in the X-axis when the noise is active.
@export_range(0, 360, 0.1, "degrees") var max_rotational_offset_x: float = 10:
	set(value):
		max_rotational_offset_x = value
		_noise_max_rotational_offset.x = value
	get:
		return max_rotational_offset_x

## Defines the max rotational, in [param degrees], change in the y-axis when the noise is active.
@export_range(0, 360, 0.1, "degrees") var max_rotational_offset_y: float = 10:
	set(value):
		max_rotational_offset_y = value
		_noise_max_rotational_offset.y = value
	get:
		return max_rotational_offset_y
## Defines the max rotational, in [param degrees], change in the z-axis when the noise is active.
@export_range(0, 360, 0.1, "degrees") var max_rotational_offset_z: float = 5:
	set(value):
		max_rotational_offset_z = value
		_noise_max_rotational_offset.z = value
	get:
		return max_rotational_offset_z

var _noise_max_rotational_offset: Vector3 = Vector3(max_rotational_offset_x, max_rotational_offset_y, max_rotational_offset_z)


@export_group("Max Positional Offset")
## Defines the max positional, in [param degrees], change in the X-axis when the noise is active.[br]
## [b]Note:[/b] Rotational Offset is recommended to avoid accidental camera clipping.
@export_range(0, 10, 0.1, "or_greater") var max_position_offset_x: float = 0:
	set(value):
		max_position_offset_x = value
		_noise_max_position_offset.x = value
	get:
		return max_position_offset_x

## Defines the max rotational, in [param degrees], change in the y-axis when the noise is active.
## [b]Note:[/b] Rotational Offset is recommended to avoid accidental camera clipping.
@export_range(0, 10, 0.1, "or_greater") var max_position_offset_y: float = 0:
		set(value):
			max_position_offset_y = value
			_noise_max_position_offset.y = value
		get:
			return max_position_offset_y
## Defines the max rotational, in [param degrees], change in the z-axis when the noise is active.
## [b]Note:[/b] Rotational Offset is recommended to avoid accidental camera clipping.
@export_range(0, 10, 0.1, "or_greater", ) var max_position_offset_z: float = 0:
	set(value):
		max_position_offset_z = value
		_noise_max_position_offset.z = value
	get:
		return max_position_offset_z

var _noise_max_position_offset: Vector3

var _trauma: float = 0.0:
	set(value):
		_trauma = value
		if _trauma == 0.0:
			_noise_time = 0.0

var _noise_time: float = 0.0

#region Private Functions

func _init():
	noise_algorithm.noise_type = FastNoiseLite.TYPE_PERLIN


func _validate_property(property: Dictionary) -> void:
	if property.name == "continous":
		property.usage = PROPERTY_USAGE_READ_ONLY

	if not has_rotational_noise:
		match property.name:
			"max_rotational_offset_x", \
			"max_rotational_offset_y", \
			"max_rotational_offset_z":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if not has_positional_noise:
		match property.name:
			"max_position_offset_x", \
			"max_position_offset_y", \
			"max_position_offset_z":
				property.usage = PROPERTY_USAGE_NO_EDITOR


func _noise_output(origin: Vector3, offset: Vector3) -> Vector3:
	var output: Vector3
	for i in 3:
		output[i] = origin[0] + offset[i] * \
		intensity * _get_noise_from_seed(i + seed)

	return output


func _get_noise_from_seed(seed: int) -> float:
	noise_algorithm.seed = seed
	return noise_algorithm.get_noise_1d(_noise_time * intensity)


func set_trauma(value: float) -> void:
	pass
	#var tween: Tween = Node.get_tree
	_trauma = value

#endregion

#region Public Functions

func get_noise_transform(rotation: Vector3, position: Vector3, delta: float) -> Transform3D:
	var output_rotation: Vector3
	var output_position: Vector3
	_noise_time += delta
	_trauma = maxf(_trauma, 0.0)

	for i in 3:
		if has_rotational_noise:
			output_rotation[i] = deg_to_rad(
				rotation[i] + _noise_max_rotational_offset[i] * pow(_trauma, 2) * _get_noise_from_seed(i + seed)
			)

		if has_positional_noise:
			output_position[i] += _noise_max_position_offset[i] * \
			pow(_trauma, 2) * _get_noise_from_seed(i + seed)

	return Transform3D(Quaternion.from_euler(output_rotation), output_position)

#endregion
