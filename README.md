<img src="./.github/assets/banners/phantom-camera-banner.svg">

# What is it?
Phantom Camera is a Godot 4 plugin designed to provide and simplify common behaviors for the built-in `Camera2D` and `Camera3D` nodes - heavily inspired by a Unity package called Cinemachine.

It allows for simple behaviours such as following and looking at specific nodes, with an optional smooth/dampened movement, to more advance logic like reframing itself to keep multiple nodes in view and dynamically animate between specific camera positions, i.e. other `PhantomCamera` nodes, on demand.

https://github.com/ramokz/phantom-camera/assets/5159399/2a900def-4a8b-46c2-976c-b8e66feec953

<table>
  <tr>
    <th>Guides</th>
    <th>Roadmap</th>
  <tr>
  <tbody>
  <tr>
    <td width="1200" align="center" valign="top">
      <a href="https://github.com/ramokz/phantom-camera/wiki"><img src=".github/assets/icons/Readme-Wiki.svg"></a>
    </td>
     <td width="1200" align="center" valign="top">
      <a href="https://github.com/ramokz/phantom-camera/milestones"><img src=".github/assets/icons/Readme-Roadmap.svg"></a>
    </td>
  </tbody>
</table>

# Features

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Priority-(2D-&-3D)">
<img src=".github/assets/icons/Icon-Priority.svg" width="100"/>
</a>
<h3>
    <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Priority-(2D-&-3D)">Priority</a>
</h3>
<p>
Determines which <code>PhantomCamera</code> should be active with the <code>Camera2D</code>/<code>Camera3D</code>.
</p>
<p>
When a new camera recieves a higher priority than currently active <code>PhantomCamera</code> the <code>Camera2D</code>/<code>Camera3D</code> will seamlessly transition to the new one.
</p>

<hr>

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)">
<img src=".github/assets/icons/Icon-Follow.svg" width="100"/>
</a>
<h3>
<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)">Follow Mode</a>
</h3>
<p>
Define how the <code>Camera2D</code>/<code>Camera3D</code> should follow, or reposition based on, its target(s).
</p>

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#glued">
  <img src=".github/assets/icons/Follow-Glued.svg"/>
</a>
<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#glued">
  <h4>Glued</h4>
</a>
<p>
  Sticks to its target.
</p>

<br>

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#simple">
  <img src=".github/assets/icons/Follow-Simple.svg"/>
</a>
<h4>
    <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#simple">Simple</a>
</h4>
<p>
  Follows the target with an optional offset and damping.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/dea63fd6136e716f5840fde05fe5db4bcd1aae2b/.github/assets/PhantomCamera2D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/e0452e8c681ea51f9e678c903ad162a12037aa14/.github/assets/PhantomCamera3D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera3D</b>
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

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#group">
  <img src=".github/assets/icons/Follow-Group.svg"/>
</a>

<h4><a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#group">Group</a></h4>
<p>
  Follows the centre of a collection of targets.
</p>
<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/dea63fd6136e716f5840fde05fe5db4bcd1aae2b/.github/assets/PhantomCamera2D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/e0452e8c681ea51f9e678c903ad162a12037aa14/.github/assets/PhantomCamera3D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera3D</b>
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

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#path">
  <img src=".github/assets/icons/Follow-Path.svg"/>
</a>
<h4>
    <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#path">Path</a>
</h4>
<p>
  Follows a target while being positionally confined to a <code>Path node</code>.
</p>
<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/dea63fd6136e716f5840fde05fe5db4bcd1aae2b/.github/assets/PhantomCamera2D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/e0452e8c681ea51f9e678c903ad162a12037aa14/.github/assets/PhantomCamera3D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera3D</b>
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

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#framed">
  <img src=".github/assets/icons/Follow-Framed.svg"/>
</a>
<h4>
    <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#framed">Framed</a>
</h4>
<p>
  Enables dynamic framing of a given target using dead zones. Dead zones enable the camera to remain still until the target moves far enough away from the camera's view. This is determined by the horizontal and vertical dead zone size in their respective properties within the inspector.
