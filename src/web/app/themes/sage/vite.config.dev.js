import { defineConfig } from 'vite';
import configBase from './vite.config.js';

export default defineConfig(({ command }) => {
  const hmrHost = process.env.VITE_HMR_HOST || 'localhost';
  const hmrProtocol = process.env.VITE_HMR_PROTOCOL || 'ws';
  const hmrPort = process.env.VITE_HMR_PORT || '5173';

  configBase.server = {
    host: '0.0.0.0',
    port: 3000,
    hmr: {
      protocol: hmrProtocol,
      host: hmrHost,
      port: parseInt(hmrPort),
    },
    origin: `${hmrProtocol}://${hmrHost}:${hmrPort}`,
  }

  if (command === 'serve') {
    configBase.base = '/app/themes/sage/public/build';
  }

  return configBase;
});