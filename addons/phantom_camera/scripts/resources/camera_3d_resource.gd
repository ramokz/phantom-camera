@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_camera_3d_resource.svg")
class_name Camera3DResource
extends Resource

## Resource for [PhantomCamera3D] to override various [Camera3D] properties.
##
## The overrides defined here will be applied to the [Camera3D] upon the
## [PhantomCamera3D] becoming active.

enum KeepAspect {
	KEEP_WIDTH = 0, ## Preserves the horizontal aspect ratio; also known as Vert- scaling. This is usually the best option for projects running in portrait mode, as taller aspect ratios will benefit from a wider vertical FOV.
	KEEP_HEIGHT = 1, ## Preserves the vertical aspect ratio; also known as Hor+ scaling. This is usually the best option for projects running in landscape mode, as wider aspect ratios will automatically benefit from a wider horizontal FOV.
}

enum ProjectionType {
	PERSPECTIVE = 	0, ## Perspective projection. Objects on the screen becomes smaller when they are far away.
	ORTHOGONAL = 	1, ## Orthogonal projection, also known as orthographic projection. Objects remain the same size on the screen no matter how far away they are.
	FRUSTUM = 		2, ## Frustum projection. This mode allows adjusting frustum_offset to create "tilted frustum" effects.
}

## Overrides [member Camera3D.keep_aspect].
@export var keep_aspect: KeepAspect = KeepAspect.KEEP_HEIGHT:
	set(value):
		keep_aspect = value
		emit_changed()
	get:
		return keep_aspect

## Overrides [member Camera3D.cull_mask].
@export_flags_3d_render var cull_mask: int = 1048575:
	set(value):
		cull_mask = value
		emit_changed()
	get:
		return cull_mask

## Overrides [member Camera3D.h_offset].
@export_range(0, 1, 0.001, "or_greater", "or_less", "hide_slider", "suffix:m") var h_offset: float = 0:
	set(value):
		h_offset = value
		emit_changed()
	get:
		return h_offset

## Overrides [member Camera3D.v_offset].
@export_range(0, 1, 0.001, "or_greater", "or_less", "hide_slider", "suffix:m") var v_offset: float = 0:
	set(value):
		v_offset = value
		emit_changed()

## Overrides [member Camera3D.projection].
@export var projection: ProjectionType = ProjectionType.PERSPECTIVE:
	set(value):
		projection = value
		notify_property_list_changed()
		emit_changed()
	get:
		return projection

## Overrides [member Camera3D.fov].
@export_range(1, 179, 0.1, "degrees") var fov: float = 75:
	set(value):
		fov = value
		emit_changed()
	get:
		return fov

## Overrides [member Camera3D.size].
@export_range(0.001, 100, 0.001, "suffix:m", "or_greater") var size: float = 1:
	set(value):
		size = value
		emit_changed()
	get:
		return size

## Overrides [member Camera3d.frustum_offset].
@export var frustum_offset: Vector2 = Vector2.ZERO:
	set(value):
		frustum_offset = value
		emit_changed()
	get:
		return frustum_offset

## Overrides [member Camera3D.near].
@export_range(0.001, 10, 0.001, "suffix:m", "or_greater") var near: float = 0.05:
	set(value):
		near = value
		emit_changed()
	get:
		return near

## Overrides [member Camera3D.far].
@export_range(0.01, 4000, 0.001, "suffix:m","or_greater") var far: float = 4000:
	set(value):
		far = value
		emit_changed()
	get:
		return far


func _validate_property(property: Dictionary) -> void:
	if property.name == "fov" and not projection == ProjectionType.PERSPECTIVE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "size" and projection == ProjectionType.PERSPECTIVE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "frustum_offset" and not projection == ProjectionType.FRUSTUM:
		property.usage = PROPERTY_USAGE_NO_EDITOR