</p>
<table>
    <thead>
        <tr>
            <th align="center" valign="top">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/dea63fd6136e716f5840fde05fe5db4bcd1aae2b/.github/assets/PhantomCamera2D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera2D</b>
            </th>
            <th align="center" valign="top">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/e0452e8c681ea51f9e678c903ad162a12037aa14/.github/assets/PhantomCamera3D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera3D</b>
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

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#third-person">
  <img src=".github/assets/icons/Follow-Third-Person.svg"/>
</a>
<h4>
    <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#third-person">Third Person</a>
</h4>
<p>
  As the name implies, this mode is meant to be used for third person camera experiences.<br>
It works by applying a <code>SpringArm3D</code> node as a parent, where its properties, such as <code>Collison Mask</code>, <code>Spring Length</code> and <code>Margin</code>, can be adjusted from the <code>PhantomCamera</code> node.
</p>
<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/dea63fd6136e716f5840fde05fe5db4bcd1aae2b/.github/assets/PhantomCamera2D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/e0452e8c681ea51f9e678c903ad162a12037aa14/.github/assets/PhantomCamera3D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera3D</b>
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

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Zoom-(2D)">
<img src=".github/assets/icons/Icon-Zoom.svg" width="100"/>
</a>
<h3>
<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Zoom-(2D)">Zoom (2D)</a>
</h3>
<p>
Define the Zoom level for the <code>Camera2D</code>.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/dea63fd6136e716f5840fde05fe5db4bcd1aae2b/.github/assets/PhantomCamera2D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/e0452e8c681ea51f9e678c903ad162a12037aa14/.github/assets/PhantomCamera3D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera3D</b>
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

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)">
<img src=".github/assets/icons/Icon-Look-At.svg" width="100"/>
</a>

<h3>
<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)">Look At (3D)</a>
</h3>
<p>
Defines where the <code>Camera3D</code> should be looking—adjusting its rotational value.
</p>
<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)#mimic">
<img src=".github/assets/icons/Icon-Look-At-Mimic.svg"/>
</a>
<br>
<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)#mimic">
<b>Mimic</b>
</a>
<p>
Copies the rotational value of its target.
</p>

<br>

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)#simple">
<img src=".github/assets/icons/Icon-Look-At-Simple.svg"/>
</a>
<br>
<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)#simple">
<b>Simple</b>
</a>
<p>
Looks At the target with an optional offset.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/dea63fd6136e716f5840fde05fe5db4bcd1aae2b/.github/assets/PhantomCamera2D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/e0452e8c681ea51f9e678c903ad162a12037aa14/.github/assets/PhantomCamera3D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera3D</b>
            </th>
        </tr>
    </thead>
    <tr>
        <td align="center">      
            Not available in 2D
        </td>
        <td align="center">
            <video src="https://github.com/ramokz/phantom-camera/assets/5159399/4bb74152-c549-4845-af03-f3edd73be645"/>
        </td>
    </tr>
</table>

<br>

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)#group">
 <img src=".github/assets/icons/Icon-Look-At-Group.svg"/>
 <br>
 <b>Group</b>
</a>
<p>
 Looks at the centre of a collection of targets.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/dea63fd6136e716f5840fde05fe5db4bcd1aae2b/.github/assets/PhantomCamera2D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera2D</b>
            </th>
            <th align="center" valign="top" width="2000">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/e0452e8c681ea51f9e678c903ad162a12037aa14/.github/assets/PhantomCamera3D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera3D</b>
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

<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Tween-(2D-&-3D)">
<img src=".github/assets/icons/Icon-Tween.svg" width="100"/>
</a>
<h3>
<a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Tween-(2D-&-3D)">Tween</a>
</h3>
<p>
Tweak how the <code>Camera2d</code>/<code>Camera3D</code> tweens to a newly active <code>PhantomCamera</code>.
</p>

