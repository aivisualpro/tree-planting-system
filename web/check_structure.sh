#!/bin/bash
FILES=(
  "app/pages/login.vue"
  "app/pages/index.vue"
  "app/pages/visits/index.vue"
  "app/pages/visits/[id].vue"
  "app/pages/analytics/index.vue"
  "app/pages/analytics/countries.vue"
  "app/pages/analytics/species.vue"
  "app/pages/analytics/users.vue"
  "app/pages/masters/index.vue"
  "app/pages/masters/countries.vue"
  "app/pages/masters/subwatersheds.vue"
  "app/pages/masters/communities.vue"
  "app/pages/masters/groups.vue"
  "app/pages/masters/schools.vue"
  "app/pages/masters/churches.vue"
  "app/pages/masters/activities.vue"
  "app/pages/masters/species.vue"
  "app/pages/masters/translations.vue"
  "app/pages/users/index.vue"
  "app/pages/users/[id].vue"
  "app/pages/audit-log.vue"
  "app/pages/settings.vue"
  "app/components/dashboard/KpiCard.vue"
  "app/components/dashboard/TimelineChart.vue"
  "app/components/dashboard/CountryBreakdownChart.vue"
  "app/components/dashboard/TopSpeciesChart.vue"
  "app/components/dashboard/UserActivityHeatmap.vue"
  "app/components/visits/VisitFilters.vue"
  "app/components/visits/VisitTable.vue"
  "app/components/visits/VisitDetailDrawer.vue"
  "app/components/masters/ResourceTable.vue"
  "app/components/masters/ResourceForm.vue"
  "app/components/common/DataTable.vue"
  "app/components/common/DateRangePicker.vue"
  "app/components/common/CountryMultiSelect.vue"
  "app/components/common/ConfirmDialog.vue"
  "app/components/common/CsvImportDialog.vue"
  "app/composables/useApi.ts"
  "app/composables/useSupabase.ts"
  "app/composables/useEntityTranslation.ts"
  "app/composables/useRole.ts"
  "app/composables/useCsvExport.ts"
  "app/stores/auth.ts"
  "app/stores/filters.ts"
  "app/stores/translations.ts"
  "app/middleware/auth.global.ts"
  "app/middleware/role.ts"
  "app/utils/formatters.ts"
  "app/utils/validators.ts"
  "server/api/dashboard/kpis.get.ts"
  "server/api/dashboard/timeline.get.ts"
  "server/api/dashboard/country-breakdown.get.ts"
  "server/api/dashboard/top-species.get.ts"
  "server/api/dashboard/user-activity.get.ts"
  "server/api/admin/users.post.ts"
  "server/api/admin/translations-import.post.ts"
  "server/api/admin/export-visits.get.ts"
  "server/api/health.get.ts"
  "server/utils/supabase-server.ts"
  "server/utils/supabase-admin.ts"
  "server/utils/require-role.ts"
  "server/utils/errors.ts"
)

MISSING=()
for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    MISSING+=("$file")
  fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "All files present!"
else
  echo "Missing files:"
  for file in "${MISSING[@]}"; do
    echo "- $file"
  done
fi
