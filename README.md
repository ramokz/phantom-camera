![phantom-camera-banner](https://user-images.githubusercontent.com/5159399/216774990-ae0a9d02-cb04-4fd6-8522-00e021c81dfa.png)

# Phantom Camera
Control and dynamically tween 2D and 3D cameras in Godot 4.0 projects.

<table>
  <tr>
    <th>Wiki Page</th>
    <th>Roadmap</th>
  <tr>
  <tbody>
  <tr>
    <td width="1200" align="center" valign="top">
      <a href="https://github.com/ramokz/phantom-camera/wiki"><img src="https://user-images.githubusercontent.com/5159399/216828486-f530a354-45e6-4cb4-978a-359e63337443.png"></a>
    </td>
     <td width="1200" align="center" valign="top">
      <a href="https://github.com/ramokz/phantom-camera/milestones"><img src="https://user-images.githubusercontent.com/5159399/216830565-42c6a0c3-2d3e-4fb0-b8a3-b10ed4fc5832.png"></a>
    </td>
  </tbody>
</table>


## Features
<table>
  <tr>
    <td width="140" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Priority-(2D-&-3D)">
        <img src="https://github.com/ramokz/phantom-camera/blob/94cd88bac148e4d2f2e53bb0b3f370827d14fc4d/.github/assets/Icon-Priority.svg"/>
      </a>
    </td>
    <td width="1200">
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Priority-(2D-&-3D)">Priority</a>
      </h3>
      <p>
        Determines which <code>PhantomCamera</code> should be active with the <code>Camera2D</code>/<code>Camera3D</code>.
      </p>
    </td>
  </tr>
  <tr>
    <td width="140" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)">
        <img src="https://github.com/ramokz/phantom-camera/blob/94cd88bac148e4d2f2e53bb0b3f370827d14fc4d/.github/assets/Icon-Follow.svg"/>
      </a>
    </td>
    <td width="1200" colspan="3">
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)">Follow Mode</a>
      </h3>
      <p>
        Define how the <code>Camera2D</code>/ <code>Camera3D</code> should follow its target(s).
      </p>
      <table>
        <tr>
          <td width="140" align="center">
            <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#glued">
              <img src="https://github.com/ramokz/phantom-camera/blob/6e3c27ff727bbeab29c1c67da1ff35cf44d26957/.github/assets/Icon-Follow-Glued.svg"/>
            </a>
          </td>
          <td>
            <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#glued">
              <h4>Glued</h4>
            </a>
            <p>
              Sticks to its target.
            </p>
            <img src="https://github.com/ramokz/phantom-camera/blob/6e3c27ff727bbeab29c1c67da1ff35cf44d26957/.github/assets/Icon-Follow-Glued.svg"/>
          </td>
        </tr>
        <tr>
          <td width="140" align="center">
            <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#simple">
              <img src="https://github.com/ramokz/phantom-camera/blob/6e3c27ff727bbeab29c1c67da1ff35cf44d26957/.github/assets/Icon-Follow-Simple.svg"/>
            </a>
          </td>
          <td>
            <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#simple">
              <h4>Simple</h4>
            </a>
            <p>
              Follows the target with an optional offset.
            </p>
          </td>
        </tr>
        <tr>
          <td width="140" align="center">
            <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#group">
              <img src="https://github.com/ramokz/phantom-camera/blob/6e3c27ff727bbeab29c1c67da1ff35cf44d26957/.github/assets/Icon-Follow-Group.svg"/>
            </a>
          </td>
          <td>
            <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#group">
              <h4>Group</h4>
            </a>
            <p>
              Follows the centre of a collection of targets.
            </p>
          </td>
        </tr>
      </table>
    </tr>
  </tr>
    <tr>
    <td width="140" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Zoom-(2D)">
        <img src="https://github.com/ramokz/phantom-camera/blob/94cd88bac148e4d2f2e53bb0b3f370827d14fc4d/.github/assets/Icon-Zoom.svg"/>
      </a>
    </td>
    <td width="1200">
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Zoom-(2D)">Zoom (2D)</a>
      </h3>
      <p>
        Define the Zoom level for the <code>Camera2D</code>.
      </p>
    </td>
  </tr>
  <tr>
    <td width="140" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)">
        <img src="https://github.com/ramokz/phantom-camera/blob/94cd88bac148e4d2f2e53bb0b3f370827d14fc4d/.github/assets/Icon-Look-At.svg"/>
      </a>
    </td>
    <td width="1200">
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)">Look At (3D)</a>
      </h3>
      <p>
        Defines where the <code>Camera3D</code> should be looking—adjusting its rotational value.
      </p>
    </td>
  </tr>
  <tr>
    <td width="140" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Tween-(2D-&-3D)">
        <img src="https://github.com/ramokz/phantom-camera/blob/94cd88bac148e4d2f2e53bb0b3f370827d14fc4d/.github/assets/Icon-Tween.svg"/>
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

