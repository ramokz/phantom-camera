<MethodSetGet methodName="Active">
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
</MethodSetGet>


<MethodSetGet methodName="Tween Onload">
<template v-slot:setMethod>

`void` set_tween_on_load(`bool` value)

</template>
<template v-slot:setDescription>

Enables or disables the `Tween on Load` behaviour.

</template>
<template v-slot:setCodeExample>

::: details Example
```gdscript
pcam.set_tween_on_load(false)
```
:::

</template>


<template v-slot:getMethod>

`bool` is_tween_on_load()

</template>
<template v-slot:getDescription>

Returns the current `Tween On Load` value.

</template>
<template v-slot:getCodeExample>

::: details Example
```gdscript
pcam.is_tween_on_load()
```
:::

</template>
</MethodSetGet>


<MethodSetGet methodName="Inactive Update Mode">
<template v-slot:getMethod>

`string` get_inactive_update_mode()

</template>
<template v-slot:getDescription>

Returns `Interactive Update Mode` property name.

</template>
<template v-slot:getCodeExample>

::: details Example
```gdscript
pcam.get_inactive_update_mode()
```
:::

</template>
</MethodSetGet>