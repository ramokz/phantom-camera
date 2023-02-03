![phantom-camera-banner](https://user-images.githubusercontent.com/5159399/216722122-247caf99-b435-4dd2-a482-37fb6ee2b06b.png)

# Phantom Camera
Control and dynamically tween 2D and 3D cameras in Godot 4.0 projects. 
## Features
### 🏃 Follow
Keeps a persistent position relative to a target.
Camera movement can be dampened to provide more smooth movement.

https://user-images.githubusercontent.com/5159399/216445112-f8e8d1f0-6572-4ef4-b7ec-6f3948da0107.mp4

https://user-images.githubusercontent.com/5159399/216178375-5f28c6cc-ae81-41ab-a43a-8a92c0600559.mp4

### 👀 Look At
Keeps the camera pointed at a specified target.

https://user-images.githubusercontent.com/5159399/216178303-b629fe99-d485-4700-b341-a10daa76611e.mp4

### 🌀 Tween
Change how the camera transitions and eases between PhantomCameras.

https://user-images.githubusercontent.com/5159399/216176537-60c8e859-f7d8-4de5-bece-c7446d4d854c.mp4

## 📔 Deep Dive & How to use
See the [[Phantom Camera - Wiki]].

### 🪀 Example Scenes
A 2D and 3D example scenes can be found inside `res://addons/phantom_camera/examples` titled `2DExampleScene` and `3DExampleScene` respectively,

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
