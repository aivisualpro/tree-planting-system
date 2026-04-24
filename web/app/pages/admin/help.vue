<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { marked } from 'marked'

definePageMeta({
  layout: 'default',
  middleware: ['role']
})

const activeTab = ref('guide')
const guideHtml = ref('')

onMounted(async () => {
  // Fetch from a public URL or raw import. For now we simulate reading the markdown content.
  // In a real scenario, this would be an API endpoint that reads from shared/docs/
  const markdownText = `
# Admin User Guide
Welcome to the Tree-Planting System Administration Portal.

## User Management
- Ensure new field users are assigned to the correct country.
- If a user needs retraining, you can toggle the **Training Required** flag on their profile. This will force them into Training Mode on their device.

## Resolving Sync Issues
- Monitor the **Conflicts** and **Audit Log** tabs.
- If a user reports an issue, check the support requests sent via the mobile app.

## Approving Visits
- Review incoming visits under Data Quality.
- Ensure photos and signatures are legible.
  `
  guideHtml.value = await marked.parse(markdownText)
})
</script>

<template>
  <div class="space-y-6 max-w-5xl mx-auto">
    <div class="flex items-center justify-between">
      <h1 class="text-2xl font-semibold tracking-tight">Help & Training Center</h1>
      <p class="text-sm text-gray-500">For Platform Administrators</p>
    </div>

    <!-- Tabs -->
    <div class="border-b border-gray-200">
      <nav class="-mb-px flex space-x-8" aria-label="Tabs">
        <button
          @click="activeTab = 'guide'"
          :class="[
            activeTab === 'guide'
              ? 'border-green-500 text-green-600'
              : 'border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700',
            'whitespace-nowrap border-b-2 py-4 px-1 text-sm font-medium'
          ]"
        >
          Admin Guide
        </button>
        <button
          @click="activeTab = 'videos'"
          :class="[
            activeTab === 'videos'
              ? 'border-green-500 text-green-600'
              : 'border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700',
            'whitespace-nowrap border-b-2 py-4 px-1 text-sm font-medium'
          ]"
        >
          Video Walkthroughs
        </button>
        <button
          @click="activeTab = 'roles'"
          :class="[
            activeTab === 'roles'
              ? 'border-green-500 text-green-600'
              : 'border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700',
            'whitespace-nowrap border-b-2 py-4 px-1 text-sm font-medium'
          ]"
        >
          Role-Specific Guides
        </button>
      </nav>
    </div>

    <!-- Tab Contents -->
    <div v-if="activeTab === 'guide'" class="bg-white p-6 rounded-lg shadow-sm ring-1 ring-gray-900/5 prose max-w-none">
      <div v-html="guideHtml"></div>
    </div>

    <div v-if="activeTab === 'videos'" class="space-y-6">
      <div class="bg-white p-6 rounded-lg shadow-sm ring-1 ring-gray-900/5">
        <h3 class="text-lg font-medium mb-4">Onboarding Field Users</h3>
        <div class="aspect-w-16 aspect-h-9 relative h-64 bg-gray-100 flex items-center justify-center rounded-lg overflow-hidden">
          <iframe 
            class="absolute top-0 left-0 w-full h-full"
            src="https://www.youtube.com/embed/dQw4w9WgXcQ?cc_load_policy=1" 
            title="Training Video" 
            frameborder="0" 
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
            allowfullscreen>
          </iframe>
        </div>
      </div>
      
      <div class="bg-white p-6 rounded-lg shadow-sm ring-1 ring-gray-900/5">
        <h3 class="text-lg font-medium mb-4">Reviewing Data Quality</h3>
        <div class="aspect-w-16 aspect-h-9 relative h-64 bg-gray-100 flex items-center justify-center rounded-lg overflow-hidden">
          <p class="text-gray-500 italic">Video coming soon...</p>
        </div>
      </div>
    </div>

    <div v-if="activeTab === 'roles'" class="space-y-4">
      <div class="bg-white p-6 rounded-lg shadow-sm ring-1 ring-gray-900/5">
        <h3 class="text-lg font-medium text-gray-900">Regional Manager</h3>
        <p class="text-gray-600 mt-2">Learn how to extract region-specific PDF and Excel reports, monitor sync statuses of your team, and resolve data conflicts.</p>
        <button class="mt-4 text-green-600 font-medium hover:text-green-700">Read the Manager Guide &rarr;</button>
      </div>

      <div class="bg-white p-6 rounded-lg shadow-sm ring-1 ring-gray-900/5">
        <h3 class="text-lg font-medium text-gray-900">Compliance Officer</h3>
        <p class="text-gray-600 mt-2">Guide to GDPR data requests, anonymization procedures, and handling DPA audits for Tanzania and Malawi.</p>
        <button class="mt-4 text-green-600 font-medium hover:text-green-700">Read the Compliance Guide &rarr;</button>
      </div>
    </div>
  </div>
</template>
