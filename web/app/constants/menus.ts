import type { NavMenu, NavMenuItems } from '~/types/nav'

export const navMenu: NavMenu[] = [
  {
    heading: 'General',
    headingKey: 'nav.general',
    items: [
      {
        title: 'Dashboard',
        titleKey: 'nav.dashboard',
        icon: 'i-lucide-layout-dashboard',
        link: '/',
      },
    ],
  },
  {
    heading: 'Operations',
    headingKey: 'nav.operations',
    items: [
      {
        title: 'Field Visits',
        titleKey: 'nav.visits',
        icon: 'i-lucide-map',
        link: '/visits',
      },
    ],
  },
  {
    heading: 'Master Data',
    headingKey: 'nav.masters',
    items: [
      {
        title: 'Countries',
        titleKey: 'nav.countries',
        icon: 'i-lucide-globe-2',
        link: '/masters/countries',
      },
      {
        title: 'Translations',
        titleKey: 'nav.translations',
        icon: 'i-lucide-languages',
        link: '/masters/translations',
      },
    ],
  },
  {
    heading: 'Administration',
    headingKey: 'nav.administration',
    items: [
      {
        title: 'Users & Roles',
        titleKey: 'nav.users',
        icon: 'i-lucide-users',
        link: '/users',
      },
      {
        title: 'Audit Log',
        titleKey: 'nav.auditLog',
        icon: 'i-lucide-activity',
        link: '/audit-log',
      },
    ],
  },
]

export const navMenuBottom: NavMenuItems = [
  {
    title: 'Help & Support',
    titleKey: 'nav.helpSupport',
    icon: 'i-lucide-circle-help',
    link: '/docs',
  },
  {
    title: 'Settings',
    titleKey: 'nav.settings',
    icon: 'i-lucide-settings',
    link: '/settings/profile',
  },
]
