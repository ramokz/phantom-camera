<img src="../assets/phantom-camera-3D.svg" height="256" width="256"/>

# PhantomCamera3D

> Inherits: Node3D

`PhantomCamera3D`, shortened to `PCam3D` (text) or `pcam_3D` (code), is used in 3D scenes.

⚠️ A scene must contain a [`pcam_host`](https://github.com/ramokz/phantom-camera/wiki/PhantomCameraHost) for the `pcam_3D` node to work.

## Example Scene

Can be found in: `res://addons/phantom_camera/examples/3DExampleScene.tscn`

## Core Properties
<div class="property-core-group">

<PropertyCore propertyName="Priority" propertyPageLink="/priority" propertyIcon="./../../assets/feature-priority.svg">
<template v-slot:propertyDescription>

Determines which `PCam` should be active with the `Camera`.

</template>
</PropertyCore>

<PropertyCore propertyName="Follow Mode" propertyPageLink="/follow-modes/overview" propertyIcon="./../../assets/feature-follow.svg">
<template v-slot:propertyDescription>

Define how the `Camera` should follow its target(s).

</template>
</PropertyCore>

<PropertyCore propertyName="Look At" propertyPageLink="/zoom" propertyIcon="./../../assets/feature-look-at.svg">
<template v-slot:propertyDescription>

Defines where the `Camera` should be looking at, which will adjust its rotational value.

</template>
</PropertyCore>

<PropertyCore propertyName="Tween" propertyPageLink="/tween" propertyIcon="./../../assets/feature-tween.svg">
<template v-slot:propertyDescription>

Determines how the `Camera` tweens to this `PhantomCamera` upon becoming active.

</template>
</PropertyCore>
</div>



## Secondary Properties
<!--@include: ./parts/phantom-camera-properties.md-->