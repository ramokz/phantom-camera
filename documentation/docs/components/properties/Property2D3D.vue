<script setup lang="ts">
import {ref, useSlots, computed} from 'vue'
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

  const borderRadius: Ref<String> = ref()
  const setCornerRadius = (value?: boolean) => {
    if (store.is2D || value) {
      borderRadius.value = "0 24px 24px 24px"
    } else{
      borderRadius.value = "24px"
    }
  }

  const propertyObj = computed<Object>( () => {
    if (store.is2D) {
      setCornerRadius()
      return {
        type: props.propertyType2D,
        default: props.propertyDefault2D
      }
    } else {
      setCornerRadius()
      return {
        type: props.propertyType3D,
        default: props.propertyDefault3D
      }
    }
  })

  const slots = useSlots()
  const slotContent: Array<string> = Object.keys(slots)
  const hasPropertyType = (typeArray: Array<string>) => {
    return slotContent.some(value => typeArray.includes(value))
  }
  
  const propertyNameID = computed(() => {
    return props.propertyName.replace(/ /g, '')
  })

</script>

<template>
  <div class="toggle-tabs">
      <input type="radio" :id="propertyNameID + '2D'" :name="propertyNameID" :value="store.is2D" v-model="store.is2D" :checked="store.is2D" @change="store.toggle2D(true)">
      <label :for="propertyNameID + '2D'" @mouseenter="setCornerRadius(true)" @mouseleave="setCornerRadius(false)">
        <img alt="Phantom Camera 2D" src="../../assets/icons/phantom-camera-2D.svg" width="32"/>
        2D
      </label>
      <input type="radio" :id="propertyNameID + '3D'" :name="propertyNameID" :value="!store.is2D" v-model="store.is2D" :checked="!store.is2D" @change="store.toggle2D(false)">
      <label :for="propertyNameID + '3D'">
        <img alt="Phantom Camera 3D" src="../../assets/icons/phantom-camera-3D.svg" width="32"/>
        3D
      </label>
  </div>
  <Property :style="{borderRadius: borderRadius}" :propertyName="propertyName" :propertyType="propertyObj.type" :propertyDefault="propertyObj.default">
    <template #propertyDescription>
      <slot name="propertyDescription"/>
    </template>
    <template #setMethod>
      <div v-show="store.is2D">
        <slot name="setMethod2D">
          <p class="missing-text">Missing setMethod2D</p>
        </slot>
      </div>

      <div v-if="!store.is2D">
        <slot name="setMethod3D">
          <p class="missing-text">Missing setMethod3D</p>
        </slot>
      </div>
    </template>
    <template #setExample >
      <div v-show="store.is2D">
        <slot name="setExample2D">
          <p class="missing-text">Missing setExample2D</p>
        </slot>
      </div>
      <div v-show="!store.is2D">
        <slot name="setExample3D">
          <p class="missing-text">Missing setExample3D</p>
        </slot>
      </div>
    </template>
    <template #getMethod>
      <div v-show="store.is2D">
        <slot name="getMethod2D">
          <p class="missing-text">Missing getMethod2D</p>
        </slot>
      </div>
      <div v-show="!store.is2D">
        <slot name="getMethod3D">
          <p class="missing-text">Missing getMethod3D</p>
        </slot>
      </div>
    </template>
    <template #getExample>
      <div v-show="store.is2D">
        <slot name="getExample2D">
          <p class="missing-text">Missing getExample2D</p>
        </slot>
      </div>
      <div v-show="!store.is2D">
        <slot name="getExample3D">
          <p class="missing-text">Missing getExample3D</p>
        </slot>
      </div>
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