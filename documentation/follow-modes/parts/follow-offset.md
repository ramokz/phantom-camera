<Property2D3D propertyName="Follow Target Offset" propertyType2D="Vector2" propertyDefault2D="Vector2(0,0)" propertyType3D="Vector3" propertyDefault3D="Vector3(0,0,0)">

<template v-slot:propertyDescription>

Offsets the targeted position.

</template>
<template v-slot:setMethod2D>

`void` set_follow_target_offset(`Vector2` offset)

</template>
<template v-slot:setMethod3D>

`void` set_follow_target_offset(`Vector3` offset)

</template>

<template v-slot:setExample2D>

::: details Example
```gdscript
pcam.set_follow_target_offset(Vector2(1, 1))
```
:::

</template>
<template v-slot:setExample3D>

::: details Example
```gdscript
pcam.set_follow_target_offset(Vector3(1, 1, 1))
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
pcam.get_follow_target_offset()
```
:::

</template>
<template v-slot:getExample3D>

::: details Example
```gdscript
pcam.get_follow_target_offset()
```
:::

</template>

</Property2D3D>