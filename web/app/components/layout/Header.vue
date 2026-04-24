<script setup lang="ts">
const route = useRoute()
const { headerState, clearHeader } = usePageHeader()
const { t } = useLocale()

// Clear header state on route change so pages without setHeader() don't show stale info
watch(() => route.fullPath, () => {
  clearHeader()
})

const isHydrated = ref(false)
onMounted(() => {
  isHydrated.value = true
})

const metaHeader = computed(() => (route.meta.header as any) || {})

// Derive fallback title from route when no explicit title is set
const fallbackTitle = computed(() => {
  if (route.fullPath === '/')
    return t('nav.dashboard')
  const segments = route.fullPath.split('/').filter(s => s !== '')
  const last = segments[segments.length - 1] || ''
  return last
    .replace(/-/g, ' ')
    .split(' ')
    .map(w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
    .join(' ')
})

// Resolve title: prefer translation key, then static title, then fallback
const displayTitle = computed(() => {
  if (metaHeader.value.titleKey)
    return t(metaHeader.value.titleKey)
  if (metaHeader.value.title)
    return metaHeader.value.title

  if (isHydrated.value) {
    if (headerState.value.titleKey)
      return t(headerState.value.titleKey)
    if (headerState.value.title)
      return headerState.value.title
  }

  return fallbackTitle.value
})

// Resolve description: prefer translation key, then static description
const displayDescription = computed(() => {
  if (metaHeader.value.descriptionKey)
    return t(metaHeader.value.descriptionKey)
  if (metaHeader.value.description)
    return metaHeader.value.description

  if (isHydrated.value) {
    if (headerState.value.descriptionKey)
      return t(headerState.value.descriptionKey)
    if (headerState.value.description)
      return headerState.value.description
  }

  return ''
})

const displayIcon = computed(() => {
  if (metaHeader.value.icon)
    return metaHeader.value.icon
  if (isHydrated.value && headerState.value.icon)
    return headerState.value.icon
  return ''
})
</script>

<template>
  <header class="sticky top-0 md:peer-data-[variant=inset]:top-2 z-10 flex items-center gap-4 border-b bg-background px-4 md:px-6 md:rounded-tl-xl md:rounded-tr-xl min-h-(--header-height)">
    <div class="flex items-center gap-4 min-w-0 shrink-0">
      <SidebarTrigger />
      <Separator orientation="vertical" class="h-4" />
      <div class="flex items-center gap-2.5 min-w-0">
        <Icon v-if="displayIcon" :name="displayIcon" class="size-5 shrink-0 text-primary" />
        <div class="min-w-0">
          <div class="flex items-center gap-1.5">
            <h1 class="text-sm font-semibold leading-tight truncate">
              {{ displayTitle }}
            </h1>
            <template v-if="displayDescription">
              <span class="text-muted-foreground text-sm hidden md:inline">/</span>
              <p class="text-sm text-muted-foreground leading-tight truncate hidden md:block">
                {{ displayDescription }}
              </p>
            </template>
          </div>
        </div>
      </div>
    </div>

    <!-- Teleport target for page-specific toolbar -->
    <div id="header-toolbar" class="flex-1 flex items-center justify-end gap-2 min-w-0" />

    <div class="flex items-center gap-2 shrink-0">
      <slot />
    </div>
  </header>
</template>
