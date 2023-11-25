<img src="./assets/icons/feature-priority.svg" height="256" width="256"/>

# Priority
Is one of the most important properties in this addon.


It defines which `PCam` a scene's `Camera` should be corresponding with and be attached to. This is decided by the `PCam` with the highest `Priority`.


Changing `Priority` will send an event to the scene's `PCamHost`, which will then determine whether if the `Priority` value is greater than or equal to the currently highest `pcam`'s in the scene. The `PCam` with the highest value will then reattach the `Camera` accordingly.


## Properties 
<Property propertyName="Priority" propertyType="int" propertyDefault="0">
<template v-slot:propertyDescription>

Determines which `PCam` is currently active. The one with the highest priority will be what decides what `PCam` a scene's `Camera` is attached to.

Modifying this is also what triggers a tween between different `PCams`. See the [Priority](../priority) and [Tween](../tween) page for more details.

</template>
<template v-slot:setMethod>

`void` set_priority (`int` priority)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_priority(10)
```
:::

</template>
<template v-slot:getMethod>

`int` get_priority()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_priority()
```
:::

</template>
</Property>

<Property propertyName="Priority Override" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

To quickly preview a `PCam` without adjusting its `Priority`, this property allows the selected `PCam` to ignore the `Priority` system altogether and forcefully become the active one.
It's partly designed to work within the [Viewfinder](./viewfinder), and will be disabled when running a build export of the game.

</template>

</Property>