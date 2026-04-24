<script setup lang="ts">
import type { Database } from '../../../../shared/types/database'
import { onMounted, ref } from 'vue'

const props = defineProps<{
  table: string
  title: string
  description: string
  columns: { key: string, label: string }[]
}>()

const supabase = useSupabaseClient<Database>()
const items = ref<any[]>([])
const loading = ref(true)

async function fetchItems() {
  loading.value = true
  // @ts-ignore - dynamic table name
  const { data, error } = await supabase.from(props.table).select('*').order('id', { ascending: true })

  if (!error && data) {
    items.value = data
  }
  loading.value = false
}

onMounted(() => {
  fetchItems()

  // Real-time subscription
  supabase.channel(`public:${props.table}`)
    .on('postgres_changes', { event: '*', schema: 'public', table: props.table }, () => {
      fetchItems()
    })
    .subscribe()
})
</script>

<template>
  <Card class="flex-1 flex flex-col min-h-0">
    <CardHeader class="flex flex-row items-center justify-between">
      <div>
        <CardTitle>{{ title }}</CardTitle>
        <CardDescription>{{ description }}</CardDescription>
      </div>
      <Button>
        <div class="i-lucide-plus mr-2" /> Add Record
      </Button>
    </CardHeader>
    <CardContent class="flex-1 flex flex-col min-h-0">
      <div class="rounded-md border h-full overflow-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead v-for="col in columns" :key="col.key">
                {{ col.label }}
              </TableHead>
              <TableHead class="text-right">
                Actions
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="i in 3" v-if="loading" :key="`skeleton-${i}`">
              <TableCell v-for="col in columns" :key="`skel-${col.key}`">
                <Skeleton class="h-4 w-full max-w-[100px]" />
              </TableCell>
              <TableCell class="text-right">
                <Skeleton class="h-8 w-8 ml-auto" />
              </TableCell>
            </TableRow>

            <TableRow v-else-if="items.length === 0">
              <TableCell :colspan="columns.length + 1" class="h-24 text-center">
                No records found.
              </TableCell>
            </TableRow>

            <TableRow v-for="item in items" v-else :key="item.id">
              <TableCell v-for="col in columns" :key="col.key">
                {{ item[col.key] }}
              </TableCell>
              <TableCell class="text-right">
                <Button variant="ghost" size="icon" class="mr-1">
                  <div class="i-lucide-pencil size-4" />
                </Button>
                <Button variant="ghost" size="icon" class="text-destructive">
                  <div class="i-lucide-trash-2 size-4" />
                </Button>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </CardContent>
  </Card>
</template>
