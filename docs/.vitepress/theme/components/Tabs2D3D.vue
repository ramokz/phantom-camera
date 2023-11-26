<script setup lang="ts">
import { store } from "../../../store.ts";
import { computed } from "vue";

const props = defineProps({
  propertyName: {
    type: String,
    required: true
  }
})

const propertyNameID = computed(() => {
  return props.propertyName.replace(/ /g, '')
})
</script>

<template>
  <div class="toggle-tabs">
    <input type="radio" :id="propertyNameID + '2D'" :name="propertyNameID" :value="store.is2D" v-model="store.is2D" :checked="store.is2D" @change="store.toggle2D(true)">
    <label :for="propertyNameID + '2D'" @mouseenter="$emit('tabHover', true)" @mouseleave="$emit('tabHover', false)">
      <img alt="Phantom Camera 2D" src="/assets/icons/phantom-camera-2D.svg" width="32"/>
      2D
    </label>
    <input type="radio" :id="propertyNameID + '3D'" :name="propertyNameID" :value="!store.is2D" v-model="store.is2D" :checked="!store.is2D" @change="store.toggle2D(false)">
    <label :for="propertyNameID + '3D'">
      <img alt="Phantom Camera 3D" src="/assets/icons/phantom-camera-3D.svg" width="32"/>
      3D
    </label>
  </div>
</template>

<style scoped>
.toggle-tabs {
  display: flex;
  input {
    margin: 20px;
    appearance: none;
    display: none;
    & + label {
      cursor: pointer;
      font-size: 18px;
      font-weight: 800;
      display: flex;
      gap: 6px;
      align-items: center;
      padding: 6px 12px 6px 12px;
      border-radius: 12px 12px 0 0;
      opacity: 0.8;
      border: 2px solid transparent;
      margin-bottom: -2px;
      &:hover {
        box-shadow: 0 0 30px var(--vp-c-bg-alt) inset;
        border-color: var(--vp-c-brand-1);
      }
    }
    &:checked + label {
      opacity: 1;
      background: var(--vp-c-bg-alt);
      box-shadow: 0px 0px 10px var(--vp-c-bg) inset;
      border: 2px solid var(--vp-c-gray-3);
      z-index: -10;
    }
  }
}
</style>