@tool
class_name PhantomCameraNoiseEmitter3D
extends Node3D

@export var noise_resource: PhantomCameraNoise3D

## If true, repeats the noise indefinitely once started.
@export var loop: bool = false:
	set(value):
		loop = value
		notify_property_list_changed()
	get:
		return loop

## Defines the duration of the noise 
@export_range(0, 100, 0.01, "or_greater") var duration: float = 1

## Defines the amount of time the noise should take to come to a stop once the .
@export_range(0, 100, 0.01, "or_greater") var decay: float = 1

var pcam_parent: PhantomCamera3D

signal trigger_noise


func _validate_property(property):
	if property.name == "duration" and loop:
		property.usage = PROPERTY_USAGE_NO_EDITOR


func _enter_tree():
	if get_parent() is PhantomCamera3D:
		pcam_parent = get_parent()


func assign_noise_resource() -> void:
	pass


func trigger_noise_resource(pcam: PhantomCamera3D = pcam_parent) -> void:
	print(pcam)