### 🏃 Follow
Keeps a persistent position relative to a target.
Camera movement can be dampened to provide more smooth movement.

<table>
  <tr>
    <th>2D</th>
    <th>3D</th>
  </tr>
  <tr>
    <td width="1200">
      <video src="https://user-images.githubusercontent.com/5159399/216445112-f8e8d1f0-6572-4ef4-b7ec-6f3948da0107.mp4"/>
    </td>
    <td width="1200">
      <video src="https://user-images.githubusercontent.com/5159399/216178375-5f28c6cc-ae81-41ab-a43a-8a92c0600559.mp4"/>
    </td>
  </tr>
</table>

### 📷 Zoom
Animate between zoom levels when switching between `PhantomCameras`.

<table>
  <tr>
    <th>2D</th>
    <th>3D</th>
  </tr>
  <tr>
    <td width="1200">
      <video src="https://user-images.githubusercontent.com/5159399/216772193-74af1fd7-73cd-4e4d-b1e1-c063609e07c6.mp4"/>
    </td>
    <td width="1200" align="center">
        🪧
       <br>
       <b>Not available in 3D scenes</b>
    </td>
</table>



### 👀 Look At (3D)
Keeps the camera pointed at a specified target.

<table>
  <tr>
    <th>2D</th>
    <th>3D</th>
  </tr>
  <tr>
    <td width="1200" align="center">
       🪧
       <br>
       <b>Not available in 2D scenes</b>
    </td>
    <td width="1200">
      <video src="https://user-images.githubusercontent.com/5159399/216178303-b629fe99-d485-4700-b341-a10daa76611e.mp4"/>
    </td>
</table>

### 🌀 Tween (2D & 3D)
Change how the camera transitions and eases between `PhantomCameras`.

<table>
  <tr>
    <th>2D</th>
    <th>3D</th>
  </tr>
  <tr>
    <td width="1200" align="center">
      🚧
      <br>
      <b>Example to be added soon</b>
    </td>
    <td width="1200">
      <video src="https://user-images.githubusercontent.com/5159399/216176537-60c8e859-f7d8-4de5-bece-c7446d4d854c.mp4"/>
    </td>
</table>


## 📔 Deep Dive & How to use
See the [Phantom Camera - Wiki](https://github.com/ramokz/phantom-camera/wiki).

### 🪀 Example Scenes
A 2D and 3D example scenes can be found inside `res://addons/phantom_camera/examples` titled `2DExampleScene` and `3DExampleScene` respectively.

## 💾 Installation
1. Download the repo and copy `addons/phantom_camera` to your root Godot directory under `res://`.
2. Enable the plugin inside `Project/Project Setttings/Plugins`
3. And that's it!
For more help, see [Godot's official documentation](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)

## 📖 Roadmap
See the [project page](https://github.com/users/ramokz/projects/3/views/8) for upcoming features.

## FAQ
### _What is the intent behind the plugin?_
Cameras are an essential part of practically any game for rendering what you see on the screen. But rarely do they remain static and immoveable, but instead dynamic and changes based on what happens in the game.

The plugin is meant to simplify some common camera behaviour, such as smoothly moving between different points in space at specified points in time or retain a particular positional/rotational value relative to other elements.

The end goal is to make it functional enough to become a generalised camera extension for Godot projects.

### _What is the state of the plugin?_
Ongoing, but still in early stages. Core features have been implemented, but may change as more get added. Things will likely break or change along the way. It's also worth keeping in mind that lots of key and, likely, frequently used features are yet to be done.

See the [project page](https://github.com/users/ramokz/projects/3/views/8) to see planned features.

### _Does this work for Godot 3.5 or older?_
Unfortunately not.

GDScript has received a lot of changes and improvements in 4.0, but as a result it would require a rather large rewrite to make it compatible with older versions.

### _When will X feature be added?_
There's no deadline or precise timeframe for when things get implemented. The [milestones page](https://github.com/MarcusSkov/phantom-camera/milestones) should give a good idea for what has, will, and currently being looked at.

## Contribution
Issues, PRs, suggestions and feedback are welcome. Please create an Issue for bugs or a Discussion post for suggestions or general discussions.

## Credits
- [Unity's Cinemachine Package](https://unity.com/unity/features/editor/art-and-design/cinemachine) for the key inspiration
- [Godot](https://godotengine.org/) for their amazing work creating the engine

[MIT License](https://github.com/ramokz/phantom-camera/blob/main/LICENSE)
