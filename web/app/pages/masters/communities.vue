<script setup lang="ts">
import ResourceTable from '@/components/masters/ResourceTable.vue'

const columns = [
  { key: 'id', label: 'ID' },
  { key: 'name', label: 'Name' },
  { key: 'subwatershed_id', label: 'Subwatershed ID' },
]
</script>

<template>
  <div class="h-full flex flex-col gap-4 p-4 lg:p-8">
    <ResourceTable
      table="communities"
      title="Communities"
      description="Manage local communities"
      :columns="columns"
    />
  </div>
</template>
