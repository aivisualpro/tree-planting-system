<script setup lang="ts">
import { onMounted, ref } from 'vue'

const { client } = useSupabase()
const conflicts = ref<any[]>([])
const loading = ref(true)

async function fetchConflicts() {
  loading.value = true
  const { data, error } = await client
    .from('sync_log')
    .select(`
      id, client_uuid, target_table, target_id, operation, status, server_received_at, error_message,
      local_state, server_state,
      profiles (id, email)
    `)
    .eq('status', 'conflict')
    .order('server_received_at', { ascending: false })

  if (!error && data) {
    conflicts.value = data
  }
  loading.value = false
}

onMounted(() => {
  fetchConflicts()
})

async function acceptServer(conflictId: string) {
  // Already applied, just mark as resolved
  await client.from('sync_log').update({ status: 'resolved_server' }).eq('id', conflictId)
  fetchConflicts()
}

async function restoreLocal(conflict: any) {
  if (!conflict.target_table || !conflict.target_id)
    return
  // Admin creates a new revision with local values
  // We can just call an RPC or update the table with local_state
  try {
    await client.from(conflict.target_table).update(conflict.local_state).eq('id', conflict.target_id)
    await client.from('sync_log').update({ status: 'resolved_local' }).eq('id', conflict.id)
    fetchConflicts()
  }
  catch (e: any) {
    alert(`Failed to restore local: ${e.message}`)
  }
}

function mergeManually(conflict: any) {
  // Mock opening a merge form
  alert(`Open manual merge form for ${conflict.target_table} - ${conflict.target_id}`)
}
</script>

<template>
  <div class="p-4 lg:p-8 flex flex-col gap-6">
    <PageHeader title="Sync Conflicts" description="Review and resolve synchronization conflicts between offline clients and the server." />

    <div v-if="loading">
      Loading conflicts...
    </div>
    <div v-else-if="conflicts.length === 0" class="p-8 text-center border border-dashed rounded-lg">
      No sync conflicts to resolve!
    </div>
    <div v-else class="flex flex-col gap-4">
      <div v-for="conflict in conflicts" :key="conflict.id" class="border rounded-lg bg-card overflow-hidden">
        <div class="p-4 border-b bg-muted/50 flex items-center justify-between">
          <div>
            <h3 class="font-semibold text-sm">
              Table: {{ conflict.target_table }} | ID: {{ conflict.target_id || conflict.client_uuid }}
            </h3>
            <p class="text-xs text-muted-foreground">
              Received: {{ new Date(conflict.server_received_at).toLocaleString() }} by {{ conflict.profiles?.email || 'Unknown User' }}
            </p>
          </div>
          <div class="flex gap-2">
            <Button size="sm" variant="outline" @click="acceptServer(conflict.id)">
              Accept Server
            </Button>
            <Button size="sm" variant="outline" @click="restoreLocal(conflict)">
              Restore Local
            </Button>
            <Button size="sm" @click="mergeManually(conflict)">
              Merge Manually
            </Button>
          </div>
        </div>
        <div class="p-4 grid grid-cols-2 gap-4">
          <div>
            <h4 class="font-medium text-sm mb-2 text-red-500">
              Local State (Client)
            </h4>
            <pre class="bg-muted p-2 rounded text-xs overflow-auto max-h-[300px]">{{ JSON.stringify(conflict.local_state, null, 2) }}</pre>
          </div>
          <div>
            <h4 class="font-medium text-sm mb-2 text-green-500">
              Server State (Current)
            </h4>
            <pre class="bg-muted p-2 rounded text-xs overflow-auto max-h-[300px]">{{ JSON.stringify(conflict.server_state, null, 2) }}</pre>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
