import { defineConfig } from 'vite'

export default defineConfig({
  root: '.',
  base: '/packages/svelte/src/js/',
  build: {
    minify: false,
    outDir: 'lib/src/js',
    lib: {
      name: '$$',
      fileName: 'svelte',
      entry: 'src/svelte.js',
    }
  }
})
