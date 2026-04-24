<script setup lang="ts">
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'

defineProps<{
  columns: { key: string, label: string }[]
  data: any[]
}>()
</script>

<template>
  <div class="rounded-md border">
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead v-for="col in columns" :key="col.key">
            {{ col.label }}
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        <TableRow v-for="(row, i) in data" :key="i">
          <TableCell v-for="col in columns" :key="col.key">
            <slot :name="`cell-${col.key}`" :row="row">
              {{ row[col.key] }}
            </slot>
          </TableCell>
        </TableRow>
        <TableRow v-if="data.length === 0">
          <TableCell :colspan="columns.length" class="text-center">
            No data available
          </TableCell>
        </TableRow>
      </TableBody>
    </Table>
  </div>
</template>
