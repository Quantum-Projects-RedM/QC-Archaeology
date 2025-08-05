import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

// Wait for jQuery and turn.js to be available (loaded via CDN)
const waitForDependencies = () => {
  return new Promise((resolve) => {
    const checkDependencies = () => {
      if (window.$ && window.jQuery && window.$.fn.turn) {
        resolve();
      } else {
        setTimeout(checkDependencies, 100);
      }
    };
    checkDependencies();
  });
};

// Mock GetParentResourceName for development
if (!window.GetParentResourceName) {
  window.GetParentResourceName = () => 'qc-archaeology';
}

// Initialize React app after all dependencies are loaded
waitForDependencies().then(() => {
  const container = document.getElementById('root');
  const root = createRoot(container);
  root.render(<App />);
});