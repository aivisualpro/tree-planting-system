<script setup lang="ts">
import ResourceTable from '@/components/masters/ResourceTable.vue'

const columns = [
  { key: 'id', label: 'ID' },
  { key: 'name', label: 'Name' },
  { key: 'country_id', label: 'Country ID' },
]
</script>

<template>
  <div class="h-full flex flex-col gap-4 p-4 lg:p-8">
    <ResourceTable
      table="subwatersheds"
      title="Subwatersheds"
      description="Manage geographical subwatersheds"
      :columns="columns"
    />
  </div>
</template>
