# Netlify Configuration Reference

Complete reference for `netlify.toml` configuration options.

## Table of Contents
- [Build Settings](#build-settings)
- [Redirects](#redirects)
- [Headers](#headers)
- [Functions](#functions)
- [Edge Functions](#edge-functions)
- [Plugins](#plugins)
- [Deploy Contexts](#deploy-contexts)

## Build Settings

```toml
[build]
  # Build command to execute
  command = "npm run build"

  # Directory to publish (relative to repo root)
  publish = "dist"

  # Base directory (monorepo support)
  base = "packages/web"

  # Directory for functions
  functions = "netlify/functions"

  # Ignore builds matching pattern
  ignore = "git diff --quiet $CACHED_COMMIT_REF $COMMIT_REF -- ."

[build.environment]
  NODE_VERSION = "20"
  NPM_VERSION = "10"
  YARN_VERSION = "1.22"
  RUBY_VERSION = "3.2"
  GO_VERSION = "1.21"
  PHP_VERSION = "8.2"
  PYTHON_VERSION = "3.11"
  # Custom environment variables
  MY_VAR = "value"

[build.processing]
  skip_processing = false

[build.processing.css]
  bundle = true
  minify = true

[build.processing.js]
  bundle = true
  minify = true

[build.processing.html]
  pretty_urls = true

[build.processing.images]
  compress = true
```

## Redirects

### Basic Syntax

```toml
[[redirects]]
  from = "/old"
  to = "/new"
  status = 301        # 301=permanent, 302=temporary, 200=rewrite
  force = false       # Override existing files

[[redirects]]
  from = "/api/*"
  to = "https://api.example.com/:splat"
  status = 200
  force = true
  headers = {X-From = "Netlify"}

# Conditional redirect
[[redirects]]
  from = "/admin/*"
  to = "/login"
  status = 302
  conditions = {Role = ["admin"]}
```

### Placeholders

| Placeholder | Description |
|------------|-------------|
| `:splat` | Matches everything after `*` |
| `:placeholder` | Named segment from path |

```toml
# /blog/2024/post -> /articles/2024/post
[[redirects]]
  from = "/blog/:year/:slug"
  to = "/articles/:year/:slug"
  status = 301

# /api/v1/users -> https://api.example.com/users
[[redirects]]
  from = "/api/v1/*"
  to = "https://api.example.com/:splat"
  status = 200
```

### Query String Handling

```toml
[[redirects]]
  from = "/search"
  to = "/find"
  query = {q = ":q"}  # Preserve query param
  status = 301
```

### Country/Language Redirects

```toml
[[redirects]]
  from = "/*"
  to = "/de/:splat"
  status = 302
  conditions = {Country = ["de", "at", "ch"]}

[[redirects]]
  from = "/*"
  to = "/fr/:splat"
  status = 302
  conditions = {Language = ["fr"]}
```

### Role-Based Redirects (Netlify Identity)

```toml
[[redirects]]
  from = "/admin/*"
  to = "/admin/:splat"
  status = 200
  conditions = {Role = ["admin"]}

[[redirects]]
  from = "/admin/*"
  to = "/login"
  status = 302
```

## Headers

```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "camera=(), microphone=(), geolocation=()"

[[headers]]
  for = "/*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/api/*"
  [headers.values]
    Access-Control-Allow-Origin = "*"
    Access-Control-Allow-Methods = "GET, POST, OPTIONS"
    Access-Control-Allow-Headers = "Content-Type, Authorization"

# Content Security Policy
[[headers]]
  for = "/*"
  [headers.values]
    Content-Security-Policy = """
      default-src 'self';
      script-src 'self' 'unsafe-inline';
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      font-src 'self';
      connect-src 'self' https://api.example.com;
    """
```

## Functions

```toml
[functions]
  # Functions directory
  directory = "netlify/functions"

  # Node.js bundler (esbuild recommended)
  node_bundler = "esbuild"

  # Include additional files
  included_files = ["data/*.json", "templates/**"]

  # External modules (not bundled)
  external_node_modules = ["sharp", "canvas"]

# Function-specific config
[functions."api-handler"]
  # Schedule (cron syntax)
  schedule = "0 0 * * *"  # Daily at midnight

  # Background function (async, 15 min timeout)
  background = true

[functions."heavy-compute"]
  # Extended timeout (up to 26 seconds for paid plans)
  timeout = 26
```

## Edge Functions

```toml
[[edge_functions]]
  path = "/api/geo"
  function = "geo"

[[edge_functions]]
  path = "/admin/*"
  function = "auth-check"

# Cache edge function responses
[[edge_functions]]
  path = "/data/*"
  function = "fetch-data"
  cache = "manual"
```

## Plugins

```toml
[[plugins]]
  package = "@netlify/plugin-lighthouse"
  [plugins.inputs]
    output_path = "reports/lighthouse.html"

[[plugins]]
  package = "netlify-plugin-sitemap"
  [plugins.inputs]
    buildDir = "dist"
    exclude = ["/admin/*", "/api/*"]

# Local plugin
[[plugins]]
  package = "./plugins/my-plugin"
```

## Deploy Contexts

```toml
# Production (main/master branch)
[context.production]
  command = "npm run build:prod"
  [context.production.environment]
    NODE_ENV = "production"
    API_URL = "https://api.example.com"

# Deploy previews (PRs)
[context.deploy-preview]
  command = "npm run build:preview"
  [context.deploy-preview.environment]
    NODE_ENV = "preview"
    API_URL = "https://staging-api.example.com"

# Branch deploys
[context.branch-deploy]
  command = "npm run build:staging"

# Specific branch
[context.staging]
  command = "npm run build:staging"
  [context.staging.environment]
    API_URL = "https://staging-api.example.com"

# Feature branches (pattern matching)
[context."feature/*"]
  command = "npm run build:feature"
```

## Framework-Specific Examples

### Next.js

```toml
[build]
  command = "npm run build"
  publish = ".next"

[[plugins]]
  package = "@netlify/plugin-nextjs"
```

### Gatsby

```toml
[build]
  command = "gatsby build"
  publish = "public"

[[plugins]]
  package = "@netlify/plugin-gatsby"
```

### Vite / React

```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### Astro

```toml
[build]
  command = "astro build"
  publish = "dist"
```

### Hugo

```toml
[build]
  command = "hugo --gc --minify"
  publish = "public"

[build.environment]
  HUGO_VERSION = "0.121.0"
```
