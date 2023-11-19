<Property propertyName="Follow Mode" propertyType="int" propertyDefault="FollowMode.None">
<template v-slot:propertyDescription>

Defines the current `Follow Mode` of the `PCam` based on `Constants.FOLLOW_MODE` enum.

The Setter for `Follow Mode` has purposely not been added.<br>
A separate `PCam` should be used instead.

</template>
<template v-slot:getMethod>

`int` get_follow_mode()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_follow_mode()
```
:::

</template>
</Property>