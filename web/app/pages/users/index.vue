<script setup lang="ts">
import type { Database } from '../../../../shared/types/database'
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { usePageHeader } from '~/composables/usePageHeader'

const { setHeader } = usePageHeader()
setHeader({ title: 'Users & Roles', icon: 'i-lucide-users', description: 'Manage system access and permissions.' })

const supabase = useSupabaseClient<Database>()
const router = useRouter()
const users = ref<any[]>([])
const loading = ref(true)

const selectedUsers = ref<string[]>([])

async function fetchUsers() {
  loading.value = true
  const { data, error } = await supabase
    .from('profiles')
    .select('*, country:countries(name)')
    .order('created_at', { ascending: false })

  if (!error && data) {
    users.value = data
  }
  loading.value = false
}

onMounted(() => fetchUsers())

function toggleSelection(id: string) {
  const index = selectedUsers.value.indexOf(id)
  if (index === -1) {
    selectedUsers.value.push(id)
  }
  else {
    selectedUsers.value.splice(index, 1)
  }
}

function toggleAll() {
  if (selectedUsers.value.length === users.value.length) {
    selectedUsers.value = []
  }
  else {
    selectedUsers.value = users.value.map(u => u.id)
  }
}

const isAllSelected = computed(() => users.value.length > 0 && selectedUsers.value.length === users.value.length)

async function bulkRoleChange() {
  const newRole = prompt('Enter new role (super_admin, admin, coordinator, field_user, viewer):')
  if (!newRole)
    return
  await supabase.rpc('bulk_update_user_role', { user_ids: selectedUsers.value, new_role: newRole })
  selectedUsers.value = []
  fetchUsers()
}

async function bulkCountryReassignment() {
  const newCountry = prompt('Enter new Country ID:')
  if (!newCountry)
    return
  await supabase.rpc('bulk_reassign_user_country', { user_ids: selectedUsers.value, new_country_id: newCountry })
  selectedUsers.value = []
  fetchUsers()
}

async function bulkResendInvite() {
  if (!confirm(`Resend invites to ${selectedUsers.value.length} users?`))
    return
  alert('Invites sent! (Mocked implementation, requires Edge Function)')
  selectedUsers.value = []
}

function viewUser(id: string) {
  router.push(`/users/${id}`)
}
</script>

<template>
  <div class="w-full flex flex-col gap-4">
    <main class="flex flex-1 flex-col gap-4">
      <Card class="flex-1 flex flex-col min-h-0">
        <CardHeader class="flex flex-row items-center justify-between">
          <div>
            <CardTitle>System Users</CardTitle>
            <CardDescription>Manage user accounts and role assignments.</CardDescription>
          </div>
        </CardHeader>

        <div v-if="selectedUsers.length > 0" class="bg-muted mx-6 p-2 flex items-center justify-between rounded-md">
          <div class="text-sm font-medium">
            {{ selectedUsers.length }} selected
          </div>
          <div class="flex items-center gap-2">
            <Button size="sm" variant="outline" @click="bulkRoleChange">
              Bulk Role Change
            </Button>
            <Button size="sm" variant="outline" @click="bulkCountryReassignment">
              Bulk Country Reassign
            </Button>
            <Button size="sm" variant="outline" @click="bulkResendInvite">
              Resend Invites
            </Button>
          </div>
        </div>

        <CardContent class="flex-1 flex flex-col min-h-0 mt-4">
          <div class="rounded-md border h-full overflow-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead class="w-[50px]">
                    <input type="checkbox" :checked="isAllSelected" @change="toggleAll">
                  </TableHead>
                  <TableHead>User ID</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Primary Country</TableHead>
                  <TableHead>Joined</TableHead>
                  <TableHead class="text-right">
                    Actions
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow v-for="i in 5" v-if="loading" :key="`skel-${i}`">
                  <TableCell><Skeleton class="h-4 w-4" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[150px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
                  <TableCell class="text-right">
                    <Skeleton class="h-8 w-8 ml-auto" />
                  </TableCell>
                </TableRow>
                <TableRow v-else-if="users.length === 0">
                  <TableCell colspan="6" class="h-24 text-center">
                    No users found.
                  </TableCell>
                </TableRow>
                <TableRow v-for="u in users" v-else :key="u.id" class="cursor-pointer hover:bg-muted/50" @click="viewUser(u.id)">
                  <TableCell @click.stop>
                    <input type="checkbox" :checked="selectedUsers.includes(u.id)" @change="toggleSelection(u.id)">
                  </TableCell>
                  <TableCell class="font-medium text-xs">
                    {{ u.id }}
                  </TableCell>
                  <TableCell><Badge>{{ u.role }}</Badge></TableCell>
                  <TableCell>{{ u.country?.name || 'Unassigned' }}</TableCell>
                  <TableCell>{{ new Date(u.created_at).toLocaleDateString() }}</TableCell>
                  <TableCell class="text-right">
                    <Button variant="ghost" size="icon" @click.stop="viewUser(u.id)">
                      <div class="i-lucide-chevron-right size-4" />
                    </Button>
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
