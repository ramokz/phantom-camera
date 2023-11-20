<img src="../assets/look-at-group.svg" height="256" width="256"/>

# Group Look At (3D)

Allows for multiple targets to be looked at. The `Pcam3D` will create a AABB that surrounds the targets and will look at the centre of it.

<!--@include: ./parts/look-at-mode.md-->

<Property propertyName="Look At Group" propertyType="Array[Node3D]" propertyDefault="null">
<template v-slot:propertyDescription>

Select a group of `Node3D` to have the camera keep its position in the centre of the assigned targets.

</template>
<template v-slot:setMethod>

`void` append_look_at_group_node(`Node3D` target_node)

`void` append_look_at_group_node_array(`Array[Node3D]` target_nodes)

`void` erase_look_at_group_node(`Node3D` target_node)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_look_at_target_offset(Vector3(0.5, 2.5, 0))
```
:::

</template>
<template v-slot:getMethod>

`Array[Node3D]` get_look_at_group_nodes()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_look_at_group_nodes()
```
:::

</template>
</Property>

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