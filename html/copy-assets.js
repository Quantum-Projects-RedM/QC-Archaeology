const fs = require('fs');
const path = require('path');

// Copy assets from src to dist after webpack build
const copyAssets = () => {
  const srcDir = path.join(__dirname, 'src');
  const distDir = path.join(__dirname, 'dist');
  
  console.log('Copying assets to dist...');
  
  // Copy img directory
  if (fs.existsSync(path.join(srcDir, 'img'))) {
    fs.cpSync(path.join(srcDir, 'img'), path.join(distDir, 'img'), { recursive: true });
    console.log('✓ Images copied');
  }
  
  // Copy turn.js
  if (fs.existsSync(path.join(srcDir, 'turn.min.js'))) {
    fs.copyFileSync(path.join(srcDir, 'turn.min.js'), path.join(distDir, 'turn.min.js'));
    console.log('✓ turn.min.js copied');
  }
  
  // Copy pageturn.mp3 audio file
  if (fs.existsSync(path.join(srcDir, 'pageturn.mp3'))) {
    fs.copyFileSync(path.join(srcDir, 'pageturn.mp3'), path.join(distDir, 'pageturn.mp3'));
    console.log('✓ pageturn.mp3 copied');
  }
  
  console.log('Assets copied successfully!');
};

// Run if called directly
if (require.main === module) {
  copyAssets();
}