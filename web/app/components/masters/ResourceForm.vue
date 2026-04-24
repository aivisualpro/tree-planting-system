<script setup lang="ts">
import { Button } from '@/components/ui/button'

defineProps<{
  title: string
  isEditing?: boolean
}>()
const emit = defineEmits(['submit', 'cancel'])
</script>

<template>
  <div class="p-4 border rounded-md bg-card">
    <h3 class="text-lg font-medium mb-4">
      {{ isEditing ? 'Edit' : 'Create' }} {{ title }}
    </h3>
    <form @submit.prevent="emit('submit')">
      <div class="space-y-4">
        <slot />
      </div>
      <div class="flex justify-end gap-2 mt-6">
        <Button variant="outline" type="button" @click="emit('cancel')">
          Cancel
        </Button>
        <Button type="submit">
          Save
        </Button>
      </div>
    </form>
  </div>
</template>
