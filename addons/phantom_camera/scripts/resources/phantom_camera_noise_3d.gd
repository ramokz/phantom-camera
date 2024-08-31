@tool
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

var _noise_max_rotational_offset: Vector3


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


signal emit_noise(duration: float, time: float)

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

	#print(intensity)
	#noise_rotation[i] = \
					#deg_to_rad(
						#camera_3d.rotation_degrees[i] + noise_max_rotation_offset[i] * \
						#1 # * _get_noise_from_seed(_noise_3d, i + _noise_3d.seed)
				#)

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

func get_noise_transform(pcam_rotation: Vector3, pcam_position: Vector3, delta: float) -> Transform3D:
	var output_rotation: Vector3
	var output_position: Vector3 = pcam_position

	_noise_time += delta

	_trauma = maxf(_trauma, 0.0)

	for i in 3:
		if has_rotational_noise:
			output_rotation[i] = deg_to_rad(
				pcam_rotation[i] + _noise_max_rotational_offset[i] * pow(_trauma, 2) * _get_noise_from_seed(i + seed)
			)
		else:
			output_rotation[i] = deg_to_rad(pcam_rotation[i])

		if has_positional_noise:
			output_position[i] += _noise_max_position_offset[i] * \
			pow(_trauma, 2) * _get_noise_from_seed(i + seed)

	return Transform3D(Quaternion.from_euler(output_rotation), output_position)


func get_noise_position(camera_position: Vector3, _intensity: float, delta: float, is_rotation: bool = true) -> Vector3:
	var output: Vector3
	var offset: Vector3

	if is_rotation:
		offset = Vector3(
			max_rotational_offset_x,
			max_rotational_offset_y,
			max_rotational_offset_z
		)
	else:
		offset = Vector3(
			max_position_offset_x,
			max_position_offset_y,
			max_position_offset_z,
		)

	return _noise_output(camera_position, offset)



func get_noise_rotation(camera_rotation: Vector3, delta: float) -> Quaternion:
	#var output: Vector3
	var output_rotation_degrees: Vector3
	for i in 3:
		#output_rotation_degrees[i] = camera_rotation[i] + _noise_max_position_offset[i] * pow(_trauma, 2) * _get_noise_from_seed(i + seed)
		output_rotation_degrees[i] = deg_to_rad(
			output_rotation_degrees[i] + _noise_max_rotational_offset[i] * \
			pow(_trauma, 2) * _get_noise_from_seed(i + seed)
		)

	return Quaternion.from_euler(output_rotation_degrees)


func noise_rotation(camera_rotation: Vector3, delta: float) -> Quaternion:
	_noise_time += delta
	_trauma = 1
	#_trauma = maxf(_trauma - delta * decay_time, 0.0)

	var rot_degrees: Vector3

	for i in 3:
		rot_degrees[i] = deg_to_rad(
			camera_rotation[i] + _noise_max_position_offset[i] * pow(_trauma, 2) * _get_noise_from_seed(i + seed)
		)
		#rot_degrees[i] = camera_rotation[i] + _noise_max_position_offset[i] * pow(_trauma, 2) * _get_noise_from_seed(i + seed)
	#print(_trauma)
	#print( _get_noise_from_seed(2 + seed))
	#print(_noise_time)
	#print(camera_rotation[2])
	return Quaternion.from_euler(rot_degrees)
	#return Quaternion.from_euler(rot_degrees)


	#var rotation_degrees: Vector3 = _noise_output(camera_rotation, max_offset)
#
	#var noise_rotation: Vector3
#
	#for i in 3:
		#noise_rotation[i] = \
			#deg_to_rad(
				#camera_rotation[i] + max_offset[i] * \
				#1 * _get_noise_from_seed(i + seed)
		#)

	#print(noise_rotation)1

	#print("Noise Resource is:")
	#print("FROM RESOURCE")
	#print(output)
	#return Quaternion.from_euler(noise_rotation)

#endregion
