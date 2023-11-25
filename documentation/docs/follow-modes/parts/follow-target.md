<Property2D3D propertyName="Follow Target" propertyType2D="Node2D" propertyDefault2D="null" propertyType3D="Node3D" propertyDefault3D="null">

<template v-slot:propertyDescription>

Determines which `Node` should be followed. The `Camera` will follow the position of the `Follow Target` based on the `Follow Mode` type and its parameters.

</template>
<template v-slot:setMethod2D>

`void` set_follow_target_node(`Node2D` target_node)

</template>
<template v-slot:setMethod3D>

`void` set_follow_target_node(`Node3D` target_node)

</template>

<template v-slot:setExample2D>

::: details Example
```gdscript
pcam.set_follow_target_node(player_node)
```
:::

</template>
<template v-slot:setExample3D>

::: details Example
```gdscript
pcam.set_follow_target_node(player_node)
```
:::

</template>

<template v-slot:getMethod2D>

`Node2D` get_follow_target_node()

</template>
<template v-slot:getMethod3D>

`Node3D` get_follow_target_node()

</template>

<template v-slot:getExample2D>

::: details Example
```gdscript
pcam.get_follow_target_node()
```
:::

</template>
<template v-slot:getExample3D>

::: details Example
```gdscript
pcam.get_follow_target_node()
```
:::

</template>

</Property2D3D>