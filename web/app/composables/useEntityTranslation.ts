import { useTranslationsStore } from '~/stores/translations'

export const useEntityTranslation = () => {
  const store = useTranslationsStore()
  
  const translate = (key: string, fallback: string) => {
    return store.getTranslation(key, fallback)
  }
  
  return { translate }
}
