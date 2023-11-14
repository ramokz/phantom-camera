<script setup lang="ts">
// import MethodsComponent from "./MethodComponent.vue";
</script>

<template>
  <div class="set-get-container">
    <MethodComponent method-type="setter">
      <template v-slot:method>
        <slot name="set-method"/>
      </template>
      <template v-slot:description>
        <slot name="set-description"/>
      </template>
      <template v-slot:code-example>
        <slot name="set-code-example"/>
      </template>
    </MethodComponent>
    
    <hr/>
    
    <MethodComponent method-type="getter">
      <template v-slot:method>
        <slot name="get-method"/>
      </template>
      <template v-slot:description>
        <slot name="get-description"/>
      </template>
      <template v-slot:code-example>
        <slot name="get-code-example"/>
      </template>
    </MethodComponent>
  </div>
</template>

<style scoped>
  .set-get-container {
    padding: 30px 20px;
    border-radius: 20px;
    box-shadow: 0 0 20px 2px #0c1518;
  }
  
  hr {
    border: none;
    border-top: 1px solid var(--vp-c-divider);
    color: var(--vp-c-divider);
    overflow: visible;
    text-align: center;
    height: 5px;
  }

hr:after {
    background: var(--vp-c-bg);
    content: '§';
    font-size: 18px;
    padding: 0 20px;
    position: relative;
    top: -13px;
  }
</style>