class_name PhantomCameraNoise3D
extends Resource

## If true, will trigger the moment the [param PhantomCamera] becomes active.
#@export var auto_start: bool = true

## If true, will shake the camera continiously while it's active. 
@export var loop: bool = false:
	set(value):
		loop = value
		notify_property_list_changed()
	get:
		return loop

## Sets the duration for the camera noise if [member loop] is set to false.
## [br][br]
## The value is set in [b]seconds[/b].
@export_range(0, 100, 0.001, "or_greater") var duration: float = 1

## Determines how many [param seconds] the noise should take to stop. Triggering more [param trauma]
## resets the decay timer.
@export_range(0, 10, 0.001, "or_greater") var decay: float = 1

## Sets the velocity of the noise.[br]
## Lower value = Slower movement[br]
## Higher value = Faster movement
@export_range(0, 100, 0.001, "or_greater") var intensity: float = 10


## Defines the noise pattern. By default, a Noise Type of Perlin is set.[br]
## [color=yellow]This property is mandatory.[/color]
@export var noise_algorithm: FastNoiseLite

## The seed within [member noise_algorithm] is automatically being overriden. To change the noise
## pattern seed, override this value.
@export var seed_offset: int = 0

@export_group("Max Rotational Offset")
## Defines the max rotational, in [param degrees], change in the X-axis when the noise is active.
@export_range(0, 360, 0.1, "or_greater") var max_rotational_offset_x: float = 10
## Defines the max rotational, in [param degrees], change in the y-axis when the noise is active.
@export_range(0, 360, 0.1, "or_greater") var max_rotational_offset_y: float = 10
## Defines the max rotational, in [param degrees], change in the z-axis when the noise is active.
@export_range(0, 360, 0.1, "or_greater") var max_rotational_offset_z: float = 5

@export_group("Max Positional Offset")
## Defines the max positional, in [param degrees], change in the X-axis when the noise is active.[br]
## [b]Note:[/b] Rotaional Offset is recommended to avoid accidantial camera clipping. 
@export_range(0, 360, 0.1, "or_greater") var max_position_offset_x: float = 0
## Defines the max rotational, in [param degrees], change in the y-axis when the noise is active.
## [b]Note:[/b] Rotaional Offset is recommended to avoid accidantial camera clipping. 
@export_range(0, 360, 0.1, "or_greater") var max_position_offset_y: float = 0
## Defines the max rotational, in [param degrees], change in the z-axis when the noise is active.
## [b]Note:[/b] Rotaional Offset is recommended to avoid accidantial camera clipping. 
@export_range(0, 360, 0.1, "or_greater") var max_position_offset_z: float = 0


func _validate_property(property: Dictionary) -> void:
	if property.name == "duration" and loop:
		property.usage = PROPERTY_USAGE_NO_EDITOR
