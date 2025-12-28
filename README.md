<img width="850" alt="phantom-camera-readme-header" src="https://phantom-camera.dev/assets/github/readme-header.png">

<p align="center">
  <a href="https://godotengine.org/download/windows/">
      <img alt="Static Badge" src="https://img.shields.io/badge/Godot-4.3%2B-blue">
  </a>
  <a href="LICENSE">
    <img alt="GitHub License" src="https://img.shields.io/github/license/ramokz/phantom-camera">
  </a>
</p>

# What is it?
Phantom Camera is a Godot 4 plugin designed to provide and simplify common behaviors for the built-in `Camera2D` and `Camera3D` nodes - heavily inspired by a Unity package called Cinemachine.

It allows for simple behaviours such as following and looking at specific nodes, with an optional smooth/dampened movement, to more advance logic like reframing itself to keep multiple nodes in view and dynamically animate between specific camera positions, i.e. other `PhantomCamera` nodes, on demand.

https://github.com/ramokz/phantom-camera/assets/5159399/2a900def-4a8b-46c2-976c-b8e66feec953

<table>
  <tr>
    <th>Documentation & Guides</th>
    <th>Roadmap</th>
  <tr>
  <tbody>
  <tr>
    <td width="1200" align="center" valign="top">
      <a href="https://phantom-camera.dev/"><img src=".github/assets/icons/Readme-Wiki.svg"></a>
    </td>
     <td width="1200" align="center" valign="top">
      <a href="https://github.com/ramokz/phantom-camera/milestones"><img src=".github/assets/icons/Readme-Roadmap.svg"></a>
    </td>
  </tbody>
</table>

### Showcases

<table>
  <tr>
    <td>
      <a href="https://www.youtube.com/watch?v=1Gtvr-Jk-iE">
        <img src="https://phantom-camera.dev/assets/github/yt-gamefromscratch-0.png" width="100%" alt="GameFromScratch's Youtube Overview"/>
      </a>
    </td>
    <td>
      <a href="https://www.youtube.com/watch?v=85K0e2Y0U3Q">
        <img src="https://phantom-camera.dev/assets/github/yt-bissash-0.png" width="100%" alt="Bissash's Youtube Video"/>
      </a>
    </td>
</tr>
  <tr>
    <td align="center">
      <p>
        <i>(English)</i>
      </p>
      <p>
        <a href="https://www.youtube.com/watch?v=1Gtvr-Jk-iE" target="_blank">Phantom Camera For Godot Is Awesome!</a>
        <br>
        <b>GameFromScratch</b>
      </p>
    </td>
    <td align="center" valign="top">
      <p>
        <i>(Spanish)</i>
      </p>
      <p>
        <a href="https://www.youtube.com/watch?v=85K0e2Y0U3Q" target="_blank">Mejores cámaras con Phantom Camera</a>
        <br>
        <b>Bissash</b>
      </p>
    </td>
  </tr>
<tr>
    <td>
      <a href="https://www.youtube.com/watch?v=5Y6AQG-Ik2A">
        <img src="https://phantom-camera.dev/assets/github/yt-clecioespindola-0.png" width="100%" alt="Clécio Espindola GameDev's Youtube Video"/>
      </a>
    </td>
    <td>
      <a href="https://www.youtube.com/watch?v=bKNmsae5zXk">
        <img src="https://phantom-camera.dev/assets/github/yt-devworm-0.png" width="100%" alt="Clécio Espindola GameDev's Youtube Video"/>
      </a>
    </td>
</tr>
<tr>
    <td align="center">
      <p>
        <i>(Portuguese)</i>
      </p>
      <p>
        <a href="https://www.youtube.com/watch?v=5Y6AQG-Ik2A" target="_blank">
          CÂMERA mais DINÂMICA com Phanton Camera
        </a>
        <br>
        <b>Clécio Espindola GameDev</b>
      </p>
    </td>
