<Property propertyName="Damping Value" propertyType="float" propertyDefault="10">
<template v-slot:propertyDescription>

Defines the damping amount.

**Lower value** = slower / heavier camera movement.

**Higher value** = faster camera movement.

</template>

<template v-slot:setMethod>

`void` set_follow_damping_value(`float` damping_value)

</template>

<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_follow_damping_value(5)
```
:::

</template>

<template v-slot:getMethod>

`float` get_follow_damping_value()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_follow_damping_value()
```
:::

</template>
</Property>