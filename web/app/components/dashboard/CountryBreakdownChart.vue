<script setup lang="ts">
import { ref } from 'vue'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart } from 'echarts/charts'
import { TooltipComponent, LegendComponent } from 'echarts/components'

use([CanvasRenderer, PieChart, TooltipComponent, LegendComponent])

const props = defineProps<{
  data: any[]
}>()

const option = computed(() => ({
  tooltip: { trigger: 'item' },
  legend: { bottom: '0%', left: 'center' },
  series: [
    {
      name: 'Total Visits',
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 10,
        borderColor: '#fff',
        borderWidth: 2
      },
      label: { show: false, position: 'center' },
      emphasis: {
        label: { show: true, fontSize: '18', fontWeight: 'bold' }
      },
      labelLine: { show: false },
      data: props.data && props.data.length > 0 
        ? props.data.map((d: any) => ({ value: d.visits, name: d.country_name }))
        : [{ value: 0, name: 'No Data' }]
    }
  ]
}))

</script>

<template>
  <Card class="col-span-3">
    <CardHeader>
      <CardTitle>Country Breakdown</CardTitle>
    </CardHeader>
    <CardContent>
      <div class="h-[350px]">
        <VChart class="w-full h-full" :option="option" autoresize />
      </div>
    </CardContent>
  </Card>
</template>
