<img src="./.github/assets/banners/phantom-camera-banner.svg">

<h1>Phantom Camera</h1>
<p>
    Control and dynamically tween 2D and 3D cameras in Godot 4.0 projects.
</p>

<table>
  <tr>
    <th>Wiki Page</th>
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

<h1>Features</h1>
<table>
<tr>
    <td width="80" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Priority-(2D-&-3D)">
        <img src=".github/assets/icons/Icon-Priority.svg"/>
      </a>
    </td>
    <td>
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Priority-(2D-&-3D)">Priority</a>
      </h3>
      <p>
        Determines which <code>PhantomCamera</code> should be active with the <code>Camera2D</code>/<code>Camera3D</code>.
      </p>
    </td>
  </tr>
  <tr>
    <td width="80" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)">
        <img src=".github/assets/icons/Icon-Follow.svg"/>
      </a>
    </td>
    <td colspan="3">
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)">Follow Mode</a>
      </h3>
      <p>
        Define how the <code>Camera2D</code>/<code>Camera3D</code> should follow its target(s).
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
        <hr>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#simple">
          <img src=".github/assets/icons/Follow-Simple.svg"/>
        </a>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#simple">
          <h4>Simple</h4>
        </a>
        <p>
          Follows the target with an optional offset.
        </p>
        <hr>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#group">
          <img src=".github/assets/icons/Follow-Group.svg"/>
        </a>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Follow-(2D-&-3D)#group">
          <h4>Group</h4>
        </a>
        <p>
          Follows the centre of a collection of targets.
        </p>
        <video src=".github/assets/videos/3D-Follow-Group.mp4" width="300" height="300"/>
    </td>
  </tr>
  <tr>
    <td width="80" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Zoom-(2D)">
        <img src=".github/assets/icons/Icon-Zoom.svg"/>
      </a>
    </td>
    <td>
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Zoom-(2D)">Zoom (2D)</a>
      </h3>
      <p>
        Define the Zoom level for the <code>Camera2D</code>.
      </p>
    </td>
  </tr>
  <tr>
    <td width="80" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)">
        <img src=".github/assets/icons/Icon-Look-At.svg"/>
      </a>
    </td>
    <td>
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
         <hr>            
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
         <hr>
         <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Look-At-(3D)#group">
             <img src=".github/assets/icons/Icon-Look-At-Group.svg"/>
             <br>
             <b>Group</b>
         </a>
         <p>
             Looks at the centre of a collection of targets.
         </p>
        </td>
    </tr>
  <tr>
    <td width="80" align="center">
      <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Tween-(2D-&-3D)">
        <img src=".github/assets/icons/Icon-Tween.svg"/>
      </a>
    </td>
    <td>
      <h3>
        <a href="https://github.com/ramokz/phantom-camera/wiki/Properties:-Tween-(2D-&-3D)">Tween</a>
      </h3>
      <p>
        Tweak how the <code>Camera2d</code>/<code>Camera3D</code> tweens to a newly active <code>PhantomCamera</code>.
      </p>
    </td>
  </tr>
</table>

## 📔 Deep Dive & How to use

See the [Phantom Camera - Wiki](https://github.com/ramokz/phantom-camera/wiki).

### 🪀 Example Scenes

A 2D and 3D example scenes can be found inside `res://addons/phantom_camera/examples` titled `2DExampleScene`
and `3DExampleScene` respectively.

## 💾 Installation

1. Download the repo and copy `addons/phantom_camera` to your root Godot directory under `res://`.
2. Enable the plugin inside `Project/Project Setttings/Plugins`
3. And that's it!
   For more help,
   see [Godot's official documentation](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)

## 📖 Roadmap

See the [project page](https://github.com/users/ramokz/projects/3/views/8) for upcoming features.

## FAQ

### _What is the intent behind the plugin?_

Cameras are an essential part of practically any game for rendering what you see on the screen. But rarely do they
remain static and immoveable, but instead dynamic and changes based on what happens in the game.

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
