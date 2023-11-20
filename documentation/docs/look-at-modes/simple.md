<img src="../assets/look-at-simple.svg" height="256" width="256"/>

# Simple Look At (3D)

The simplest of the available options. Effectively copies the rotational value of the targeted `Node3D`.

<!--@include: ./parts/look-at-mode.md-->

<!--@include: ./parts/look-at-target.md-->

<Property propertyName="Look At Offset" propertyType="Vector3" propertyDefault="null">
<template v-slot:propertyDescription>

Offsets the forward vector of the camera from the target's `Vector3` position.

</template>
<template v-slot:setMethod>

`void` set_look_at_target_offset(`Vector3` offset)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_look_at_target_offset(Vector3(0.5, 2.5, 0))
```
:::

</template>
<template v-slot:getMethod>

`Vector3` get_look_at_target_offset()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_look_at_target_offset()
```
:::

</template>
</Property>