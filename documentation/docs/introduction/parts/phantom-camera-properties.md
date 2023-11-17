<Property propertyName="Active State" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

Determines how the `Camera` tweens to this `PhantomCamera` once becoming active.

</template>

<template v-slot:getMethod>

`bool` is_active()

</template>
<template v-slot:getDescription>

Gets current active state of the `PhantomCamera`.

If it returns true, it means the `PhantomCamera` is what the `Camera` node is currently tracking.

</template>
<template v-slot:getCodeExample>

::: details Example
```gdscript
pcam.is_active()
```
:::

</template>

</Property>
<Property propertyName="Tween on Load" propertyType="bool" propertyDefault="true">
<template v-slot:propertyType>

`bool` tween_on_load = `true`

</template>

<template v-slot:propertyDescription>

Enables or disables the Tween on Load.

</template>
<template v-slot:getMethod>

`bool` is_tween_on_load()

</template>
<template v-slot:getCodeExample>

::: details Example
```gdscript
pcam.is_tween_on_load()
```
:::

</template>
<template v-slot:setMethod>

`void` set_tween_on_load(`bool` value)

</template>
<template v-slot:setCodeExample>

::: details Example
```gdscript
pcam.set_tween_on_load(false)
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
<template v-slot:getCodeExample>

::: details Example
```gdscript
pcam.get_inactive_update_mode()
```
:::

</template>
</Property>

<Property propertyName="Frame Preview" propertyType="bool" propertyDefault="true">

<template v-slot:propertyType>

`bool` frame_preview = `true`

</template>

<template v-slot:propertyDescription>

Enables a preview 

</template>
<template v-slot:getMethod>

`string` get_inactive_update_mode()

</template>
<template v-slot:getCodeExample>

::: details Example
```gdscript
pcam.get_inactive_update_mode()
```
:::

</template>
</Property>