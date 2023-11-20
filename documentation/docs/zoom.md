<img src="./assets/feature-zoom.svg" height="256" width="256"/>

# Zoom (2D)

Applies a set zoom level to the `PCam2D`, effectively overrides the `Zoom` property of the `Camera2D` node.

<Property propertyName="Zoom" propertyType="Vector2" propertyDefault="Vector2(1,1)">
<template v-slot:propertyDescription>

Sets the zoom level for the Camera2D.

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