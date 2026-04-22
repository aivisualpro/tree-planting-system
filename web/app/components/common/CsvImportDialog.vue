<script setup lang="ts">
import { ref } from 'vue'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

const emit = defineEmits(['import'])
const file = ref<File | null>(null)
const open = ref(false)

const onFileChange = (e: Event) => {
  const target = e.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    file.value = target.files[0]
  }
}

const handleImport = () => {
  if (file.value) {
    emit('import', file.value)
    open.value = false
    file.value = null
  }
}
</script>

<template>
  <Dialog v-model:open="open">
    <DialogTrigger as-child>
      <slot name="trigger">
        <Button variant="outline">Import CSV</Button>
      </slot>
    </DialogTrigger>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>Import Data</DialogTitle>
        <DialogDescription>
          Upload a CSV file to import data.
        </DialogDescription>
      </DialogHeader>
      <div class="grid gap-4 py-4">
        <Input type="file" accept=".csv" @change="onFileChange" />
      </div>
      <DialogFooter>
        <Button @click="handleImport" :disabled="!file">Import</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
