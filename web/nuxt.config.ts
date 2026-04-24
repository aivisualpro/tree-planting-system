import tailwindcss from '@tailwindcss/vite'
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: false },
  spaLoadingTemplate: false,

  build: {
    transpile: [
      '@supabase/supabase-js',
      '@supabase/ssr',
      '@supabase/auth-js',
      '@supabase/storage-js',
      '@supabase/realtime-js',
      '@supabase/functions-js',
    ],
  },

  watch: ['~/app.config.ts'],

  css: ['~/assets/css/tailwind.css'],
  vite: {
    logLevel: 'error',
    plugins: [
      tailwindcss(),
    ],
    optimizeDeps: {
      include: ['cookie', '@supabase/ssr'],
      exclude: ['@supabase/postgrest-js'],
    },
    resolve: {
      alias: {
        cookie: 'cookie-es',
        // §7 – tree-shake lodash: force named-function imports
        lodash: 'lodash-es',
      },
    },
    build: {
      // §7 – bundle analysis + chunk splitting
      chunkSizeWarningLimit: 200, // warn if any chunk > 200 KB
      rollupOptions: {
        onwarn(warning, warn) {
          if (warning.message.includes('"PostgrestError"') || warning.message.includes('@supabase'))
            return
          warn(warning)
        },
        output: {
          manualChunks(id) {
            // §7 – move ECharts into its own async chunk (lazy-loaded)
            if (id.includes('echarts') || id.includes('zrender')) {
              return 'echarts'
            }
            // Vendor split
            if (id.includes('node_modules/@supabase'))
              return 'supabase'
            if (id.includes('node_modules/date-fns'))
              return 'date-fns'
            if (id.includes('node_modules/zod'))
              return 'zod'
          },
        },
      },
    },
    server: {
      watch: {
        usePolling: true,
        interval: 1000,
        ignored: ['**/node_modules/**', '**/.git/**'],
      },
      fs: {
        allow: ['..'],
      },
    },
  },

  hooks: {
    'nitro:build:before': function (nitro) {
      nitro.options.rollupConfig = nitro.options.rollupConfig || ({} as any)
      const originalOnWarn = nitro.options.rollupConfig!.onwarn
      nitro.options.rollupConfig!.onwarn = (warning, warn) => {
        if (warning.message.includes('"PostgrestError"'))
          return
        if (warning.code === 'CIRCULAR_DEPENDENCY')
          return
        if (originalOnWarn) {
          originalOnWarn(warning, warn)
        }
        else {
          warn(warning)
        }
      }
    },
  },

  components: [
    {
      path: '~/components',
      extensions: ['.vue'],
    },
  ],

  modules: [
    'shadcn-nuxt',
    '@vueuse/nuxt',
    '@nuxt/eslint',
    '@nuxt/icon',
    '@pinia/nuxt',
    '@nuxtjs/color-mode',
    '@nuxt/fonts',
    '@nuxt/image', // §8 – responsive images + webp
    '@nuxtjs/supabase',
    '@nuxtjs/i18n',
    'nuxt-security',
  ],

  // §8 – @nuxt/image configuration
  image: {
    quality: 80,
    format: ['webp', 'avif', 'jpeg'],
    screens: {
      xs: 320,
      sm: 640,
      md: 768,
      lg: 1024,
      xl: 1280,
    },
    // Supabase Storage image transformations (§8)
    providers: {
      supabase: {
        name: 'supabase',
        provider: '~/providers/supabase-image.ts',
      },
    },
  },

  supabase: {
    redirect: true,
    redirectOptions: {
      login: '/login',
      callback: '/confirm',
      exclude: ['/register', '/forgot-password', '/otp'],
    },
  },

  i18n: {
    strategy: 'no_prefix',
    defaultLocale: 'en',
    langDir: '../../shared/i18n/',
    locales: [
      { code: 'en', file: 'en.json' },
      { code: 'es', file: 'es.json' },
      { code: 'sw', file: 'sw.json' },
    ],
  },

  shadcn: {
    prefix: '',
    componentDir: '~/components/ui',
  },

  colorMode: {
    classSuffix: '',
  },

  eslint: {
    config: {
      standalone: false,
    },
  },

  fonts: {
    defaults: {
      weights: [300, 400, 500, 600, 700, 800],
    },
  },

  // §11 – ISR + route-level optimizations
  routeRules: {
    '/components': { redirect: '/components/accordion' },
    '/settings': { redirect: '/settings/profile' },

    // §11 – ISR for dashboard (revalidate every 60 s, CDN-cached)
    '/dashboard': { isr: 60, prerender: false },

    // §11 – visits list: short ISR + cache headers
    '/visits': { isr: 30 },

    // Static assets: long cache
    '/_nuxt/**': { headers: { 'cache-control': 's-maxage=31536000,immutable' } },

    // API routes: no-store, fine-grained caching in handler
    '/api/**': { headers: { 'cache-control': 'no-store' } },
  },

  runtimeConfig: {
    serviceRoleKey: process.env.SUPABASE_SERVICE_KEY,
    axiomApiKey: process.env.AXIOM_API_KEY,
    axiomDataset: process.env.AXIOM_DATASET || 'tree-planting-prod',
    public: {
      // public configs go here
    },
  },

  // @ts-ignore - Module types not loaded
  security: {
    headers: {
      contentSecurityPolicy: {
        'default-src': ['\'self\''],
        'connect-src': [
          '\'self\'',
          'http://127.0.0.1:54321',
          'ws://127.0.0.1:54321',
          'http://localhost:54321',
          'ws://localhost:54321',
          'https://*.supabase.co',
          'wss://*.supabase.co',
          'https://api.axiom.co',
        ],
        'base-uri': ['\'self\''],
        'font-src': ['\'self\'', 'https:', 'data:'],
        'form-action': ['\'self\''],
        'frame-ancestors': ['\'none\''],
        'img-src': ['\'self\'', 'data:', 'https:', 'blob:'],
        'object-src': ['\'none\''],
        'script-src-attr': ['\'none\''],
        'style-src': ['\'self\'', 'https:', '\'unsafe-inline\''],
        'script-src': ['\'self\'', 'https:', '\'unsafe-inline\'', '\'strict-dynamic\'', '\'nonce-{{nonce}}\''],
        'upgrade-insecure-requests': true,
      },
      xFrameOptions: 'DENY',
      referrerPolicy: 'strict-origin-when-cross-origin',
      strictTransportSecurity: {
        maxAge: 31536000,
        includeSubdomains: true,
        preload: true,
      },
    },
    corsHandler: {
      origin: [
        'https://tree-planting-system.aivisualpro.com',
        'https://staging.tree-planting-system.aivisualpro.com',
        'http://localhost:3000',
      ],
      methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE'],
    },
  },

  imports: {
    dirs: [
      './lib',
    ],
  },

  compatibilityDate: '2024-12-14',
})
