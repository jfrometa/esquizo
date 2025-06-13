#!/usr/bin/env node

const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 5001;
const BUILD_DIR = path.join(__dirname, 'build', 'web');

// Serve static files from the build directory
app.use(express.static(BUILD_DIR));

// SPA fallback: serve index.html for all non-file routes
app.get('*', (req, res) => {
  const indexPath = path.join(BUILD_DIR, 'index.html');

  // Check if the requested path corresponds to a real file
  const requestedFile = path.join(BUILD_DIR, req.path);

  if (fs.existsSync(requestedFile) && fs.statSync(requestedFile).isFile()) {
    // If it's a real file, serve it
    res.sendFile(requestedFile);
  } else {
    // Otherwise, serve index.html (SPA routing)
    console.log(`SPA Route: ${req.path} -> index.html`);
    res.sendFile(indexPath);
  }
});

app.listen(PORT, () => {
  console.log(`🚀 SPA Server running at http://localhost:${PORT}`);
  console.log(`📁 Serving files from: ${BUILD_DIR}`);
  console.log(`🔄 All non-file routes will fallback to index.html`);
});
