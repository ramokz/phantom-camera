@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_tween.svg")
class_name TweenDirectorResource
extends Resource

## Resource to conditionally override tweens between specific [param PhantomCameras].
##
## [param TweenDirectorResource] allows for overriding the [PhantomCameraTween] applied to [param PhantomCameras]
## based on a list of [b]To[/b] and [b]From[/b] targets.[br][br]
## The targets are defined by either individually selected [param PhantomCameras] in the current scene,
## or by the [PhantomCameraTween] resource IDs applied to them.

#region Enums

enum Type {
	PHANTOM_CAMERA  = 0, ## Identify individual [param PhantomCameras] from the current current scene.
	TWEEN_RESOURCE  = 1, ## Identify [param PhantomCameras] based on the [PhantomCameraTween] resource applied to them.[br][color=3AB99A]Note:[/color] The resources [i]must[/i] be saved on the filesystem and applied to [param PhantomCameras] in order to be referenced.
	ANY             = 2, ## Applies globally to all [param PhantomCameras].[br][color=3AB99A]Note:[/color] Be mindful when using this.
}

#endregion

#region Public Variables

## The [PhantomCameraTween] that should be used if a member of [member from_type] and [member to_type] list are valid when a tween should occur.
@export var tween_resource: PhantomCameraTween = null


@export_group("From")
## The type idenfider for the [b]from[/b], or currently active, [param PhantomCamera] that should make the [member tween_resource] override
## the tween defined in the [param To] section.
@export var from_type: Type = Type.PHANTOM_CAMERA:
	set(value):
		from_type = value
		notify_property_list_changed()
	get:
		return from_type

## The list of [param PhantomCameras] that should trigger the [member tween_resource] overrided when tweened [i]from[/i].
@export_node_path("PhantomCamera2D", "PhantomCamera3D") var from_phantom_cameras: Array[NodePath] = []

## The list of [param PhantomCameras] with the [PhantomCameraTween] resources applied to them that should trigger the
## [member tween_resource] override when tweened [i]from[/i].[br]
## [color=3AB99A][b]Important:[/b][/color] The tween resources on the list [i]must[/i] be saved on the filestyle.
@export var from_tween_resources: Array[PhantomCameraTween] = []:
	set(value):
		from_tween_resources = value
	get:
		return from_tween_resources

@export_group("To")
## The type idenfider for the [b]to[/b], or about-to-become-active, [param PhantomCamera] that should make the [member tween_resource] override
## the tween defined in the [param To] section.
@export var to_type: Type = Type.PHANTOM_CAMERA:
	set(value):
		to_type = value
		notify_property_list_changed()

## The list of [param PhantomCamera] nodes that should trigger the [member tween_resource] overrided when tweened [i]to[/i].
@export_node_path("PhantomCamera2D", "PhantomCamera3D") var to_phantom_cameras: Array[NodePath] = []

## The list of [param PhantomCameras] with the [PhantomCameraTween] resources applied to them that should trigger the
## [member tween_resource] override when tweened [i]to[/i].[br]
## [color=3AB99A][b]Important:[/b][/color] The tween resources on the list [i]must[/i] be saved on the filestyle.
@export var to_tween_resources: Array[PhantomCameraTween] = []:
	set(value):
		to_tween_resources = value
		notify_property_list_changed()
	get:
		return to_tween_resources

#endregion


#region Private Functions

func _validate_property(property: Dictionary) -> void:
	if property.name == "from_phantom_cameras" and from_type != Type.PHANTOM_CAMERA:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "from_tween_resources" and from_type != Type.TWEEN_RESOURCE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "to_phantom_cameras" and to_type != Type.PHANTOM_CAMERA:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "to_tween_resources" and to_type != Type.TWEEN_RESOURCE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

#endregion
