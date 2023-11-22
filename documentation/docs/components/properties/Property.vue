<script setup lang="ts">
import {computed, useSlots} from "vue";
import { store } from '../../store'

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
  disableOutlineEntry: {
    bool: String,
    required: false
  }
})

const id = computed<String>(() =>{
  if (props.disableOutlineEntry) { return null }
  
  return props.propertyName.replace(/ /g, '-').toLowerCase()
})

// Setter names
const setMethod: string = "setMethod"
const setExample: string = "setExample"

// Getter names
const getMethod: string = "getMethod"
const getExample: string = "getExample"

const slots = useSlots()
const slotContent: Array<string> = Object.keys(slots)

const hasPropertyType = (typeArray: Array<string>) => {
  return slotContent.some(value => typeArray.includes(value))
}

const hasSetterContent = computed(() => {
  return hasPropertyType([setMethod, setExample])
})
const hasGetterContent = computed(() => {
  return hasPropertyType([getMethod, getExample])
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
        Missing propertyDescription
      </p>
    </slot>

    <p class="property-usage-note" v-if="hasSetterContent && hasGetterContent"><b><i>Note:</i></b> Properties should be modified and read via  their setters & getters respectively during runtime.</p>
    
    <hr v-if="hasSetGet" />
    
    <MethodComponent method-type="Setter" :methodName="propertyName" v-if="hasSetterContent">
      <template #method>
        <slot :name="setMethod">
          <p class="missing-text">Missing setMethod</p>
        </slot>
      </template>
      <template #example>
        <slot :name="setExample">
          <p class="missing-text">Missing setExample</p>
        </slot>
      </template>
    </MethodComponent>
    
    <MethodComponent method-type="Getter" :methodName="propertyName" v-if="hasGetterContent">
      <template #method>
        <slot :name="getMethod">
          <p class="missing-text">Missing getMethod</p>
        </slot>
      </template>
      <template #example>
        <slot :name="getExample">
          <p class="missing-text">Missing getExample</p>
        </slot>
      </template>
    </MethodComponent>
    
    <div v-if="!hasSetGet">
      <p class="property-usage-note"><b><i>Note:</i></b> This property is only accessible within the node's inspector panel in the editor. </p> 
    </div>
    
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
  padding: 30px 30px 20px 30px;
  margin-bottom: 36px;
  border-radius: 20px;
  border: 2px solid var(--vp-c-gray-3);
  background: var(--vp-c-bg-alt);
  box-shadow: 0px 0px 40px var(--vp-c-bg) inset;
}
</style>