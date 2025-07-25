import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false, // Disable source maps completely
    minify: 'esbuild', // Use esbuild instead of terser
    target: 'es2015',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          icons: ['lucide-react']
        },
        // Clean file naming to prevent conflicts
        chunkFileNames: 'assets/[name]-[hash].js',
        entryFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash].[ext]'
      }
    }
  },
  base: '/',
  // Optimize dependencies to prevent JS issues
  optimizeDeps: {
    include: ['react', 'react-dom', 'lucide-react'],
    force: true
  },
  // Fix module resolution
  resolve: {
    alias: {
      '@': '/src'
    }
  },
  // Prevent CSS-in-JS issues
  css: {
    postcss: './postcss.config.js'
  }
});
