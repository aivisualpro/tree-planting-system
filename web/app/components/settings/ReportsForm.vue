<script setup lang="ts">
import { toast } from 'vue-sonner'

interface ScheduledReport {
  id: string
  user_id: string
  report_type: string
  schedule: string
  active: boolean
  params?: any
}

const supabase = useSupabaseClient<any>()
const user = useSupabaseUser()

const availableReports = [
  {
    type: 'monthly-country-report',
    title: 'Monthly Country Report',
    description: 'Detailed KPIs and visit timelines for your assigned countries, sent on the 1st of every month.',
    schedule: '0 0 1 * *',
  },
  {
    type: 'weekly-activity-digest',
    title: 'Weekly Activity Digest',
    description: 'A summary of all planting activities and survey progress from the past week.',
    schedule: '0 0 * * 1',
  },
]

const { data: subscriptions, refresh } = await useAsyncData<ScheduledReport[]>('scheduled_reports', async () => {
  if (!user.value)
    return []
  const { data } = await supabase
    .from('scheduled_reports')
    .select('*')
    .eq('user_id', user.value.id)
  return (data as ScheduledReport[]) || []
})

const isSubscribed = (type: string) => subscriptions.value?.some(s => s.report_type === type && s.active)

async function toggleSubscription(report: any) {
  const existing = subscriptions.value?.find(s => s.report_type === report.type)

  if (existing) {
    await supabase
      .from('scheduled_reports')
      .update({ active: !existing.active } as any)
      .eq('id', existing.id)
  }
  else {
    await supabase
      .from('scheduled_reports')
      .insert({
        user_id: user.value?.id,
        report_type: report.type,
        schedule: report.schedule,
        active: true,
      } as any)
  }

  refresh()
  toast.success('Subscription updated')
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h3 class="text-lg font-medium">
        Report Subscriptions
      </h3>
      <p class="text-sm text-muted-foreground">
        Choose which automated reports you would like to receive via email.
      </p>
    </div>
    <Separator />

    <div class="space-y-4">
      <div v-for="report in availableReports" :key="report.type" class="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors">
        <div class="space-y-0.5">
          <Label class="text-base font-semibold">{{ report.title }}</Label>
          <p class="text-sm text-muted-foreground max-w-md">
            {{ report.description }}
          </p>
        </div>
        <Switch
          :checked="isSubscribed(report.type)"
          @update:checked="toggleSubscription(report)"
        />
      </div>
    </div>

    <div class="mt-8 p-4 bg-muted/50 rounded-xl border border-dashed border-muted-foreground/20">
      <div class="flex items-start gap-3">
        <Icon name="i-lucide-info" class="size-5 text-muted-foreground mt-0.5" />
        <p class="text-sm text-muted-foreground">
          Reports are generated using the most recent data available at the time of generation.
          PDF attachments will be sent to <strong>{{ user?.email }}</strong>.
        </p>
      </div>
    </div>
  </div>
</template>
