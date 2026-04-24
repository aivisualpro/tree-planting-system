// Lazy-loaded ECharts component (§7 – moved to async chunk)
// Import this with defineAsyncComponent() to keep initial JS < 200KB.
//
// Usage:
//   const LazyEChart = defineAsyncComponent(() => import('~/components/charts/LazyEChart.vue'))
//
// Or in Nuxt with auto-import (lazy prefix):
//   <LazyChartsLazyEChart :option="chartOption" />

<template>
  <div ref="chartRef" :style="{ width: width, height: height }" />
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'

interface Props {
  option: Record<string, unknown>
  width?: string
  height?: string
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  width: '100%',
  height: '300px',
  loading: false,
})

const chartRef = ref<HTMLElement | null>(null)
// eslint-disable-next-line @typescript-eslint/no-explicit-any
let chart: any = null

onMounted(async () => {
  if (!chartRef.value) return

  // §7 – dynamic import: ECharts loads only when this component is rendered
  const echarts = await import('echarts')
  chart = echarts.init(chartRef.value)
  chart.setOption(props.option)

  if (props.loading) chart.showLoading()

  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  chart?.dispose()
  window.removeEventListener('resize', handleResize)
})

watch(() => props.option, (newOption) => {
  chart?.setOption(newOption, { notMerge: false, lazyUpdate: true })
}, { deep: true })

watch(() => props.loading, (loading) => {
  if (loading) chart?.showLoading()
  else chart?.hideLoading()
})

function handleResize() {
  chart?.resize()
}
</script>
