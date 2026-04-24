<script setup lang="ts">
import { toast } from 'vue-sonner'
const user = useSupabaseUser()
const exporting = ref(false)
const showDeleteDialog = ref(false)
const confirmEmail = ref('')
const deleting = ref(false)

const downloadData = async () => {
  exporting.value = true
  try {
    const response = await $fetch('/api/gdpr/export', { method: 'POST' })
    // Browser download
    const blob = new Blob([response as any], { type: 'application/zip' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `data-export-${user.value?.id}.zip`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    toast.success('Data export started')
  } catch (err: any) {
    if (err.statusCode === 429) {
      toast.error('One export per day allowed. Please try again tomorrow.')
    } else {
      toast.error('Failed to generate export')
    }
  } finally {
    exporting.value = false
  }
}

const anonymizeAccount = async () => {
  if (confirmEmail.value !== user.value?.email) {
    toast.error('Email does not match')
    return
  }
  
  deleting.value = true
  try {
    await $fetch('/api/gdpr/anonymize', {
      method: 'POST',
      body: { confirmEmail: confirmEmail.value }
    })
    toast.success('Account anonymized. You will be logged out.')
    setTimeout(() => {
      window.location.href = '/login'
    }, 2000)
  } catch (err) {
    toast.error('Failed to anonymize account')
  } finally {
    deleting.value = false
  }
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h3 class="text-lg font-medium">Privacy & Data Portability</h3>
      <p class="text-sm text-muted-foreground">
        Manage your data and exercise your rights to portability and erasure (GDPR).
      </p>
    </div>
    <Separator />

    <!-- Export Section -->
    <div class="grid gap-4">
      <Card>
        <CardHeader>
          <CardTitle class="text-base flex items-center gap-2">
            <Icon name="i-lucide-download" class="size-4" />
            Download your data
          </CardTitle>
          <CardDescription>
            Get a copy of your information in JSON format, including your profile, visits, and media metadata.
          </CardDescription>
        </CardHeader>
        <CardFooter class="border-t px-6 py-4">
          <Button :loading="exporting" @click="downloadData">
            Request Export
          </Button>
        </CardFooter>
      </Card>

      <!-- Delete Section -->
      <Card class="border-destructive/20 bg-destructive/5">
        <CardHeader>
          <CardTitle class="text-base text-destructive flex items-center gap-2">
            <Icon name="i-lucide-user-x" class="size-4" />
            Anonymize account
          </CardTitle>
          <CardDescription class="text-destructive/80">
            Once you anonymize your account, there is no going back. Your personal data will be redacted, and your account will be disabled.
          </CardDescription>
        </CardHeader>
        <CardFooter class="border-t border-destructive/10 px-6 py-4">
          <Dialog v-model:open="showDeleteDialog">
            <DialogTrigger as-child>
              <Button variant="destructive">Anonymize Account</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Are you absolutely sure?</DialogTitle>
                <DialogDescription>
                  This action cannot be undone. This will permanently redact your personal information from our servers. 
                  Historical visit data will remain for reporting purposes but will no longer be associated with you.
                </DialogDescription>
              </DialogHeader>
              <div class="py-4">
                <Label for="email-confirm">Please type your email to confirm: <span class="font-bold">{{ user?.email }}</span></Label>
                <Input id="email-confirm" v-model="confirmEmail" class="mt-2" placeholder="Enter your email" />
              </div>
              <DialogFooter>
                <Button variant="outline" @click="showDeleteDialog = false">Cancel</Button>
                <Button variant="destructive" :loading="deleting" @click="anonymizeAccount">
                  Confirm Anonymization
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </CardFooter>
      </Card>
    </div>
  </div>
</template>
