<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { usePageHeader } from '~/composables/usePageHeader'
import type { Database } from '../../../../shared/types/database'

const { setHeader } = usePageHeader()
setHeader({ title: 'Users & Roles', icon: 'i-lucide-users', description: 'Manage system access and permissions.' })

const supabase = useSupabaseClient<Database>()
const users = ref<any[]>([])
const loading = ref(true)

const fetchUsers = async () => {
  loading.value = true
  // @ts-ignore
  const { data, error } = await supabase.from('users').select('*').order('name')
  if (!error && data) {
    users.value = data
  }
  loading.value = false
}

onMounted(() => fetchUsers())

const inviteEmail = ref('')
const inviteRole = ref('field_agent')
const inviting = ref(false)

const inviteUser = async () => {
  if (!inviteEmail.value) return
  inviting.value = true
  
  try {
    await $fetch('/api/admin/users', {
      method: 'POST',
      body: { email: inviteEmail.value, role: inviteRole.value }
    })
    inviteEmail.value = ''
    await fetchUsers()
  } catch (error) {
    console.error('Failed to invite user', error)
  } finally {
    inviting.value = false
  }
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
          <div class="flex items-center gap-2">
            <Input v-model="inviteEmail" placeholder="Email address" class="w-[200px]" />
            <select v-model="inviteRole" class="flex h-9 w-full items-center justify-between whitespace-nowrap rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring disabled:cursor-not-allowed disabled:opacity-50 [&>span]:line-clamp-1">
              <option value="field_agent">Field Agent</option>
              <option value="admin">Admin</option>
              <option value="super_admin">Super Admin</option>
            </select>
            <Button :disabled="inviting || !inviteEmail" @click="inviteUser">
              <div class="i-lucide-mail mr-2" /> {{ inviting ? 'Inviting...' : 'Invite' }}
            </Button>
          </div>
        </CardHeader>
        <CardContent class="flex-1 flex flex-col min-h-0">
          <div class="rounded-md border h-full overflow-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Joined</TableHead>
                  <TableHead class="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow v-if="loading" v-for="i in 5" :key="`skel-${i}`">
                  <TableCell><Skeleton class="h-4 w-[150px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[200px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
                  <TableCell><Skeleton class="h-4 w-[100px]" /></TableCell>
                  <TableCell class="text-right"><Skeleton class="h-8 w-8 ml-auto" /></TableCell>
                </TableRow>
                <TableRow v-else-if="users.length === 0">
                  <TableCell colspan="5" class="h-24 text-center">No users found.</TableCell>
                </TableRow>
                <TableRow v-else v-for="u in users" :key="u.id">
                  <TableCell class="font-medium">{{ u.name || 'Pending Invite' }}</TableCell>
                  <TableCell>{{ u.email }}</TableCell>
                  <TableCell><Badge>{{ u.role }}</Badge></TableCell>
                  <TableCell>{{ new Date(u.created_at).toLocaleDateString() }}</TableCell>
                  <TableCell class="text-right">
                    <Button variant="ghost" size="sm">Edit Role</Button>
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