<td align="center">
  <p>
    <i>(English)</i>
  </p>
  <a href="https://youtube.com/watch?v=bKNmsae5zXk" target="_blank">
    The 4 MUST Have ADDONS for Godot 4
  </a>
    <br>
    <b>DevWorm</b>
  </td>
</tr>
</table>

# Features

<a href="https://phantom-camera.dev/priority">
<img src="https://phantom-camera.dev/assets/icons/feature-priority.svg" width="100"/>
</a>
<h3>
    <a href="https://phantom-camera.dev/priority">Priority</a>
</h3>
<p>
Determines which <code>PhantomCamera</code> should be active with the <code>Camera2D</code>/<code>Camera3D</code>.
</p>
<p>
When a new camera recieves a higher priority than currently active <code>PhantomCamera</code> the <code>Camera2D</code>/<code>Camera3D</code> will seamlessly transition to the new one.
</p>

<hr>

<a href="https://phantom-camera.dev/follow-modes/overview">
<img src="https://phantom-camera.dev/assets/icons/feature-follow.svg" width="100"/>
</a>
<h3>
<a href="https://phantom-camera.dev/follow-modes/overview">Follow Mode</a>
</h3>
<p>
Define how the <code>Camera2D</code>/<code>Camera3D</code> should follow, or reposition based on, its target(s).
</p>

<a href="https://phantom-camera.dev/follow-modes/glued">
  <img src="https://phantom-camera.dev/assets/icons/follow-glued.svg"/>
</a>
<h4>
  <a href="https://phantom-camera.dev/follow-modes/glued">Glued</a>
</h4>
<p>
  Sticks to its target.
</p>

<br>

<a href="https://phantom-camera.dev/follow-modes/simple">
  <img src="https://phantom-camera.dev/assets/icons/follow-simple.svg"/>
</a>
<h4>
    <a href="https://phantom-camera.dev/follow-modes/simple">Simple</a>
</h4>
<p>
  Follows the target with an optional offset and damping.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-2D.svg" width="32" height="32"/>
              <br/>
              <b>2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-3D.svg" width="32" height="32"/>
              <br/>
              <b>3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">      
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/ec211454-5079-44d7-b4f9-29204f3f836f"/> 
        </td>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/b992b06f-e9bb-4f52-b55d-427c10fbef72"/>
        </td>
    </tr>
</table>

<br>

<a href="https://phantom-camera.dev/follow-modes/group">
  <img src="https://phantom-camera.dev/assets/icons/follow-group.svg"/>
</a>

<h4><a href="https://phantom-camera.dev/follow-modes/group">Group</a></h4>
<p>
  Follows the centre of a collection of targets.
</p>
<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-2D.svg" width="32" height="32"/>
              <br/>
              <b>2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-3D.svg" width="32" height="32"/>
              <br/>
              <b>3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/e1905dd4-16cf-43ab-a369-5ac29e820a38"/>
        </td>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/60732a36-ff63-461d-972b-be179121fd12"/>
        </td>
    </tr>
</table>


<br>

<a href="https://phantom-camera.dev/follow-modes/path">
  <img src="https://phantom-camera.dev/assets/icons/follow-path.svg"/>
</a>
<h4>
    <a href="https://phantom-camera.dev/follow-modes/path">Path</a>
</h4>
<p>
  Follows a target while being positionally confined to a <code>Path node</code>.
</p>
<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-2D.svg" width="32" height="32"/>
              <br/>
              <b>2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-3D.svg" width="32" height="32"/>
              <br/>
              <b>3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/2b099a97-ef6d-4546-8863-a03297eef830"/>
        </td>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/521f713a-eee4-488e-9093-17aaa3c31acb"/>
        </td>
    </tr>
</table>

<br>

<a href="https://phantom-camera.dev/follow-modes/framed">
  <img src="https://phantom-camera.dev/assets/icons/follow-framed.svg"/>
</a>
<h4>
    <a href="https://phantom-camera.dev/follow-modes/framed">Framed</a>
