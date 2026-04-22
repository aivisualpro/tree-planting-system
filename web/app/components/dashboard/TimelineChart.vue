<script setup lang="ts">
import { use } from 'echarts/core'
import { LineChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  GridComponent,
  LegendComponent,
} from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'
import VChart from 'vue-echarts'

use([
  TitleComponent,
  TooltipComponent,
  GridComponent,
  LegendComponent,
  LineChart,
  CanvasRenderer,
])

const { data: timeline } = await useFetch('/api/dashboard/timeline')

const option = computed(() => {
  const dates = timeline.value?.map(item => item.date) || []
  const trees = timeline.value?.map(item => item.trees) || []
  const attendance = timeline.value?.map(item => item.attendance) || []

  return {
    tooltip: { trigger: 'axis' },
    legend: { data: ['Trees Planted', 'Attendance'] },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'category', boundaryGap: false, data: dates },
    yAxis: { type: 'value' },
    series: [
      {
        name: 'Trees Planted',
        type: 'line',
        smooth: true,
        data: trees,
        itemStyle: { color: '#16a34a' } // green
      },
      {
        name: 'Attendance',
        type: 'line',
        smooth: true,
        data: attendance,
        itemStyle: { color: '#2563eb' } // blue
      }
    ]
  }
})
</script>

<template>
  <div class="h-[400px] w-full">
    <VChart :option="option" autoresize class="h-full w-full" />
  </div>
</template>
