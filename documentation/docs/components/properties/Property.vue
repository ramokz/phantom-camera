<script setup lang="ts">
import {computed, useSlots} from "vue";

const props = defineProps({
  propertyName: {
    type: String,
    required: true,
  },
  propertyType: {
    type: String,
    required: true,
  },
  propertyDefault: {
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
    <div class="property-overview">
      <h4>
        Type: <code>{{ propertyType }}</code>
      </h4>
      <h4>
        Default: <code>{{ propertyDefault }}</code>
      </h4>
    </div>
      
    <slot name="propertyDescription">
      <p class="missing-text">
        MISSING PROPERTY DESCRIPTION
      </p>
    </slot>

    <p class="property-usage-note"><i>Note:</i> Properties should be modified and read via setters and getters respectively.</p>
    
    <hr v-if="hasSetGet" />
    
    <MethodComponent method-type="Setter" :methodName="propertyName" v-if="hasSetterContent">
      <template #method>
        <slot :name="setMethod"/>
      </template>
      <template #codeExample>
        <slot :name="setCodeExample"/>
      </template>
    </MethodComponent>

<!--    <hr v-if="hasSetGet" />-->

    <MethodComponent method-type="Getter" :methodName="propertyName" v-if="hasGetterContent">
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
.property-overview {
  @media(min-width: 600px) {
    display: flex;
    flex-wrap: wrap;
  }
  & > h4 {
    & >code {
      color: var(--vp-code-color);
    }
    &:last-child {
      margin: 10px 0 0 0;
      @media(min-width: 600px) {
        margin: 0 0 0 20px;
      }
    }
  }
}

.property-usage-note {
  font-size: 16px;
  opacity: 0.8;
  margin-top: 0;
}

.property-method-container {
  padding: 20px 20px 10px 20px;
  margin-bottom: 36px;
  border-radius: 20px;
  border: 1px solid var(--vp-c-gray-3);
}
</style>