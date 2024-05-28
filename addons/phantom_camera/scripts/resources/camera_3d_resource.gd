@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_camera_3d_resource.svg")
class_name Camera3DResource
extends Resource

## Resource for [PhantomCamera3D] to override various [Camera3D] properties.
##
## The overrides defined here will be applied to the [Camera3D] upon the
## [PhantomCamera3D] becoming active.

## Overrides [member Camera3D.cull_mask].
@export_flags_3d_render var cull_mask: int = 1048575

## Overrides [member Camera3D.h_offset].
@export_range(0, 1, 0.001, "hide_slider", "suffix:m") var h_offset: float = 0

## Overrides [member Camera3D.v_offset].
@export_range(0, 1, 0.001, "hide_slider", "suffix:m") var v_offset: float = 0


enum ProjectionType {
	PERSPECTIVE = 	0, ## Perspective projection. Objects on the screen becomes smaller when they are far away.
	ORTHOGONAL = 	1, ## Orthogonal projection, also known as orthographic projection. Objects remain the same size on the screen no matter how far away they are.
	FRUSTUM = 		2, ## Frustum projection. This mode allows adjusting frustum_offset to create "tilted frustum" effects.
}

## Overrides [member Camera3D.projection].
@export var projection: ProjectionType = ProjectionType.PERSPECTIVE:
	set(value):
		projection = value
		notify_property_list_changed()
	get:
		return projection

## Overrides [member Camera3D.fov].
@export_range(1, 179, 0.1, "degrees") var fov: float = 75

## Overrides [member Camera3D.size].
@export_range(0.001, 100, 0.001, "suffix:m", "or_greater") var size: float = 1

## Overrides [member Camera3d.frustum_offset].
@export var frustum_offset: Vector2 = Vector2.ZERO

## Overrides [member Camera3D.near].
@export_range(0.001, 10, 0.001, "suffix:m", "or_greater") var near: float = 0.05

## Overrides [member Camera3D.far].
@export_range(0.01, 4000, 0.001, "suffix:m","or_greater") var far: float = 4000


func _validate_property(property: Dictionary) -> void:
	if property.name == "fov" and not projection == ProjectionType.PERSPECTIVE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "size" and projection == ProjectionType.PERSPECTIVE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "frustum_offset" and not projection == ProjectionType.FRUSTUM:
		property.usage = PROPERTY_USAGE_NO_EDITOR
