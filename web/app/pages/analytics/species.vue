<script setup lang="ts">
import TopSpeciesChart from '@/components/dashboard/TopSpeciesChart.vue'

const mockData: any[] = []
</script>

<template>
  <div class="flex flex-col gap-4 p-4 lg:p-8">
    <h2 class="text-2xl font-bold tracking-tight">
      Species Analytics
    </h2>
    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <TopSpeciesChart :data="mockData" class="col-span-full" />
    </div>
  </div>
</template>
