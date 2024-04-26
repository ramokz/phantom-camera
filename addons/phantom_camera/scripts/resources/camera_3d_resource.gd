@icon("res://addons/phantom_camera/icons/phantom_camera_camera_3d_resource.svg")
class_name Camera3DResource
extends Resource

## Resource for [PhantomCamera3D] to override various [Camera3D] properties.
##
## The overrides defined here will be applied to the [Camera3D] upon the
## [PhantomCamera3D] becoming active.

## Overrides [member Camera3D.cull_mask].
@export_flags_3d_physics var cull_mask: int = 1048575

## Overrides [member Camera3D.h_offset].
@export var h_offset: float = 0

## Overrides [member Camera3D.v_offset].
@export var v_offset: float = 0

## Overrides [member Camera3D.fov].
@export var fov: float = 75
