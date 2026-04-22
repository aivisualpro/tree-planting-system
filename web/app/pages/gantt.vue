<script setup lang="ts">
import { TrendingUp } from 'lucide-vue-next'

const { setHeader } = usePageHeader()
setHeader({ title: 'Gantt Chart', icon: 'i-lucide-gantt-chart', description: 'Project timeline & resource planning' })

// ── Types ──────────────────────────────────────────────
interface GanttTask {
  id: string
  name: string
  phase: string
  start: string // YYYY-MM-DD
  end: string
  progress: number // 0-100
  status: 'completed' | 'in-progress' | 'upcoming' | 'at-risk' | 'blocked'
  assignee: string
  priority: 'critical' | 'high' | 'medium' | 'low'
  dependencies?: string[]
  milestone?: boolean
  color?: string
}

interface Phase {
  id: string
  name: string
  icon: string
  color: string
  bgColor: string
  expanded: boolean
}

// ── State ──────────────────────────────────────────────
const viewMode = ref<'weeks' | 'months'>('weeks')
const selectedTask = ref<GanttTask | null>(null)
const showDetail = ref(false)
const filterStatus = ref('all')
const searchQuery = ref('')

// ── Phases ─────────────────────────────────────────────
const phases = ref<Phase[]>([
  { id: 'discovery', name: 'Discovery & Planning', icon: 'i-lucide-compass', color: 'text-violet-500', bgColor: 'bg-violet-500', expanded: true },
  { id: 'design', name: 'UI/UX Design', icon: 'i-lucide-figma', color: 'text-pink-500', bgColor: 'bg-pink-500', expanded: true },
  { id: 'backend', name: 'Backend Development', icon: 'i-lucide-server', color: 'text-blue-500', bgColor: 'bg-blue-500', expanded: true },
  { id: 'frontend', name: 'Frontend Development', icon: 'i-lucide-monitor', color: 'text-emerald-500', bgColor: 'bg-emerald-500', expanded: true },
  { id: 'integration', name: 'Integration & Testing', icon: 'i-lucide-test-tubes', color: 'text-amber-500', bgColor: 'bg-amber-500', expanded: true },
  { id: 'launch', name: 'Launch & Deployment', icon: 'i-lucide-rocket', color: 'text-rose-500', bgColor: 'bg-rose-500', expanded: true },
])

