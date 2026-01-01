@tool
class_name TweenControllerResource
extends Resource

enum Type {
	PHANTOM_CAMERA  = 0,
	TWEEN_RESOURCE  = 1, ## Tweens when this resource type is applied to a PCam.[br][color=yellow]Note:[/color] This must be a saved resource in order to be triggered.
	ANY             = 2, ## Will trigger on any transition. [br] [color=red]Warning[/color] Be mindful when using this type.
}
@export var tween_resource: PhantomCameraTween

@export_group("From")

@export var from_type: Type = Type.PHANTOM_CAMERA:
	set(value):
		from_type = value
		notify_property_list_changed()
	get:
		return from_type

@export var from_tween_resource: Array[PhantomCameraTween] = []:
	set(value):
		from_tween_resource = value
	get:
		return from_tween_resource

@export_node_path("PhantomCamera2D", "PhantomCamera3D") var from_phantom_camera: Array[NodePath] = []


@export_group("To")

@export var to_type: Type:
	set(value):
		to_type = value
		notify_property_list_changed()

@export var to_tween_resource: Array[PhantomCameraTween] = []:
	set(value):
		to_tween_resource = value
		notify_property_list_changed()
	get:
		return to_tween_resource

@export_node_path("PhantomCamera2D", "PhantomCamera3D") var to_phantom_camera: Array[NodePath] = []


func _validate_property(property: Dictionary) -> void:
	if property.name == "from_phantom_camera" and from_type != Type.PHANTOM_CAMERA:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "from_tween_resource" and from_type != Type.TWEEN_RESOURCE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "to_phantom_camera" and to_type != Type.PHANTOM_CAMERA:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "to_tween_resource" and to_type != Type.TWEEN_RESOURCE:
		property.usage = PROPERTY_USAGE_NO_EDITOR
