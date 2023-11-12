// https://vitepress.dev/guide/custom-theme
import { h } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import './style.css'
import './custom.css'

import MethodsComponent from "../../components/methods/MethodsComponent.vue";
import MethodsSetGet from "../../components/methods/MethodsSetGet.vue";

export default {
  extends: DefaultTheme,
  async enhanceApp({ app }) {
    // register your custom global components
    app.component('MethodsComponent', MethodsComponent),
    app.component('MethodsSetGet', MethodsSetGet)
  },
  Layout: () => {
    return h(DefaultTheme.Layout, null, {
      // https://vitepress.dev/guide/extending-default-theme#layout-slots
    })
  },
} satisfies Theme
