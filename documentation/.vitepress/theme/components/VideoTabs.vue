<script setup>
import {withBase} from "vitepress";
import {store} from "../../../store.ts";
import Tabs2D3D from "./Tabs2D3D.vue";

const props = defineProps({
  propertyName: {
    type: String,
    required: true
  },
  video2d: {
    type: String,
    required: true
  },
  video3d: {
    type: String,
    required: true
  }
})

</script>

<template>
  <Tabs2D3D :property-name="propertyName"/>
  <div class="property-method-container">
    <video controls v-show="store.is2D">
      <source :src="withBase(`/assets/${video2d}`)">
    </video>
    <video controls v-show="!store.is2D">
      <source :src="withBase(`/assets/${video3d}`)">
    </video>
  </div>
</template>

<style scoped>

</style>