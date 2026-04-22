<script setup lang="ts">
import ResourceTable from '@/components/masters/ResourceTable.vue'

const columns = [
  { key: 'id', label: 'ID' },
  { key: 'scientific_name', label: 'Scientific Name' },
  { key: 'common_name', label: 'Common Name' },
]
</script>

<template>
  <div class="h-full flex flex-col gap-4 p-4 lg:p-8">
    <ResourceTable
      table="species"
      title="Species"
      description="Manage tree species"
      :columns="columns"
    />
  </div>
</template>
