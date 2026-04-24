<script setup lang="ts">
import { MapPin, TreePine, TrendingUp, Users } from 'lucide-vue-next'
import CountryBreakdownChart from '@/components/dashboard/CountryBreakdownChart.vue'
import KpiCard from '@/components/dashboard/KpiCard.vue'
import TimelineChart from '@/components/dashboard/TimelineChart.vue'
import TopSpeciesChart from '@/components/dashboard/TopSpeciesChart.vue'
import UserActivityHeatmap from '@/components/dashboard/UserActivityHeatmap.vue'

const { setHeader } = usePageHeader()
setHeader({ title: 'Global Dashboard', icon: 'i-lucide-globe', description: 'Real-time overview of the Tree Planting System.' })

// Fetch real data from our backend APIs
const { data: kpis } = await useFetch('/api/dashboard/kpis')
const { data: timeline } = await useFetch('/api/dashboard/timeline')
const { data: countryBreakdown } = await useFetch('/api/dashboard/country-breakdown')
const { data: topSpecies } = await useFetch('/api/dashboard/top-species')
const { data: userActivity } = await useFetch('/api/dashboard/user-activity')
</script>

<template>
  <div class="w-full flex flex-col gap-4 p-4 lg:p-8">
    <main class="@container/main flex flex-1 flex-col gap-4 md:gap-8">
      <!-- KPI Cards -->
      <div class="grid grid-cols-1 gap-4 @xl/main:grid-cols-3">
        <KpiCard
          title="Total Visits"
          :value="kpis?.visits || 0"
          :icon="MapPin"
          format="number"
          :trend="12"
        />
        <KpiCard
          title="Total Trees Planted"
          :value="kpis?.trees || 0"
          :icon="TreePine"
          format="number"
          :trend="8"
        />
        <KpiCard
          title="Total Attendance"
          :value="kpis?.attendance || 0"
          :icon="Users"
          format="number"
          :trend="15"
        />
      </div>

      <!-- Main Chart Area -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <TimelineChart :data="timeline || []" />
      </div>

      <!-- Secondary Charts -->
      <div class="grid grid-cols-1 md:grid-cols-6 gap-4">
        <CountryBreakdownChart :data="countryBreakdown || []" />
        <TopSpeciesChart :data="topSpecies || []" />
      </div>

      <!-- Heatmap -->
      <div class="grid grid-cols-1 gap-4">
        <UserActivityHeatmap :data="userActivity || []" />
      </div>
    </main>
  </div>
</template>
