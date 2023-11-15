<script setup lang="ts">
import {computed, useSlots} from "vue";

const props = defineProps({
  propertyName: {
    type: String,
    required: true,
  },
  propertyPageLink: {
    type: String,
    required: true,
  },
})

const id = computed<String>(() =>{
  return props.propertyName.replace(/ /g, '-').toLowerCase()
})


// Setter names
const setMethod: string = "setMethod"
const setDescription: string = "setDescription"
const setCodeExample: string = "setCodeExample"

// Getter names
const getMethod: string = "getMethod"
const getDescription: string = "getDescription"
const getCodeExample: string = "getCodeExample"


const slots = useSlots()
const slotContent: Array<string> = Object.keys(slots)

const hasType = (typeArray: Array<string>) => {
  return slotContent.some(value => typeArray.includes(value))
}

const hasSetterContent = computed(() => {
  return hasType([setMethod, setDescription, setDescription])
})
const hasGetterContent = computed(() => {
  return hasType([getMethod, getDescription, getCodeExample])
})

const hasSetGet = computed(() => {
  return !!(hasSetterContent.value && hasGetterContent.value);
})

</script>

<template>
  <div class="property-method-container">
    <h3 :id="id" tabindex="-1">
      {{ propertyName }}
      <a class="header-anchor" :href="`#${id}`" :aria-label="`Permalink to ${propertyName}`">&#8203;</a>
    </h3>
    <h3 class="property-name" >
      <slot name="propertyType">
        MISSING PROPERTY TYPE
      </slot>
      
    </h3>
      <slot name="propertyDescription">

        <p class="missing-text">
          MISSING PROPERTY DESCRIPTION
        </p>
      </slot>
    
    <hr>

    <h3 :id="id" tabindex="-1">{{ methodName }}
      <a class="header-anchor" :href="`#${id}`" :aria-label="`Permalink to ${methodName}`">&#8203;</a>
    </h3>
    <MethodComponent method-type="setter" :methodName="propertyName" v-if="hasSetterContent">
      <template #method>
        <slot :name="setMethod"/>
      </template>
      <template #codeExample>
        <slot :name="setCodeExample"/>
      </template>
    </MethodComponent>

<!--    <hr v-if="hasSetGet" />-->

    <MethodComponent method-type="getter" :methodName="propertyName" v-if="hasGetterContent">
      <template #method>
        <slot :name="getMethod"/>
      </template>
      <template #codeExample>
        <slot :name="getCodeExample"/>
      </template>
    </MethodComponent>
  </div>
</template>

<style scoped>

.property-name {
  --font-size: 22px;  
  font-size: var(--font-size);
  
  &:deep(code) {
    font-size: var(--font-size);
  }
}

/*
hr {
  border: none;
  border-top: 1px solid var(--vp-c-divider);
  color: var(--vp-c-divider);
  overflow: visible;
  text-align: center;
  height: 5px;
}

hr:nth-of-type(2) {
  margin: 0 20%;
  &:after {
    background: var(--vp-c-bg);
    content: '§';
    font-size: 18px;
    padding: 0 20px;
    position: relative;
    top: -13px;
  }
}
 */
</style>