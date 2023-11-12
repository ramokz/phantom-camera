# Follow - Third Person
As the name implies, this mode is meant to be used for third person camera experiences. It works by applying a `SpringArm3D` where the properties, such as `Collison Mask`, `Spring Length` and `Margin`, can be controlled from the `PhantomCamera3D`.

To adjust the orbit rotation around the target, the PhantomCamera3D uses the setter function `set_third_person_rotation() (radians)` or `set_third_person_rotation_degrees() (degrees)`.

## Example Setup
```gdscript
var mouse_sensitivity: float = 0.05

var min_yaw: float = -89.9
var max_yaw: float = 50

var min_pitch: float = 0
var max_pitch: float = 360

func _unhandled_input(event) -> void:
  # Trigger whenever the mouse moves
  if event is InputEventMouseMotion:
    var pcam_rotation_degrees: Vector3

    # Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor 
    pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()

    # Change the X rotation
    pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
		
    # Clamp the rotation in the X axis so it go over or under the target
    pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_yaw, max_yaw)

    # Change the Y rotation value
    pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
		
    # Sets the rotation to fully loop around its target, but witout going below or exceeding 0 and 360 degrees respectively
    pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_pitch, max_pitch)
		
    # Change the SpringArm3D node's rotation and rotate around its target
    pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
```

## Setters
<!--@include: ./common/methods/follow-mode.md-->

---

<!--@include: ./common/methods/follow-target-node.md-->