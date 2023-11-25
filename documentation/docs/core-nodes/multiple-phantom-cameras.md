# Multiple Phantom Cameras
When multiple `PCams` are in a given scene, the `Priority` property is what determines which one controls the `Camera` node. The one with the highest value becomes the active and, therefore, controlling one.

Switching a `PCam`'s priority can be done either from the inspector within the editor on the individual `PCam` node, or via code - see the [Priority page](../priority) for more.

Changing the active `PCam`, when there are multiple in a scene, is also what triggers a tween, or interpolation, between different `PCams` - see the [Tween page](../tween) for more.

## Visual Example
![prim](../assets/guides/phantom-camera-first-priority.svg)
_PlayerPCam has the highest Priority at 10_

![prim](../assets/guides/phantom-camera-second-priority.svg)
_NodePCam now has the highest Priority at 20_