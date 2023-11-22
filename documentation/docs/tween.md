<img src="./assets/icons/feature-tween.svg" height="256" width="256"/>

# Tween

Defines how `PCams` transitions between one another. Changing the tween values for a given `PCam` determines how transitioning _to that_ instance will look like.

This is a resource type that can be either used for one `PCam` or reused across multiple.

By default, all `PCams` will use a `linear` transition, `easeInOut` ease with a `1s` duration.

### Instant Transitions
To have an instant transitions, simply apply a value of `0` to the duration property.

## Properties

<Property propertyName="Tween Resource" propertyType="PhantomCameraTween" propertyDefault="null">
<template v-slot:propertyDescription>

The resource that defines how this `PCam` should be transitioned to.

Can be shared across multiple `PCams`

</template>
<template v-slot:setMethod>

`void` set_tween_resource(`PhantomCameraTween` tween_resource)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_tween_resource(tween_resource)
```
:::

</template>
<template v-slot:getMethod>

`PhantomCameraTween` get_tween_resource()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_tween_resource()
```
:::

</template>
</Property>

<Property propertyName="Tween Duration" propertyType="float" propertyDefault="1">
<template v-slot:propertyDescription>

Defines how long the transition to this `PCam` should last in **seconds**.

</template>
<template v-slot:setMethod>

`void` set_tween_duration(`float` duration)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_tween_duration(4.2)
```
:::

</template>
<template v-slot:getMethod>

`PhantomCameraTween` get_tween_duration()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_tween_duration()
```
:::

</template>
</Property>

<Property propertyName="Tween Transition" propertyType="int" propertyDefault="0">
<template v-slot:propertyDescription>

Defines the `Transition` type for the tweening to this `PCam` using the `Constants.TweenTransitions` enum.

| Transition Name | Value |
|-----------------|-------|
| LINEAR          | 0     |
| SINE            | 1     |
| QUINT           | 2     |
| QUART           | 3     |
| QUAD            | 4     |
| EXPO            | 5     |
| ELASTIC         | 6     |
| CUBIC           | 7     |
| CIRC            | 8     |
| BOUNCE          | 9     |
| BACK            | 10    |


</template>
<template v-slot:setMethod>

`void` set_tween_transition(`int` transition_type)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_tween_transition(2)

# Instead of applying an int directly,
# it's also possible to supply an enum value like so:
pcam.set_tween_transition(pcam.Constants.TweenTransitions.QUINT)

```
:::

</template>
<template v-slot:getMethod>

`int` get_tween_transition()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_tween_transition()
```
:::

</template>
</Property>

<Property propertyName="Tween Ease" propertyType="int" propertyDefault="2">
<template v-slot:propertyDescription>

Defines the `Ease` type for the tweening to this `PCam` using the `Constants.TweenEases` enum.

| Ease Type   | Value |
|-------------|-------|
| EASE_IN     | 0     |
| EASE_OUT    | 1     |
| EASE_IN_OUT | 2     |
| EASE_OUT_IN | 3     |

</template>
<template v-slot:setMethod>

`void` set_tween_ease(`int` ease_type)

</template>
<template v-slot:setExample>

::: details Example
```gdscript
pcam.set_tween_ease(0)

# Instead of applying an int directly,
# it's also possible to supply an enum value like so
pcam.set_tween_ease(pcam.Constants.TweenEases.EASE_IN)

```
:::

</template>
<template v-slot:getMethod>

`int` get_tween_ease()

</template>
<template v-slot:getExample>

::: details Example
```gdscript
pcam.get_tween_ease()
```
:::

</template>
</Property>