export const useApi = () => {
  return {
    async get<T = any>(url: string, params?: Record<string, any>) {
      return await $fetch<T>(url, { params })
    },
    async post<T = any>(url: string, body: any) {
      return await $fetch<T>(url, { method: 'POST', body })
    },
    async put<T = any>(url: string, body: any) {
      return await $fetch<T>(url, { method: 'PUT', body })
    },
    async del<T = any>(url: string) {
      return await $fetch<T>(url, { method: 'DELETE' })
    }
  }
}
