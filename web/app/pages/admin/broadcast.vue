<script setup lang="ts">
import { toTypedSchema } from '@vee-validate/zod'
import { useForm } from 'vee-validate'
import { ref } from 'vue'
import { toast } from 'vue-sonner'
import * as z from 'zod'

const supabase = useSupabaseClient()
const isSubmitting = ref(false)

const broadcastSchema = toTypedSchema(z.object({
  message: z.string().min(10, 'Message must be at least 10 characters.'),
  targetRole: z.string().default('all'),
  targetCountry: z.string().default('all'),
}))

const { handleSubmit, resetForm } = useForm({
  validationSchema: broadcastSchema,
  initialValues: {
    targetRole: 'all',
    targetCountry: 'all',
    message: '',
  },
})

const onSubmit = handleSubmit(async (values) => {
  isSubmitting.value = true

  try {
    // Determine target users based on roles/country
    let query = supabase.from('profiles').select('id')

    if (values.targetRole !== 'all') {
      query = query.eq('role', values.targetRole)
    }
    if (values.targetCountry !== 'all') {
      query = query.eq('country', values.targetCountry)
    }

    const { data: users, error: usersError } = await query

    if (usersError)
      throw usersError

    if (!users || users.length === 0) {
      toast.warning('No users matched the target criteria.')
      isSubmitting.value = false
      return
    }

    // Insert batch notification events
    const events = users.map(u => ({
      event_type: 'emergency.broadcast',
      payload: { message: values.message },
      recipient_user_id: u.id,
      channels: ['push', 'email', 'whatsapp'], // broadcast goes to all available channels
    }))

    const { error: insertError } = await supabase
      .from('notification_events')
      .insert(events)

    if (insertError)
      throw insertError

    toast.success(`Successfully scheduled broadcast to ${events.length} users.`)
    resetForm()
  }
  catch (error: any) {
    toast.error('Failed to send broadcast', { description: error.message })
  }
  finally {
    isSubmitting.value = false
  }
})
</script>

<template>
  <div class="p-6 max-w-4xl mx-auto">
    <div class="mb-8">
      <h1 class="text-2xl font-bold">
        Emergency Broadcast
      </h1>
      <p class="text-muted-foreground mt-1">
        Send a critical alert to users via push notification, email, and WhatsApp.
      </p>
    </div>

    <div class="bg-card text-card-foreground border border-border rounded-lg shadow-sm">
      <div class="p-6 border-b border-border">
        <h2 class="text-lg font-semibold">
          Compose Broadcast
        </h2>
      </div>

      <form class="p-6 space-y-6" @submit="onSubmit">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <FormField v-slot="{ componentField }" name="targetRole">
            <FormItem>
              <FormLabel>Target Role</FormLabel>
              <Select v-bind="componentField">
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Select a role" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectGroup>
                    <SelectItem value="all">
                      All Roles
                    </SelectItem>
                    <SelectItem value="field_user">
                      Field Users
                    </SelectItem>
                    <SelectItem value="coordinator">
                      Coordinators
                    </SelectItem>
                    <SelectItem value="admin">
                      Admins
                    </SelectItem>
                  </SelectGroup>
                </SelectContent>
              </Select>
              <FormDescription>Filter recipients by their role.</FormDescription>
              <FormMessage />
            </FormItem>
          </FormField>

          <FormField v-slot="{ componentField }" name="targetCountry">
            <FormItem>
              <FormLabel>Target Country</FormLabel>
              <Select v-bind="componentField">
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Select a country" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectGroup>
                    <SelectItem value="all">
                      All Countries
                    </SelectItem>
                    <SelectItem value="Tanzania">
                      Tanzania
                    </SelectItem>
                    <SelectItem value="Kenya">
                      Kenya
                    </SelectItem>
                    <SelectItem value="Uganda">
                      Uganda
                    </SelectItem>
                  </SelectGroup>
                </SelectContent>
              </Select>
              <FormDescription>Filter recipients by their country.</FormDescription>
              <FormMessage />
            </FormItem>
          </FormField>
        </div>

        <FormField v-slot="{ componentField }" name="message">
          <FormItem>
            <FormLabel>Message Content</FormLabel>
            <FormControl>
              <Textarea
                placeholder="Enter the broadcast message..."
                class="min-h-[150px] resize-y"
                v-bind="componentField"
              />
            </FormControl>
            <FormDescription>
              This message will be sent exactly as written. Variables are not currently supported in emergency broadcasts.
            </FormDescription>
            <FormMessage />
          </FormItem>
        </FormField>

        <div class="flex items-center justify-end gap-4 pt-4">
          <Button type="button" variant="outline" @click="resetForm">
            Reset
          </Button>
          <Button type="submit" variant="destructive" :disabled="isSubmitting">
            <Icon v-if="isSubmitting" name="lucide:loader-2" class="mr-2 h-4 w-4 animate-spin" />
            <Icon v-else name="lucide:alert-triangle" class="mr-2 h-4 w-4" />
            Send Broadcast Now
          </Button>
        </div>
      </form>
    </div>
  </div>
</template>
