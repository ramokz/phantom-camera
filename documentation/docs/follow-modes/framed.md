<img alt="Follow Framed Icon" class="page-header-icon" src="../assets/follow-framed.svg" height="256" width="256" />

# Framed Follow

Enables dynamic framing of a given target using horizontal and vertical dead zones. The dead zones enable the `PCam` to remain still until the target moves beyond them where the `PCam` will then resume following.

Previewing the Dead Zone can be done from the [Viewfinder panel](../viewfinder), which can be found at the bottom of the editor.

Alternatively, enable the [Play Viewfinder](#play-viewfinder) property in the inspector to show the dead zone while running the game from the editor.

## Properties

<!--@include: ./parts/follow-target.md-->

<!--@include: ./parts/follow-offset.md-->

<!--@include: ./parts/damping.md-->

<!--@include: ./parts/damping-value.md-->

<!--@include: ./parts/follow-distance.md-->

<Property propertyName="Dead Zone Horizontal" propertyType="float" propertyDefault="0">
<template v-slot:propertyDescription>

Defines the horizontal dead zone area. While the target is within it, the `PCam` will not move in the horizontal axis. If the targeted node leaves the horizontal bounds, the `PCam` will follow the target horizontally to keep it within bounds.

</template>
</Property>

<Property propertyName="Dead Zone Vertical" propertyType="float" propertyDefault="0">
<template v-slot:propertyDescription>

Defines the vertical dead zone area. While the target is within it, the `PCam` will not move in the vertical axis. If the targeted node leaves the vertical bounds, the `PCam` will follow vertically to keep it within bounds.

</template>
</Property>

<Property propertyName="Play Viewfinder" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

Enables the dead zones to be visible when running the game from the editor.

_Dead zones will never be visible in build exports._

</template>
</Property>