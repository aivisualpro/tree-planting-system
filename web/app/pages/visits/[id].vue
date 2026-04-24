<script setup lang="ts">
import type { Database } from '../../../../shared/types/database'
import { useRoute } from 'vue-router'
import { usePageHeader } from '~/composables/usePageHeader'

const route = useRoute()
const visitId = route.params.id as string

const { setHeader } = usePageHeader()
setHeader({ title: `Visit Details`, icon: 'i-lucide-file-text', description: 'Read-only view of a field visit.' })

const supabase = useSupabaseClient<Database>()
const visit = ref<any>(null)
const loading = ref(true)

async function fetchVisit() {
  const { data, error } = await supabase
    .from('visits')
    .select('*, country:countries(name), user:users(name)')
    .eq('id', visitId)
    .single()

  if (!error && data) {
    visit.value = data
  }
  loading.value = false
}

onMounted(() => {
  fetchVisit()
})
</script>

<template>
  <div class="w-full flex flex-col gap-4">
    <main class="flex flex-1 flex-col gap-4 md:gap-8">
      <div v-if="loading" class="flex flex-col gap-4">
        <Skeleton class="h-[200px] w-full" />
        <Skeleton class="h-[400px] w-full" />
      </div>

      <div v-else-if="!visit" class="flex items-center justify-center p-8 border rounded-lg bg-muted/20">
        <div class="text-muted-foreground">
          Visit not found.
        </div>
      </div>

      <template v-else>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <Card>
            <CardHeader class="pb-2">
              <CardDescription>Status</CardDescription>
              <CardTitle><Badge>{{ visit.status || 'Completed' }}</Badge></CardTitle>
            </CardHeader>
          </Card>
          <Card>
            <CardHeader class="pb-2">
              <CardDescription>Trees Planted</CardDescription>
              <CardTitle class="text-2xl text-green-600">
                {{ visit.trees_planted || 0 }}
              </CardTitle>
            </CardHeader>
          </Card>
          <Card>
            <CardHeader class="pb-2">
              <CardDescription>Date</CardDescription>
              <CardTitle class="text-xl">
                {{ new Date(visit.created_at).toLocaleDateString() }}
              </CardTitle>
            </CardHeader>
          </Card>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
          <Card class="lg:col-span-2">
            <CardHeader>
              <CardTitle>Field Data</CardTitle>
              <CardDescription>Detailed information collected during the visit.</CardDescription>
            </CardHeader>
            <CardContent>
              <div class="grid grid-cols-2 gap-y-4">
                <div>
                  <div class="text-sm font-medium text-muted-foreground">
                    Country
                  </div>
                  <div>{{ visit.country?.name || 'Unknown' }}</div>
                </div>
                <div>
                  <div class="text-sm font-medium text-muted-foreground">
                    Field Agent
                  </div>
                  <div>{{ visit.user?.name || 'Unknown' }}</div>
                </div>
                <div>
                  <div class="text-sm font-medium text-muted-foreground">
                    Coordinates
                  </div>
                  <div class="text-sm font-mono">
                    {{ visit.lat }}, {{ visit.lng }}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Photos</CardTitle>
            </CardHeader>
            <CardContent>
              <div class="aspect-video bg-muted rounded-md flex items-center justify-center">
                <div class="text-muted-foreground text-sm">
                  No photos uploaded
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </template>
    </main>
  </div>
</template>
