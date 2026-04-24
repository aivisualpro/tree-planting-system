import { useI18n } from '#imports'
import { isRef, onMounted, ref, unref, watchEffect } from 'vue'
import { useTranslationsStore } from '../stores/translations'

export async function useEntityTranslation(
  entityType: string,
  entityId: string | (() => string),
  field: string,
) {
  const store = useTranslationsStore()
  const { locale } = useI18n()
  const translatedValue = ref('')

  watchEffect(async () => {
    const id = unref(typeof entityId === 'function' ? entityId() : entityId)
    if (!id)
      return

    const currentLocale = locale.value

    // Try current locale
    let value = await store.fetchTranslation(entityType, id, field, currentLocale)

    if (!value && currentLocale !== 'en') {
      // Fallback to en
      value = await store.fetchTranslation(entityType, id, field, 'en')
    }

    if (value) {
      translatedValue.value = value
    }
    else {
      // Fallback to field name
      translatedValue.value = field
    }
  })

  return translatedValue
}
