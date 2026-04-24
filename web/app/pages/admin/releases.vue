<script setup lang="ts">
import { ref } from 'vue'
import { toast } from 'vue-sonner'

const supabase = useSupabaseClient<any>()

const versions = ref<any[]>([])
const loading = ref(true)

async function fetchVersions() {
  loading.value = true
  const { data, error } = await supabase.from('app_versions').select('*').order('platform')
  if (error) {
    toast.error('Error: ' + error.message)
  }
  else {
    versions.value = data || []
  }
  loading.value = false
}

async function updateVersion(versionId: string, minSupported: string, latest: string) {
  const { error } = await (supabase
    .from('app_versions')
    .update({ min_supported_version: minSupported, latest_version: latest }) as any)
    .eq('id', versionId)

  if (error) {
    toast.error('Error: ' + error.message)
  }
  else {
    toast.success('Version updated successfully')
    fetchVersions()
  }
}

onMounted(() => {
  fetchVersions()
})
</script>

<template>
  <div class="p-6 max-w-4xl mx-auto">
    <div class="mb-8">
      <h1 class="text-2xl font-bold tracking-tight">
        Release Engineering
      </h1>
      <p class="text-muted-foreground mt-2">
        Manage minimum supported versions and force update mechanisms.
      </p>
    </div>

    <div v-if="loading" class="flex justify-center p-8">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
    </div>

    <div v-else class="grid gap-6">
      <Card v-for="version in versions" :key="version.id">
        <CardHeader>
          <CardTitle class="capitalize">
            {{ version.platform }} App Versioning
          </CardTitle>
          <CardDescription>Controls force updates for {{ version.platform }} platform.</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label>Minimum Supported Version</Label>
              <Input v-model="version.min_supported_version" placeholder="1.0.0" />
            </div>
            <div class="space-y-2">
              <Label>Latest Version</Label>
              <Input v-model="version.latest_version" placeholder="1.0.0" />
            </div>
          </div>
        </CardContent>
        <CardFooter class="flex justify-end">
          <Button @click="updateVersion(version.id, version.min_supported_version, version.latest_version)">
            Save Changes
          </Button>
        </CardFooter>
      </Card>
    </div>
  </div>
</template>
