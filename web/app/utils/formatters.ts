import { format, parseISO } from 'date-fns'

export function formatDate(dateString?: string | null, formatStr = 'PPP') {
  if (!dateString)
    return '-'
  try {
    return format(parseISO(dateString), formatStr)
  }
  catch (e) {
    return dateString
  }
}

export function formatCurrency(amount?: number | null, currency = 'USD') {
  if (amount == null)
    return '-'
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount)
}
