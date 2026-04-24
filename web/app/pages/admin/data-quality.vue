<script setup lang="ts">
import { ref, onMounted } from 'vue'

const { client } = useSupabase()
const loading = ref(true)
const report = ref<any>({
  orphaned_visits: [],
  missing_photos: [],
  zero_trees: [],
  inactive_users: [],
  duplicates: []
})

const fetchReport = async () => {
  loading.value = true
  const { data, error } = await client.rpc('admin_data_quality_report')
  if (!error && data) {
    report.value = data
  }
  loading.value = false
}

onMounted(() => fetchReport())

const viewDetails = (type: string) => {
  alert(`Investigating ${type}... (mock navigation)`)
}
</script>

<template>
  <div class="p-4 lg:p-8 flex flex-col gap-8">
    <PageHeader title="Data Quality Dashboard" description="Identify anomalies, orphaned records, and potential fraud or sync issues." />

    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <Skeleton v-for="i in 5" :key="i" class="h-32 rounded-lg" />
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <Card class="cursor-pointer hover:bg-muted/50 transition-colors" @click="viewDetails('orphaned_visits')">
        <CardHeader>
          <CardTitle class="flex items-center gap-2 text-red-500">
            <Icon name="lucide:alert-triangle" class="w-5 h-5" />
            Orphaned Visits
          </CardTitle>
          <CardDescription>Visits with missing mandatory FKs</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="text-3xl font-bold">{{ report.orphaned_visits.length }}</div>
        </CardContent>
      </Card>

      <Card class="cursor-pointer hover:bg-muted/50 transition-colors" @click="viewDetails('missing_photos')">
        <CardHeader>
          <CardTitle class="flex items-center gap-2 text-orange-500">
            <Icon name="lucide:image-off" class="w-5 h-5" />
            Missing Photos
          </CardTitle>
          <CardDescription>Completed visits lacking required media</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="text-3xl font-bold">{{ report.missing_photos.length }}</div>
        </CardContent>
      </Card>

      <Card class="cursor-pointer hover:bg-muted/50 transition-colors" @click="viewDetails('zero_trees')">
        <CardHeader>
          <CardTitle class="flex items-center gap-2 text-yellow-500">
            <Icon name="lucide:leaf" class="w-5 h-5" />
            Zero Trees Planted
          </CardTitle>
          <CardDescription>Completed visits with 0 trees (suspicious)</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="text-3xl font-bold">{{ report.zero_trees.length }}</div>
        </CardContent>
      </Card>

      <Card class="cursor-pointer hover:bg-muted/50 transition-colors" @click="viewDetails('inactive_users')">
        <CardHeader>
          <CardTitle class="flex items-center gap-2 text-gray-500">
            <Icon name="lucide:user-x" class="w-5 h-5" />
            Inactive Users
          </CardTitle>
          <CardDescription>Users with no activity in 30+ days</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="text-3xl font-bold">{{ report.inactive_users.length }}</div>
        </CardContent>
      </Card>

      <Card class="cursor-pointer hover:bg-muted/50 transition-colors" @click="viewDetails('duplicates')">
        <CardHeader>
          <CardTitle class="flex items-center gap-2 text-red-600">
            <Icon name="lucide:copy" class="w-5 h-5" />
            Duplicate Detection
          </CardTitle>
          <CardDescription>Same GPS, Date, and User</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="text-3xl font-bold">{{ report.duplicates.length }}</div>
        </CardContent>
      </Card>
      
      <Card class="cursor-pointer hover:bg-muted/50 transition-colors" @click="viewDetails('missing_translations')">
        <CardHeader>
          <CardTitle class="flex items-center gap-2 text-blue-500">
            <Icon name="lucide:languages" class="w-5 h-5" />
            Missing Translations
          </CardTitle>
          <CardDescription>Entities missing translations for active locales</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="text-3xl font-bold">Check</div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
