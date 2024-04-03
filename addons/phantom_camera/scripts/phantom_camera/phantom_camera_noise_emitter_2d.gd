@tool
class_name PhantomCameraNoiseEmitter2D
extends Node2D

@export var noise_resource: PhantomCameraNoise2D
@export var loop: bool
@export var duration: float

signal trigger_noise


func _validate_property(property):
	if property.name == "duration" and not loop:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func assign_noise_resource() -> void:
	pass


func trigger_noise_resource() -> void:
	pass
