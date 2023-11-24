# Scene Requirement
![Basic Structure Overview](../assets/guides/basic-setup.svg)

To get started with the addon, the scene will need the below basic setup:

- `Camera2D`/`Camera3D` - ideally without a parent node except for the scene's root.
- `PhantomCameraHost` - as a child of the `Camera2D`/`Camera3D`.
- `PhantomCamera2D`/`PhantomCamera3D` - ideally without a parent node except for the scene's root.

After this, the scene is now meeting the minimum requirements and you can now use the `PCam` however you wish!

## What now?
Explore the various properties and built-in behaviours on the `PCams`, such as the various [Follow Modes](../follow-modes/overview.md), and find an approach that suits your needs. Alternatively, keep on reading about the [Core Nodes](../core-nodes/phantom-camera-2d) in the next page.