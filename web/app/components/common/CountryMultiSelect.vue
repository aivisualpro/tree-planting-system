<script setup lang="ts">
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'

const modelValue = defineModel<string>()
</script>

<template>
  <Select v-model="modelValue">
    <SelectTrigger class="w-[280px]">
      <SelectValue placeholder="Select country..." />
    </SelectTrigger>
    <SelectContent>
      <SelectItem value="ke">Kenya</SelectItem>
      <SelectItem value="ug">Uganda</SelectItem>
      <SelectItem value="tz">Tanzania</SelectItem>
    </SelectContent>
  </Select>
</template>
