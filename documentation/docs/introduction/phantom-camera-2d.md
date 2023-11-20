<img src="../assets/phantom-camera-2D.svg" height="256" width="256"/>

# PhantomCamera2D
> Inherits: Node2D

`PhantomCamera2D`, shortened to `PCam2D` (text) or `pcam_2d` (code), is used in 2D scenes.

⚠️ A scene must contain a [`pcam_host`](https://github.com/ramokz/phantom-camera/wiki/PhantomCameraHost) for the `pcam_2d` node to work.

## Example Scene
Can be found in: `res://addons/phantom_camera/examples/2DExampleScene.tscn`

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

<PropertyCore propertyName="Tween" propertyPageLink="/tween" propertyIcon="./../../assets/feature-tween.svg">
<template v-slot:propertyDescription>

Determines how the `Camera` tweens to this `PCam` upon becoming active.

</template>
</PropertyCore>
</div>

## Secondary Properties
<!--@include: ./parts/phantom-camera-properties.md-->

<Property propertyName="Zoom" propertyType="Vector2" propertyDefault="Vector2(1,1)">
<template v-slot:propertyDescription>

Applies a zoom level to the `PCam2D`, effectively overrides the `Zoom` property of the `Camera2D` node.

</template>
<template v-slot:setMethod>

`Vector2` set_zoom()

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_zoom(Vector2(1.5, 1.5))
```
:::

</template>
<template v-slot:getMethod>

`Vector2` get_zoom()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_zoom()
```
:::

</template>
</Property>

<Property propertyName="Frame Preview" propertyType="bool" propertyDefault="true">
<template v-slot:propertyDescription>

Enables a preview

</template>
<template v-slot:getMethod>

`string` get_inactive_update_mode()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_inactive_update_mode()
```
:::

</template>
</Property>