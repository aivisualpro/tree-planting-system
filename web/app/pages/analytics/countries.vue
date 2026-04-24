<script setup lang="ts">
import CountryBreakdownChart from '@/components/dashboard/CountryBreakdownChart.vue'

const mockData: any[] = []
</script>

<template>
  <div class="flex flex-col gap-4 p-4 lg:p-8">
    <h2 class="text-2xl font-bold tracking-tight">
      Country Analytics
    </h2>
    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <CountryBreakdownChart :data="mockData" class="col-span-full" />
    </div>
  </div>
</template>
