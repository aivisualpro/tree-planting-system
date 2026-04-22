<script setup lang="ts">
</script>

<template>
  <div class="flex flex-col gap-4 p-4 lg:p-8 h-full">
    <h2 class="text-2xl font-bold tracking-tight mb-2">Settings</h2>
    <div class="flex-1 flex flex-col md:flex-row gap-6 min-h-0 overflow-hidden">
      <!-- Nav -->
      <nav class="md:w-64 flex flex-col gap-2">
        <NuxtLink to="/settings/profile" class="px-4 py-2 hover:bg-muted rounded-md" active-class="bg-muted font-medium">Profile</NuxtLink>
        <NuxtLink to="/settings/account" class="px-4 py-2 hover:bg-muted rounded-md" active-class="bg-muted font-medium">Account</NuxtLink>
        <NuxtLink to="/settings/appearance" class="px-4 py-2 hover:bg-muted rounded-md" active-class="bg-muted font-medium">Appearance</NuxtLink>
      </nav>
      <!-- Content -->
      <div class="flex-1 border rounded-lg p-6 bg-card overflow-auto">
        <NuxtPage />
      </div>
    </div>
  </div>
</template>
