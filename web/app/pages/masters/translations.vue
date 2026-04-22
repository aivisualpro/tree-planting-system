<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { usePageHeader } from '~/composables/usePageHeader'
import type { Database } from '../../../../shared/types/database'

const { setHeader } = usePageHeader()
setHeader({ title: 'Translations', icon: 'i-lucide-languages', description: 'Manage dynamic application translations.' })

const supabase = useSupabaseClient<Database>()
const translations = ref<any[]>([])
const loading = ref(true)

const fetchTranslations = async () => {
  loading.value = true
  const { data, error } = await supabase.from('translations').select('*').order('language_code')
  if (!error && data) {
    translations.value = data
  }
  loading.value = false
}

onMounted(() => fetchTranslations())

// File upload for CSV import
const fileInput = ref<HTMLInputElement | null>(null)
const importLoading = ref(false)

const triggerImport = () => fileInput.value?.click()

const handleFileUpload = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return

  importLoading.value = true
  const formData = new FormData()
  formData.append('file', file)

  try {
    await $fetch('/api/admin/translations-import', {
      method: 'POST',
      body: formData
    })
    // Refresh table
    await fetchTranslations()
  } catch (error) {
    console.error('Import failed', error)
  } finally {
    importLoading.value = false
    if (target) target.value = ''
  }
}
</script>

<template>
  <div class="w-full flex flex-col gap-4">
    <main class="flex flex-1 flex-col gap-4">
      <Card class="flex-1 flex flex-col min-h-0">
        <CardHeader class="flex flex-row items-center justify-between">
          <div>
            <CardTitle>Translation Dictionary</CardTitle>
            <CardDescription>Manage terms across multiple languages.</CardDescription>
          </div>
          <div class="flex items-center gap-2">
            <input type="file" ref="fileInput" class="hidden" accept=".csv" @change="handleFileUpload" />
            <Button variant="outline" :disabled="importLoading" @click="triggerImport">
              <div class="i-lucide-upload mr-2" /> {{ importLoading ? 'Importing...' : 'Import CSV' }}
            </Button>
            <Button>
              <div class="i-lucide-plus mr-2" /> Add Term
            </Button>
          </div>
        </CardHeader>
        <CardContent class="flex-1 flex flex-col min-h-0">
          <div class="rounded-md border h-full overflow-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Key</TableHead>
                  <TableHead>Language</TableHead>
                  <TableHead>Value</TableHead>
                  <TableHead class="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow v-if="loading" v-for="i in 5" :key="`skel-${i}`">
                  <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[50px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[200px]" /></TableCell>
                  <TableCell class="text-right"><Skeleton class="h-8 w-8 ml-auto" /></TableCell>
                </TableRow>
                <TableRow v-else-if="translations.length === 0">
                  <TableCell colspan="4" class="h-24 text-center">No translations found.</TableCell>
                </TableRow>
                <TableRow v-else v-for="t in translations" :key="t.id">
                  <TableCell class="font-mono text-xs">{{ t.key }}</TableCell>
                  <TableCell><Badge variant="outline">{{ t.language_code }}</Badge></TableCell>
                  <TableCell>{{ t.value }}</TableCell>
                  <TableCell class="text-right">
                    <Button variant="ghost" size="sm">Edit</Button>
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
