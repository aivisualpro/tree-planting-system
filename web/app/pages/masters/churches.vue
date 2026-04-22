<script setup lang="ts">
import ResourceTable from '@/components/masters/ResourceTable.vue'

const columns = [
  { key: 'id', label: 'ID' },
  { key: 'name', label: 'Name' },
  { key: 'community_id', label: 'Community ID' },
]
</script>

<template>
  <div class="h-full flex flex-col gap-4 p-4 lg:p-8">
    <ResourceTable
      table="churches"
      title="Churches"
      description="Manage partnered churches"
      :columns="columns"
    />
  </div>
</template>
