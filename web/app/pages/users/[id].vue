<script setup lang="ts">
import { useRoute } from 'vue-router'

const route = useRoute()
const userId = route.params.id
</script>

<template>
  <div class="flex flex-col gap-4 p-4 lg:p-8">
    <h2 class="text-2xl font-bold tracking-tight">User Details: {{ userId }}</h2>
    <div class="p-6 border rounded-lg bg-card mt-4">
      <p class="text-muted-foreground">Details and permissions for user {{ userId }} will go here.</p>
    </div>
  </div>
</template>
