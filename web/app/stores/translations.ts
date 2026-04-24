import { defineStore } from 'pinia';
import { useSupabaseClient } from '#imports';

export const useTranslationsStore = defineStore('translations', {
  state: () => ({
    cache: {} as Record<string, string>,
  }),
  actions: {
    getCacheKey(entityType: string, entityId: string, field: string, locale: string) {
      return `${entityType}:${entityId}:${field}:${locale}`;
    },
    async fetchTranslation(entityType: string, entityId: string, field: string, locale: string): Promise<string | null> {
      const key = this.getCacheKey(entityType, entityId, field, locale);
      if (this.cache[key] !== undefined) {
        return this.cache[key];
      }

      const supabase = useSupabaseClient();
      const { data, error } = await supabase
        .from('translations')
        .select('value')
        .eq('entity_type', entityType)
        .eq('entity_id', entityId)
        .eq('field', field)
        .eq('locale', locale)
        .maybeSingle();

      if (!error && data) {
        this.cache[key] = data.value;
        return data.value;
      }

      this.cache[key] = ''; // cache miss
      return null;
    },
    setTranslation(entityType: string, entityId: string, field: string, locale: string, value: string) {
      const key = this.getCacheKey(entityType, entityId, field, locale);
      this.cache[key] = value;
    }
  }
});
