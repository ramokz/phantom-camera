<img src="./assets/feature-priority.svg" height="256" width="256"/>

# Priority
The most important property of the plugin.


It defines which `PCam` a scene's `Camera2D`/`Camera3D` should be corresponding with and be attached to. This is decided by the `pcam` with the highest `Priority`.


Changing `Priority` will send an event to the scene's `pcam_host`, which will then determine whether if the `Priority` value is greater than or equal to the currently highest `pcam`'s in the scene and reattach the `Camera2D`/`Camera3D` accordingly.


## Properties 
<Property propertyName="Priority" propertyType="int" propertyDefault="0">
<template v-slot:propertyDescription>

Determines which `PCam` is currently used. The one with the highest priority will be what decides what `PCam` the scene's `Camera2D`/`Camera3D` is attached to.

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

<img src="https://raw.githubusercontent.com/ramokz/phantom-camera/main/.github/assets/icons/Priority-Override.svg" height="64">

## Priority Override

To quickly preview a `PCam` without adjusting its `Priority`, there is an optional `Priority Override` property that allows the selected PhantomCamera to ignore the `Priority` system and become the active one.
**Note:** This is only enabled within the editor to be used with the [Viewfinder](./viewfinder.md), and will be disabled when running the game.

<Property propertyName="Priority Override" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

Will override all other `PCams` in the scene.

</template>

</Property>