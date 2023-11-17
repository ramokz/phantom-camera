<script setup>
  import { store } from '../../store.ts'
  
  const props = defineProps({
    propertyName: {
      type: String,
      required: true
    },
    propertyType2D: {
      type: String,
      required: true
    },
    propertyType3D: {
      type: String,
      required: true
    },
    propertyDefault2D: {
      type: String,
      required: true
    },
    propertyDefault3D: {
      type: String,
      required: true
    },
  })
  
  const toggle2D = (value) => {
    store.toggle2D(value)
  }
</script>

<template>
  <div class="toggle-tabs">
    <input type="radio" id="2DTab" name="2D3DTabs" :value="store.is2D" @change="toggle2D(true)">
    <label for="2DTab">
      <img src="../../assets/phantom-camera-2D.svg" width="32"/>
      <span>2D</span>
    </label>
    <input type="radio" id="3DTab" name="2D3DTabs" :value="!store.is2D" @change="toggle2D(false)">
    <label for="3DTab">
      <img src="../../assets/phantom-camera-3D.svg" width="32"/>
      3D
    </label>
  </div>
  
  <Property :propertyName="propertyName" :propertyType="propertyType2D" :propertyDefault="propertyDefault2D" v-show="store.is2D">
    <template v-slot:propertyDescription>

      <slot name="propertyDescription"/>

    </template>
    <template v-slot:getMethod>

      <slot name="getMethod2D"/>

    </template>
    <template v-slot:getCodeExample>

      <slot name="getCodeExample2D"/>

    </template>
    <template v-slot:setMethod>

      <slot name="setMethod2D"/>

    </template>
    <template v-slot:setCodeExample>

      <slot name="setCodeExample2D"/>

    </template>
  </Property>
  
  <Property :propertyName="propertyName" :propertyType="propertyType3D" :propertyDefault="propertyDefault3D" disableOutlineEntry="true" v-show="!store.is2D">
    <template v-slot:propertyDescription>

      <slot name="propertyDescription"/>

    </template>
    <template v-slot:getMethod>

      <slot name="getMethod3D"/>

    </template>
    <template v-slot:getCodeExample>

      <slot name="getCodeExample3D"/>

    </template>
    <template v-slot:setMethod>
      
      <slot name="setMethod3D"/>

    </template>
    <template v-slot:setCodeExample>

      <slot name="setCodeExample"/>

    </template>
  </Property>
</template>

<style scoped>
.toggle-tabs {
  display: flex;
  input {
    margin: 20px;
    appearance: none;
    display: none;
    &:checked {
      background: red;
    }
    & + label {
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