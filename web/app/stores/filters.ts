import { defineStore } from 'pinia'

export const useFiltersStore = defineStore('filters', {
  state: () => ({
    dateRange: { start: null as Date | null, end: null as Date | null },
    selectedCountries: [] as string[],
    selectedSpecies: [] as string[],
  }),
  actions: {
    setDateRange(start: Date | null, end: Date | null) {
      this.dateRange = { start, end }
    },
    setCountries(countries: string[]) {
      this.selectedCountries = countries
    },
    setSpecies(species: string[]) {
      this.selectedSpecies = species
    },
    reset() {
      this.dateRange = { start: null, end: null }
      this.selectedCountries = []
      this.selectedSpecies = []
    },
  },
})
