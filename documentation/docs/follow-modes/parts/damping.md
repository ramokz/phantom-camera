<Property propertyName="Damping" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

Enables damping follow movement, which leads to heavier / slower camera follow movement.

</template>

<template v-slot:setMethod>

`void` set_follow_has_damping(`bool` value)

</template>

<template v-slot:setExample>

::: details Example
```gdscript
void set_follow_has_damping(bool value)
```
:::

</template>

<template v-slot:getMethod>

`bool` get_follow_has_damping()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_follow_has_damping()
```
:::

</template>
</Property>