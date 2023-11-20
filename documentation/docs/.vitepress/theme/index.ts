// https://vitepress.dev/guide/custom-theme
import { h } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import './style.css'
import './custom.css'

import MethodComponent from "../../components/methods/MethodComponent.vue";

import PropertyCore from "../../components/properties/PropertyCore.vue";
import Property from "../../components/properties/Property.vue";
import Property2D3D from "../../components/properties/Property2D3D.vue";
import Property2D3DOnly from "../../components/properties/Property2D3DOnly.vue";

export default {
  extends: DefaultTheme,
  async enhanceApp({ app }) {
    // register your custom global components
    app.component('MethodComponent', MethodComponent),
    app.component('PropertyCore', PropertyCore),
    app.component('Property', Property),
    app.component('Property2D3D', Property2D3D),
    app.component('Property2D3DOnly', Property2D3DOnly)
  },
  Layout: () => {
    return h(DefaultTheme.Layout, null, {
      // https://vitepress.dev/guide/extending-default-theme#layout-slots
    })
  },
} satisfies Theme
