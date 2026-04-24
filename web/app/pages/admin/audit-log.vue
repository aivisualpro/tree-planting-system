<script setup lang="ts">
import * as jsondiffpatch from 'jsondiffpatch'
import { onMounted, ref } from 'vue'
import 'jsondiffpatch/dist/formatters-styles/html.css'

const client = useSupabaseClient()
const auditLogs = ref<any[]>([])
const loading = ref(true)

// Filters
const filterUser = ref('')
const filterTable = ref('')
const filterOperation = ref('')
const filterDateStart = ref('')
const filterDateEnd = ref('')
const filterImpersonated = ref(false)

const expandedRow = ref<string | null>(null)

async function fetchAuditLogs() {
  loading.value = true
  let query = client.from('audit_log').select('*, actor_id(email), impersonator_id(email)').order('occurred_at', { ascending: false })

  if (filterUser.value) {
    query = query.eq('actor_id', filterUser.value)
  }
  if (filterTable.value) {
    query = query.eq('table_name', filterTable.value)
  }
  if (filterOperation.value) {
    query = query.eq('operation', filterOperation.value)
  }
  if (filterDateStart.value) {
    query = query.gte('occurred_at', new Date(filterDateStart.value).toISOString())
  }
  if (filterDateEnd.value) {
    query = query.lte('occurred_at', new Date(filterDateEnd.value).toISOString())
  }
  if (filterImpersonated.value) {
    query = query.not('impersonator_id', 'is', null)
  }

  const { data, error } = await query.limit(100)
  if (!error) {
    auditLogs.value = data || []
  }
  loading.value = false
}

function exportLogs() {
  const csvData = [
    ['ID', 'Table', 'Row ID', 'Operation', 'Actor', 'Impersonator', 'Occurred At'].join(','),
    ...auditLogs.value.map(log =>
      [
        log.id,
        log.table_name,
        log.row_id,
        log.operation,
        log.actor_id?.email || log.actor_id,
        log.impersonator_id?.email || log.impersonator_id || '',
        log.occurred_at,
      ].join(','),
    ),
  ].join('\n')

  const blob = new Blob([csvData], { type: 'text/csv' })
  const url = window.URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.setAttribute('href', url)
  a.setAttribute('download', 'audit_logs.csv')
  a.click()
  a.remove()
}

onMounted(fetchAuditLogs)

function toggleExpand(id: string) {
  expandedRow.value = expandedRow.value === id ? null : id
}

function getDiffHtml(oldRow: any, newRow: any) {
  if (!oldRow && !newRow)
    return 'No changes recorded'
  const diff = jsondiffpatch.diff(oldRow || {}, newRow || {})
  if (!diff)
    return 'No changes detected'
  return jsondiffpatch.formatters.html.format(diff, oldRow || {})
}
</script>

