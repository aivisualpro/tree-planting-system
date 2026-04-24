// Supabase Storage image transformation provider for @nuxt/image (§8)
// Leverages built-in image transformation API to serve WebP thumbnails.
//
// Usage in templates:
//   <NuxtImg provider="supabase" src="visit-media/path/to/image.jpg" :width="300" />
//
// This generates: <SUPABASE_URL>/storage/v1/render/image/public/visit-media/path/...?width=300&format=webp

declare const process: { env: Record<string, string> }

const SUPABASE_URL = process.env.SUPABASE_URL || ''

export function getImage(src: string, { modifiers = {}, baseURL = SUPABASE_URL }: { modifiers?: Record<string, any>, baseURL?: string } = {}) {
  const {
    width,
    height,
    quality = 80,
    format = 'webp',
    fit = 'cover',
  } = modifiers

  // Build Supabase Storage transform URL
  const params = new URLSearchParams()
  if (width)
    params.set('width', String(width))
  if (height)
    params.set('height', String(height))
  if (quality)
    params.set('quality', String(quality))
  if (format)
    params.set('format', format)
  if (fit)
    params.set('resize', fit)

  const transformPath = src.startsWith('/') ? src : `/${src}`
  const queryString = params.toString()

  return {
    url: `${baseURL}/storage/v1/render/image/public${transformPath}${queryString ? `?${queryString}` : ''}`,
  }
}
