<script setup lang="ts">
import type { Database } from '../../../../shared/types/database'
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { toast } from 'vue-sonner'

const router = useRouter()
const supabase = useSupabaseClient<Database>()

const visits = ref<any[]>([])
const loading = ref(true)
const page = ref(1)
const pageSize = ref(50)
const total = ref(0)
const selectedVisits = ref<string[]>([])
const cancelReason = ref('')

async function fetchVisits() {
  loading.value = true
  const from = (page.value - 1) * pageSize.value
  const to = from + pageSize.value - 1

  const { data, count, error } = await supabase
    .from('visits')
    .select('*, country:countries(name)', { count: 'exact' }) // removed user relation because it was failing probably? or we can keep assignee.
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

function viewVisit(id: string) {
  router.push(`/visits/${id}`)
}

function toggleSelection(id: string) {
  const index = selectedVisits.value.indexOf(id)
  if (index === -1) {
    selectedVisits.value.push(id)
  }
  else {
    selectedVisits.value.splice(index, 1)
  }
}

function toggleAll() {
  if (selectedVisits.value.length === visits.value.length) {
    selectedVisits.value = []
  }
  else {
    selectedVisits.value = visits.value.map(v => v.id)
  }
}

const isAllSelected = computed(() => visits.value.length > 0 && selectedVisits.value.length === visits.value.length)

async function bulkCancel() {
  if (!cancelReason.value) {
    toast.error('Reason Required', {
      description: 'Please provide a reason for cancelling these visits.',
    })
    return
  }
  if (!confirm(`Cancel ${selectedVisits.value.length} visits?`))
    return

  const { error } = await supabase.rpc('bulk_cancel_visits', { visit_ids: selectedVisits.value, reason: cancelReason.value })
  if (error) {
    toast.error('Bulk Cancel Failed', {
      description: error.message,
    })
  }
  else {
    toast.success('Visits Cancelled', {
      description: `Successfully cancelled ${selectedVisits.value.length} visits.`,
    })
    selectedVisits.value = []
    cancelReason.value = ''
    fetchVisits()
  }
}

async function bulkReassign() {
  const newAssignee = prompt('Enter new assignee User ID:')
  if (!newAssignee)
    return

  const { error } = await supabase.rpc('bulk_reassign_visits', { visit_ids: selectedVisits.value, new_assignee_id: newAssignee })
  if (error) {
    toast.error('Reassignment Failed', {
      description: error.message,
    })
  }
  else {
    toast.success('Visits Reassigned', {
      description: `Successfully reassigned ${selectedVisits.value.length} visits.`,
    })
    selectedVisits.value = []
    fetchVisits()
  }
}

function bulkExportCsv() {
  const selectedData = visits.value.filter(v => selectedVisits.value.includes(v.id))
  if (selectedData.length === 0)
    return

  const headers = ['ID', 'Country', 'Trees Planted', 'Status', 'Date']
  const rows = selectedData.map(v => [
    v.id,
    v.country?.name || '',
    v.trees_planted || 0,
    v.status || 'Completed',
    new Date(v.created_at).toLocaleDateString(),
  ])

  const csvContent = `data:text/csv;charset=utf-8,${
    [headers.join(','), ...rows.map(e => e.join(','))].join('\n')}`

  const encodedUri = encodeURI(csvContent)
  const link = document.createElement('a')
  link.setAttribute('href', encodedUri)
  link.setAttribute('download', 'visits_export.csv')
  document.body.appendChild(link)
  link.click()
  link.remove()
}
</script>

<template>
  <div v-if="selectedVisits.length > 0" class="bg-muted p-2 flex items-center justify-between mb-4 rounded-md">
    <div class="text-sm font-medium">
      {{ selectedVisits.length }} selected
    </div>
    <div class="flex items-center gap-2">
      <Input v-model="cancelReason" placeholder="Cancel reason" class="w-40 h-8" />
      <Button size="sm" variant="destructive" @click="bulkCancel">
        Bulk Cancel
      </Button>
      <Button size="sm" variant="outline" @click="bulkReassign">
        Bulk Reassign
      </Button>
      <Button size="sm" variant="outline" @click="bulkExportCsv">
        Export CSV
      </Button>
    </div>
  </div>

  <div class="rounded-md border h-full overflow-auto">
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead class="w-[50px]">
            <input type="checkbox" :checked="isAllSelected" @change="toggleAll">
          </TableHead>
          <TableHead>Date</TableHead>
          <TableHead>Country</TableHead>
          <TableHead>Trees Planted</TableHead>
          <TableHead>Status</TableHead>
          <TableHead class="text-right">
            Actions
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        <TableRow v-for="i in 5" v-if="loading" :key="`skeleton-${i}`">
          <TableCell><Skeleton class="h-4 w-4" /></TableCell>
          <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
          <TableCell><Skeleton class="h-4 w-[150px]" /></TableCell>
          <TableCell><Skeleton class="h-4 w-[80px]" /></TableCell>
          <TableCell><Skeleton class="h-4 w-[80px]" /></TableCell>
          <TableCell class="text-right">
            <Skeleton class="h-8 w-8 ml-auto" />
          </TableCell>
        </TableRow>

        <TableRow v-else-if="visits.length === 0">
          <TableCell colspan="6" class="h-24 text-center">
            No visits found.
          </TableCell>
        </TableRow>

        <TableRow v-for="visit in visits" v-else :key="visit.id" class="cursor-pointer hover:bg-muted/50" @click="viewVisit(visit.id)">
          <TableCell @click.stop>
            <input type="checkbox" :checked="selectedVisits.includes(visit.id)" @change="toggleSelection(visit.id)">
          </TableCell>
          <TableCell>{{ new Date(visit.created_at).toLocaleDateString() }}</TableCell>
          <TableCell>{{ visit.country?.name || 'Unknown' }}</TableCell>
          <TableCell>{{ visit.trees_planted || visit.total_trees_planted || 0 }}</TableCell>
          <TableCell>
            <Badge variant="outline">
              {{ visit.status || 'draft' }}
            </Badge>
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
      <Button variant="outline" size="sm" :disabled="page === 1" @click="page--; fetchVisits()">
        Previous
      </Button>
      <Button variant="outline" size="sm" :disabled="page * pageSize >= total" @click="page++; fetchVisits()">
        Next
      </Button>
    </div>
  </div>
</template>
