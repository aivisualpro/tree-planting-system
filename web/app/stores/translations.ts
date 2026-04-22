import { defineStore } from 'pinia'

export const useTranslationsStore = defineStore('translations', {
  state: () => ({
    translations: {} as Record<string, string>,
    isLoaded: false,
  }),
  actions: {
    async fetchTranslations() {
      // Logic to fetch dynamic translations from DB
      this.isLoaded = true
    },
    getTranslation(key: string, defaultVal: string) {
      return this.translations[key] || defaultVal
    }
  }
})
