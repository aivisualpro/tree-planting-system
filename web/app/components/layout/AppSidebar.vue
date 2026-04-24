<script setup lang="ts">
import type { TranslationKey } from '~/composables/useLocale'
import type { NavGroup, NavLink, NavSectionTitle } from '~/types/nav'
import { navMenu, navMenuBottom } from '~/constants/menus'

function resolveNavItemComponent(item: NavLink | NavGroup | NavSectionTitle): any {
  if ('children' in item)
    return resolveComponent('LayoutSidebarNavGroup')

  return resolveComponent('LayoutSidebarNavLink')
}

const { t } = useLocale()

function getHeading(nav: { heading: string, headingKey?: string }) {
  return nav.headingKey ? t(nav.headingKey as TranslationKey) : nav.heading
}

const teams: {
  name: string
  logo: string
  plan: string
}[] = [
  {
    name: 'Plant With Purpose',
    logo: 'i-lucide-gallery-vertical-end',
    plan: 'Free',
  },
  {
    name: 'Plant With Purpose',
    logo: 'i-lucide-audio-waveform',
    plan: 'Professional',
  },
  {
    name: 'Plant With Purpose',
    logo: 'i-lucide-command',
    plan: 'Organization',
  },
]

const user: {
  name: string
  email: string
  avatar: string
} = {
  name: 'Adeel Jabbar',
  email: 'adeel@aivisualpro.com',
  avatar: '/avatars/adeel.png',
}

const { sidebar } = useAppSettings()
</script>

<template>
  <Sidebar :collapsible="sidebar?.collapsible" :side="sidebar?.side" :variant="sidebar?.variant">
    <SidebarHeader>
      <LayoutSidebarNavHeader :teams="teams" />
      <Search />
    </SidebarHeader>
    <SidebarContent>
      <SidebarGroup v-for="(nav, indexGroup) in navMenu" :key="indexGroup">
        <SidebarGroupLabel v-if="nav.heading">
          {{ getHeading(nav) }}
        </SidebarGroupLabel>
        <component :is="resolveNavItemComponent(item)" v-for="(item, index) in nav.items" :key="index" :item="item" />
      </SidebarGroup>
      <SidebarGroup class="mt-auto">
        <component :is="resolveNavItemComponent(item)" v-for="(item, index) in navMenuBottom" :key="index" :item="item" size="sm" />
      </SidebarGroup>
    </SidebarContent>
    <SidebarFooter>
      <LayoutSidebarNavFooter :user="user" />
    </SidebarFooter>
    <SidebarRail />
  </Sidebar>
</template>
