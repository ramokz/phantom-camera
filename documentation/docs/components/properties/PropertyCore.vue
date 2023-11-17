<script setup>
import { computed } from "vue";

const props = defineProps({
  propertyName: {
    type: String,
    required: true,
  },
  propertyPageLink: {
    type: String,
    required: true,
  },
  propertyIcon: {
    type: String,
    required: true,
  }
})

const id = computed(() =>{
  return props.propertyName.replace(/ /g, '-').toLowerCase()
})
</script>

<template>
  <div class="property-method-container">
    <div class="feature-icon">
      <a :href="propertyPageLink">
        <img :src="propertyIcon" width="64"/>
      </a>
    </div>
    <div>
      <h3 :id="id" tabindex="-1">
        <a :href="propertyPageLink">{{ propertyName }}</a>
        <a class="header-anchor" :href="`#${id}`" :aria-label="`Permalink to ${propertyName}`">&#8203;</a>
      </h3>
      <slot name="propertyDescription">
        
        MISSING DESCRIPTION

      </slot>
    </div>
  </div>
</template>

<style scoped>
.property-method-container {
  padding: 20px 20px 10px 20px;
  margin-bottom: 36px;
  border-radius: 20px;
  box-shadow: 0 0 10px 10px rgba(12, 21, 24, 0.40);

  transition: box-shadow 120ms;
  transition-timing-function: linear;
&:hover {
    box-shadow: 0 0 15px 15px rgba(12, 21, 24, 0.60);
  }
}
</style>