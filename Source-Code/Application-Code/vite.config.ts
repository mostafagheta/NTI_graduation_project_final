/// <reference types="vitest" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ mode }) => {
  // Vitest عادة بيحط env اسمها VITEST أثناء التشغيل
  const isVitest = !!process.env.VITEST || mode === 'test'

  return {
    plugins: [
      // أثناء test: اقفلي react-refresh
      isVitest ? react({ fastRefresh: false }) : react(),
    ],

    test: {
      globals: true,
      environment: 'jsdom',
      setupFiles: ['src/setupTests.ts'],
      coverage: {
        provider: 'v8',
        reporter: ['text', 'lcov'],
        reportsDirectory: 'coverage'
      }
    }
  }
})
