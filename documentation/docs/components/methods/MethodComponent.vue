<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps({
  methodType: {
    type: String,
    required: true,
  },
  methodName: {
    type: String,
    required: true,
  },
})

const id = computed<string>(() => {
  if (props.methodName) {
    return props.methodName.replace(/ /g, '-').toLowerCase() + "-" + props.methodType.replace(/ /g, '-').toLowerCase()
  }
})
</script>


<template>
  <h4 :id="id" tabindex="-1">{{ methodType }}
    <a class="header-anchor" :href="`#${id}`" :aria-label="`Permalink to ${id}`">&#8203;</a>
  </h4>
  
  <div class="method">
    <slot name="method">
      <p class="missing-text">MISSING METHOD</p>
    </slot>
  </div>
  
  <div>
    <slot name="codeExample">
      <p class="missing-text">MISSING CODE EXAMPLE</p>
    </slot>
  </div>
</template>


<style scoped>
.method {
  --font-size: 16px;
  font-size: var(--font-size);
  color: var(--vp-c-white);
  font-weight: 700;
  &:deep(p) {
    font-family: var(--vp-font-family-mono);
  }
}

.method :deep(code) {
  font-size: var(--font-size);
}
</style>