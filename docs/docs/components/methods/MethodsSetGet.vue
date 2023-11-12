<script setup lang="ts">
import type { MethodType } from '../../types/MethodsTypes'
import MethodsComponent from "./MethodsComponent.vue";

const props = defineProps<MethodType>()

// const getter = {
//   props: defineProps<MethodType>()
// }


</script>

<template>
  <div class="foo">
    <slot></slot>
    <MethodsComponent method-description="" method-type="" method-return="" method-name="" method-parameter="" method-example="">
      <slot name="set-description"/>
    </MethodsComponent>
    
    <MethodsComponent method-description="" method-type="" method-return="" method-name="" method-parameter="" method-example="">
      <slot name="get-description"/>
    </MethodsComponent>
  </div>
</template>

<style scoped>
.foo {
  background: red;
}
</style>