// ── Tasks (Rich ERP Project Data) ──────────────────────
const tasks = ref<GanttTask[]>([
  // Phase 1: Discovery & Planning
  { id: 'T-001', name: 'Stakeholder Interviews', phase: 'discovery', start: '2026-01-06', end: '2026-01-17', progress: 100, status: 'completed', assignee: 'Sarah Chen', priority: 'critical', color: '#8b5cf6' },
  { id: 'T-002', name: 'Requirements Documentation', phase: 'discovery', start: '2026-01-13', end: '2026-01-31', progress: 100, status: 'completed', assignee: 'James Wilson', priority: 'critical', dependencies: ['T-001'], color: '#8b5cf6' },
  { id: 'T-003', name: 'Technical Architecture', phase: 'discovery', start: '2026-01-20', end: '2026-02-07', progress: 100, status: 'completed', assignee: 'Alex Rivera', priority: 'high', dependencies: ['T-001'], color: '#8b5cf6' },
  { id: 'T-004', name: 'Project Roadmap Sign-off', phase: 'discovery', start: '2026-02-07', end: '2026-02-07', progress: 100, status: 'completed', assignee: 'Sarah Chen', priority: 'critical', dependencies: ['T-002', 'T-003'], milestone: true, color: '#8b5cf6' },

  // Phase 2: UI/UX Design
  { id: 'T-005', name: 'User Research & Personas', phase: 'design', start: '2026-02-10', end: '2026-02-21', progress: 100, status: 'completed', assignee: 'Maya Patel', priority: 'high', dependencies: ['T-004'], color: '#ec4899' },
  { id: 'T-006', name: 'Wireframes & Prototyping', phase: 'design', start: '2026-02-17', end: '2026-03-07', progress: 100, status: 'completed', assignee: 'Maya Patel', priority: 'high', dependencies: ['T-005'], color: '#ec4899' },
  { id: 'T-007', name: 'Design System & Components', phase: 'design', start: '2026-02-24', end: '2026-03-21', progress: 85, status: 'in-progress', assignee: 'Leo Kim', priority: 'high', dependencies: ['T-005'], color: '#ec4899' },
  { id: 'T-008', name: 'High-Fidelity Mockups', phase: 'design', start: '2026-03-10', end: '2026-03-28', progress: 60, status: 'in-progress', assignee: 'Maya Patel', priority: 'medium', dependencies: ['T-006'], color: '#ec4899' },
  { id: 'T-009', name: 'Design Review & Approval', phase: 'design', start: '2026-03-28', end: '2026-03-28', progress: 0, status: 'upcoming', assignee: 'Sarah Chen', priority: 'critical', dependencies: ['T-007', 'T-008'], milestone: true, color: '#ec4899' },

  // Phase 3: Backend Development
  { id: 'T-010', name: 'Database Schema Design', phase: 'backend', start: '2026-03-03', end: '2026-03-14', progress: 100, status: 'completed', assignee: 'Alex Rivera', priority: 'critical', dependencies: ['T-003'], color: '#3b82f6' },
  { id: 'T-011', name: 'Authentication & Authorization', phase: 'backend', start: '2026-03-10', end: '2026-03-28', progress: 90, status: 'in-progress', assignee: 'Daniel Osei', priority: 'critical', dependencies: ['T-010'], color: '#3b82f6' },
  { id: 'T-012', name: 'Core API Development', phase: 'backend', start: '2026-03-17', end: '2026-04-18', progress: 65, status: 'in-progress', assignee: 'Alex Rivera', priority: 'critical', dependencies: ['T-010'], color: '#3b82f6' },
  { id: 'T-013', name: 'Real-time WebSocket Layer', phase: 'backend', start: '2026-03-31', end: '2026-04-18', progress: 30, status: 'at-risk', assignee: 'Daniel Osei', priority: 'high', dependencies: ['T-011'], color: '#3b82f6' },
  { id: 'T-014', name: 'File Storage & CDN Setup', phase: 'backend', start: '2026-04-07', end: '2026-04-18', progress: 10, status: 'at-risk', assignee: 'Alex Rivera', priority: 'medium', dependencies: ['T-012'], color: '#3b82f6' },

  // Phase 4: Frontend Development
  { id: 'T-015', name: 'Component Library Setup', phase: 'frontend', start: '2026-03-24', end: '2026-04-04', progress: 75, status: 'in-progress', assignee: 'Leo Kim', priority: 'high', dependencies: ['T-007'], color: '#10b981' },
  { id: 'T-016', name: 'Dashboard & Analytics Views', phase: 'frontend', start: '2026-04-07', end: '2026-04-25', progress: 20, status: 'in-progress', assignee: 'Leo Kim', priority: 'high', dependencies: ['T-015', 'T-012'], color: '#10b981' },
  { id: 'T-017', name: 'CRM Module Frontend', phase: 'frontend', start: '2026-04-14', end: '2026-05-02', progress: 0, status: 'upcoming', assignee: 'Nina Vasquez', priority: 'critical', dependencies: ['T-015', 'T-012'], color: '#10b981' },
  { id: 'T-018', name: 'Finance Module Frontend', phase: 'frontend', start: '2026-04-21', end: '2026-05-09', progress: 0, status: 'upcoming', assignee: 'Leo Kim', priority: 'high', dependencies: ['T-016'], color: '#10b981' },
  { id: 'T-019', name: 'Inventory Module Frontend', phase: 'frontend', start: '2026-04-28', end: '2026-05-16', progress: 0, status: 'upcoming', assignee: 'Nina Vasquez', priority: 'medium', dependencies: ['T-017'], color: '#10b981' },

  // Phase 5: Integration & Testing
  { id: 'T-020', name: 'API Integration Testing', phase: 'integration', start: '2026-05-05', end: '2026-05-23', progress: 0, status: 'upcoming', assignee: 'Daniel Osei', priority: 'critical', dependencies: ['T-012', 'T-016'], color: '#f59e0b' },
  { id: 'T-021', name: 'E2E Test Suite', phase: 'integration', start: '2026-05-12', end: '2026-05-30', progress: 0, status: 'upcoming', assignee: 'James Wilson', priority: 'high', dependencies: ['T-017'], color: '#f59e0b' },
  { id: 'T-022', name: 'Performance & Load Testing', phase: 'integration', start: '2026-05-19', end: '2026-06-06', progress: 0, status: 'upcoming', assignee: 'Alex Rivera', priority: 'high', dependencies: ['T-020'], color: '#f59e0b' },
  { id: 'T-023', name: 'UAT & Bug Fixes', phase: 'integration', start: '2026-05-26', end: '2026-06-13', progress: 0, status: 'upcoming', assignee: 'Maya Patel', priority: 'critical', dependencies: ['T-021'], color: '#f59e0b' },

  // Phase 6: Launch & Deployment
  { id: 'T-024', name: 'Staging Environment Setup', phase: 'launch', start: '2026-06-02', end: '2026-06-13', progress: 0, status: 'upcoming', assignee: 'Alex Rivera', priority: 'high', dependencies: ['T-022'], color: '#ef4444' },
  { id: 'T-025', name: 'Data Migration & Seeding', phase: 'launch', start: '2026-06-09', end: '2026-06-20', progress: 0, status: 'upcoming', assignee: 'Daniel Osei', priority: 'critical', dependencies: ['T-024'], color: '#ef4444' },
  { id: 'T-026', name: 'Production Deployment', phase: 'launch', start: '2026-06-16', end: '2026-06-27', progress: 0, status: 'upcoming', assignee: 'Alex Rivera', priority: 'critical', dependencies: ['T-023', 'T-025'], color: '#ef4444' },
  { id: 'T-027', name: '🚀 Go Live!', phase: 'launch', start: '2026-06-27', end: '2026-06-27', progress: 0, status: 'upcoming', assignee: 'Sarah Chen', priority: 'critical', dependencies: ['T-026'], milestone: true, color: '#ef4444' },
])

