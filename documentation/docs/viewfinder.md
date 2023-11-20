<img src="./assets/feature-viewfinder.svg" height="256" width="256"/>

# Viewfinder
Preview what the `Camera3D` sees when attached to a `PCam3D`.

It's accessible from the bottom panel in the editor labelled `Phantom Camera`.

The viewfinder rendering of the scene will only work when the combination of a Camera, PhantomCameraHost and PhantomCamera are present in the scene.

## Dead Zones
When Follow Mode is set to Framed, dead zones will also be visible in the viewfinder and, if enabled, when playing the game from the editor.

Note: Dead Zones will never be visible in build exports.

## Empty States
When creating a new scene, the Viewfinder will not work by default due to the missing required nodes. To improve the user experience, and to provide better guidance for why it isn't working, the Viewfinder provides a quick and simple button flow to adding any missing required nodes.

## About 2D Support
Most of the setup is there, however, getting the 2D view to render in the viewfinder doesn't quite work yet. Issue can be found here: https://github.com/ramokz/phantom-camera/issues/105