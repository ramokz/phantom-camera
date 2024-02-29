class_name PhantomCameraNoise2D
extends Resource

## If true, will shake the camera continiously. 
@export var loop: bool = true:
	set(value):
		loop = value
		notify_property_list_changed()
	get:
		return loop

## Sets the duration for the camera noise if [member loop] is set to false.
## [br][br]
## The value is set in [b]seconds[/b].
@export_range(0, 100, 1, "or_greater") var duration: float = 1

## TODO
@export_range(0, 100, 1, "or_greater") var decay: float = 1

## TODO
@export_range(0, 100, 1, "or_greater") var intensity: float = 10

## TODO
@export var noise_algorithm: FastNoiseLite = FastNoiseLite.new()

## TODO
## 2D PARAMETERS

func _validate_property(property: Dictionary) -> void:
	if property.name == "duration" and not loop:
		property.usage = PROPERTY_USAGE_NO_EDITOR
