<script setup lang="ts">
import { usePageHeader } from '~/composables/usePageHeader'

const { setHeader } = usePageHeader()
setHeader({ title: 'Field Visits', icon: 'i-lucide-map', description: 'Manage and review field visit reports.' })
</script>

<template>
  <div class="w-full flex flex-col gap-4">
    <main class="flex flex-1 flex-col gap-4">
      <Card class="flex-1 flex flex-col min-h-0">
        <CardHeader class="flex flex-row items-center justify-between">
          <div>
            <CardTitle>Visits Log</CardTitle>
            <CardDescription>Filter and browse all field visits.</CardDescription>
          </div>
          <VisitsVisitFilters />
        </CardHeader>
        <CardContent class="flex-1 flex flex-col min-h-0">
          <VisitsVisitTable />
        </CardContent>
      </Card>
    </main>
  </div>
</template>
