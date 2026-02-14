#!/usr/bin/env node
/**
 * html2images.js - Convert infographic HTML to multiple PNG images
 * 
 * Usage: node html2images.js <input.html> <output-dir>
 * 
 * Splits the HTML by section-divider elements and captures each section as a PNG.
 * Falls back to viewport-based splitting if no section dividers found.
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function html2images(inputHtml, outputDir) {
  // Ensure output directory exists
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // Read HTML file
  const htmlContent = fs.readFileSync(inputHtml, 'utf8');

  // Launch browser
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  
  // Set viewport width for consistent rendering
  await page.setViewport({ width: 800, height: 1200, deviceScaleFactor: 2 });

  // Load HTML
  if (inputHtml.startsWith('http')) {
    await page.goto(inputHtml, { waitUntil: 'networkidle0' });
  } else {
    const absolutePath = path.resolve(inputHtml);
    await page.goto(`file://${absolutePath}`, { waitUntil: 'networkidle0' });
  }

  // Wait for fonts to load
  await page.waitForFunction(() => document.fonts.ready);
  await new Promise(r => setTimeout(r, 1000)); // Extra wait for font rendering

  // Get section boundaries
  const sections = await page.evaluate(() => {
    const container = document.querySelector('.container');
    if (!container) return [];

    const elements = container.children;
    const sections = [];
    let currentSection = { start: 0, elements: [] };
    
    // Find all section dividers and group content
    for (let i = 0; i < elements.length; i++) {
      const el = elements[i];
      
      if (el.classList.contains('section-divider')) {
        // Save previous section if it has content
        if (currentSection.elements.length > 0) {
          const firstEl = currentSection.elements[0];
          const lastEl = currentSection.elements[currentSection.elements.length - 1];
          sections.push({
            top: firstEl.offsetTop - 20,
            height: (lastEl.offsetTop + lastEl.offsetHeight) - firstEl.offsetTop + 40
          });
        }
        // Start new section with the divider
        currentSection = { elements: [el] };
      } else {
        currentSection.elements.push(el);
      }
    }
    
    // Add final section
    if (currentSection.elements.length > 0) {
      const firstEl = currentSection.elements[0];
      const lastEl = currentSection.elements[currentSection.elements.length - 1];
      sections.push({
        top: firstEl.offsetTop - 20,
        height: (lastEl.offsetTop + lastEl.offsetHeight) - firstEl.offsetTop + 40
      });
    }

    return sections;
  });

  const images = [];

  if (sections.length > 1) {
    // Capture each section as a separate image
    console.log(`Found ${sections.length} sections, capturing each...`);
    
    for (let i = 0; i < sections.length; i++) {
      const section = sections[i];
      const outputPath = path.join(outputDir, `slide-${String(i + 1).padStart(2, '0')}.png`);
      
      // Set viewport to section height
      await page.setViewport({ 
        width: 800, 
        height: Math.ceil(section.height) + 40,
        deviceScaleFactor: 2 
      });

      // Scroll to section and capture
      await page.evaluate((top) => window.scrollTo(0, top), section.top);
      await new Promise(r => setTimeout(r, 200));

      await page.screenshot({
        path: outputPath,
        clip: {
          x: 0,
          y: 0,
          width: 800,
          height: Math.min(section.height + 40, 2000) // Cap height
        }
      });

      images.push(outputPath);
      console.log(`  Saved: ${outputPath}`);
    }
  } else {
    // Fallback: capture by viewport chunks
    console.log('No section dividers found, using viewport-based splitting...');
    
    const fullHeight = await page.evaluate(() => document.body.scrollHeight);
    const chunkHeight = 1200;
    let slideNum = 1;

    for (let y = 0; y < fullHeight; y += chunkHeight) {
      const outputPath = path.join(outputDir, `slide-${String(slideNum).padStart(2, '0')}.png`);
      
      await page.evaluate((scrollY) => window.scrollTo(0, scrollY), y);
      await new Promise(r => setTimeout(r, 200));

      const captureHeight = Math.min(chunkHeight, fullHeight - y);
      
      await page.screenshot({
        path: outputPath,
        clip: { x: 0, y: 0, width: 800, height: captureHeight }
      });

      images.push(outputPath);
      console.log(`  Saved: ${outputPath}`);
      slideNum++;
    }
  }

  await browser.close();
  
  console.log(`\nDone! Created ${images.length} images in ${outputDir}`);
  return images;
}

// CLI
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.log('Usage: node html2images.js <input.html> <output-dir>');
    console.log('Example: node html2images.js /tmp/infographic.html /tmp/output');
    process.exit(1);
  }

  const [inputHtml, outputDir] = args;

  if (!fs.existsSync(inputHtml)) {
    console.error(`Error: Input file not found: ${inputHtml}`);
    process.exit(1);
  }

  html2images(inputHtml, outputDir)
    .then(() => process.exit(0))
    .catch(err => {
      console.error('Error:', err);
      process.exit(1);
    });
}

module.exports = { html2images };
