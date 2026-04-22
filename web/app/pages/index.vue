<script setup lang="ts">
import NumberFlow from '@number-flow/vue'
import { TrendingUp, TreePine, Users, MapPin } from 'lucide-vue-next'

const { setHeader } = usePageHeader()
setHeader({ title: 'Global Dashboard', icon: 'i-lucide-globe', description: 'Real-time overview of the Tree Planting System.' })

// Fetch real data from our backend APIs
const { data: kpis } = await useFetch('/api/dashboard/kpis')
</script>

<template>
  <div class="w-full flex flex-col gap-4">
    <main class="@container/main flex flex-1 flex-col gap-4 md:gap-8">
      <!-- KPI Cards -->
      <div class="grid grid-cols-1 gap-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:shadow-xs @xl/main:grid-cols-3">
        <Card class="@container/card">
          <CardHeader>
            <CardDescription>Total Visits</CardDescription>
            <CardTitle class="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
              <NumberFlow :value="kpis?.visits || 0" />
            </CardTitle>
            <CardAction>
              <Badge variant="outline">
                <MapPin class="size-4 mr-1" /> All Zones
              </Badge>
            </CardAction>
          </CardHeader>
          <CardFooter class="flex-col items-start gap-1.5 text-sm">
            <div class="text-muted-foreground">Successful field visits</div>
          </CardFooter>
        </Card>

        <Card class="@container/card">
          <CardHeader>
            <CardDescription>Total Trees Planted</CardDescription>
            <CardTitle class="text-2xl font-semibold tabular-nums text-green-600 @[250px]/card:text-3xl">
              <NumberFlow :value="kpis?.trees || 0" />
            </CardTitle>
            <CardAction>
              <Badge variant="outline">
                <TreePine class="size-4 mr-1" />
                Global
              </Badge>
            </CardAction>
          </CardHeader>
          <CardFooter class="flex-col items-start gap-1.5 text-sm">
            <div class="text-muted-foreground">Aggregate tree count</div>
          </CardFooter>
        </Card>

        <Card class="@container/card">
          <CardHeader>
            <CardDescription>Total Attendance</CardDescription>
            <CardTitle class="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
              <NumberFlow :value="kpis?.attendance || 0" />
            </CardTitle>
            <CardAction>
              <Badge variant="outline">
                <Users class="size-4 mr-1" />
                Community
              </Badge>
            </CardAction>
          </CardHeader>
          <CardFooter class="flex-col items-start gap-1.5 text-sm">
            <div class="text-muted-foreground">People engaged in programs</div>
          </CardFooter>
        </Card>
      </div>

      <!-- Main Chart Area -->
      <Card class="@container/card">
        <CardHeader>
          <CardTitle>Planting Activity Timeline</CardTitle>
          <CardDescription>
            Last 30 Days of Trees Planted & Attendance
          </CardDescription>
        </CardHeader>
        <CardContent>
          <!-- Using the new Vue-Echarts timeline component -->
          <DashboardTimelineChart />
        </CardContent>
      </Card>
    </main>
  </div>
</template>
