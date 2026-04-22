<script setup lang="ts">
defineProps<{
  reverse?: boolean
}>()
</script>

<template>
  <div
    class="relative flex items-center justify-center px-4 h-dvh lg:max-w-none lg:px-0"
    :class="{ 'flex-row-reverse': reverse }"
  >
    <div class="relative hidden h-full flex-1 flex-col bg-muted p-10 text-white lg:flex dark:border-r">
      <div class="absolute inset-0 bg-zinc-900 flex flex-col items-center justify-center p-8">
        <img src="/logo.png" alt="Tree Planting System Logo" class="max-w-md w-full h-auto object-contain drop-shadow-2xl mb-8" />
      </div>
      <div class="relative z-20 flex items-center text-lg font-medium gap-2">
        Tree Planting System
      </div>
      <div class="relative z-20 mt-auto">
        <blockquote class="space-y-2">
          <p class="text-lg">
            &ldquo;Empowering communities through sustainable agroforestry. Every tree planted is a step towards a greener future.&rdquo;
          </p>
          <footer class="text-sm text-zinc-300">
            Global Reforestation Initiative
          </footer>
        </blockquote>
      </div>
    </div>
    <div class="mx-auto flex-1 lg:p-8">
      <slot />
    </div>
  </div>
</template>
