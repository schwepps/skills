# SEO Audit Tool Commands Reference

## Table of Contents
1. [Command Line Tools](#command-line-tools)
2. [Screaming Frog Exports](#screaming-frog-exports)
3. [Google Search Console API](#google-search-console-api)
4. [Performance Testing](#performance-testing)
5. [Structured Data Testing](#structured-data-testing)

---

## Command Line Tools

### HTTP Header Analysis

```bash
# Check response headers
curl -I https://example.com/

# Follow redirects and show chain
curl -ILs https://example.com/ | grep -i "location\|http/"

# Check specific headers
curl -s -D - https://example.com/ -o /dev/null | grep -i "x-robots\|canonical"

# Check robots.txt
curl -s https://example.com/robots.txt

# Check sitemap
curl -s https://example.com/sitemap.xml | head -50
```

### DNS and SSL

```bash
# DNS lookup
dig example.com +short
nslookup example.com

# SSL certificate check
openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates

# Check SSL grade (via API)
curl "https://api.ssllabs.com/api/v3/analyze?host=example.com"
```

### Content Analysis

```bash
# Count words on page
curl -s https://example.com/ | html2text | wc -w

# Extract all links
curl -s https://example.com/ | grep -oP 'href="\K[^"]+'

# Find broken images
curl -s https://example.com/ | grep -oP 'src="\K[^"]+' | xargs -I {} curl -Is {} | grep "HTTP/"

# Check for mixed content
curl -s https://example.com/ | grep -i "http://"
```

### Sitemap Validation

```bash
# Download and count URLs
curl -s https://example.com/sitemap.xml | grep -c "<loc>"

# Check all sitemap URLs respond 200
curl -s https://example.com/sitemap.xml | grep -oP '<loc>\K[^<]+' | head -20 | xargs -I {} curl -Is {} | grep "HTTP/"

# Validate XML syntax
curl -s https://example.com/sitemap.xml | xmllint --noout - 2>&1
```

---

## Screaming Frog Exports

### Key Exports for Analysis

```
1. Internal: All URLs with status codes, canonicals, meta robots
2. Response Codes: Filter by 3xx, 4xx, 5xx
3. Page Titles: Duplicates, missing, over 60 chars
4. Meta Descriptions: Duplicates, missing, over 160 chars
5. H1: Missing, duplicates, multiple per page
6. Canonicals: Non-canonical pages, canonical chains
7. Directives: noindex, nofollow analysis
8. Structured Data: All JSON-LD, validation errors
9. Sitemaps: Compare sitemap vs crawled URLs
10. Orphan Pages: Pages not in crawl but in sitemap
```

### Analysis Queries

```sql
-- Pages with canonical pointing elsewhere
SELECT url, canonical WHERE canonical != url AND indexability = 'Indexable'

-- Thin content pages
SELECT url, word_count WHERE word_count < 300 AND indexability = 'Indexable'

-- Deep pages
SELECT url, crawl_depth WHERE crawl_depth > 4

-- Redirect chains
SELECT url, redirect_chain WHERE redirect_chain_count > 1
```

---

## Google Search Console API

### Python Setup

```python
from google.oauth2 import service_account
from googleapiclient.discovery import build

SCOPES = ['https://www.googleapis.com/auth/webmasters.readonly']
credentials = service_account.Credentials.from_service_account_file(
    'service-account.json', scopes=SCOPES)
service = build('searchconsole', 'v1', credentials=credentials)
```

### Search Analytics Query

```python
def get_search_analytics(site_url, start_date, end_date):
    request = {
        'startDate': start_date,
        'endDate': end_date,
        'dimensions': ['page', 'query'],
        'rowLimit': 1000
    }
    response = service.searchanalytics().query(
        siteUrl=site_url, body=request).execute()
    return response.get('rows', [])
```

### URL Inspection

```python
def inspect_url(site_url, url_to_inspect):
    request = {
        'inspectionUrl': url_to_inspect,
        'siteUrl': site_url
    }
    response = service.urlInspection().index().inspect(
        body=request).execute()
    return response
```

---

## Performance Testing

### PageSpeed Insights API

```bash
# Desktop analysis
curl "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://example.com&strategy=desktop&key=YOUR_API_KEY"

# Mobile analysis
curl "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://example.com&strategy=mobile&key=YOUR_API_KEY"
```

### Lighthouse CLI

```bash
# Install
npm install -g lighthouse

# Run audit
lighthouse https://example.com --output=json --output-path=./report.json

# Mobile audit
lighthouse https://example.com --emulated-form-factor=mobile

# Specific categories
lighthouse https://example.com --only-categories=performance,seo
```

### WebPageTest API

```bash
# Start test
curl "https://www.webpagetest.org/runtest.php?url=https://example.com&f=json&k=YOUR_API_KEY"

# Get results
curl "https://www.webpagetest.org/jsonResult.php?test=TEST_ID"
```

### Core Web Vitals Check

```python
# Using CrUX API
import requests

def get_crux_data(url, api_key):
    endpoint = f"https://chromeuxreport.googleapis.com/v1/records:queryRecord?key={api_key}"
    payload = {
        "url": url,
        "metrics": ["largest_contentful_paint", "interaction_to_next_paint", "cumulative_layout_shift"]
    }
    response = requests.post(endpoint, json=payload)
    return response.json()
```

---

## Structured Data Testing

### Google Rich Results Test (Programmatic)

```bash
# Note: No public API, use headless browser or manual testing
# Alternative: Use schema.org validator API

curl -X POST "https://validator.schema.org/validate" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/"}'
```

### JSON-LD Extraction

```python
from bs4 import BeautifulSoup
import json
import requests

def extract_jsonld(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    scripts = soup.find_all('script', type='application/ld+json')
    
    schemas = []
    for script in scripts:
        try:
            data = json.loads(script.string)
            schemas.append(data)
        except json.JSONDecodeError:
            continue
    return schemas
```

### Schema Validation

```python
# Validate against schema.org
import jsonschema

def validate_schema(data, schema_type):
    # Download schema from schema.org
    schema_url = f"https://schema.org/{schema_type}.jsonld"
    # Validate using jsonschema
    try:
        jsonschema.validate(data, schema)
        return True, None
    except jsonschema.ValidationError as e:
        return False, str(e)
```

---

## Bulk Analysis Scripts

### Batch URL Check

```bash
#!/bin/bash
# check_urls.sh - Check status codes for URL list

while IFS= read -r url; do
    status=$(curl -Is "$url" | head -1 | awk '{print $2}')
    echo "$url,$status"
done < urls.txt
```

### Canonical Consistency Check

```python
import requests
from bs4 import BeautifulSoup

def check_canonical(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    canonical = soup.find('link', rel='canonical')
    
    if canonical:
        canonical_url = canonical.get('href')
        return {
            'url': url,
            'canonical': canonical_url,
            'self_canonical': url == canonical_url
        }
    return {'url': url, 'canonical': None, 'self_canonical': False}
```

### Robots Meta Check

```python
def check_robots_meta(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    robots = soup.find('meta', attrs={'name': 'robots'})
    googlebot = soup.find('meta', attrs={'name': 'googlebot'})
    
    return {
        'url': url,
        'robots': robots.get('content') if robots else None,
        'googlebot': googlebot.get('content') if googlebot else None,
        'x_robots': response.headers.get('X-Robots-Tag')
    }
```
