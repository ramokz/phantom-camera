<img alt="Follow Framed Icon" class="page-header-icon" src="../assets/follow-framed.svg" />

# Framed Follow

Enables dynamic framing of a given target using dead zones. Dead zones enable the camera to remain still until the target moves far enough away from the camera's view. This is determined by the horizontal and vertical dead zone size in their respective properties within the inspector.
Previewing the Dead Zone

Open the `Phantom Camera` panel at the bottom of the editor to open the viewfinder and preview the dead zone area.
Note: This particular approach is only supported in 3D scenes for now.

Alternatively, enable the `Play Viewfinder` property in the inspector to show the dead zone while running the game from the editor - this property, and thus dead zone visibility, will always be disabled in build exports.

## Properties

<!--@include: ./parts/follow-mode.md-->

<!--@include: ./parts/follow-target.md-->

<!--@include: ./parts/follow-offset.md-->

<!--@include: ./parts/damping.md-->

<!--@include: ./parts/damping-value.md-->


<!--@include: ./parts/follow-distance.md-->

<Property propertyName="Dead Zone Horizontal" propertyType="float" propertyDefault="0">
<template v-slot:propertyDescription>

Defines the horizontal dead zone area. While the target is within it, the camera will not move in the horizontal axis. If the targeted node tries to exit the horizontal bounds, the camera will follow the target horizontally to keep it within bounds.

</template>
</Property>

<Property propertyName="Dead Zone Vertical" propertyType="float" propertyDefault="0">
<template v-slot:propertyDescription>

Defines the vertical dead zone area. While the target is within it, the camera will not move in the vertical axis. If the targeted node tries to exit the vertical bounds, the camera will follow vertically to keep it within bounds.

</template>
</Property>

<Property propertyName="Play Viewfinder" propertyType="bool" propertyDefault="false">
<template v-slot:propertyDescription>

Enables the dead zones to be visible when running the game from the editor.

Dead zones will never be visible in build exports.

</template>
</Property>