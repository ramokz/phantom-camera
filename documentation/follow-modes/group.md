<img alt="Follow Group Icon" class="page-header-icon" src="/assets/icons/follow-group.svg" height="256" width="256" />

# Group Follow

Allows for multiple nodes to be followed and affect the `PCam`'s positional behaviour. It works by setting a `Rect2` (2D) or `AABB` (3D) bounding box around the targets where the `PCam` will track the centre of it.

An [Auto Zoom (2D)](#auto-zoom-(2d)) and [Auto Distance (3D)](#auto-distance-(3d)) parameter can be applied to dynamically make the `PCam` readjust itself to keep multiple targets within view if they start to spread out.

This mode can be useful for single stage experiences that relies on having multiple targets in view at all times.

## Video Examples

<VideoTabs propertyName="follow-group-videos" video2d="../assets/videos/follow-group-2d.mp4" video3d="../assets/videos/follow-group-3d.mp4"/>

## Properties

<Property2D3D propertyName="Group Targets" propertyType2D="Array[Node2D]" propertyDefault2D="null" propertyType3D="Array[Node3D]" propertyDefault3D="null">

<template v-slot:propertyDescription>

Defines the nodes that the `PCam` should be following.

</template>
<template v-slot:setMethod2D>

`void` append_follow_group_node(`Node2D` target_node)

`void` append_follow_group_node_array(`Array[Node2D]` target_nodes)

`void` erase_follow_group_node(`Node2D` target_node)

</template>
<template v-slot:setMethod3D>

`void` append_follow_group_node(`Node3D` target_node)

`void` append_follow_group_node_array(`Array[Node3D]` target_nodes)

`void` erase_follow_group_node(`Node3D` target_node)

</template>

<template v-slot:setExample2D>

::: details Example
```gdscript
# Appends one node to the Follow Group
pcam.append_follow_group_node(player_node)
# Appends an array of nodes to the Follow Group
pcam.append_follow_group_node_array(node_array)
# Removes a node from the Follow Group
pcam.erase_follow_group_node(another_node)
```
:::

</template>
<template v-slot:setExample3D>

::: details Example
```gdscript
# Appends one node to the Follow Group
pcam.append_follow_group_node(player_node)
# Appends an array of nodes to the Follow Group
pcam.append_follow_group_node_array(node_array)
# Removes a node from the Follow Group
pcam.erase_follow_group_node(another_node)
```
:::

</template>

<template v-slot:getMethod2D>

`Array[Node2D]` get_follow_group_nodes()

</template>
<template v-slot:getMethod3D>

`Array[Node3D]` get_follow_group_nodes()

</template>

<template v-slot:getExample2D>

::: details Example
```gdscript
pcam.get_follow_group_nodes()
```
:::

</template>
<template v-slot:getExample3D>

::: details Example
```gdscript
pcam.get_follow_group_nodes()
```
:::

</template>

</Property2D3D>

<!--@include: ./parts/damping.md-->

<!--@include: ./parts/damping-value.md-->

<Property propertyName="Auto Zoom (2D)" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

Enables the `PCam2D` to dynamically zoom in and out based on the targets' distances between each other.

Once enabled, the `PCam` will stay as zoomed in as possible, limited by the `Maximum Zoom` and start zooming out as the targets move further apart, limited by the `Minimum Zoom`.

Note: Enabling this property hides and disables the `Zoom` property as this effectively overrides that value.

<Property2D3DOnly :is2D="true" altProp="Auto Distance" altPropLink="./group#auto-distance-(3d)"/>

</template>
<template v-slot:setMethod>

`void` set_auto_zoom (`bool` should_auto_zoom)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_auto_zoom(true)
```
:::

</template>

<template v-slot:getMethod>

`bool` get_auto_zoom()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_auto_zoom()
```
:::

</template>
</Property>

<Property propertyName="Min Auto Zoom (2D)" propertyType="float" propertyDefault="1">
<template v-slot:propertyDescription>

Sets the minimum zoom level, in other words how far away the `Camera2D` can be from scene.

This only works when `Auto Zoom` is enabled.

<Property2D3DOnly :is2D="true" altProp="Min Auto Distance" altPropLink="./group#min-auto-distance-(3d)"/>

</template>
<template v-slot:setMethod>

`void` set_min_auto_zoom (`float` min_zoom)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_min_auto_zoom(0.42)
```
:::

</template>

<template v-slot:getMethod>

`float` get_min_auto_zoom()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_min_auto_zoom()
```
:::

</template>
</Property>

<Property propertyName="Max Auto Zoom (2D)" propertyType="float" propertyDefault="5">
<template v-slot:propertyDescription>

Sets the maximum zoom level, in other words how close the `Camera` can move towards the scene.

This only works when `Auto Zoom` is enabled.

<Property2D3DOnly :is2D="true" altProp="Max Auto Distance" altPropLink="./group#max-auto-distance-(3d)"/>

</template>
<template v-slot:setMethod>

`void` set_max_auto_zoom (`float` min_zoom)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_max_auto_zoom(4)
```
:::

</template>

<template v-slot:getMethod>

`float` get_max_auto_zoom()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_max_auto_zoom()
```
:::

</template>
</Property>

<Property propertyName="Zoom Margin (2D)" propertyType="Vector4" propertyDefault="Vector4(0,0,0,0)">
<template v-slot:propertyDescription>

Determines how close to the edges the targets are allowed to be. <br>
This is useful to avoid targets being cut off at the edges of the screen.

The `Vector4` parameter order goes: Left - Top - Right - Bottom.

<Property2D3DOnly :is2D="true" altProp="Auto Distance Divisor" altPropLink="./group#auto-distance-divisor-(3d)"/>

</template>
<template v-slot:setMethod>

`void` set_zoom_margin (`Vector4` zoom_margin)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_zoom_margin(Vector4(10, 30, 10, 40))
```
:::

</template>

<template v-slot:getMethod>

`float` get_zoom_margin()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_zoom_margin()
```
:::

</template>
</Property>

<!--@include: ./parts/follow-distance.md-->

<Property propertyName="Auto Distance (3D)" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

Enables the `PCam` to automatically distance itself based on the targets' distances between each other.

It looks at the longest axis between the different targets and interpolates the distance length between the `Minimum Distance` and `Maximum Distance` properties below.

**Note:** Enabling this property hides and disables the `Distance` property as this effectively overrides that value.

<Property2D3DOnly :is2D="false" altProp="Auto Zoom" altPropLink="./group#auto-zoom-(2d)"/>


</template>
<template v-slot:setMethod>

`void` set_auto_follow_distance(`bool` should_auto_distance)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_auto_follow_distance(true)
```
:::

</template>
<template v-slot:getMethod>

`bool` get_auto_follow_distance()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_auto_follow_distance()
```
:::

</template>
</Property>

<Property propertyName="Min Auto Distance (3D)" propertyType="float" propertyDefault="1">
<template v-slot:propertyDescription>

Sets the minimum distance between the `Camera` and centre of `AABB`.

**Note:** This distance will only ever be reached when all the targets' positions are in the exact same `Vector3` coordinate, which will very unlikely happen, so adjust the value here accordingly.

<Property2D3DOnly :is2D="false" altProp="Max Auto Zoom" altPropLink="./group#max-auto-zoom-(2d)"/>

</template>
<template v-slot:setMethod>

`void` set_min_auto_follow_distance(`float` min_distance)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_min_auto_follow_distance(4.2)
```
:::

</template>
<template v-slot:getMethod>

`float` get_min_auto_follow_distance()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_min_auto_follow_distance()
```
:::

</template>
</Property>

<Property propertyName="Max Auto Distance (3D)" propertyType="float" propertyDefault="5">
<template v-slot:propertyDescription>

Sets the maximum distance between the `Camera` and centre of `AABB`.

<Property2D3DOnly :is2D="false" altProp="Min Auto Zoom" altPropLink="./group#min-auto-zoom-(2d)"/>

</template>
<template v-slot:setMethod>

`void` set_max_auto_follow_distance(`float` max_distance)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_max_auto_follow_distance(4.2)
```
:::

</template>
<template v-slot:getMethod>

`float` get_max_auto_follow_distance()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_max_auto_follow_distance()
```
:::

</template>
</Property>

<Property propertyName="Auto Distance Divisor (3D)" propertyType="float" propertyDefault="10">
<template v-slot:propertyDescription>

Determines how fast the `Auto Distance` moves between the maximum and minimum distance. The higher the value, the sooner the maximum distance is reached.

This value should be based on the sizes of the `Minimum Distance` and `Maximum Distance`. <br>
E.g. if the value between the `Minimum Distance` and `Maximum Distance` is small, consider keeping the number low and vice versa.

</template>
<template v-slot:setMethod>

`void` set_auto_follow_distance_divisor(`float` distance_divisor)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_auto_follow_distance_divisor(4.2)
```
:::

</template>
<template v-slot:getMethod>

`float` get_auto_follow_distance_divisor()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_auto_follow_distance_divisor()
```
:::

</template>
</Property>