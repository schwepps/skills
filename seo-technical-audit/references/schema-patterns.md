# Schema Markup Patterns

## Table of Contents
1. [JSON-LD Best Practices](#json-ld-best-practices)
2. [Schema Types by Content](#schema-types-by-content)
3. [E-commerce Schema](#e-commerce-schema)
4. [Local Business Schema](#local-business-schema)
5. [Article Schema](#article-schema)
6. [FAQ Schema](#faq-schema)
7. [HowTo Schema](#howto-schema)
8. [Validation & Testing](#validation-testing)

---

## JSON-LD Best Practices

**Format**: Always use JSON-LD (Google's preferred format)

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "name": "Page Title",
  "description": "Page description"
}
</script>
```

**Principles:**
- One `<script>` block per entity type
- Place in `<head>` or end of `<body>`
- Match schema to visible page content
- No exaggeration or spam
- Keep minimal—only what's needed for rich results

---

## Schema Types by Content

| Content Type | Primary Schema | Rich Result |
|--------------|----------------|-------------|
| Blog posts | Article, BlogPosting | Article carousel |
| Products | Product, Offer | Product snippets |
| Q&A content | FAQPage | FAQ dropdowns |
| Tutorials | HowTo | Step-by-step |
| Local business | LocalBusiness | Knowledge panel |
| Events | Event | Event listings |
| Recipes | Recipe | Recipe cards |
| Reviews | Review, AggregateRating | Star ratings |
| Videos | VideoObject | Video carousel |
| Breadcrumbs | BreadcrumbList | Breadcrumb trail |

---

## E-commerce Schema

### Product Page

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Product Name",
  "image": [
    "https://example.com/photo1.jpg",
    "https://example.com/photo2.jpg"
  ],
  "description": "Product description here",
  "sku": "SKU123",
  "brand": {
    "@type": "Brand",
    "name": "Brand Name"
  },
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/product",
    "priceCurrency": "USD",
    "price": "99.99",
    "priceValidUntil": "2025-12-31",
    "availability": "https://schema.org/InStock",
    "seller": {
      "@type": "Organization",
      "name": "Store Name"
    }
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.5",
    "reviewCount": "89"
  }
}
```

### Product with Reviews

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Product Name",
  "review": [
    {
      "@type": "Review",
      "reviewRating": {
        "@type": "Rating",
        "ratingValue": "5",
        "bestRating": "5"
      },
      "author": {
        "@type": "Person",
        "name": "John Doe"
      },
      "reviewBody": "Great product, highly recommend!"
    }
  ]
}
```

---

## Local Business Schema

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Business Name",
  "image": "https://example.com/logo.jpg",
  "@id": "https://example.com",
  "url": "https://example.com",
  "telephone": "+1-555-123-4567",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "123 Main St",
    "addressLocality": "City",
    "addressRegion": "State",
    "postalCode": "12345",
    "addressCountry": "US"
  },
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "openingHoursSpecification": [
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
      "opens": "09:00",
      "closes": "17:00"
    }
  ],
  "priceRange": "$$"
}
```

---

## Article Schema

### BlogPosting

```json
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "Article Headline (max 110 chars)",
  "image": "https://example.com/article-image.jpg",
  "datePublished": "2025-01-08T08:00:00+00:00",
  "dateModified": "2025-01-08T10:00:00+00:00",
  "author": {
    "@type": "Person",
    "name": "Author Name",
    "url": "https://example.com/author"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Publisher Name",
    "logo": {
      "@type": "ImageObject",
      "url": "https://example.com/logo.png"
    }
  },
  "description": "Article meta description",
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://example.com/article"
  }
}
```

---

## FAQ Schema

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the return policy?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You can return items within 30 days for a full refund."
      }
    },
    {
      "@type": "Question",
      "name": "Do you offer free shipping?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, free shipping on orders over $50."
      }
    }
  ]
}
```

**Critical**: Only use FAQPage for actual FAQ content visible on page.

---

## HowTo Schema

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "How to Change a Tire",
  "description": "Step-by-step guide to changing a flat tire",
  "totalTime": "PT30M",
  "estimatedCost": {
    "@type": "MonetaryAmount",
    "currency": "USD",
    "value": "0"
  },
  "supply": [
    {"@type": "HowToSupply", "name": "Spare tire"},
    {"@type": "HowToSupply", "name": "Jack"}
  ],
  "tool": [
    {"@type": "HowToTool", "name": "Lug wrench"}
  ],
  "step": [
    {
      "@type": "HowToStep",
      "name": "Loosen the lug nuts",
      "text": "Use the lug wrench to loosen each nut one turn.",
      "image": "https://example.com/step1.jpg"
    },
    {
      "@type": "HowToStep",
      "name": "Position the jack",
      "text": "Place the jack under the vehicle frame.",
      "image": "https://example.com/step2.jpg"
    }
  ]
}
```

---

## Validation & Testing

### Tools

1. **Google Rich Results Test**
   - https://search.google.com/test/rich-results
   - Tests if page qualifies for rich results

2. **Schema Markup Validator**
   - https://validator.schema.org/
   - Validates against schema.org spec

3. **GSC Enhancements Reports**
   - Monitor indexed structured data
   - See errors and warnings

### Common Errors

| Error | Fix |
|-------|-----|
| Missing required field | Add the field |
| Invalid URL | Use absolute HTTPS URLs |
| Price not valid | Use decimal format "99.99" |
| Date format invalid | Use ISO 8601 format |
| Markup not matching content | Align schema with visible content |

### Validation Checklist

```
□ No errors in Rich Results Test
□ No warnings in Schema Validator
□ Schema matches visible page content
□ Required fields present
□ URLs are absolute and HTTPS
□ Dates in ISO 8601 format
□ No exaggerated claims
□ Appropriate schema type for content
```
