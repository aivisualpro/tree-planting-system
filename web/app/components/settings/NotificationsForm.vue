<script setup lang="ts">
import { toTypedSchema } from '@vee-validate/zod'
import { useForm } from 'vee-validate'
import { h, onMounted, ref } from 'vue'
import { toast } from 'vue-sonner'
import * as z from 'zod'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const isLoading = ref(true)

const notificationsFormSchema = toTypedSchema(z.object({
  push_enabled: z.boolean().default(true),
  email_enabled: z.boolean().default(true),
  whatsapp_enabled: z.boolean().default(false),
  quiet_hours_start: z.string().optional(),
  quiet_hours_end: z.string().optional(),
  timezone: z.string().default('UTC'),
}))

const { handleSubmit, setValues } = useForm({
  validationSchema: notificationsFormSchema,
  initialValues: {
    push_enabled: true,
    email_enabled: true,
    whatsapp_enabled: false,
    quiet_hours_start: '',
    quiet_hours_end: '',
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC',
  },
})

onMounted(async () => {
  if (!user.value) return
  
  try {
    const { data, error } = await supabase
      .from('notification_preferences')
      .select('*')
      .eq('user_id', user.value.id)
      .single()
      
    if (error && error.code !== 'PGRST116') throw error
    
    if (data) {
      setValues({
        push_enabled: data.push_enabled,
        email_enabled: data.email_enabled,
        whatsapp_enabled: data.whatsapp_enabled,
        quiet_hours_start: data.quiet_hours_start || '',
        quiet_hours_end: data.quiet_hours_end || '',
        timezone: data.timezone || Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC',
      })
    }
  } catch (e: any) {
    toast.error('Failed to load preferences', { description: e.message })
  } finally {
    isLoading.value = false
  }
})

const onSubmit = handleSubmit(async (values) => {
  if (!user.value) return
  
  try {
    const { error } = await supabase
      .from('notification_preferences')
      .upsert({
        user_id: user.value.id,
        push_enabled: values.push_enabled,
        email_enabled: values.email_enabled,
        whatsapp_enabled: values.whatsapp_enabled,
        quiet_hours_start: values.quiet_hours_start || null,
        quiet_hours_end: values.quiet_hours_end || null,
        timezone: values.timezone,
        updated_at: new Date().toISOString()
      })
      
    if (error) throw error
    
    toast.success('Preferences updated successfully.')
  } catch (e: any) {
    toast.error('Failed to update preferences', { description: e.message })
  }
})
</script>

<template>
  <div v-if="isLoading" class="flex items-center justify-center p-8">
    <Icon name="lucide:loader-2" class="w-6 h-6 animate-spin text-muted-foreground" />
  </div>
  <div v-else>
    <div>
      <h3 class="text-lg font-medium">
        Notifications
      </h3>
      <p class="text-sm text-muted-foreground">
        Configure how you receive alerts and updates.
      </p>
    </div>
    <Separator class="my-6" />
    <form class="space-y-8" @submit="onSubmit">
      <div>
        <h3 class="mb-4 text-lg font-medium">
          Delivery Channels
        </h3>
        <div class="space-y-4">
          <FormField v-slot="{ handleChange, value }" type="checkbox" name="push_enabled">
            <FormItem class="flex flex-row items-center justify-between border rounded-lg p-4">
              <div class="space-y-0.5">
                <FormLabel class="text-base">Push Notifications</FormLabel>
                <FormDescription>Receive push alerts on your mobile and web devices.</FormDescription>
              </div>
              <FormControl>
                <Switch :checked="value" @update:checked="handleChange" />
              </FormControl>
            </FormItem>
          </FormField>

          <FormField v-slot="{ handleChange, value }" type="checkbox" name="email_enabled">
            <FormItem class="flex flex-row items-center justify-between border rounded-lg p-4">
              <div class="space-y-0.5">
                <FormLabel class="text-base">Email Notifications</FormLabel>
                <FormDescription>Receive updates via email.</FormDescription>
              </div>
              <FormControl>
                <Switch :checked="value" @update:checked="handleChange" />
              </FormControl>
            </FormItem>
          </FormField>

          <FormField v-slot="{ handleChange, value }" type="checkbox" name="whatsapp_enabled">
            <FormItem class="flex flex-row items-center justify-between border rounded-lg p-4">
              <div class="space-y-0.5">
                <FormLabel class="text-base">WhatsApp Notifications</FormLabel>
                <FormDescription>Receive critical alerts via WhatsApp.</FormDescription>
              </div>
              <FormControl>
                <Switch :checked="value" @update:checked="handleChange" />
              </FormControl>
            </FormItem>
          </FormField>
        </div>
      </div>

      <div>
        <h3 class="mb-4 text-lg font-medium">
          Quiet Hours
        </h3>
        <div class="grid gap-4 md:grid-cols-2">
          <FormField v-slot="{ componentField }" name="quiet_hours_start">
            <FormItem>
              <FormLabel>Start Time</FormLabel>
              <FormControl>
                <Input type="time" v-bind="componentField" />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>

          <FormField v-slot="{ componentField }" name="quiet_hours_end">
            <FormItem>
              <FormLabel>End Time</FormLabel>
              <FormControl>
                <Input type="time" v-bind="componentField" />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
        </div>
        <p class="mt-2 text-sm text-muted-foreground">
          Notifications will be deferred during this window in your local time zone.
        </p>
      </div>

      <div class="flex justify-start">
        <Button type="submit">
          Save preferences
        </Button>
      </div>
    </form>
  </div>
</template>
