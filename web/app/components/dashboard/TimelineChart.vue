<script setup lang="ts">
import { LineChart } from 'echarts/charts'
import { GridComponent, LegendComponent, TooltipComponent } from 'echarts/components'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { ref } from 'vue'
import VChart from 'vue-echarts'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

const props = defineProps<{
  data: any[]
}>()

use([CanvasRenderer, LineChart, GridComponent, TooltipComponent, LegendComponent])

const option = computed(() => ({
  tooltip: { trigger: 'axis' },
  xAxis: {
    type: 'category',
    data: props.data ? props.data.map((d: any) => d.date) : [],
  },
  yAxis: { type: 'value' },
  series: [
    {
      data: props.data ? props.data.map((d: any) => d.trees) : [],
      type: 'line',
      smooth: true,
      itemStyle: { color: '#16a34a' },
    },
  ],
}))
</script>

<template>
  <Card class="col-span-4">
    <CardHeader>
      <CardTitle>Planting Timeline</CardTitle>
    </CardHeader>
    <CardContent>
      <div class="h-[350px]">
        <VChart class="w-full h-full" :option="option" autoresize />
      </div>
    </CardContent>
  </Card>
</template>
