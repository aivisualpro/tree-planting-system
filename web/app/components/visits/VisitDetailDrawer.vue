<script setup lang="ts">
import { ref } from 'vue'
import { Button } from '@/components/ui/button'
import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
} from '@/components/ui/drawer'

const open = ref(false)
const visitId = ref<string | null>(null)

export interface VisitDetailMethods {
  open: (id: string) => void
}

defineExpose({
  open: (id: string) => {
    visitId.value = id
    open.value = true
  },
})
</script>

<template>
  <Drawer v-model:open="open">
    <DrawerContent>
      <div class="mx-auto w-full max-w-lg">
        <DrawerHeader>
          <DrawerTitle>Visit Details</DrawerTitle>
          <DrawerDescription>View detailed information for visit #{{ visitId }}</DrawerDescription>
        </DrawerHeader>
        <div class="p-4 pb-0">
          <p>Loading details for {{ visitId }}...</p>
        </div>
        <DrawerFooter>
          <Button>Edit Visit</Button>
          <DrawerClose as-child>
            <Button variant="outline">
              Close
            </Button>
          </DrawerClose>
        </DrawerFooter>
      </div>
    </DrawerContent>
  </Drawer>
</template>
