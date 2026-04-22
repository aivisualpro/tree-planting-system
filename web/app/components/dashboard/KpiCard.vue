<script setup lang="ts">
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import NumberFlow from '@number-flow/vue'
import { cn } from '@/lib/utils'

defineProps<{
  title: string
  value: number
  icon?: any
  trend?: number
  format?: 'number' | 'currency'
}>()
</script>

<template>
  <Card>
    <CardHeader class="flex flex-row items-center justify-between pb-2">
      <CardTitle class="text-sm font-medium text-muted-foreground">{{ title }}</CardTitle>
      <component :is="icon" v-if="icon" class="h-4 w-4 text-muted-foreground" />
    </CardHeader>
    <CardContent>
      <div class="text-2xl font-bold">
        <NumberFlow :value="value" :format="{ style: format === 'currency' ? 'currency' : 'decimal', currency: 'USD' }" />
      </div>
      <p v-if="trend !== undefined" :class="cn('text-xs', trend >= 0 ? 'text-green-500' : 'text-red-500')">
        {{ trend >= 0 ? '+' : '' }}{{ trend }}% from last month
      </p>
    </CardContent>
  </Card>
</template>
