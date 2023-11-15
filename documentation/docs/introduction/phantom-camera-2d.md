<script setup>
    import PropertyCore from "../components/properties/PropertyCore.vue";
</script>

<img src="../assets/phantom-camera-2D.svg" height="256" width="256"/>

# PhantomCamera2D
> Inherits: Node2D

`PhantomCamera2D`, shortened to `PCam2D` (text) or `pcam_2D` (code), is the  used in 2D scenes.

⚠️ A scene must contain a [`pcam_host`](https://github.com/ramokz/phantom-camera/wiki/PhantomCameraHost) for the `pcam_2D` node to work.

## Example Scene
Can be found in: `res://addons/phantom_camera/examples/2DExampleScene.tscn`

## Core Properties
<div class="property-core-group">

<PropertyCore propertyName="Priority" propertyPageLink="/priority" propertyIcon="./../../assets/feature-priority.svg">
<template v-slot:propertyDescription>

Determines which `PCam` should be active with the `Camera2D`.

</template>
</PropertyCore>

<PropertyCore propertyName="Follow Mode" propertyPageLink="/follow-modes/overview" propertyIcon="./../../assets/feature-follow.svg">
<template v-slot:propertyDescription>

Define how the `Camera` should follow its target(s).

</template>
</PropertyCore>

<PropertyCore propertyName="Zoom" propertyPageLink="/zoom" propertyIcon="./../../assets/feature-zoom.svg">
<template v-slot:propertyDescription>

Set the `Zoom` level for the `Camera2D`.

</template>
</PropertyCore>

<PropertyCore propertyName="Tween" propertyPageLink="/tween" propertyIcon="./../../assets/feature-tween.svg">
<template v-slot:propertyDescription>

Determines how the `Camera` tweens to this `PCam` upon becoming active.

</template>
</PropertyCore>
</div>



## Secondary Properties
<!--@include: ./parts/phantom-camera-properties.md-->