<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">
        Audit Log
      </h1>
      <button class="bg-primary text-primary-foreground px-4 py-2 rounded-md hover:bg-primary/90" @click="exportLogs">
        Export CSV
      </button>
    </div>

    <div class="bg-card text-card-foreground p-4 rounded-lg shadow mb-6 border border-border">
      <h2 class="text-lg font-semibold mb-4">
        Filters
      </h2>
      <div class="grid grid-cols-1 md:grid-cols-6 gap-4 items-end">
        <div>
          <label class="block text-sm mb-1 text-muted-foreground">User ID</label>
          <input v-model="filterUser" type="text" class="w-full border border-border bg-background rounded-md p-2 h-10" placeholder="UUID">
        </div>
        <div>
          <label class="block text-sm mb-1 text-muted-foreground">Table</label>
          <select v-model="filterTable" class="w-full border border-border bg-background rounded-md p-2 h-10">
            <option value="">
              All
            </option>
            <option value="visits">
              Visits
            </option>
            <option value="profiles">
              Profiles
            </option>
            <option value="admin_actions">
              Admin Actions
            </option>
            <option value="translations">
              Translations
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm mb-1 text-muted-foreground">Operation</label>
          <select v-model="filterOperation" class="w-full border border-border bg-background rounded-md p-2 h-10">
            <option value="">
              All
            </option>
            <option value="INSERT">
              INSERT
            </option>
            <option value="UPDATE">
              UPDATE
            </option>
            <option value="DELETE">
              DELETE
            </option>
            <option value="impersonate_start">
              impersonate_start
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm mb-1 text-muted-foreground">Start Date</label>
          <input v-model="filterDateStart" type="date" class="w-full border border-border bg-background rounded-md p-2 h-10">
        </div>
        <div>
          <label class="block text-sm mb-1 text-muted-foreground">End Date</label>
          <input v-model="filterDateEnd" type="date" class="w-full border border-border bg-background rounded-md p-2 h-10">
        </div>
        <div class="flex items-center h-10 px-2 gap-2 border border-border rounded-md bg-background cursor-pointer" @click="filterImpersonated = !filterImpersonated">
          <input v-model="filterImpersonated" type="checkbox" class="cursor-pointer">
          <span class="text-sm">Impersonated Only</span>
        </div>
      </div>
      <div class="mt-4 flex justify-end">
        <button class="bg-secondary text-secondary-foreground px-4 py-2 rounded-md hover:bg-secondary/90 h-10" @click="fetchAuditLogs">
          Apply Filters
        </button>
      </div>
    </div>

    <div v-if="loading" class="text-center py-8 text-muted-foreground">
      Loading audit logs...
    </div>

    <div v-else class="bg-card text-card-foreground rounded-lg shadow overflow-hidden border border-border">
      <table class="w-full text-left border-collapse">
        <thead>
          <tr class="bg-muted text-muted-foreground text-sm border-b border-border">
            <th class="p-3 font-medium w-10" />
            <th class="p-3 font-medium">
              Timestamp
            </th>
            <th class="p-3 font-medium">
              Actor
            </th>
            <th class="p-3 font-medium">
              Operation
            </th>
            <th class="p-3 font-medium">
              Table
            </th>
            <th class="p-3 font-medium">
              Row ID
            </th>
            <th class="p-3 font-medium">
              Impersonator
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-border text-sm">
          <template v-for="log in auditLogs" :key="log.id">
            <tr class="hover:bg-muted/50 transition-colors cursor-pointer" @click="toggleExpand(log.id)">
              <td class="p-3 text-center">
                <Icon :name="expandedRow === log.id ? 'lucide:chevron-down' : 'lucide:chevron-right'" />
              </td>
              <td class="p-3 whitespace-nowrap">
                {{ new Date(log.occurred_at).toLocaleString() }}
              </td>
              <td class="p-3">
                <span v-if="log.actor_id?.email">{{ log.actor_id.email }}</span>
                <span v-else class="text-muted-foreground font-mono text-xs">{{ log.actor_id }}</span>
              </td>
              <td class="p-3">
                <span
                  :class="{
                    'text-green-600 bg-green-100 dark:bg-green-900/30 dark:text-green-400': log.operation === 'INSERT',
                    'text-blue-600 bg-blue-100 dark:bg-blue-900/30 dark:text-blue-400': log.operation === 'UPDATE',
                    'text-red-600 bg-red-100 dark:bg-red-900/30 dark:text-red-400': log.operation === 'DELETE',
                    'text-purple-600 bg-purple-100 dark:bg-purple-900/30 dark:text-purple-400': log.operation === 'impersonate_start',
                  }" class="px-2 py-1 rounded text-xs font-semibold"
                >
                  {{ log.operation }}
                </span>
              </td>
              <td class="p-3 font-medium">
                {{ log.table_name }}
              </td>
              <td class="p-3 font-mono text-xs text-muted-foreground truncate max-w-[150px]">
                {{ log.row_id }}
              </td>
              <td class="p-3">
                <Badge v-if="log.impersonator_id" variant="destructive" class="text-[10px]">
                  {{ log.impersonator_id.email || 'Yes' }}
                </Badge>
              </td>
            </tr>
            <tr v-if="expandedRow === log.id">
              <td colspan="7" class="p-0 border-b border-border">
                <div class="bg-muted/30 p-4 w-full overflow-x-auto text-xs">
                  <div v-html="getDiffHtml(log.old_row, log.new_row)" />
                </div>
              </td>
            </tr>
          </template>
          <tr v-if="auditLogs.length === 0">
            <td colspan="7" class="p-6 text-center text-muted-foreground">
              No audit logs found.
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
