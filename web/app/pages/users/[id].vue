<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'

import { toast } from 'vue-sonner'

const route = useRoute()
const userId = route.params.id as string
const { isSuperAdmin } = useRole()
const { startImpersonation } = useImpersonation()
const isLoading = ref(false)

async function handleImpersonate() {
  isLoading.value = true
  try {
    await startImpersonation(userId, `User ${userId}`)
    toast.success('Impersonation Started', {
      description: `You are now viewing the app as user ${userId}`,
    })
  }
  catch (e: any) {
    toast.error('Impersonation Failed', {
      description: e.message || 'Failed to impersonate',
    })
  }
  finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="flex flex-col gap-4 p-4 lg:p-8">
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold tracking-tight">
        User Details: {{ userId }}
      </h2>
      <Button v-if="isSuperAdmin" :disabled="isLoading" variant="outline" class="gap-2" @click="handleImpersonate">
        <Icon name="lucide:user-check" class="w-4 h-4" />
        {{ isLoading ? 'Starting...' : 'View as this user' }}
      </Button>
    </div>
    <div class="p-6 border rounded-lg bg-card mt-4">
      <p class="text-muted-foreground">
        Details and permissions for user {{ userId }} will go here.
      </p>
    </div>
  </div>
</template>
