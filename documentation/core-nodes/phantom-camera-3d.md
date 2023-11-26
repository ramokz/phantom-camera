<img src="/assets/icons/phantom-camera-3D.svg" height="256" width="256"/>

# PhantomCamera3D

> Inherits: Node3D

`PhantomCamera3D`, shortened to `PCam3D` (text) and `pcam_3d` (code), is used in 3D scenes.

## Core Properties
<div class="property-core-group">

<PropertyCore propertyName="Priority" propertyPageLink="/priority" propertyIcon="feature-priority.svg">
<template v-slot:propertyDescription>

Determines which `PCam3D` should be controlling the `Camera3D`.

</template>
</PropertyCore>

<PropertyCore propertyName="Follow Mode" propertyPageLink="/follow-modes/overview" propertyIcon="feature-follow.svg">
<template v-slot:propertyDescription>

Enables the `PCam3D` to follow specific target(s) using various logics.

</template>
</PropertyCore>

<PropertyCore propertyName="Look At" propertyPageLink="/look-at-modes/overview" propertyIcon="feature-look-at.svg">
<template v-slot:propertyDescription>


Enables the `PCam3D` to look at specific node(s), effectively adjusting its rotational value.

</template>
</PropertyCore>

<PropertyCore propertyName="Tween" propertyPageLink="/tween" propertyIcon="feature-tween.svg">
<template v-slot:propertyDescription>

Determines how the `Camera3D` should tween to this `PhantomCamera3D` upon becoming active.

</template>
</PropertyCore>
</div>

## Secondary Properties
<!--@include: ./parts/phantom-camera-properties.md-->

<Property propertyName="Camera3D Resource" propertyType="Camera3DResource" propertyDefault="null">
<template v-slot:propertyDescription>

A resource type that allows for overriding the `Camera3D` node's properties.

</template>
<template v-slot:setMethod>

`void` set_camera_3D_resource(`Camera3DResource` resource)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_camera_3D_resource(resource)
```
:::

</template>
<template v-slot:getMethod>

`Camera3DResource` get_camera_3D_resource()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_camera_3D_resource()
```
:::

</template>
</Property>

<Property propertyName="Camera Cull Mask" propertyType="int" propertyDefault="1048575">
<template v-slot:propertyDescription>

Overrides the Camera Cull Mask property of the `Camera3D` once becoming active.

</template>
<template v-slot:setMethod>

`void` set_camera_cull_mask(`int` cull_mask)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_camera_cull_mask(cull_mask)
```
:::

</template>
<template v-slot:getMethod>

`int` get_camera_cull_mask()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_camera_cull_mask()
```
:::

</template>
</Property>

<Property propertyName="H Offset" propertyType="float" propertyDefault="0">
<template v-slot:propertyDescription>

Overrides the H Offset property of the `Camera3D` once becoming active.

</template>
<template v-slot:setMethod>

`void` set_camera_h_offset(`float` h_offset)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_camera_h_offset(4.2)
```
:::

</template>
<template v-slot:getMethod>

`int` get_camera_h_offset()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_camera_h_offset()
```
:::

</template>
</Property>

<Property propertyName="V Offset" propertyType="float" propertyDefault="0">
<template v-slot:propertyDescription>

Overrides the V Offset property of the `Camera3D` once becoming active.

</template>
<template v-slot:setMethod>

`void` set_camera_v_offset(`float` v_offset)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_camera_v_offset(4.2)
```
:::

</template>
<template v-slot:getMethod>

`int` get_camera_v_offset()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_camera_v_offset()
```
:::

</template>
</Property>

<Property propertyName="FOV" propertyType="float" propertyDefault="0">
<template v-slot:propertyDescription>

Overrides the FOV (Field of View) property of the `Camera3D` once becoming active.

</template>
<template v-slot:setMethod>

`void` set_camera_fov(`float` fov)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_camera_fov(4.2)
```
:::

</template>
<template v-slot:getMethod>

`int` get_camera_fov()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_camera_fov()
```
:::

</template>
</Property>