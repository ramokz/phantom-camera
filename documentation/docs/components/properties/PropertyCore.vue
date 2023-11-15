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