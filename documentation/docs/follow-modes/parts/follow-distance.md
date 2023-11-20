<Property propertyName="Distance (3D)" propertyType="float" propertyDefault="1">
<template v-slot:propertyDescription>

Sets a distance offset from the centre of the target group. The distance is applied to the `PCam`'s local z axis.

<Property2D3DOnly :is2D="false" altProp="Zoom" altPropLink="./../introduction/phantom-camera-2d#zoom"/>


</template>
<template v-slot:setMethod>

`float` set_follow_distance()

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_follow_distance(4.2)
```
:::

</template>
<template v-slot:getMethod>

`float` get_follow_distance()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_follow_distance()
```
:::

</template>
</Property>