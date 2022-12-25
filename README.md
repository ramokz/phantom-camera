# Phantom Camera

Control and dynamically tween between cameras in 2D and 3D scenes in your Godot projects.
The addon is designed to work alongside the a scene's Camera2D and Camera3D nodes.

Note: This addon is only compatible with Godot 4.0

# Features
## Follow
Keeps a persistent position relative to a target node.

## Look At (3D scenes only)
Retains the forward vector at a specified target.

## Tween
Change the tweening behaviour between one another. The property changes the   how the using Godot's built-in tweening system. More information about  

# Roadmap
See the [project page](https://github.com/users/MarcusSkov/projects/3/views/8) for upcoming features

# How to use
See the [[Phantom Camera - Wiki]] for more information

# FAQ
## Does the addon work for Godot 3.5 or older?
Unfortunately not. GDscript has received a lot of changes and improvements in 4.0, but as a result it would require a rather large rewrite to make it compatible with older versions.

## Is this production ready?
Short answer, no. There's still a fair amount work and testing left to do before it's ready for production. Lots of key and, arguably, very important features are yet to be added.

## What is the state for this addon?
Ongoing but not stable yet. Core features have been added and simple camera behaviour is already in place but may change as more get added since not all features have been added yet it might break as those get implemented. See the [Project page] to see planned features.

# Contribution
Issues, PRs, suggestions and feedback are welcome. Please create an Issue for bugs or a Discussion post for suggestions or general discussions.

# Credits
[Unity's Cinemachine Package](https://unity.com/unity/features/editor/art-and-design/cinemachine) for the key inspiration

[Godot](https://godotengine.org/) for their amazing work with the engine