</h4>
<p>
  Enables dynamic framing of a given target using dead zones. Dead zones enable the camera to remain still until the target moves far enough away from the camera's view. This is determined by the horizontal and vertical dead zone size in their respective properties within the inspector.
</p>
<table>
    <thead>
        <tr>
            <th align="center" valign="top">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-2D.svg" width="32" height="32"/>
              <br/>
              <b>2D</b>
            </th>
            <th align="center" valign="top">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-3D.svg" width="32" height="32"/>
              <br/>
              <b>3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">      
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/a887a603-b95f-474e-9141-b451ac6a8d91"/> 
        </td>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/ff091b27-bdbb-4115-a3f2-939a24b2b6de"/>
        </td>
    </tr>
</table>

<br>

<a href="https://phantom-camera.dev/follow-modes/third-person">
  <img src="https://phantom-camera.dev/assets/icons/follow-third-person.svg"/>
</a>
<h4>
    <a href="https://phantom-camera.dev/follow-modes/third-person">Third Person</a>
</h4>
<p>
  As the name implies, this mode is meant to be used for third person camera experiences.<br>
It works by applying a <code>SpringArm3D</code> node as a parent, where its properties, such as <code>Collison Mask</code>, <code>Spring Length</code> and <code>Margin</code>, can be adjusted from the <code>PhantomCamera</code> node.
</p>
<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-2D.svg" width="32" height="32"/>
              <br/>
              <b>2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-3D.svg" width="32" height="32"/>
              <br/>
              <b>3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">      
            Not available in 2D
        </td>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/419c403d-257a-4d15-8c16-04972fc36a43"/>
        </td>
    </tr>
</table>

<hr>

<a href="https://phantom-camera.dev/core-nodes/phantom-camera-2d#zoom">
<img src="https://phantom-camera.dev/assets/icons/feature-zoom.svg" width="100"/>
</a>
<h3>
<a href="https://phantom-camera.dev/core-nodes/phantom-camera-2d#zoom">Zoom (2D)</a>
</h3>
<p>
Define the Zoom level for the <code>Camera2D</code>.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-2D.svg" width="32" height="32"/>
              <br/>
              <b>2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-3D.svg" width="32" height="32"/>
              <br/>
              <b>3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/327db36a-29c1-40d3-a378-18e98d9012ce"/>
        </td>
        <td align="center" valign="center">
            Not available in 3D
        </td>
    </tr>
</table>

<hr>

<a href="https://phantom-camera.dev/look-at-modes/overview">
<img src="https://phantom-camera.dev/assets/icons/feature-look-at.svg" width="100"/>
</a>

<h3>
<a href="https://phantom-camera.dev/look-at-modes/overview">Look At (3D)</a>
</h3>
<p>
Defines where the <code>Camera3D</code> should be looking—adjusting its rotational value.
</p>
<a href="https://phantom-camera.dev/look-at-modes/mimic">
<img src="https://phantom-camera.dev/assets/icons/look-at-mimic.svg"/>
</a>
<br>
<h4>
  <a href="https://phantom-camera.dev/look-at-modes/mimic">Mimic</a>
</h4>
<p>
Copies the rotational value of its target.
</p>

<br>

<a href="https://phantom-camera.dev/look-at-modes/simple">
<img src="https://phantom-camera.dev/assets/icons/look-at-simple.svg"/>
</a>
<br>
<h4>
  <a href="https://phantom-camera.dev/look-at-modes/simple">Simple</a>
</h4>
<p>
Looks At the target with an optional offset.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-2D.svg" width="32" height="32"/>
              <br/>
              <b>2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-3D.svg" width="32" height="32"/>
              <br/>
              <b>3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">      
            Not available in 2D
        </td>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/9f740b3d-a244-4ada-88da-e7160cb7b0b0"/>
        </td>
    </tr>
</table>

<br>

