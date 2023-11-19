<Property propertyName="Active State" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

Determines how the `Camera` tweens to this `PhantomCamera` once becoming active.

</template>

<template v-slot:getMethod>

`bool` is_active()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.is_active()
```
:::

</template>
</Property>
<Property propertyName="Tween on Load" propertyType="bool" propertyDefault="true">
<template v-slot:propertyDescription>

Enables or disables the Tween on Load.

</template>
<template v-slot:setMethod>

`void` set_tween_on_load(`bool` value)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_tween_on_load(false)
```
:::

</template>
<template v-slot:getMethod>

`bool` is_tween_on_load()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.is_tween_on_load()
```
:::

</template>
</Property>
<Property propertyName="Inactive Update Mode" propertyType="InactiveUpdateMode" propertyDefault="ALWAYS">
<template v-slot:propertyDescription>

Enables or disables the Tween on Load.

</template>
<template v-slot:getMethod>

`string` get_inactive_update_mode()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_inactive_update_mode()
```
:::

</template>
</Property>