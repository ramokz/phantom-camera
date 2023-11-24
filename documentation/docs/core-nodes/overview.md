# Core Nodes

<br>

<div class="side-by-side">
<img alt="Phantom Camera 2D" src="../assets/icons/phantom-camera-2D.svg" width="128" />
<img alt="Phantom Camera 3D" src="../assets/icons/phantom-camera-3D.svg" width="128" />
</div>

### Phantom Camera (2D & 3D)
Shortened to `PCam` (text) and `pcam` (code) is the primary node type for this addon. It exists in two different variants, one for 2D scenes and another for 3D scenes. See the [Phantom Camera 2D](./phantom-camera-2d) and [Phantom Camera 3D](./phantom-camera-3d) pages respectively for more details.

Its purpose is to contain the positional, rotational, tween and other data that should be applied to a scene's `Camera`. Upon a `PCam` becoming active it will effectively take over the scene's `Camera` node. Moving that `PCam` node then directly affects the `Camera`.

Because multiple of these can exist in a given scene, it doesn't communicate directly to a `Camera`. Instead, it sends signals to the scene's `PhantomCameraHost` (below), which handles transferring the information from the `PCam` to the `Camera` node. The `PhantomCameraHost` then determines which `PCam` should be followed and relays that to the `Camera`.

<img src="../assets/icons/phantom-camera-host.svg" width="128" />

### Phantom Camera Host
Manages a scene's `PCam` and `Camera`. This node decides which `PCam` the `Camera` should be attached to and, consequently, what logic is should have. For all intents and purposes, it's a set and forget node once it's a child of a `Camera` node. See the [PhantomCameraHost page](../core-nodes/phantom-camera-host) for more details.
