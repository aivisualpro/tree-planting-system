<script setup lang="ts">
import { toast } from 'vue-sonner'

const exporting = ref<string | null>(null)

async function exportData(type: string) {
  exporting.value = type
  try {
    const url = `/api/exports/${type}`
    window.open(url, '_blank')
    toast.success(`${type.charAt(0).toUpperCase() + type.slice(1)} export started`)
  }
  catch (err) {
    toast.error('Failed to start export')
  }
  finally {
    exporting.value = null
  }
}

async function generatePdf(type: string, params: Record<string, string>) {
  exporting.value = type
  try {
    const queryString = new URLSearchParams(params).toString()
    const url = `/api/reports/${type}?${queryString}`
    window.open(url, '_blank')
    toast.success('Generating report...')
  }
  catch (err) {
    toast.error('Failed to generate report')
  }
  finally {
    exporting.value = null
  }
}

const reportTypes = [
  {
    title: 'Data Exports',
    description: 'Download raw data in Excel format for offline analysis.',
    actions: [
      { id: 'visits', label: 'Visits Data', icon: 'i-lucide-tree-pine', type: 'export' },
      { id: 'users', label: 'User Directory', icon: 'i-lucide-users', type: 'export' },
      { id: 'translations', label: 'Translations List', icon: 'i-lucide-languages', type: 'export' },
    ],
  },
  {
    title: 'Performance Reports',
    description: 'Formatted PDF reports with charts and summaries.',
    actions: [
      { id: 'monthly-country', label: 'Country Monthly', icon: 'i-lucide-globe', type: 'pdf' },
      { id: 'tree-impact', label: 'Tree Impact Report', icon: 'i-lucide-trending-up', type: 'pdf' },
    ],
  },
]
</script>

<template>
  <div class="p-8 max-w-7xl mx-auto space-y-10">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-4xl font-black text-green-900 tracking-tight">
          Reporting Center
        </h1>
        <p class="text-muted-foreground text-lg mt-2">
          Export data and generate compliance-ready reports.
        </p>
      </div>
      <div class="bg-green-50 px-4 py-2 rounded-full border border-green-100 flex items-center gap-2">
        <span class="relative flex h-3 w-3">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75" />
          <span class="relative inline-flex rounded-full h-3 w-3 bg-green-500" />
        </span>
        <span class="text-sm font-bold text-green-700 uppercase tracking-widest">Real-time Data</span>
      </div>
    </div>

    <div class="grid md:grid-cols-2 gap-8">
      <Card v-for="section in reportTypes" :key="section.title" class="overflow-hidden border-2 hover:border-green-600/20 transition-all duration-300">
        <CardHeader class="bg-muted/30 pb-8">
          <CardTitle class="text-2xl">
            {{ section.title }}
          </CardTitle>
          <CardDescription class="text-base">
            {{ section.description }}
          </CardDescription>
        </CardHeader>
        <CardContent class="p-6 grid gap-4">
          <Button
            v-for="action in section.actions"
            :key="action.id"
            variant="outline"
            class="h-16 justify-between text-lg group hover:bg-green-50 hover:text-green-700 hover:border-green-200 transition-all"
            @click="action.type === 'pdf' ? generatePdf(action.id, { countryId: 'c0000000-0000-0000-0000-000000000001' }) : exportData(action.id)"
          >
            <div class="flex items-center gap-4">
              <div class="p-2 bg-white rounded-lg border group-hover:border-green-200 shadow-sm">
                <Icon :name="action.icon" class="size-6" />
              </div>
              <span class="font-bold">{{ action.label }}</span>
            </div>
            <Icon name="i-lucide-chevron-right" class="size-5 opacity-0 group-hover:opacity-100 transition-all translate-x-[-10px] group-hover:translate-x-0" />
          </Button>
        </CardContent>
      </Card>
    </div>

    <div class="bg-blue-50 border border-blue-100 rounded-2xl p-8 flex items-center gap-8">
      <div class="bg-white p-4 rounded-2xl shadow-sm border border-blue-100">
        <Icon name="i-lucide-calendar-clock" class="size-12 text-blue-600" />
      </div>
      <div>
        <h3 class="text-xl font-bold text-blue-900 mb-1">
          Scheduled Reports
        </h3>
        <p class="text-blue-700 max-w-2xl">
          Want these reports delivered to your inbox automatically?
          You can manage your subscriptions in the account settings.
        </p>
        <Button variant="link" class="p-0 h-auto text-blue-600 font-bold mt-4" as-child>
          <NuxtLink to="/settings/reports">
            Manage Subscriptions &rarr;
          </NuxtLink>
        </Button>
      </div>
    </div>
  </div>
</template>