// ── Timeline Computation ───────────────────────────────
const timelineStart = computed(() => new Date('2026-01-06'))
const timelineEnd = computed(() => new Date('2026-07-04'))

const totalDays = computed(() => {
  return Math.ceil((timelineEnd.value.getTime() - timelineStart.value.getTime()) / (1000 * 60 * 60 * 24))
})

const dayWidth = computed(() => viewMode.value === 'weeks' ? 18 : 6)
const timelineWidth = computed(() => totalDays.value * dayWidth.value)

// Generate time markers
const timeMarkers = computed(() => {
  const markers: { label: string, sublabel?: string, left: number, width: number, isMonth: boolean }[] = []
  const start = new Date(timelineStart.value)

  if (viewMode.value === 'months') {
    const current = new Date(start.getFullYear(), start.getMonth(), 1)
    while (current < timelineEnd.value) {
      const monthStart = new Date(Math.max(current.getTime(), start.getTime()))
      const nextMonth = new Date(current.getFullYear(), current.getMonth() + 1, 1)
      const monthEnd = new Date(Math.min(nextMonth.getTime(), timelineEnd.value.getTime()))
      const daysInView = Math.ceil((monthEnd.getTime() - monthStart.getTime()) / (1000 * 60 * 60 * 24))
      const offsetDays = Math.ceil((monthStart.getTime() - start.getTime()) / (1000 * 60 * 60 * 24))

      markers.push({
        label: current.toLocaleDateString('en-US', { month: 'short' }),
        sublabel: current.toLocaleDateString('en-US', { year: 'numeric' }),
        left: offsetDays * dayWidth.value,
        width: daysInView * dayWidth.value,
        isMonth: true,
      })
      current.setMonth(current.getMonth() + 1)
    }
  }
  else {
    // Weekly markers
    const current = new Date(start)
    // align to Monday
    current.setDate(current.getDate() - current.getDay() + 1)
    while (current < timelineEnd.value) {
      const weekStart = new Date(Math.max(current.getTime(), start.getTime()))
      const weekEnd = new Date(current)
      weekEnd.setDate(weekEnd.getDate() + 7)
      const actualEnd = new Date(Math.min(weekEnd.getTime(), timelineEnd.value.getTime()))
      const daysInView = Math.ceil((actualEnd.getTime() - weekStart.getTime()) / (1000 * 60 * 60 * 24))
      const offsetDays = Math.ceil((weekStart.getTime() - start.getTime()) / (1000 * 60 * 60 * 24))

      markers.push({
        label: weekStart.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        left: offsetDays * dayWidth.value,
        width: daysInView * dayWidth.value,
        isMonth: false,
      })
      current.setDate(current.getDate() + 7)
    }
  }
  return markers
})

// Month headers (always shown above for weeks view)
const monthHeaders = computed(() => {
  const headers: { label: string, left: number, width: number }[] = []
  const start = new Date(timelineStart.value)
  const current = new Date(start.getFullYear(), start.getMonth(), 1)

  while (current < timelineEnd.value) {
    const monthStart = new Date(Math.max(current.getTime(), start.getTime()))
    const nextMonth = new Date(current.getFullYear(), current.getMonth() + 1, 1)
    const monthEnd = new Date(Math.min(nextMonth.getTime(), timelineEnd.value.getTime()))
    const daysInView = Math.ceil((monthEnd.getTime() - monthStart.getTime()) / (1000 * 60 * 60 * 24))
    const offsetDays = Math.ceil((monthStart.getTime() - start.getTime()) / (1000 * 60 * 60 * 24))

    headers.push({
      label: current.toLocaleDateString('en-US', { month: 'long', year: 'numeric' }),
      left: offsetDays * dayWidth.value,
      width: daysInView * dayWidth.value,
    })
    current.setMonth(current.getMonth() + 1)
  }
  return headers
})

// ── Task Bar Computation ───────────────────────────────
function getTaskStyle(task: GanttTask) {
  const start = new Date(task.start)
  const end = new Date(task.end)
  const offsetDays = Math.ceil((start.getTime() - timelineStart.value.getTime()) / (1000 * 60 * 60 * 24))
  const durationDays = Math.max(1, Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)) + 1)

  return {
    left: `${offsetDays * dayWidth.value}px`,
    width: `${task.milestone ? 20 : durationDays * dayWidth.value}px`,
  }
}

// ── Today indicator ────────────────────────────────────
const todayOffset = computed(() => {
  const today = new Date('2026-03-26') // Simulated "today" for demo
  const days = Math.ceil((today.getTime() - timelineStart.value.getTime()) / (1000 * 60 * 60 * 24))
  return days * dayWidth.value
})

