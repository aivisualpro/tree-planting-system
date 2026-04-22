<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { Database } from '../../../../shared/types/database'

const router = useRouter()
const supabase = useSupabaseClient<Database>()

const visits = ref<any[]>([])
const loading = ref(true)
const page = ref(1)
const pageSize = ref(50)
const total = ref(0)

const fetchVisits = async () => {
  loading.value = true
  const from = (page.value - 1) * pageSize.value
  const to = from + pageSize.value - 1

  const { data, count, error } = await supabase
    .from('visits')
    .select('*, country:countries(name), user:users(name)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to)

  if (!error && data) {
    visits.value = data
    total.value = count || 0
  }
  loading.value = false
}

onMounted(() => {
  fetchVisits()
})

const viewVisit = (id: string) => {
  router.push(`/visits/${id}`)
}
</script>

<template>
  <div class="rounded-md border h-full overflow-auto">
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Date</TableHead>
          <TableHead>Country</TableHead>
          <TableHead>User</TableHead>
          <TableHead>Trees Planted</TableHead>
          <TableHead>Status</TableHead>
          <TableHead class="text-right">Actions</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        <TableRow v-if="loading" v-for="i in 5" :key="`skeleton-${i}`">
          <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
          <TableCell><Skeleton class="h-4 w-[150px]" /></TableCell>
          <TableCell><Skeleton class="h-4 w-[150px]" /></TableCell>
          <TableCell><Skeleton class="h-4 w-[80px]" /></TableCell>
          <TableCell><Skeleton class="h-4 w-[80px]" /></TableCell>
          <TableCell class="text-right"><Skeleton class="h-8 w-8 ml-auto" /></TableCell>
        </TableRow>
        
        <TableRow v-else-if="visits.length === 0">
          <TableCell colspan="6" class="h-24 text-center">
            No visits found.
          </TableCell>
        </TableRow>

        <TableRow v-else v-for="visit in visits" :key="visit.id" class="cursor-pointer hover:bg-muted/50" @click="viewVisit(visit.id)">
          <TableCell>{{ new Date(visit.created_at).toLocaleDateString() }}</TableCell>
          <TableCell>{{ visit.country?.name || 'Unknown' }}</TableCell>
          <TableCell>{{ visit.user?.name || 'Unknown' }}</TableCell>
          <TableCell>{{ visit.trees_planted || 0 }}</TableCell>
          <TableCell>
            <Badge variant="outline">{{ visit.status || 'Completed' }}</Badge>
          </TableCell>
          <TableCell class="text-right">
            <Button variant="ghost" size="icon" @click.stop="viewVisit(visit.id)">
              <div class="i-lucide-chevron-right size-4" />
            </Button>
          </TableCell>
        </TableRow>
      </TableBody>
    </Table>
  </div>
  
  <div class="flex items-center justify-between pt-4">
    <div class="text-sm text-muted-foreground">
      Showing {{ (page - 1) * pageSize + 1 }} to {{ Math.min(page * pageSize, total) }} of {{ total }} entries
    </div>
    <div class="flex items-center gap-2">
      <Button variant="outline" size="sm" :disabled="page === 1" @click="page--; fetchVisits()">Previous</Button>
      <Button variant="outline" size="sm" :disabled="page * pageSize >= total" @click="page++; fetchVisits()">Next</Button>
    </div>
  </div>
</template>
