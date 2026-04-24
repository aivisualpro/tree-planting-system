<template>
  <div v-if="!dismissed" class="fixed bottom-0 left-0 right-0 z-50 p-4 bg-background border-t shadow-lg flex flex-col sm:flex-row items-center justify-between gap-4">
    <div class="text-sm text-muted-foreground text-center sm:text-left">
      We use strictly necessary cookies to keep you logged in and save your preferences. No third-party tracking is used. 
      <NuxtLink to="/privacy" class="underline text-primary hover:text-primary/80">Read our Privacy Policy</NuxtLink>.
    </div>
    <div class="flex-shrink-0">
      <Button variant="default" size="sm" @click="dismiss">Got it</Button>
    </div>
  </div>
</template>

<script setup lang="ts">
const dismissed = useCookie('cookie_banner_dismissed', { default: () => false, maxAge: 60 * 60 * 24 * 365 })

function dismiss() {
  dismissed.value = true
}
</script>
