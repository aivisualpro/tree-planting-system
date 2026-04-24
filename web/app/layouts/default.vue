<script setup lang="ts">
const { isImpersonating, impersonatedUserName, exitImpersonation } = useImpersonation()
</script>

<template>
  <SidebarProvider>
    <LayoutAppSidebar />
    <SidebarInset>
      <div v-if="isImpersonating" class="bg-red-500 text-white px-4 py-2 flex items-center justify-between text-sm font-medium z-50">
        <div class="flex items-center gap-2">
          <Icon name="lucide:user-check" class="w-4 h-4" />
          <span>VIEWING AS {{ impersonatedUserName }}</span>
        </div>
        <button @click="exitImpersonation" class="bg-white text-red-500 px-3 py-1 rounded text-xs font-bold hover:bg-red-50">
          Exit impersonation
        </button>
      </div>
      <LayoutHeader />
      <div class="flex flex-col flex-1">
        <div class="@container/main p-4 lg:p-6 grow">
          <slot />
        </div>
      </div>
    </SidebarInset>
  </SidebarProvider>
</template>

<style scoped>

</style>