// ── Filtering ──────────────────────────────────────────
const filteredTasks = computed(() => {
  return tasks.value.filter((t) => {
    if (filterStatus.value !== 'all' && t.status !== filterStatus.value)
      return false
    if (searchQuery.value && !t.name.toLowerCase().includes(searchQuery.value.toLowerCase()) && !t.assignee.toLowerCase().includes(searchQuery.value.toLowerCase()))
      return false
    return true
  })
})

function getPhaseTasksFiltered(phaseId: string) {
  return filteredTasks.value.filter(t => t.phase === phaseId)
}

// ── Stats ──────────────────────────────────────────────
const stats = computed(() => {
  const total = tasks.value.length
  const completed = tasks.value.filter(t => t.status === 'completed').length
  const inProgress = tasks.value.filter(t => t.status === 'in-progress').length
  const atRisk = tasks.value.filter(t => t.status === 'at-risk' || t.status === 'blocked').length
  const avgProgress = Math.round(tasks.value.reduce((s, t) => s + t.progress, 0) / total)
  return { total, completed, inProgress, atRisk, avgProgress }
})

// ── Status Colors ──────────────────────────────────────
const statusConfig: Record<string, { label: string, class: string, dot: string }> = {
  'completed': { label: 'Completed', class: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-200 dark:border-emerald-800', dot: 'bg-emerald-500' },
  'in-progress': { label: 'In Progress', class: 'bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-200 dark:border-blue-800', dot: 'bg-blue-500' },
  'upcoming': { label: 'Upcoming', class: 'bg-muted text-muted-foreground', dot: 'bg-muted-foreground/50' },
  'at-risk': { label: 'At Risk', class: 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-200 dark:border-amber-800', dot: 'bg-amber-500' },
  'blocked': { label: 'Blocked', class: 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border-rose-200 dark:border-rose-800', dot: 'bg-rose-500' },
}

const priorityConfig: Record<string, { label: string, class: string }> = {
  critical: { label: 'Critical', class: 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border-rose-200 dark:border-rose-800' },
  high: { label: 'High', class: 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-200 dark:border-amber-800' },
  medium: { label: 'Medium', class: 'bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-200 dark:border-blue-800' },
  low: { label: 'Low', class: 'bg-muted text-muted-foreground' },
}

function togglePhase(phaseId: string) {
  const p = phases.value.find(ph => ph.id === phaseId)
  if (p)
    p.expanded = !p.expanded
}

function openTaskDetail(task: GanttTask) {
  selectedTask.value = task
  showDetail.value = true
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function getDuration(start: string, end: string) {
  const days = Math.ceil((new Date(end).getTime() - new Date(start).getTime()) / (1000 * 60 * 60 * 24)) + 1
  if (days === 1)
    return '1 day'
  if (days < 7)
    return `${days} days`
  const weeks = Math.round(days / 7)
  return `${weeks} week${weeks > 1 ? 's' : ''}`
}

function getInitials(name: string) {
  return name.split(' ').map(w => w[0]).join('').toUpperCase()
}

function getAvatarColor(name: string) {
  const colors = [
    'bg-violet-500/15 text-violet-600 dark:text-violet-400',
    'bg-pink-500/15 text-pink-600 dark:text-pink-400',
    'bg-blue-500/15 text-blue-600 dark:text-blue-400',
    'bg-emerald-500/15 text-emerald-600 dark:text-emerald-400',
    'bg-amber-500/15 text-amber-600 dark:text-amber-400',
    'bg-rose-500/15 text-rose-600 dark:text-rose-400',
    'bg-cyan-500/15 text-cyan-600 dark:text-cyan-400',
  ]
  const idx = name.split('').reduce((a, c) => a + c.charCodeAt(0), 0) % colors.length
  return colors[idx]
}

// Bar color opacity based on status
function getBarClasses(task: GanttTask) {
  if (task.status === 'completed')
    return 'opacity-70'
  if (task.status === 'at-risk')
    return 'animate-pulse-subtle'
  if (task.status === 'blocked')
    return 'opacity-40'
  return ''
}

// ── Scroll Sync ────────────────────────────────────────
const headerTimelineRef = ref<HTMLElement | null>(null)
const bodyTimelineRef = ref<HTMLElement | null>(null)
const leftPanelRef = ref<HTMLElement | null>(null)

let isSyncing = false

function onBodyScroll() {
  if (isSyncing)
    return
  isSyncing = true
  if (headerTimelineRef.value && bodyTimelineRef.value) {
    headerTimelineRef.value.scrollLeft = bodyTimelineRef.value.scrollLeft
  }
  requestAnimationFrame(() => { isSyncing = false })
}

function onHeaderScroll() {
  if (isSyncing)
    return
  isSyncing = true
  if (bodyTimelineRef.value && headerTimelineRef.value) {
    bodyTimelineRef.value.scrollLeft = headerTimelineRef.value.scrollLeft
  }
  requestAnimationFrame(() => { isSyncing = false })
}

function onBodyVerticalScroll() {
  if (leftPanelRef.value && bodyTimelineRef.value) {
    leftPanelRef.value.scrollTop = bodyTimelineRef.value.scrollTop
  }
}

function onLeftPanelScroll() {
  if (bodyTimelineRef.value && leftPanelRef.value) {
    bodyTimelineRef.value.scrollTop = leftPanelRef.value.scrollTop
  }
}
</script>

<template>
  <div class="w-full flex flex-col gap-4">
    <!-- Toolbar -->
    <div class="flex flex-wrap items-center justify-between gap-3">
      <div class="flex items-center gap-2">
        <div class="relative">
          <Icon name="i-lucide-search" class="absolute left-2.5 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
          <Input v-model="searchQuery" placeholder="Search tasks or people..." class="pl-8 w-56" />
        </div>
        <Select v-model="filterStatus">
          <SelectTrigger class="w-36">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">
              All Status
            </SelectItem>
            <SelectItem value="completed">
              Completed
            </SelectItem>
            <SelectItem value="in-progress">
              In Progress
            </SelectItem>
            <SelectItem value="at-risk">
              At Risk
            </SelectItem>
            <SelectItem value="upcoming">
              Upcoming
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div class="flex items-center gap-2">
        <!-- View mode -->
        <div class="flex items-center rounded-lg border bg-muted/30 p-0.5">
          <button
            class="px-3 py-1.5 text-xs font-medium rounded-md transition-all"
            :class="viewMode === 'weeks' ? 'bg-background shadow-sm text-foreground' : 'text-muted-foreground hover:text-foreground'"
            @click="viewMode = 'weeks'"
          >
            Weeks
          </button>
          <button
            class="px-3 py-1.5 text-xs font-medium rounded-md transition-all"
            :class="viewMode === 'months' ? 'bg-background shadow-sm text-foreground' : 'text-muted-foreground hover:text-foreground'"
            @click="viewMode = 'months'"
          >
            Months
          </button>
        </div>
        <Button variant="outline" size="sm">
          <Icon name="i-lucide-download" class="mr-1 size-4" />
          Export
        </Button>
      </div>
    </div>

    <!-- Stats Row -->
    <div class="grid grid-cols-2 gap-3 md:grid-cols-5">
      <Card class="@container/stat">
        <CardContent class="flex items-center gap-3 p-4">
          <div class="flex items-center justify-center rounded-lg bg-primary/10 p-2">
            <Icon name="i-lucide-list-checks" class="size-4 text-primary" />
          </div>
          <div>
            <p class="text-2xl font-bold tabular-nums">
              {{ stats.total }}
            </p>
            <p class="text-xs text-muted-foreground">
              Total Tasks
            </p>
          </div>
        </CardContent>
      </Card>
      <Card class="@container/stat">
        <CardContent class="flex items-center gap-3 p-4">
          <div class="flex items-center justify-center rounded-lg bg-emerald-500/10 p-2">
            <Icon name="i-lucide-check-circle-2" class="size-4 text-emerald-500" />
          </div>
          <div>
            <p class="text-2xl font-bold tabular-nums text-emerald-600 dark:text-emerald-400">
              {{ stats.completed }}
            </p>
            <p class="text-xs text-muted-foreground">
              Completed
            </p>
          </div>
        </CardContent>
      </Card>
      <Card class="@container/stat">
        <CardContent class="flex items-center gap-3 p-4">
          <div class="flex items-center justify-center rounded-lg bg-blue-500/10 p-2">
            <Icon name="i-lucide-loader" class="size-4 text-blue-500" />
          </div>
          <div>
            <p class="text-2xl font-bold tabular-nums text-blue-600 dark:text-blue-400">
              {{ stats.inProgress }}
            </p>
            <p class="text-xs text-muted-foreground">
              In Progress
            </p>
          </div>
        </CardContent>
      </Card>
      <Card class="@container/stat">
        <CardContent class="flex items-center gap-3 p-4">
          <div class="flex items-center justify-center rounded-lg bg-amber-500/10 p-2">
            <Icon name="i-lucide-alert-triangle" class="size-4 text-amber-500" />
          </div>
          <div>
            <p class="text-2xl font-bold tabular-nums text-amber-600 dark:text-amber-400">
              {{ stats.atRisk }}
            </p>
            <p class="text-xs text-muted-foreground">
              At Risk
            </p>
          </div>
        </CardContent>
      </Card>
      <Card class="@container/stat col-span-2 md:col-span-1">
        <CardContent class="flex items-center gap-3 p-4">
          <div class="flex items-center justify-center rounded-lg bg-violet-500/10 p-2">
            <TrendingUp class="size-4 text-violet-500" />
          </div>
          <div>
            <p class="text-2xl font-bold tabular-nums text-violet-600 dark:text-violet-400">
              {{ stats.avgProgress }}%
            </p>
            <p class="text-xs text-muted-foreground">
              Avg. Progress
            </p>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Gantt Chart -->
    <Card class="overflow-hidden">
      <div class="flex border-b">
        <!-- Left panel header -->
        <div class="w-[320px] shrink-0 px-4 py-3 bg-muted/30 border-r flex items-center gap-2">
          <Icon name="i-lucide-folder-tree" class="size-4 text-muted-foreground" />
          <span class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Tasks</span>
        </div>
        <!-- Timeline header (synced with body) -->
        <div
          ref="headerTimelineRef"
          class="flex-1 overflow-x-auto gantt-scroll-header"
          @scroll="onHeaderScroll"
        >
          <div :style="{ width: `${timelineWidth}px` }" class="relative">
            <!-- Month labels -->
            <div class="flex border-b bg-muted/20">
              <div
                v-for="(mh, i) in monthHeaders"
                :key="i"
                class="text-xs font-semibold text-center py-2 border-r border-border/50"
                :style="{ position: 'absolute', left: `${mh.left}px`, width: `${mh.width}px` }"
              >
                {{ mh.label }}
              </div>
            </div>
            <!-- Week/day labels -->
            <div v-if="viewMode === 'weeks'" class="flex h-7 relative">
              <div
                v-for="(tm, i) in timeMarkers"
                :key="i"
                class="text-[10px] text-muted-foreground text-center border-r border-border/30 flex items-center justify-center"
                :style="{ position: 'absolute', left: `${tm.left}px`, width: `${tm.width}px` }"
              >
                {{ tm.label }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Body -->
      <div class="flex max-h-[600px]">
        <!-- Left panel: task list -->
        <div
          ref="leftPanelRef"
          class="w-[320px] shrink-0 border-r overflow-y-auto gantt-scroll-y"
          @scroll="onLeftPanelScroll"
        >
          <template v-for="phase in phases" :key="phase.id">
            <div
              v-if="getPhaseTasksFiltered(phase.id).length > 0"
            >
              <!-- Phase header -->
              <button
                class="w-full flex items-center gap-2 px-4 py-2.5 bg-muted/30 hover:bg-muted/50 transition-colors border-b cursor-pointer"
                @click="togglePhase(phase.id)"
              >
                <Icon
                  name="i-lucide-chevron-right"
                  class="size-3.5 text-muted-foreground transition-transform duration-200"
                  :class="{ 'rotate-90': phase.expanded }"
                />
                <div class="flex items-center justify-center rounded-md p-1" :class="`${phase.bgColor}/15`">
                  <Icon :name="phase.icon" class="size-3.5" :class="phase.color" />
                </div>
                <span class="text-xs font-semibold truncate">{{ phase.name }}</span>
                <Badge variant="secondary" class="ml-auto text-[10px] h-5 px-1.5">
                  {{ getPhaseTasksFiltered(phase.id).length }}
                </Badge>
              </button>

              <!-- Tasks -->
              <div v-show="phase.expanded" class="divide-y">
                <button
                  v-for="task in getPhaseTasksFiltered(phase.id)"
                  :key="task.id"
                  class="w-full flex items-center gap-2 px-4 py-2 hover:bg-muted/30 transition-colors cursor-pointer text-left"
                  :class="{ 'bg-primary/5': selectedTask?.id === task.id }"
                  @click="openTaskDetail(task)"
                >
                  <!-- Status dot -->
                  <div class="size-2 rounded-full shrink-0" :class="statusConfig[task.status]?.dot" />
                  <!-- Task info -->
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-1.5">
                      <Icon v-if="task.milestone" name="i-lucide-diamond" class="size-3 text-amber-500 shrink-0" />
                      <span class="text-xs font-medium truncate" :class="{ 'line-through text-muted-foreground': task.status === 'completed' }">
                        {{ task.name }}
                      </span>
                    </div>
                    <div class="flex items-center gap-1.5 mt-0.5">
                      <span class="text-[10px] text-muted-foreground font-mono">{{ task.id }}</span>
                      <span class="text-[10px] text-muted-foreground">·</span>
                      <span class="text-[10px] text-muted-foreground truncate">{{ task.assignee }}</span>
                    </div>
                  </div>
                  <!-- Progress -->
                  <div class="flex items-center gap-1.5 shrink-0">
                    <div class="w-10 h-1.5 rounded-full bg-muted overflow-hidden">
                      <div
                        class="h-full rounded-full transition-all duration-500"
                        :class="task.progress === 100 ? 'bg-emerald-500' : task.progress > 0 ? 'bg-blue-500' : 'bg-transparent'"
                        :style="{ width: `${task.progress}%` }"
                      />
                    </div>
                    <span class="text-[10px] text-muted-foreground tabular-nums w-7 text-right">{{ task.progress }}%</span>
                  </div>
                </button>
              </div>
            </div>
          </template>
        </div>

        <!-- Right panel: timeline bars (drives horizontal scroll) -->
        <div
          ref="bodyTimelineRef"
          class="flex-1 overflow-auto gantt-scroll"
          @scroll="onBodyScroll(); onBodyVerticalScroll()"
        >
          <div :style="{ width: `${timelineWidth}px` }" class="relative">
            <template v-for="phase in phases" :key="phase.id">
              <template v-if="getPhaseTasksFiltered(phase.id).length > 0">
                <!-- Phase row spacer -->
                <div class="h-[37px] border-b bg-muted/15 relative">
                  <!-- Phase bar (span of all tasks in phase) -->
                  <div
                    v-if="phase.expanded"
                    class="absolute top-[14px] h-[9px] rounded-full opacity-15"
                    :class="phase.bgColor"
                    :style="{
                      left: getTaskStyle(getPhaseTasksFiltered(phase.id)[0]!).left,
                      width: (() => {
                        const phaseTasks = getPhaseTasksFiltered(phase.id)
                        const minStart = Math.min(...phaseTasks.map(t => new Date(t.start).getTime()))
                        const maxEnd = Math.max(...phaseTasks.map(t => new Date(t.end).getTime()))
                        const days = Math.ceil((maxEnd - minStart) / (1000 * 60 * 60 * 24)) + 1
                        return `${days * dayWidth}px`
                      })(),
                    }"
                  />
                </div>

                <!-- Task bars -->
                <template v-if="phase.expanded">
                  <div
                    v-for="task in getPhaseTasksFiltered(phase.id)"
                    :key="task.id"
                    class="h-[33px] border-b relative group"
                    :class="{ 'bg-primary/[0.02]': selectedTask?.id === task.id }"
                  >
                    <!-- Grid lines for weeks -->
                    <template v-if="viewMode === 'weeks'">
                      <div
                        v-for="(tm, tmIdx) in timeMarkers"
                        :key="tmIdx"
                        class="absolute top-0 bottom-0 border-r border-border/10"
                        :style="{ left: `${tm.left + tm.width}px` }"
                      />
                    </template>

                    <!-- Today line -->
                    <div
                      class="absolute top-0 bottom-0 w-px bg-rose-500/60 z-10"
                      :style="{ left: `${todayOffset}px` }"
                    />

                    <!-- Task bar -->
                    <div
                      v-if="task.milestone"
                      class="absolute top-[6px] cursor-pointer z-20"
                      :style="getTaskStyle(task)"
                      @click="openTaskDetail(task)"
                    >
                      <!-- Milestone diamond -->
                      <div
                        class="size-5 rotate-45 rounded-sm shadow-lg border-2 border-background ring-2"
                        :style="{ 'backgroundColor': task.color, '--tw-ring-color': `${task.color}40` }"
                      />
                    </div>
                    <div
                      v-else
                      class="absolute top-[7px] h-[19px] rounded-full cursor-pointer z-20 group/bar transition-all hover:scale-y-125 hover:shadow-lg"
                      :class="getBarClasses(task)"
                      :style="{ ...getTaskStyle(task), backgroundColor: `${task.color}30`, border: `1.5px solid ${task.color}60` }"
                      @click="openTaskDetail(task)"
                    >
                      <!-- Progress fill -->
                      <div
                        class="absolute inset-0 rounded-full transition-all duration-700"
                        :style="{ width: `${task.progress}%`, backgroundColor: `${task.color}90` }"
                      />
                      <!-- Task name on hover -->
                      <div
                        class="absolute -top-7 left-1/2 -translate-x-1/2 px-2 py-1 rounded-md text-[10px] font-medium whitespace-nowrap opacity-0 group-hover/bar:opacity-100 transition-opacity bg-popover border shadow-lg z-30 pointer-events-none"
                      >
                        {{ task.name }} · {{ task.progress }}%
                      </div>
                    </div>
                  </div>
                </template>
              </template>
            </template>
          </div>
        </div>
      </div>

      <!-- Legend -->
      <div class="flex flex-wrap items-center gap-4 px-4 py-2.5 border-t bg-muted/20">
        <span class="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Legend:</span>
        <div v-for="(cfg, key) in statusConfig" :key="key" class="flex items-center gap-1.5">
          <div class="size-2 rounded-full" :class="cfg.dot" />
          <span class="text-[10px] text-muted-foreground">{{ cfg.label }}</span>
        </div>
        <div class="flex items-center gap-1.5">
          <div class="size-3 rotate-45 rounded-sm bg-amber-500" />
          <span class="text-[10px] text-muted-foreground">Milestone</span>
        </div>
        <div class="flex items-center gap-1.5">
          <div class="w-px h-4 bg-rose-500/60" />
          <span class="text-[10px] text-muted-foreground">Today</span>
        </div>
      </div>
    </Card>

    <!-- Task Detail Dialog -->
    <Dialog v-model:open="showDetail">
      <DialogContent class="sm:max-w-[520px]">
        <DialogHeader>
          <DialogTitle class="flex items-center gap-2">
            <Icon v-if="selectedTask?.milestone" name="i-lucide-diamond" class="size-4 text-amber-500" />
            {{ selectedTask?.name }}
          </DialogTitle>
          <DialogDescription>{{ selectedTask?.id }} — Task Details</DialogDescription>
        </DialogHeader>

        <div v-if="selectedTask" class="space-y-4">
          <!-- Status & Priority -->
          <div class="flex flex-wrap gap-2">
            <Badge variant="outline" :class="statusConfig[selectedTask!.status]?.class">
              <div class="size-1.5 rounded-full mr-1" :class="statusConfig[selectedTask!.status]?.dot" />
              {{ statusConfig[selectedTask!.status]?.label }}
            </Badge>
            <Badge variant="outline" :class="priorityConfig[selectedTask!.priority]?.class">
              {{ priorityConfig[selectedTask!.priority]?.label }} Priority
            </Badge>
          </div>

          <!-- Info grid -->
          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1">
              <p class="text-xs text-muted-foreground">
                Assignee
              </p>
              <div class="flex items-center gap-2">
                <div class="size-6 rounded-full flex items-center justify-center text-[10px] font-semibold" :class="getAvatarColor(selectedTask.assignee)">
                  {{ getInitials(selectedTask.assignee) }}
                </div>
                <span class="text-sm font-medium">{{ selectedTask.assignee }}</span>
              </div>
            </div>
            <div class="space-y-1">
              <p class="text-xs text-muted-foreground">
                Duration
              </p>
              <p class="text-sm font-medium">
                {{ getDuration(selectedTask.start, selectedTask.end) }}
              </p>
            </div>
            <div class="space-y-1">
              <p class="text-xs text-muted-foreground">
                Start Date
              </p>
              <p class="text-sm font-medium">
                {{ formatDate(selectedTask.start) }}
              </p>
            </div>
            <div class="space-y-1">
              <p class="text-xs text-muted-foreground">
                End Date
              </p>
              <p class="text-sm font-medium">
                {{ formatDate(selectedTask.end) }}
              </p>
            </div>
          </div>

          <!-- Progress -->
          <div class="space-y-2">
            <div class="flex items-center justify-between">
              <p class="text-xs text-muted-foreground">
                Progress
              </p>
              <span class="text-sm font-semibold tabular-nums">{{ selectedTask.progress }}%</span>
            </div>
            <Progress :model-value="selectedTask.progress" class="h-2" />
          </div>

          <!-- Dependencies -->
          <div v-if="selectedTask.dependencies?.length" class="space-y-1.5">
            <p class="text-xs text-muted-foreground">
              Dependencies
            </p>
            <div class="flex flex-wrap gap-1.5">
              <Badge v-for="dep in selectedTask.dependencies" :key="dep" variant="secondary" class="text-xs font-mono">
                {{ dep }} — {{ tasks.find(t => t.id === dep)?.name }}
              </Badge>
            </div>
          </div>

          <!-- Phase -->
          <div class="space-y-1">
            <p class="text-xs text-muted-foreground">
              Phase
            </p>
            <div class="flex items-center gap-2">
              <Icon :name="phases.find(p => p.id === selectedTask!.phase)?.icon || ''" class="size-4" :class="phases.find(p => p.id === selectedTask!.phase)?.color" />
              <span class="text-sm font-medium">{{ phases.find(p => p.id === selectedTask!.phase)?.name }}</span>
            </div>
          </div>
        </div>

        <DialogFooter class="gap-2">
          <Button variant="outline" @click="showDetail = false">
            Close
          </Button>
          <Button>
            <Icon name="i-lucide-pencil" class="mr-1 size-4" />
            Edit Task
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>

<style scoped>
.gantt-scroll::-webkit-scrollbar {
  height: 6px;
}
.gantt-scroll::-webkit-scrollbar-track {
  background: transparent;
}
.gantt-scroll::-webkit-scrollbar-thumb {
  background: hsl(var(--muted-foreground) / 0.2);
  border-radius: 3px;
}
.gantt-scroll::-webkit-scrollbar-thumb:hover {
  background: hsl(var(--muted-foreground) / 0.4);
}

/* Header timeline: scrollable but scrollbar hidden (synced via JS) */
.gantt-scroll-header {
  overflow-x: auto;
  scrollbar-width: none; /* Firefox */
  -ms-overflow-style: none; /* IE/Edge */
}
.gantt-scroll-header::-webkit-scrollbar {
  display: none; /* Chrome/Safari */
}

.gantt-scroll-y::-webkit-scrollbar {
  width: 4px;
}
.gantt-scroll-y::-webkit-scrollbar-track {
  background: transparent;
}
.gantt-scroll-y::-webkit-scrollbar-thumb {
  background: hsl(var(--muted-foreground) / 0.2);
  border-radius: 2px;
}

@keyframes pulse-subtle {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.animate-pulse-subtle {
  animation: pulse-subtle 2s ease-in-out infinite;
}
</style>
