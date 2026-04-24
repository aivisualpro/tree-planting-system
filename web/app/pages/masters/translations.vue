<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useSupabaseClient } from '#imports'
// @ts-ignore
import { Card, CardContent, CardHeader, CardTitle } from '~/components/ui/card'
// @ts-ignore
import { Button } from '~/components/ui/button'
// @ts-ignore
import { Input } from '~/components/ui/input'
// @ts-ignore
import { Switch } from '~/components/ui/switch'
// @ts-ignore
import { Label } from '~/components/ui/label'

const supabase = useSupabaseClient<any>()

const translations = ref<any[]>([])
const loading = ref(true)

// Filters
const filterEntityType = ref('')
const filterLocale = ref('')
const missingOnly = ref(false)

// Add Language Form
const newLocaleCode = ref('')
const newLocaleName = ref('')
const addingLanguage = ref(false)

const completenessStats = ref<any[]>([])

const fetchTranslations = async () => {
  loading.value = true
  let query = supabase.from('translations').select('*')
  
  if (filterEntityType.value) {
    query = query.eq('entity_type', filterEntityType.value)
  }
  if (filterLocale.value) {
    query = query.eq('locale', filterLocale.value)
  }
  if (missingOnly.value) {
    query = query.is('value', null)
  }

  const { data } = await query.order('entity_type').order('entity_id')
  translations.value = data || []
  loading.value = false
  calculateCompleteness()
}

const calculateCompleteness = async () => {
  // Rough estimate logic based on fetched data
  // In a real scenario, this would be an aggregation query on the server
  const stats = []
  
  // Just querying all translations to get stats
  const { data } = await supabase.from('translations').select('entity_type, locale, value')
  if (data) {
    const grouped: Record<string, { total: number, filled: number }> = {}
    data.forEach((row: any) => {
      const key = `${row.entity_type}_${row.locale}`
      if (!grouped[key]) grouped[key] = { total: 0, filled: 0 }
      grouped[key].total++
      if (row.value) grouped[key].filled++
    })
    
    for (const [key, val] of Object.entries(grouped)) {
      const [type, loc] = key.split('_')
      stats.push({
        entity_type: type,
        locale: loc,
        percentage: Math.round((val.filled / val.total) * 100)
      })
    }
  }
  completenessStats.value = stats
}

onMounted(() => {
  fetchTranslations()
})

const saveTranslation = async (item: any, newValue: string) => {
  const previousValue = item.value
  // Optimistic UI update
  item.value = newValue
  
  const { error } = await supabase
    .from('translations')
    .update({ value: newValue, updated_at: new Date().toISOString() })
    .eq('id', item.id)

  if (error) {
    // Rollback on error
    item.value = previousValue
    alert('Failed to save translation')
  } else {
    calculateCompleteness()
  }
}

const handleInlineEdit = (e: Event, item: any) => {
  const target = e.target as HTMLInputElement
  if (target.value !== item.value) {
    saveTranslation(item, target.value)
  }
}

const addNewLanguage = async () => {
  if (!newLocaleCode.value || !newLocaleName.value) return
  addingLanguage.value = true

  // Get all English translations to use as template
  const { data: enTranslations } = await supabase
    .from('translations')
    .select('*')
    .eq('locale', 'en')

  if (enTranslations && enTranslations.length > 0) {
    const newRows = enTranslations.map(row => ({
      entity_type: row.entity_type,
      entity_id: row.entity_id,
      field: row.field,
      locale: newLocaleCode.value,
      value: null // Value is empty for new translations to be progressively filled
    }))

    const { error } = await supabase.from('translations').insert(newRows)
    
    if (error) {
      alert('Failed to add language')
    } else {
      newLocaleCode.value = ''
      newLocaleName.value = ''
      alert('Language added successfully')
      fetchTranslations()
    }
  }
  
  addingLanguage.value = false
}

const filteredTranslations = computed(() => translations.value)
</script>

