<script setup lang="ts">
import { usePageHeader } from '~/composables/usePageHeader'

const { setHeader } = usePageHeader()
setHeader({ title: 'Countries', icon: 'i-lucide-globe-2', description: 'Manage countries for the Tree Planting System.' })

const tableConfig = {
  table: 'countries',
  title: 'Countries Master',
  description: 'Manage allowed countries and their codes.',
  columns: [
    { key: 'id', label: 'ID' },
    { key: 'name', label: 'Country Name' }
  ]
}
</script>

<template>
  <div class="w-full flex flex-col gap-4">
    <main class="flex flex-1 flex-col gap-4">
      <MastersResourceTable v-bind="tableConfig" />
    </main>
  </div>
</template>
