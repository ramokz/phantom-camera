import { reactive } from 'vue'

export const store = reactive({
    is2D: true,
    toggle2D(value: boolean) {
        this.is2D = value
}
})