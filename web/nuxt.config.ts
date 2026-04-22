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
      exclude: ['@supabase/postgrest-js']
    },
    resolve: {
      alias: {
        cookie: 'cookie-es'
      }
    },
    build: {
      rollupOptions: {
        onwarn(warning, warn) {
          if (warning.message.includes('"PostgrestError"') || warning.message.includes('@supabase')) return
          warn(warning)
        }
      }
    },
    server: {
      watch: {
        usePolling: true,
        interval: 1000,
        ignored: ['**/node_modules/**', '**/.git/**'],
      },
      fs: {
        allow: ['..']
      },
    },
  },

  hooks: {
    'nitro:build:before'(nitro) {
      nitro.options.rollupConfig = nitro.options.rollupConfig || ({} as any)
      const originalOnWarn = nitro.options.rollupConfig!.onwarn
      nitro.options.rollupConfig!.onwarn = (warning, warn) => {
        if (warning.message.includes('"PostgrestError"')) return
        if (warning.code === 'CIRCULAR_DEPENDENCY') return
        if (originalOnWarn) {
          originalOnWarn(warning, warn)
        } else {
          warn(warning)
        }
      }
    }
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
    '@nuxtjs/supabase',
    '@nuxtjs/i18n',
  ],

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
      { code: 'sw', file: 'sw.json' }
    ]
  },

  shadcn: {
    /**
     * Prefix for all the imported component
     */
    prefix: '',
    /**
     * Directory that the component lives in.
     * @default "~/components/ui"
     */
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

  routeRules: {
    '/components': { redirect: '/components/accordion' },
    '/settings': { redirect: '/settings/profile' },
  },

  imports: {
    dirs: [
      './lib',
    ],
  },

  compatibilityDate: '2024-12-14',
})