<table>
    <thead>
        <tr>
            <th align="center" valign="top">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/dea63fd6136e716f5840fde05fe5db4bcd1aae2b/.github/assets/PhantomCamera2D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera2D</b>
            </th>
            <th align="center" valign="top">
              <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/e0452e8c681ea51f9e678c903ad162a12037aa14/.github/assets/PhantomCamera3D.svg" width="32" height="32"/>
              <br/>
              <b>PhantomCamera3D</b>
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

<a href="https://github.com/ramokz/phantom-camera/wiki/Viewfinder">
    <img src="https://raw.githubusercontent.com/ramokz/phantom-camera/main/.github/assets/icons/Icon-Viewfinder.svg" width="100" />
</a>

<h3><a href="https://github.com/ramokz/phantom-camera/wiki/Viewfinder">Viewfinder</a></h3>

https://github.com/ramokz/phantom-camera/assets/5159399/6c9d1653-b4c6-4b5d-8855-402776645689

Preview what the `Camera2D` / `Camera3D` sees when attached to a PhantomCamera. Accessible from the bottom panel labelled `Phantom Camera`. The viewfinder rendering of the scene will only work when the combination of a `Camera`, `PhantomCameraHost` and `PhantomCamera` are present in the scene.

<hr>

## 📔 Deep Dive & How to use

See the [Phantom Camera - Wiki](https://github.com/ramokz/phantom-camera/wiki).

### 🪀 Example Scenes
A 2D and 3D example scenes can be found inside `res://addons/phantom_camera/examples`.

## 💾 Installation
### Asset Library (Recommended - Stable)
1. In Godot, open the `AssetLib` tab.
2. Search for and select "Phantom Camera".
3. Download then install the plugin (be sure to only select the `phantom_camera` directory).
4. Enable the plugin inside `Project/Project Setttings/Plugins`.

### Github Releases (Recommended - Stable)
1. Download a [release build](https://github.com/ramokz/phantom-camera/releases/).
2. Extract the zip file and move the `addons/phantom_camera` directory into the project root location.
3. Enable the plugin inside `Project/Project Setttings/Plugins`.

### Github Main (Latest - Unstable)
1. Download the latest [`main branch`](https://github.com/ramokz/phantom-camera/archive/refs/heads/main.zip).
2. Extract the zip file and move the `addons/phantom_camera` directory into project's root location.
3. Enable the plugin inside `Project/Project Setttings/Plugins`.

For more help,
see [Godot's official documentation](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)

## 📖 Roadmap

See the [project page](https://github.com/users/ramokz/projects/3/views/8) for upcoming features.

## FAQ

### _What is the intent behind the plugin?_

Cameras are an essential part of practically any game for rendering what you see on the screen. But rarely do they
remain static and immovable, but instead dynamic and changes based on what happens in the game.

The plugin is meant to simplify some common camera behaviour, such as smoothly moving between different points in space
at specified points in time or retain a particular positional/rotational value relative to other elements.

The end goal is to make it functional enough to become a generalised camera extension for Godot projects.

### _What is the state of the plugin?_

Ongoing, but still in early stages. Core features have been implemented, but may change as more get added. Things will
likely break or change along the way. It's also worth keeping in mind that lots of key and, likely, frequently used
features are yet to be done.

See the [project page](https://github.com/users/ramokz/projects/3/views/8) to see planned features.

### _Does this work for Godot 3.5 or older?_

Unfortunately not.

GDScript has received a lot of changes and improvements in 4.0, but as a result it would require a rather large rewrite
to make it compatible with older versions.

### _When will X feature be added?_

There's no deadline or precise timeframe for when things get implemented.
The [milestones page](https://github.com/MarcusSkov/phantom-camera/milestones) should give a good idea for what has,
will, and currently being looked at.

## Contribution

Issues, PRs, suggestions and feedback are welcome. Please create an Issue for bugs or a Discussion post for suggestions
or general discussions.

## Credits

- [Unity's Cinemachine Package](https://unity.com/unity/features/editor/art-and-design/cinemachine) for the key
  inspiration
- [Godot](https://godotengine.org/) for their amazing work creating the engine

[MIT License](https://github.com/ramokz/phantom-camera/blob/main/LICENSE)
