<script setup lang="ts">
import { ref } from 'vue'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'

use([CanvasRenderer, LineChart, GridComponent, TooltipComponent, LegendComponent])

const props = defineProps<{
  data: any[]
}>()

const option = computed(() => ({
  tooltip: { trigger: 'axis' },
  xAxis: { 
    type: 'category', 
    data: props.data ? props.data.map((d: any) => d.date) : [] 
  },
  yAxis: { type: 'value' },
  series: [
    {
      data: props.data ? props.data.map((d: any) => d.trees) : [],
      type: 'line',
      smooth: true,
      itemStyle: { color: '#16a34a' }
    }
  ]
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