<template>
  <div class="p-8 space-y-6 max-w-7xl mx-auto">
    <div class="flex justify-between items-center">
      <h1 class="text-3xl font-bold">Dynamic Translations</h1>
    </div>

    <!-- Filters & Stats Row -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <Card>
        <CardHeader>
          <CardTitle>Filters</CardTitle>
        </CardHeader>
        <CardContent class="space-y-4">
          <div>
            <Label>Entity Type</Label>
            <Input v-model="filterEntityType" placeholder="e.g. countries" @blur="fetchTranslations" />
          </div>
          <div>
            <Label>Locale</Label>
            <Input v-model="filterLocale" placeholder="e.g. es" @blur="fetchTranslations" />
          </div>
          <div class="flex items-center space-x-2 pt-2">
            <Switch v-model:checked="missingOnly" @update:checked="fetchTranslations" id="missing-only" />
            <Label htmlFor="missing-only">Show missing translations only</Label>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Add New Language</CardTitle>
        </CardHeader>
        <CardContent class="space-y-4">
          <div>
            <Label>Locale Code</Label>
            <Input v-model="newLocaleCode" placeholder="e.g. pt" />
          </div>
          <div>
            <Label>Display Name</Label>
            <Input v-model="newLocaleName" placeholder="e.g. Portuguese" />
          </div>
          <Button :disabled="addingLanguage" @click="addNewLanguage" class="w-full">
            {{ addingLanguage ? 'Adding...' : 'Add Language' }}
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Completeness Report</CardTitle>
        </CardHeader>
        <CardContent>
          <div v-if="completenessStats.length === 0" class="text-sm text-gray-500">
            Calculating...
          </div>
          <div v-else class="space-y-2 max-h-48 overflow-y-auto pr-2">
            <div v-for="stat in completenessStats" :key="stat.entity_type + stat.locale" class="flex justify-between items-center text-sm">
              <span class="font-medium">{{ stat.entity_type }} ({{ stat.locale }})</span>
              <span :class="{'text-green-600': stat.percentage === 100, 'text-amber-600': stat.percentage < 100}">
                {{ stat.percentage }}%
              </span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Translations Table -->
    <Card>
      <CardHeader>
        <CardTitle>Translation Entries</CardTitle>
      </CardHeader>
      <CardContent>
        <div v-if="loading" class="py-8 text-center text-gray-500">
          Loading translations...
        </div>
        <div v-else-if="filteredTranslations.length === 0" class="py-8 text-center text-gray-500">
          No translations found.
        </div>
        <div v-else class="overflow-x-auto">
          <table class="w-full text-sm text-left">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-800 dark:text-gray-400">
              <tr>
                <th class="px-4 py-3">Entity Type</th>
                <th class="px-4 py-3">Entity ID</th>
                <th class="px-4 py-3">Field</th>
                <th class="px-4 py-3">Locale</th>
                <th class="px-4 py-3 w-1/3">Value</th>
                <th class="px-4 py-3">Updated At</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in filteredTranslations" :key="item.id" class="border-b dark:border-gray-700">
                <td class="px-4 py-3 font-medium">{{ item.entity_type }}</td>
                <td class="px-4 py-3 text-gray-500">{{ item.entity_id }}</td>
                <td class="px-4 py-3">{{ item.field }}</td>
                <td class="px-4 py-3">
                  <span class="bg-blue-100 text-blue-800 text-xs font-medium px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300">
                    {{ item.locale }}
                  </span>
                </td>
                <td class="px-4 py-3">
                  <Input 
                    :defaultValue="item.value" 
                    @blur="(e: Event) => handleInlineEdit(e, item)"
                    :class="{'border-red-300 bg-red-50': !item.value}"
                    placeholder="Missing translation..."
                  />
                </td>
                <td class="px-4 py-3 text-xs text-gray-500">
                  {{ new Date(item.updated_at).toLocaleString() }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  </div>
</template>
