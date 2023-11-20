<script setup>
const props = defineProps({
  is2D: {
    type: Boolean,
    required: true,
  },
  altProp: {
    type: String,
    required: false,
  },
  altPropLink: {
    type: String,
    required: false,
  }
})
</script>

<template>
  <div class="container2D3DOnly">
    <img alt="Phantom Camera 2D" src="../../assets/phantom-camera-2D.svg" v-if="is2D" width="24"/>
    <img alt="Phantom Camera 3D" src="../../assets/phantom-camera-3D.svg" v-if="!is2D" width="24"/>
    <div>
      <p>
        This property is for <code>PCam{{ is2D ? '2D' : '3D' }}</code> <b><i>only</i></b>.
        <span v-if="altProp">
          <br>
          The <code>PCam{{ !is2D ? '2D' : '3D' }}</code> alternative to this is can be found in the <a src :alt="altProp" :href="altPropLink"> {{altProp}}</a> section.
        </span>
      </p>
    </div>
  </div>
</template>

<style scoped>
  .container2D3DOnly {
    display: flex;
    gap: 6px;
    align-items: start;
    padding: 12px 18px;
    border: 2px solid var(--vp-c-bg);
    margin-bottom: 24px;
    border-radius: 12px;
    & p {
      margin: 0;
    }
  }
</style>