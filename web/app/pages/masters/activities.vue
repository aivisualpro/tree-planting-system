<script setup lang="ts">
import ResourceTable from '@/components/masters/ResourceTable.vue'

const columns = [
  { key: 'id', label: 'ID' },
  { key: 'name', label: 'Name' },
]
</script>

<template>
  <div class="h-full flex flex-col gap-4 p-4 lg:p-8">
    <ResourceTable
      table="activities"
      title="Activities"
      description="Manage project activities"
      :columns="columns"
    />
  </div>
</template>
