![Wiki-PhantomCamera2D](https://user-images.githubusercontent.com/5159399/216775720-f97259db-b8d8-4e52-a995-d82f35abe2f7.png)
# Overview
> Inherits: Node2D

Shorten to `pcam_2D`, is used in 2D scenes and allows for following any node that is inherited from `Node2D`.

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

### `PhantomCameraHost` get_pcam_host_owner ()

Gets the current `PhantomCameraHost` this `PhantomCamera2D` is assigned to.

#### Example
```gdscript
    pcam.get_pcam_host_owner()
```

<hr>

### `bool` is_active ()

```gdscript
    pcam.is_active()
```
Gets current active state of the PhantomCamera2D.

If it returns true, it means the `PhantomCamera2D` is what the `Camera2D` is currently following.

<h3>Methods</h3>
<table>
    <tr>
        <td width="1200">
            <h4><code>PhantomCameraHost</code> get_pcam_host_owner ()</h4>
            <blockquote><b>Example:</b> pcam.get_pcam_host_owner()</blockquote>
            <p>Gets the current <code>PhantomCameraHost</code> this <code>PhantomCamera2D</code> is assigned to.</p>
        </td>
    </tr>
    <tr>
        <td width="1200">
            <h4><code>bool</code> is_active ()</h4>
            <blockquote><b>Example:</b> pcam.is_active()</blockquote>
            <p>Gets current active state of the <code>PhantomCamera2D</code>.</p>
            <p>If it returns true, it means the <code>PhantomCamera2D</code> is what the <code>Camera2D</code> is currently following.</p>
        </td>
      </tr>
    <tr>
        <td width="1200">
            <h4><code>void</code> set_tween_on_load (bool value)</h4>
            <blockquote><b>Example:</b> pcam.tween_onload(false)</blockquote>
            <p>Enables or disables the Tween on Load. </p>
        </td>
    </tr>
    <tr>
        <td width="1200">
            <h4><code>bool</code> is_tween_on_load ()</h4>
            <blockquote><b>Example:</b> pcam.is_tween_on_load()</blockquote>
            <p>Gets the current Tween On Load value.</p>
        </td>
    </tr>
    <tr>
        <td width="1200">
            <h4><code>string</code> get_inactive_update_mode ()</h4>
            <blockquote><b>Example:</b> pcam.get_inactive_update_mode()</blockquote>
            <p>Returns Interactive Update Mode property name.</p>
        </td>
    </tr>
</table>