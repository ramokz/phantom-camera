<script setup lang="ts">

// import type { MethodType } from '../../types/MethodsTypes'
// defineProps<MethodType>()

// console.log(this.$refs.foo)

</script>

<template>
  <h4>{{ methodType }}</h4>
  <div class="method">
    <slot class="method" name="method"/>
  </div>
<!--      <p>-->
<!--        <code>-->
<!--          {{ methodReturn }}-->
<!--        </code>-->
<!--        {{ methodName }} ({{methodParameter}})-->
<!--      </p>-->
  <slot name="description"/>
  <slot name="code-example"/>
</template>

<style scoped>
:root {
  --font-sizezzz: 34px;
}

.method {
  font-size: 24px;
  color: var(--vp-c-white);
  font-weight: 700;
}

.vp-doc > code {
  font-size: 36px;
}

</style>