// https://vitepress.dev/guide/custom-theme
import { h } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import './style.css'
import './custom.css'

import MethodComponent from "../../components/methods/MethodComponent.vue";
import MethodSetGet from "../../components/methods/MethodSetGet.vue";

import PropertyCore from "../../components/properties/PropertyCore.vue";
import Property from "../../components/properties/Property.vue";

export default {
  extends: DefaultTheme,
  async enhanceApp({ app }) {
    // register your custom global components
    app.component('MethodComponent', MethodComponent),
    app.component('MethodSetGet', MethodSetGet),
    app.component('PropertyCore', PropertyCore),
    app.component('Property', Property)
  },
  Layout: () => {
    return h(DefaultTheme.Layout, null, {
      // https://vitepress.dev/guide/extending-default-theme#layout-slots
    })
  },
} satisfies Theme
