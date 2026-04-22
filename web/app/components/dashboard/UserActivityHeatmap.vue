<script setup lang="ts">
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

defineProps<{
  data: any[]
}>()

// Using a basic div grid for heatmap mockup
const weeks = 52
const days = 7
</script>

<template>
  <Card class="col-span-full">
    <CardHeader>
      <CardTitle>User Activity</CardTitle>
    </CardHeader>
    <CardContent>
      <div class="overflow-x-auto">
        <div class="flex gap-1 min-w-max pb-4">
          <div v-for="w in weeks" :key="w" class="flex flex-col gap-1">
            <div 
              v-for="d in days" :key="`${w}-${d}`" 
              class="w-3 h-3 rounded-sm"
              :class="Math.random() > 0.7 ? 'bg-green-500' : Math.random() > 0.4 ? 'bg-green-300' : 'bg-muted'"
            ></div>
          </div>
        </div>
      </div>
    </CardContent>
  </Card>
</template>
