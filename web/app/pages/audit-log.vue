<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { usePageHeader } from '~/composables/usePageHeader'
import type { Database } from '../../../shared/types/database'

const { setHeader } = usePageHeader()
setHeader({ title: 'System Audit Log', icon: 'i-lucide-activity', description: 'Monitor all system events and data modifications.' })

const supabase = useSupabaseClient<Database>()
const logs = ref<any[]>([])
const loading = ref(true)

const fetchLogs = async () => {
  loading.value = true
  const { data, error } = await supabase
    // @ts-ignore
    .from('audit_logs')
    .select('*, user:users(name)')
    .order('created_at', { ascending: false })
    .limit(100)
    
  if (!error && data) {
    logs.value = data
  }
  loading.value = false
}

onMounted(() => fetchLogs())
</script>

<template>
  <div class="w-full flex flex-col gap-4">
    <main class="flex flex-1 flex-col gap-4">
      <Card class="flex-1 flex flex-col min-h-0">
        <CardHeader class="flex flex-row items-center justify-between">
          <div>
            <CardTitle>Audit Events</CardTitle>
            <CardDescription>Recent system events and actions.</CardDescription>
          </div>
          <Button variant="outline" @click="fetchLogs">
            <div class="i-lucide-refresh-cw mr-2" /> Refresh
          </Button>
        </CardHeader>
        <CardContent class="flex-1 flex flex-col min-h-0">
          <div class="rounded-md border h-full overflow-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Timestamp</TableHead>
                  <TableHead>User</TableHead>
                  <TableHead>Action</TableHead>
                  <TableHead>Entity</TableHead>
                  <TableHead>Details</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow v-if="loading" v-for="i in 5" :key="`skel-${i}`">
                  <TableCell><Skeleton class="h-4 w-[150px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[80px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[250px]" /></TableCell>
                </TableRow>
                <TableRow v-else-if="logs.length === 0">
                  <TableCell colspan="5" class="h-24 text-center">No audit logs found.</TableCell>
                </TableRow>
                <TableRow v-else v-for="log in logs" :key="log.id">
                  <TableCell class="font-mono text-xs">{{ new Date(log.created_at).toLocaleString() }}</TableCell>
                  <TableCell>{{ log.user?.name || 'System' }}</TableCell>
                  <TableCell>
                    <Badge :variant="log.action === 'DELETE' ? 'destructive' : 'default'">{{ log.action }}</Badge>
                  </TableCell>
                  <TableCell>{{ log.entity_type }} ({{ log.entity_id }})</TableCell>
                  <TableCell class="text-xs text-muted-foreground truncate max-w-[300px]" :title="JSON.stringify(log.details)">
                    {{ JSON.stringify(log.details) }}
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </main>
  </div>
</template>
