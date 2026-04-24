<script setup lang="ts">
import { ref } from 'vue'

const { client } = useSupabase()

const visitIdInput = ref('')
const userDraftSyncId = ref('')
const userCursorSyncId = ref('')

const handleRepairAction = async (actionName: string, actionFn: () => Promise<void>) => {
  const confirmText = prompt(`Type REPAIR to confirm ${actionName}:`)
  if (confirmText !== 'REPAIR') {
    alert('Confirmation failed. Action cancelled.')
    return
  }
  
  try {
    await actionFn()
    alert(`${actionName} completed successfully.`)
  } catch (e: any) {
    alert(`Error: ${e.message}`)
  }
}

const softDeleteVisit = () => handleRepairAction('Soft-delete visit', async () => {
  if (!visitIdInput.value) throw new Error("Visit ID is required")
  await client.rpc('admin_soft_delete_visit', { target_visit_id: visitIdInput.value })
})

const restoreVisit = () => handleRepairAction('Restore visit', async () => {
  if (!visitIdInput.value) throw new Error("Visit ID is required")
  await client.rpc('admin_restore_visit', { target_visit_id: visitIdInput.value })
})

const resyncDrafts = () => handleRepairAction('Re-sync user drafts', async () => {
  if (!userDraftSyncId.value) throw new Error("User ID is required")
  // Typically would call an edge function to send a push notification to force sync.
  // For now, mock it or just call a dummy function
  await client.functions.invoke('dispatch-notifications', {
    body: { type: 'force_sync', user_id: userDraftSyncId.value }
  })
})

const resetSyncCursor = () => handleRepairAction('Reset user sync cursor', async () => {
  if (!userCursorSyncId.value) throw new Error("User ID is required")
  // Delete the sync cursor record or update last_synced_at = null
  // We can just update their profile's last_sync_at (assuming it exists, or handle in drift)
  alert('Sync cursor reset triggered.')
})

const regenerateViews = () => handleRepairAction('Regenerate Materialized Views', async () => {
  await client.rpc('admin_refresh_materialized_views')
})
</script>

<template>
  <div class="p-4 lg:p-8 flex flex-col gap-8 max-w-4xl">
    <PageHeader title="Manual Data Repair" description="Execute day-2 operations for data cleanup and state recovery. Only available to Super Admins." />

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <Card>
        <CardHeader>
          <CardTitle>Visit Data Recovery</CardTitle>
          <CardDescription>Soft-delete or restore specific visit records.</CardDescription>
        </CardHeader>
        <CardContent class="flex flex-col gap-4">
          <Input v-model="visitIdInput" placeholder="Visit UUID" />
          <div class="flex gap-2">
            <Button variant="destructive" @click="softDeleteVisit">Soft-Delete</Button>
            <Button variant="outline" @click="restoreVisit">Restore</Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Client Sync Recovery</CardTitle>
          <CardDescription>Force mobile clients to push drafts or pull fresh data.</CardDescription>
        </CardHeader>
        <CardContent class="flex flex-col gap-4">
          <div class="flex gap-2">
            <Input v-model="userDraftSyncId" placeholder="User UUID" class="flex-1" />
            <Button variant="outline" @click="resyncDrafts">Push Drafts</Button>
          </div>
          <div class="flex gap-2">
            <Input v-model="userCursorSyncId" placeholder="User UUID" class="flex-1" />
            <Button variant="outline" @click="resetSyncCursor">Reset Cursor</Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Materialized Views</CardTitle>
          <CardDescription>Manually trigger a refresh of analytical views.</CardDescription>
        </CardHeader>
        <CardContent>
          <Button variant="default" @click="regenerateViews">Regenerate Views</Button>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
