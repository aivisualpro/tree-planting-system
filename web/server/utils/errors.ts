import { H3Error, createError } from 'h3'

export const handleApiError = (error: unknown, defaultMessage = 'Internal Server Error'): H3Error => {
  if (error instanceof H3Error) {
    return error
  }
  console.error('[API Error]', error)
  return createError({
    statusCode: 500,
    statusMessage: defaultMessage,
    data: error,
  })
}
