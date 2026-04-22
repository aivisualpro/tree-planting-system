<script setup lang="ts">
import { ref } from 'vue'
import { Search } from 'lucide-vue-next'

const searchQuery = ref('')
// Will add more filters later (e.g. date range, country)
</script>

<template>
  <div class="flex items-center gap-2">
    <div class="relative max-w-sm w-full items-center">
      <Input id="search" type="text" placeholder="Search visits..." class="pl-10" v-model="searchQuery" />
      <span class="absolute start-0 inset-y-0 flex items-center justify-center px-2">
        <Search class="size-4 text-muted-foreground" />
      </span>
    </div>
    <Button variant="outline">
      <div class="i-lucide-filter mr-2" />
      Filter
    </Button>
  </div>
</template>
