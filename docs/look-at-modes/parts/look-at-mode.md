<Property propertyName="Look At Mode" propertyType="LookAtEnum" propertyDefault="None">
<template v-slot:propertyDescription>

Gets `Look At Mode`. Value is based on `Constants.LookAtMode` enum.

| Look At Mode | Value |
|--------------|-------|
| NONE         | 0     |
| MIMIC        | 1     |
| SIMPLE       | 2     |
| GROUP        | 3     |

**_Note:_** The Setter for `Look At Mode` has purposely not been added.<br>
A separate `PCam3D` should be used instead.


</template>
<template v-slot:getMethod>

`int` get_look_at_mode()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_look_at_mode()
```
:::

</template>
</Property>