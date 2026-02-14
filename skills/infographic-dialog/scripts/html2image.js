#!/usr/bin/env node
/**
 * html2image.js - Convert infographic HTML to a SINGLE full-page PNG
 * 
 * Usage: node html2image.js <input.html> <output.png>
 * 
 * Captures the entire page as one seamless image.
 * 
 * KNOWN ISSUE: CSS `background-attachment: fixed` and default body background
 * gradients cause content duplication on long pages in Puppeteer.
 * This script injects CSS overrides to prevent that.
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function html2image(inputHtml, outputPath) {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-gpu']
  });

  const page = await browser.newPage();
  
  // Set viewport width to 690px (WeChat optimized)
  await page.setViewport({ width: 690, height: 800, deviceScaleFactor: 2 });

  // Load HTML
  if (inputHtml.startsWith('http')) {
    await page.goto(inputHtml, { waitUntil: 'networkidle0', timeout: 60000 });
  } else {
    const absolutePath = path.resolve(inputHtml);
    await page.goto(`file://${absolutePath}`, { waitUntil: 'networkidle0', timeout: 60000 });
  }

  // Wait for fonts to load
  await page.waitForFunction(() => document.fonts.ready);
  await new Promise(r => setTimeout(r, 2000));

  // Step 1: Measure the actual content height
  const contentHeight = await page.evaluate(() => {
    const container = document.querySelector('.container');
    if (!container) return document.body.scrollHeight;
    
    // Get all children and find the bottom of the last one
    const children = container.children;
    if (children.length === 0) return container.scrollHeight;
    
    const lastChild = children[children.length - 1];
    const lastRect = lastChild.getBoundingClientRect();
    // Add some padding at the bottom
    return Math.ceil(lastRect.bottom + 30);
  });

  console.log('Content height:', contentHeight);

  // Step 2: Inject CSS overrides via <style> tag (more reliable than inline styles)
  // This prevents background gradient from repeating on long pages
  await page.evaluate((height) => {
    const style = document.createElement('style');
    style.textContent = `
      html {
        background: #24243e !important;
        height: ${height}px !important;
        overflow: hidden !important;
      }
      body {
        background-size: 100% ${height}px !important;
        background-repeat: no-repeat !important;
        background-attachment: scroll !important;
        height: ${height}px !important;
        max-height: ${height}px !important;
        min-height: unset !important;
        overflow: hidden !important;
      }
    `;
    document.head.appendChild(style);
  }, contentHeight);

  await new Promise(r => setTimeout(r, 500));

  // Step 3: Set viewport to exact content size
  await page.setViewport({
    width: 690,
    height: contentHeight,
    deviceScaleFactor: 2
  });

  await new Promise(r => setTimeout(r, 300));

  // Step 4: Take screenshot with clip (NOT fullPage)
  await page.screenshot({
    path: outputPath,
    type: 'png',
    fullPage: false,
    clip: {
      x: 0,
      y: 0,
      width: 690,
      height: contentHeight
    }
  });

  // Check file size
  const stats = fs.statSync(outputPath);
  const fileSizeMB = stats.size / (1024 * 1024);
  
  console.log(`Saved: ${outputPath}`);
  console.log(`Size: ${fileSizeMB.toFixed(2)} MB`);
  
  if (fileSizeMB > 10) {
    console.warn(`⚠️  Warning: File exceeds 10MB limit (${fileSizeMB.toFixed(2)} MB)`);
  }

  await browser.close();
  return outputPath;
}

// CLI
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.log('Usage: node html2image.js <input.html> <output.png>');
    process.exit(1);
  }

  const [inputHtml, outputPath] = args;

  if (!fs.existsSync(inputHtml)) {
    console.error(`Error: Input file not found: ${inputHtml}`);
    process.exit(1);
  }

  html2image(inputHtml, outputPath)
    .then(() => process.exit(0))
    .catch(err => {
      console.error('Error:', err);
      process.exit(1);
    });
}

module.exports = { html2image };
