<img src="../assets/icons/phantom-camera-host.svg" height="256" width="256"/>

# PhantomCameraHost
> Inherits: Node

`PhantomCameraHost` shortened to `PCamHost` (text) and `pcam_host` (code) manages a scene's `PCam2D`/ `PCam3D` nodes and is what ultimately supplies the logic to the `Camera2D`/`Camera3D`. It decides which `PCam2D`/`PCam3D` the `Camera2D`/`Camera3D` should be attached to and, consequently, its logic.

## Guide
Set this node as a direct child of the scene's `Camera2D`/`Camera3D` node.