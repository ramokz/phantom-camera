<Property propertyName="Look At Target" propertyType="Node3D" propertyDefault="null">
<template v-slot:propertyDescription>

Determines which `Node3D` should be looked at. The `PCam3D` will update its rotational value as the target changes its position.

</template>
<template v-slot:setMethod>

`void` set_look_at_target(`Node3D` target)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_look_at_target(node_name)
```
:::

</template>
<template v-slot:getMethod>

`Node3D` get_look_at_target()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_look_at_target()
```
:::

</template>
</Property>