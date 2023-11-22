<img src="../assets/icons/feature-follow.svg" height="256" width="256"/>

# Follow Overview

Determines the positional logic for a given `PCam`.

The different modes has different functionalities and purposes, so choosing the correct mode depends on what each `PCam` is meant to do. 

## Core Modes

<div class="property-core-group">
<PropertyCore propertyName="Glued" propertyPageLink="./glued" propertyIcon="./../../assets/icons/follow-glued.svg">
<template v-slot:propertyDescription>

Sticks to its targeted node.

</template>
</PropertyCore>
<PropertyCore propertyName="Simple" propertyPageLink="./simple" propertyIcon="./../../assets/icons/follow-simple.svg">
<template v-slot:propertyDescription>

Has similar logic to `Glued`, but with the additional option to apply a positional offset.

</template>
</PropertyCore>
<PropertyCore propertyName="Group" propertyPageLink="./group" propertyIcon="./../../assets/icons/follow-group.svg">
<template v-slot:propertyDescription>

Allows for multiple nodes to be selected.
Can also dynamically readjusting itself to keep multiple targets within view, should they start to spread out.

</template>
</PropertyCore>
<PropertyCore propertyName="Path" propertyPageLink="./path" propertyIcon="./../../assets/icons/follow-path.svg">
<template v-slot:propertyDescription>

Follows a target while being positionally confined to a `Path` node. The position on the path is based on the closest baked point relative to the target's position.

</template>
</PropertyCore>
<PropertyCore propertyName="Framed" propertyPageLink="/follow-modes/framed" propertyIcon="./../../assets/icons/follow-framed.svg">
<template v-slot:propertyDescription>

Enables a dynamic framing of a given target using dead zones. The dead zones allows the `Camera` to remain still until the target tries to move beyond the dead zone.

</template>
</PropertyCore>
<PropertyCore propertyName="Third Person" propertyPageLink="/follow-modes/third-person" propertyIcon="./../../assets/icons/follow-third-person.svg">
<template v-slot:propertyDescription>

As the name implies, this mode is meant to be used for third person camera experiences. It works by using a `SpringArm3D` node where its properties can be adjusted from the `PCam`.

</template>
</PropertyCore>
</div>

## Properties
<!--@include: ./parts/follow-mode.md-->
