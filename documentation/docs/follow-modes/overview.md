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

Follows a target while being positionally confined to a `Path` node. The position on the path is based on the closest baked point relative to the target's position.

</template>
</PropertyCore>
<PropertyCore propertyName="Framed" propertyPageLink="/follow-modes/framed" propertyIcon="./../../assets/follow-framed.svg">
<template v-slot:propertyDescription>

Enables dynamic framing of a given target using dead zones. Dead zones enable the camera to remain still until the target moves far enough away from the camera's view. This is determined by the horizontal and vertical dead zone size in their respective properties within the inspector.

</template>
</PropertyCore>
<PropertyCore propertyName="Third Person" propertyPageLink="/follow-modes/third-person" propertyIcon="./../../assets/follow-third-person.svg">
<template v-slot:propertyDescription>

As the name implies, this mode is meant to be used for third person camera experiences. It works by applying a SpringArm3D where the properties, such as `Collison Mask`, `Spring Length` and `Margin`, can be controlled from the PhantomCamera3D.

_This is for 3D scenes only_

</template>
</PropertyCore>
</div>