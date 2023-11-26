<Property propertyName="Active State" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

Returns `true` if this `PCam` is the one controlling the scene's `Camera`.

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

By default, the moment a `PCam` is instantiated into a scene, and has the highest priority, it will perform its tween transition.

This is most obvious if a `PCam` has a long duration and is attached to a playable character that can be moved the moment a scene is loaded.

Disabling the Tween on Load property will disable this behaviour and skip the tweening entirely when instantiated.

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
<Property propertyName="Inactive Update Mode" propertyType="int" propertyDefault="0" :editorOnly="true">
<template v-slot:propertyDescription>

Determines how often an inactive `PCam` should update its positional and rotational values.
This is meant to reduce the amount of calculations inactive `PCams` are doing when idling to improve performance. The value is based on the enum type `Constants.InactiveUpdateMode`.

| Inactive Update Mode | Value |
|----------------------|-------|
| ALWAYS               | 0     |
| NEVER                | 1     |
 


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