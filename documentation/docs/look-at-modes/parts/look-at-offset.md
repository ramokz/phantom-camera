<Property propertyName="Look At Offset" propertyType="Vector3" propertyDefault="null">
<template v-slot:propertyDescription>

Offsets the target's `Vector3` position that the `PCam3D` is looking at.

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