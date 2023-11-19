<img src="../assets/feature-follow.svg" height="256" width="256"/>

# Follow - Overview

Determines the positional logic for the `PCam`.
This is 

## Core Modes

<div class="property-core-group">
<PropertyCore propertyName="Glued" propertyPageLink="./glued" propertyIcon="./../../assets/follow-glued.svg">
<template v-slot:propertyDescription>

Mimics the positional movement of its target.

This is the simplest of the follow modes and, likely, requires additional external logic before being useful.

</template>
</PropertyCore>
<PropertyCore propertyName="Simple" propertyPageLink="./simple" propertyIcon="./../../assets/follow-simple.svg">
<template v-slot:propertyDescription>

Has similar logic to `Glued`, but with the additional option to be offset from its targeted node.

</template>
</PropertyCore>
<PropertyCore propertyName="Group" propertyPageLink="./group" propertyIcon="./../../assets/follow-group.svg">
<template v-slot:propertyDescription>

Allows for multiple nodes to be selected.
It also allows for dynamically readjusting itself to keep multiple targets within view, should they start to spread out.

</template>
</PropertyCore>
<PropertyCore propertyName="Path" propertyPageLink="./path" propertyIcon="./../../assets/follow-path.svg">
<template v-slot:propertyDescription>

Determines how the `Camera` tweens to this `PCam` upon becoming active.

</template>
</PropertyCore>
<PropertyCore propertyName="Framed" propertyPageLink="/tween" propertyIcon="./../../assets/follow-framed.svg">
<template v-slot:propertyDescription>

Determines how the `Camera` tweens to this `PCam` upon becoming active.

</template>
</PropertyCore>
<PropertyCore propertyName="Third Person" propertyPageLink="/tween" propertyIcon="./../../assets/follow-third-person.svg">
<template v-slot:propertyDescription>

Determines how the `Camera` tweens to this `PCam` upon becoming active.

_This is for 3D scenes only_

</template>
</PropertyCore>
</div>