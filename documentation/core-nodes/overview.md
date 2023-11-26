# Core Nodes

<br>

<div class="side-by-side">
<img alt="PhantomCamera2D" src="/assets/icons/phantom-camera-2D.svg" width="128" />
<img alt="PhantomCamera3D" src="/assets/icons/phantom-camera-3D.svg" width="128" />
</div>

### Phantom Camera (2D & 3D)
Shortened to `PCam` (text) and `pcam` (code) is the primary node type for this addon. It exists in two different variants, one for 2D scenes and another for 3D scenes. See the [PhantomCamera2D](./phantom-camera-2d) and [PhantomCamera3D](./phantom-camera-3d) pages respectively for more details.

Its purpose is to contain the positional, rotational, tween and other data that should be applied to a scene's `Camera`. Upon a `PCam` becoming active it will effectively take over the scene's `Camera` node and apply its data to it.

<img src="/assets/icons/phantom-camera-host.svg" width="128" />

### Phantom Camera Host
Manages a scene's `PCams` and `Camera`. This node decides which `PCam` the `Camera` should be attached to and, consequently, what logic it should have. For all intents and purposes, it's a set and forget node once it's a child of a `Camera` node.
