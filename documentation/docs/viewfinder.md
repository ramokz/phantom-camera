<img src="./assets/icons/feature-viewfinder.svg" height="256" width="256"/>

# Viewfinder
_⚠️ OBS: This is currently only functional in 3D scenes with `PCam3D` nodes._

Preview what the `Camera` sees when attached to a `PCam`.

It's accessible from the bottom panel in the editor labelled `Phantom Camera`.

The viewfinder rendering of the scene will only work when the combination of a `Camera`, `PCamHost` and `PCam` are present and set up correctly.

## Video Example
<video controls>
<source src="./assets/videos/viewfinder.mp4">
</video>

## Dead Zones
When `Follow Mode` is set to [Framed](./follow-modes/framed.md), dead zones will also be visible in the viewfinder and, if enabled, when playing the game from the editor.

_**Note**: Dead Zones will never be visible in build exports._

## About 2D Support
Most of the setup is there, however, getting the 2D view to render in the viewfinder doesn't quite work yet.

GitHub issue can be found here: https://github.com/ramokz/phantom-camera/issues/105