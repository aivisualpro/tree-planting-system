<script setup lang="ts">
import { BarChart } from 'echarts/charts'
import { GridComponent, TooltipComponent } from 'echarts/components'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { ref } from 'vue'
import VChart from 'vue-echarts'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

const props = defineProps<{
  data: any[]
}>()

use([CanvasRenderer, BarChart, GridComponent, TooltipComponent])

const option = computed(() => ({
  tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
  grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
  xAxis: { type: 'value', boundaryGap: [0, 0.01] },
  yAxis: { type: 'category', data: props.data ? props.data.map((d: any) => d.common_name_en || 'Unknown') : [] },
  series: [
    {
      name: 'Planted',
      type: 'bar',
      data: props.data ? props.data.map((d: any) => d.total_planted) : [],
      itemStyle: { color: '#16a34a' },
    },
  ],
}))
</script>

<template>
  <Card class="col-span-3">
    <CardHeader>
      <CardTitle>Top Species Planted</CardTitle>
    </CardHeader>
    <CardContent>
      <div class="h-[350px]">
        <VChart class="w-full h-full" :option="option" autoresize />
      </div>
    </CardContent>
  </Card>
</template>