<a href="https://phantom-camera.dev/look-at-modes/group">
 <img src="https://phantom-camera.dev/assets/icons/look-at-group.svg"/>
  <h4> 
   <a href="https://phantom-camera.dev/look-at-modes/group">Group</a>
  </h4>
</a>
<p>
 Looks at the centre of a collection of targets.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-2D.svg" width="32" height="32"/>
              <br/>
              <b>2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-3D.svg" width="32" height="32"/>
              <br/>
              <b>3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">      
            Not available in 2D
        </td>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/5350d466-a1ca-48b6-8b4f-bfc4009e2f6f"/>
        </td>
    </tr>
</table>

<hr>

<a href="https://phantom-camera.dev/tween">
<img src="https://phantom-camera.dev/assets/icons/feature-tween.svg" width="100"/>
</a>
<h3>
<a href="https://phantom-camera.dev/tween">Tween</a>
</h3>
<p>
Tweak how the <code>Camera2d</code>/<code>Camera3D</code> tweens to a newly active <code>PhantomCamera</code>.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-2D.svg" width="32" height="32"/>
              <br/>
              <b>2D</b>
            </th>
            <th align="center" valign="top">
              <img src="https://phantom-camera.dev/assets/icons/phantom-camera-3D.svg" width="32" height="32"/>
              <br/>
              <b>3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">      
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/b11e9447-26fe-4cda-b0af-8f0d2507bcdf"/> 
        </td>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/ec551b24-228e-4617-88e4-728315cf163d"/>
        </td>
    </tr>
</table>

<hr>

<a href="https://phantom-camera.dev/viewfinder">
    <img src="https://phantom-camera.dev/assets/icons/feature-viewfinder.svg" width="100" />
</a>

<h3><a href="https://phantom-camera.dev/viewfinder">Viewfinder</a></h3>

https://github.com/ramokz/phantom-camera/assets/5159399/6c9d1653-b4c6-4b5d-8855-402776645689

Preview what the `Camera2D` / `Camera3D` sees when attached to a PhantomCamera. Accessible from the bottom panel labelled `Phantom Camera`. The viewfinder rendering of the scene will only work when the combination of a `Camera`, `PhantomCameraHost` and `PhantomCamera` are present in the scene.

<hr>

### 🪀 Example Scenes
A 2D and 3D example scenes can be found inside `res://addons/phantom_camera/examples`.

## 💾 Installation
### Asset Library (Recommended - Stable)
1. In Godot, open the `AssetLib` tab.
2. Search for and select "Phantom Camera".
3. Download then install the plugin (be sure to only select the `phantom_camera` directory).
4. Enable the plugin inside `Project/Project Settings/Plugins`.

### Github Releases (Recommended - Stable)
1. Download a [release build](https://github.com/ramokz/phantom-camera/releases/).
2. Extract the zip file and move the `addons/phantom_camera` directory into the project root location.
3. Enable the plugin inside `Project/Project Settings/Plugins`.

### Github Main (Latest - Unstable)
1. Download the latest [`main branch`](https://github.com/ramokz/phantom-camera/archive/refs/heads/main.zip).
2. Extract the zip file and move the `addons/phantom_camera` directory into project's root location.
3. Enable the plugin inside `Project/Project Settings/Plugins`.

For more help,
see [Godot's official documentation](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)

## 📖 Roadmap
See the [project page](https://github.com/users/ramokz/projects/3/views/8) for upcoming features.

## FAQ
See the [FAQ page on the documentation site](https://phantom-camera.dev/support/faq).

## Contribution
See the [contribution guidelines on the documentation site](https://phantom-camera.dev/support/how-to-contribute).

## Credits
- [Unity's Cinemachine Package](https://unity.com/unity/features/editor/art-and-design/cinemachine) for the key
  inspiration
- [Godot](https://godotengine.org/) for their amazing work creating the engine

[MIT License](https://github.com/ramokz/phantom-camera/blob/main/LICENSE)
