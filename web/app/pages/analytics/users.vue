<script setup lang="ts">
import UserActivityHeatmap from '@/components/dashboard/UserActivityHeatmap.vue'

const mockData: any[] = []
</script>

<template>
  <div class="flex flex-col gap-4 p-4 lg:p-8">
    <h2 class="text-2xl font-bold tracking-tight">User Analytics</h2>
    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <UserActivityHeatmap :data="mockData" class="col-span-full" />
    </div>
  </div>
</template>
