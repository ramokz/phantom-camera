<img alt="Follow Group Icon" class="page-header-icon" src="../assets/icons/follow-path.svg" height="256" width="256" />

# Path Follow

Follows a target while being positionally confined to a `Path` node. The position on the path is based on the closest baked point relative to the target's position.

**_Note:_** that this _can_ lead to sudden Camera jumps if the `Path` spline has steep curvatures.

## Video Examples
<VideoTabs propertyName="follow-path-videos" video2d="../assets/videos/follow-path-2d.mp4" video3d="../assets/videos/follow-path-3d.mp4"/>

## Properties
<!--@include: ./parts/follow-target.md-->

<Property2D3D propertyName="Follow Path" propertyType2D="Path2D" propertyDefault2D="null" propertyType3D="Path3D" propertyDefault3D="null">

<template v-slot:propertyDescription>

Determines the `Path` node the `PCam` should be bound to. The `PCam` will follow the position of the `Follow Target` while sticking to the closest point on this path.

</template>
<template v-slot:setMethod2D>

`void` set_follow_path(`Path2D` path_name)

</template>
<template v-slot:setMethod3D>

`void` set_follow_path(`Path3D` path_name)

</template>

<template v-slot:setExample2D>

::: details Example
```gdscript
pcam.set_follow_path(follow_path_2d)
```
:::

</template>
<template v-slot:setExample3D>

::: details Example
```gdscript
pcam.set_follow_path(follow_path_3d)
```
:::

</template>

<template v-slot:getMethod2D>

`Vector2` get_follow_target_offset()

</template>
<template v-slot:getMethod3D>

`Vector3` get_follow_target_offset()

</template>

<template v-slot:getExample2D>

::: details Example
```gdscript
pcam.get_follow_path()
```
:::

</template>
<template v-slot:getExample3D>

::: details Example
```gdscript
pcam.get_follow_path()
```
:::

</template>

</Property2D3D>

<!--@include: ./parts/damping.md-->

<!--@include: ./parts/damping-value.md-->
