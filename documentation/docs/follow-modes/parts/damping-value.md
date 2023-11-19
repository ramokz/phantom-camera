<Property propertyName="Damping Value" propertyType="float" propertyDefault="10">
<template v-slot:propertyDescription>

Defines the damping amount.

**Lower value** = slower / heavier camera movement

**Higher value** = fast camera movement.

</template>

<template v-slot:setMethod>

`void` set_follow_damping_value(`float` value)

</template>

<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_follow_has_damping(5)
```
:::

</template>

<template v-slot:getMethod>

`float` get_follow_damping_value()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.is_active()
```
:::

</template>
</Property>