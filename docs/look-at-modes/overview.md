<img src="/assets/icons/feature-look-at.svg" height="256" width="256"/>

# Look At Overview (3D)
Determines the rotational logic for a given `PCam3D`.

The different modes has different functionalities and purposes, so choosing the correct mode depends on what each `PCam` is meant to do.

## Core Modes

<div class="property-core-group">
<PropertyCore propertyName="Glued" propertyPageLink="./mimic" propertyIcon="./../../assets/icons/look-at-mimic.svg">
<template v-slot:propertyDescription>

The simplest of the available options. Effectively copies the rotational value of the targeted `Node3D`.

</template>
</PropertyCore>
<PropertyCore propertyName="Simple" propertyPageLink="./simple" propertyIcon="./../../assets/icons/look-at-simple.svg">
<template v-slot:propertyDescription>

Keeps a persistent forward direction towards a target.

</template>
</PropertyCore>
<PropertyCore propertyName="Group" propertyPageLink="./group" propertyIcon="./../../assets/icons/look-at-group.svg">
<template v-slot:propertyDescription>

Allows for multiple targets to be looked at. The camera will look at the centre of the assigned targets' `Vector3` coordinate.

</template>
</PropertyCore>
</div>

## Properties
<!--@include: ./parts/look-at-mode.md-->