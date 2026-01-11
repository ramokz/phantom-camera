@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_tween_director_resource.svg")
class_name TweenDirectorResource
extends Resource

## Resource to conditionally override tweens between specific [param PhantomCameras].
##
## [param TweenDirectorResource] allows for overriding the [PhantomCameraTween] applied to [param PhantomCameras]
## based on a list of [b]To[/b] and [b]From[/b] targets.[br][br]
## The targets are defined by either individually selected [param PhantomCameras] in the current scene,
## or by the [PhantomCameraTween] resource applied to them.

#region Enums

enum Type {
	PHANTOM_CAMERA  = 0, ## Target individual [param PhantomCameras] from the current current scene.
	TWEEN_RESOURCE  = 1, ## Target [param PhantomCameras] based on the [PhantomCameraTween] resource applied to them.[br][color=3AB99A]Note:[/color] The resources [b]must[/b] be saved on the filesystem and applied to [param PhantomCameras] in order to be referenced.
	ANY             = 2, ## Target all [param PhantomCameras] in the scene.
}

#endregion


#region Public Variables

## The [PhantomCameraTween] that should be used if a member of [member from_type] and [member to_type] list match when a tween should occur.
@export var tween_resource: PhantomCameraTween = null:
	set = set_tween_resource,
	get = get_tween_resource


@export_group("From")
## The type identifier for the [b]from[/b], or currently active, [param PhantomCamera] that should make the [member tween_resource] override
## the tween defined in the [param To] section.
@export var from_type: Type = Type.PHANTOM_CAMERA:
	set = set_from_type,
	get = get_from_type

## The list of [param PhantomCameras] that should trigger the [member tween_resource] override when tweened [b]from[/b].
@export_node_path("PhantomCamera2D", "PhantomCamera3D") var from_phantom_cameras: Array[NodePath] = []:
	set = set_from_phantom_cameras,
	get = get_from_phantom_cameras

## The list of [param PhantomCameras] with the [PhantomCameraTween] resources applied to them that should trigger the
## [member tween_resource] override when tweened [b]from[/b].[br]
## [color=3AB99A][b]Important:[/b][/color] The tween resources on the list [b]must[/b] be saved on the filestyle.
@export var from_tween_resources: Array[PhantomCameraTween] = []:
	set = set_from_tween_resources,
	get = get_from_tween_resources

@export_group("To")
## The type identifier for the [b]to[/b], or about-to-become-active, [param PhantomCamera] that should make the [member tween_resource] override
## the tween defined in the [param To] section.
@export var to_type: Type = Type.PHANTOM_CAMERA:
	set = set_to_type,
	get = get_to_type

## The list of [param PhantomCamera] nodes that should trigger the [member tween_resource] override when tweened [b]to[/b].
@export_node_path("PhantomCamera2D", "PhantomCamera3D") var to_phantom_cameras: Array[NodePath] = []:
	set = set_to_phantom_cameras,
	get = get_to_phantom_cameras

## The list of [param PhantomCameras] with the [PhantomCameraTween] resources applied to them that should trigger the
## [member tween_resource] override when tweened [b]to[/b].[br]
## [color=3AB99A][b]Important:[/b][/color] The tween resources on the list [b]must[/b] be saved on the filestyle.
@export var to_tween_resources: Array[PhantomCameraTween] = []:
	set = set_to_tween_resources,
	get = get_to_tween_resources

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


#region Public Functions

## Sets the [member tween_resource] value.
func set_tween_resource(value: PhantomCameraTween) -> void:
	tween_resource = value

## Returns the [member tween_resource] value.
func get_tween_resource() -> PhantomCameraTween:
	return tween_resource


## Sets the [member from_type] value.
func set_from_type(value: Type) -> void:
	from_type = value
	notify_property_list_changed()

## Returns the [member from_type] value.
func get_from_type() -> Type:
	return from_type


## Sets the [member from_phantom_cameras] value.
func set_from_phantom_cameras(value: Array[NodePath]) -> void:
	from_phantom_cameras = value

## Returns the [member from_type] value.
func get_from_phantom_cameras() -> Array[NodePath]:
	return from_phantom_cameras


## Sets the [member from_tween_resources] value.
func set_from_tween_resources(value: Array[PhantomCameraTween]) -> void:
	from_tween_resources = value

## Returns the [member from_type] value.
func get_from_tween_resources() -> Array[PhantomCameraTween]:
	return from_tween_resources


## Sets the [member to_type] value.
func set_to_type(value: Type) -> void:
	to_type = value
	notify_property_list_changed()

## Returns the [member from_type] value.
func get_to_type() -> Type:
	return to_type


## Sets the [member to_phantom_cameras] value.
func set_to_phantom_cameras(value: Array[NodePath]) -> void:
	to_phantom_cameras = value

## Returns the [member to_phantom_cameras] value.
func get_to_phantom_cameras() -> Array[NodePath]:
	return to_phantom_cameras


## Sets the [member to_tween_resources] value.
func set_to_tween_resources(value: Array[PhantomCameraTween]) -> void:
	to_tween_resources = value

## Returns the [member to_tween_resources] value.
func get_to_tween_resources() -> Array[PhantomCameraTween]:
	return to_tween_resources

#endregion
