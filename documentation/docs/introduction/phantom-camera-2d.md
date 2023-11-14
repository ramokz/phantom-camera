<img src="../assets/phantom-camera-2D.svg" height="256" width="256"/>

# PhantomCamera2D
> Inherits: Node2D

Shorten to `PCam2D` (text) or `pcam_2D` (code), is used in 2D scenes.

⚠️ A scene must contain a [`pcam_host`](https://github.com/ramokz/phantom-camera/wiki/PhantomCameraHost) for the `pcam_2D` node to work.

## Example Scene
Can be found in: `res://addons/phantom_camera/examples/2DExampleScene.tscn`

## Properties

<table>
  <tr>
    <td width="140">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Priority-(2D-&-3D)">
        <img src="https://github.com/ramokz/phantom-camera/blob/94cd88bac148e4d2f2e53bb0b3f370827d14fc4d/.github/assets/Icon-Priority.svg" width="100" height="100"/>
      </a>
    </td>
    <td width="1200">
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Priority-(2D-&-3D)">Priority</a>
      </h3>
      <p>
        Determines which <code>pcam_2D</code> should be active with the <code>Camera2D</code>.
      </p>
    </td>
  </tr>
  <tr>
    <td width="140">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)">
        <img src="https://github.com/ramokz/phantom-camera/blob/94cd88bac148e4d2f2e53bb0b3f370827d14fc4d/.github/assets/Icon-Follow.svg" width="100" height="100"/>
      </a>
    </td>
    <td width="1200">
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)">Follow Mode</a>
      </h3>
      <p>
        Define how the <code>Camera2D</code> should follow.
      </p>
    </td>
  </tr>
  <tr>
    <td width="140">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Zoom-(2D)">
        <img src="https://github.com/ramokz/phantom-camera/blob/94cd88bac148e4d2f2e53bb0b3f370827d14fc4d/.github/assets/Icon-Zoom.svg" width="100" height="100"/>
      </a>
    </td>
    <td width="1200">
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Zoom-(2D)">Zoom</a>
      </h3>
      <p>
        Set the Zoom level for the <code>pcam_2D</code>.
      </p>
    </td>
  </tr>
  <tr>
    <td width="140">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Tween-(2D-&-3D)">
        <img src="https://github.com/ramokz/phantom-camera/blob/94cd88bac148e4d2f2e53bb0b3f370827d14fc4d/.github/assets/Icon-Tween.svg" width="100" height="100"/>
      </a>
    </td>
    <td width="1200">
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Tween-(2D-&-3D)">Tween</a>
      </h3>
      <p>
        Tweak how the <code>Camera2D</code> tweens to this camera once becoming active.
      </p>
    </td>
    </tr>
</table>

## Methods

<!--@include: ./parts/phantom-camera-methods.md-->