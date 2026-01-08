# Technical SEO Audit Detailed Checklist

## Table of Contents
1. [Crawlability Deep Dive](#crawlability-deep-dive)
2. [Indexation Analysis](#indexation-analysis)
3. [Core Web Vitals Details](#core-web-vitals-details)
4. [Site Architecture Patterns](#site-architecture-patterns)
5. [Mobile Optimization](#mobile-optimization)
6. [Security Hardening](#security-hardening)

---

## Crawlability Deep Dive

### robots.txt Validation

```bash
# Fetch and analyze robots.txt
curl -s https://example.com/robots.txt

# Test specific URL blocking
# In GSC: URL Inspection > View crawled page
```

**Check for these issues:**
- Blocking important directories (`/assets/`, `/images/`)
- Overly broad `Disallow` rules
- Missing `Sitemap:` directive
- Blocking CSS/JS (breaks rendering)
- Multiple conflicting User-agent blocks

### XML Sitemap Requirements

**Valid sitemap contains only:**
- Canonical URLs (self-referencing canonical)
- 200 status codes
- Indexable pages (no noindex)
- Updated `<lastmod>` dates
- Priority and changefreq (optional, largely ignored)

**Sitemap limits:**
- Max 50,000 URLs per file
- Max 50MB uncompressed
- Use sitemap index for larger sites

**Split by content type:**
```xml
<sitemapindex>
  <sitemap><loc>/sitemap-pages.xml</loc></sitemap>
  <sitemap><loc>/sitemap-posts.xml</loc></sitemap>
  <sitemap><loc>/sitemap-products.xml</loc></sitemap>
</sitemapindex>
```

### Crawl Budget Optimization

**Crawl waste sources:**
- Infinite scroll without pagination links
- Calendar widgets with infinite dates
- Session IDs in URLs
- Faceted navigation without canonicals
- Soft 404s (200 status, thin content)

**Solutions:**
- Canonicalize parameter variations
- Noindex low-value facets
- Block session parameters in robots.txt
- Implement proper pagination

---

## Indexation Analysis

### GSC Pages Report Analysis

**Key statuses to investigate:**

| Status | Action |
|--------|--------|
| Crawled - currently not indexed | Improve content quality |
| Discovered - currently not indexed | Check internal linking |
| Alternate page with proper canonical | Verify intended |
| Duplicate without user-selected canonical | Add canonical tag |
| Soft 404 | Fix or implement real 404 |
| Blocked by robots.txt | Update robots.txt |

### Canonical Tag Best Practices

```html
<!-- Self-referencing canonical (required on all pages) -->
<link rel="canonical" href="https://example.com/page/" />

<!-- Cross-domain canonical (for syndicated content) -->
<link rel="canonical" href="https://original-source.com/article/" />
```

**Common mistakes:**
- Relative URLs in canonical (use absolute)
- HTTP in canonical on HTTPS site
- Canonical pointing to 404
- Canonical pointing to redirect
- Multiple canonical tags

---

## Core Web Vitals Details

### LCP Optimization

**Target**: ≤ 2.5s at 75th percentile

**LCP elements (largest visible):**
- Hero images
- Background images
- Video poster images
- Large text blocks

**Optimization techniques:**
```html
<!-- Preload LCP image -->
<link rel="preload" as="image" href="/hero.webp" fetchpriority="high">

<!-- Responsive images -->
<img src="hero.webp" 
     srcset="hero-400.webp 400w, hero-800.webp 800w"
     sizes="(max-width: 600px) 400px, 800px"
     loading="eager"
     fetchpriority="high">
```

### INP Optimization

**Target**: ≤ 200ms at 75th percentile

**Causes of poor INP:**
- Long JavaScript tasks (>50ms)
- Heavy event handlers
- Layout thrashing
- Third-party scripts

**Solutions:**
- Break up long tasks with `yield()`
- Debounce input handlers
- Use `requestIdleCallback()` for non-critical work
- Defer third-party scripts

### CLS Optimization

**Target**: ≤ 0.10 at 75th percentile

**CLS causes:**
- Images without dimensions
- Ads/embeds without reserved space
- Web fonts causing FOIT/FOUT
- Dynamic content injection

**Solutions:**
```html
<!-- Always include dimensions -->
<img src="photo.jpg" width="800" height="600" alt="...">

<!-- Reserve space for ads -->
<div style="min-height: 250px;">
  <!-- Ad loads here -->
</div>

<!-- Font display strategy -->
@font-face {
  font-family: 'Custom';
  font-display: swap;
  src: url('font.woff2');
}
```

---

## Site Architecture Patterns

### Flat Architecture

```
Homepage (depth 0)
├── Category 1 (depth 1)
│   ├── Subcategory A (depth 2)
│   │   └── Product pages (depth 3)
│   └── Subcategory B (depth 2)
├── Category 2 (depth 1)
└── Key landing pages (depth 1)
```

**Rule**: No important page more than 3-4 clicks from homepage.

### Internal Link Equity Distribution

**High-value pages should receive:**
- Navigation links (sitewide)
- Contextual links from related content
- Footer links (strategic, not spammy)
- Breadcrumb links

**PageRank modeling:**
- Homepage = highest authority
- Category pages = medium authority
- Individual pages = distributed from above

### Pagination Best Practices

```html
<!-- Page 2 of paginated series -->
<link rel="canonical" href="https://example.com/blog/page/2/">
<!-- Note: rel="prev/next" no longer used by Google -->

<!-- Provide View All option if possible -->
<a href="/blog/all/">View all posts</a>
```

---

## Mobile Optimization

### Viewport Configuration

```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

### Touch Target Sizing

```css
/* Minimum 48x48px touch targets */
.button, a {
  min-height: 48px;
  min-width: 48px;
  padding: 12px 16px;
}

/* Adequate spacing between targets */
.nav-link {
  margin: 8px 0;
}
```

### Mobile Content Parity

**Ensure mobile version has:**
- Same text content
- Same images (with alt text)
- Same structured data
- Same internal links
- Same meta tags

**Check with:**
- GSC URL Inspection (mobile rendering)
- Chrome DevTools device emulation
- Real device testing

---

## Security Hardening

### HTTPS Implementation

```apache
# Force HTTPS redirect
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

### Security Headers

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Content-Security-Policy: default-src 'self'
```

### Mixed Content Detection

```bash
# Find mixed content
grep -r "http://" --include="*.html" ./
```

**Fix**: Update all resource URLs to HTTPS or protocol-relative.
