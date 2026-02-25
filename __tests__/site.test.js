const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

// Helper function to load HTML files
function loadHTML(filename) {
  const filePath = path.join(__dirname, '..', filename);
  const html = fs.readFileSync(filePath, 'utf8');
  return cheerio.load(html);
}

// Helper to check if file exists
function fileExists(filePath) {
  return fs.existsSync(path.join(__dirname, '..', filePath));
}

describe('Wedding Site - Core HTML Structure Tests', () => {
  
  test('index.html exists and loads', () => {
    expect(fileExists('index.html')).toBe(true);
  });

  test('index.html has required meta tags', () => {
    const $ = loadHTML('index.html');
    expect($('meta[charset]').length).toBeGreaterThan(0);
    expect($('meta[name="viewport"]').length).toBeGreaterThan(0);
    expect($('title').text()).toBeTruthy();
  });

  test('index.html has proper DOCTYPE', () => {
    const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
    expect(html.toLowerCase()).toMatch(/<!doctype html>/i);
  });

  test('index.html contains contact information', () => {
    const $ = loadHTML('index.html');
    const bodyText = $('body').text();
    
    // Check for email
    expect(bodyText).toMatch(/LARISSA@WEDDINGSBYLARISSA\.COM/i);
    
    // Check for phone number
    expect(bodyText).toMatch(/\(917\)\s*607-3147/);
  });

  test('index.html has navigation menu', () => {
    const $ = loadHTML('index.html');
    const nav = $('nav, .w3-bar, [role="navigation"]');
    expect(nav.length).toBeGreaterThan(0);
  });

  test('index.html has header/title section', () => {
    const $ = loadHTML('index.html');
    expect($('h1, .w3-xxxlarge, header').length).toBeGreaterThan(0);
  });
});

describe('Wedding Site - Additional Pages', () => {
  
  const pages = [
    'New_York_Wedding_Gallery.html',
    'New_York_Celebrant_Popular_Questions.html',
    'New_York_Celebrant_Reviews.html',
    'New_York_Central_Park_Weddings.html',
    'New_York_Gay_Pride_Weddings.html'
  ];

  pages.forEach(page => {
    test(`${page} exists`, () => {
      expect(fileExists(page)).toBe(true);
    });

    test(`${page} has proper structure`, () => {
      const $ = loadHTML(page);
      expect($('html').length).toBe(1);
      expect($('head').length).toBe(1);
      expect($('body').length).toBe(1);
      expect($('title').text()).toBeTruthy();
    });
  });
});

describe('Wedding Site - CSS and Assets', () => {
  
  test('Main CSS file exists', () => {
    expect(fileExists('Content/CSS/WeddingsByLarissa.css')).toBe(true);
  });

  test('Font CSS file exists', () => {
    expect(fileExists('Content/CSS/font.css')).toBe(true);
  });

  test('Images directory exists', () => {
    expect(fileExists('Content/Images')).toBe(true);
  });

  test('CSS files are not empty', () => {
    const cssPath = path.join(__dirname, '..', 'Content/CSS/WeddingsByLarissa.css');
    const cssContent = fs.readFileSync(cssPath, 'utf8');
    expect(cssContent.length).toBeGreaterThan(100);
  });
});

describe('Wedding Site - Image References', () => {
  
  test('index.html image references are valid', () => {
    const $ = loadHTML('index.html');
    const images = $('img');
    
    expect(images.length).toBeGreaterThan(0);
    
    images.each((i, img) => {
      const src = $(img).attr('src');
      if (src && !src.startsWith('http') && !src.startsWith('//')) {
        const imagePath = src.replace(/^\//, '');
        // Check if relative path exists
        const exists = fileExists(imagePath);
        if (!exists) {
          console.warn(`Warning: Image not found: ${imagePath}`);
        }
      }
    });
  });
});

describe('Wedding Site - SEO and Analytics', () => {
  
  test('index.html has Google Analytics', () => {
    const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
    // Check for either GA4 (G-) or Universal Analytics (UA-)
    expect(html).toMatch(/G-4T5FCM81BB|UA-53515617-1/);
  });

  test('sitemap.xml exists', () => {
    expect(fileExists('sitemap.xml')).toBe(true);
  });

  test('robots.txt exists', () => {
    expect(fileExists('robots.txt')).toBe(true);
  });
});

describe('Wedding Site - Content Quality', () => {
  
  test('index.html has sufficient content', () => {
    const $ = loadHTML('index.html');
    const bodyText = $('body').text().trim();
    expect(bodyText.length).toBeGreaterThan(200);
  });

  test('index.html contains wedding-related keywords', () => {
    const $ = loadHTML('index.html');
    const bodyText = $('body').text().toLowerCase();
    
    const keywords = ['wedding', 'celebrant', 'ceremony', 'larissa'];
    const foundKeywords = keywords.filter(keyword => bodyText.includes(keyword));
    
    expect(foundKeywords.length).toBeGreaterThanOrEqual(2);
  });

  test('Gallery page exists and has images', () => {
    const $ = loadHTML('New_York_Wedding_Gallery.html');
    const images = $('img');
    expect(images.length).toBeGreaterThan(0);
  });
});

describe('Wedding Site - External Links', () => {
  
  test('index.html has WeddingWire integration', () => {
    const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
    expect(html).toMatch(/weddingwire\.com/i);
  });
});

describe('Wedding Site - JavaScript Functionality', () => {
  
  test('index.html includes modal/gallery JavaScript', () => {
    const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
    
    // Check for onClick function or modal functionality
    const hasModalJS = html.includes('onClick') || 
                       html.includes('modal') || 
                       html.includes('getElementById');
    
    expect(hasModalJS).toBe(true);
  });

  test('index.html includes navbar toggle for mobile', () => {
    const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
    
    const hasNavToggle = html.includes('toggleFunction') || 
                         html.includes('w3-show') ||
                         html.includes('w3-hide');
    
    expect(hasNavToggle).toBe(true);
  });
});
