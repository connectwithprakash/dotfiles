---
name: netlify
description: Deploy and manage sites on Netlify. Use when user asks to deploy a site to Netlify, configure netlify.toml, set up redirects/headers, create serverless functions, edge functions, or manage Netlify forms. Covers CLI deployment, build configuration, environment variables, and all Netlify platform features.
---

# Netlify Skill

Deploy, configure, and manage sites on the Netlify platform.

## Quick Reference

| Task | Command/File |
|------|-------------|
| Deploy | `netlify deploy --prod` |
| Dev server | `netlify dev` |
| Link site | `netlify link` |
| Env vars | `netlify env:set KEY value` |
| Functions | `netlify functions:create` |
| Config | `netlify.toml` in project root |

## Deployment Workflow

### First-time Setup

```bash
# Install CLI
npm install -g netlify-cli

# Login (opens browser)
netlify login

# Initialize new site (in project directory)
netlify init

# Or link existing site
netlify link
```

### Deploy Commands

```bash
# Preview deploy (creates unique URL)
netlify deploy

# Production deploy
netlify deploy --prod

# Deploy specific directory
netlify deploy --dir=dist --prod

# Deploy with build
netlify deploy --build --prod
```

### CI/CD Deployment

For GitHub/GitLab auto-deploys, connect repo in Netlify dashboard. Alternatively, use deploy hooks:

```bash
curl -X POST -d {} https://api.netlify.com/build_hooks/YOUR_HOOK_ID
```

## Configuration (netlify.toml)

Create `netlify.toml` in project root:

```toml
[build]
  command = "npm run build"
  publish = "dist"
  # Or for specific frameworks
  # publish = "build"        # Create React App
  # publish = ".next"        # Next.js
  # publish = "public"       # Gatsby (after build)

[build.environment]
  NODE_VERSION = "20"

# Redirects
[[redirects]]
  from = "/old-path"
  to = "/new-path"
  status = 301

# SPA fallback
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

# Proxy to API
[[redirects]]
  from = "/api/*"
  to = "https://api.example.com/:splat"
  status = 200

# Headers
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Cache-Control = "public, max-age=31536000"

# Context-specific settings
[context.production]
  command = "npm run build:prod"

[context.deploy-preview]
  command = "npm run build:preview"

[context.branch-deploy]
  command = "npm run build:staging"

# Functions directory
[functions]
  directory = "netlify/functions"
```

For detailed configuration options, see [references/configuration.md](references/configuration.md).

## Environment Variables

```bash
# Set variable
netlify env:set API_KEY "your-secret-key"

# Set for specific context
netlify env:set API_URL "https://staging.api.com" --context deploy-preview

# List all
netlify env:list

# Get specific
netlify env:get API_KEY

# Unset
netlify env:unset API_KEY

# Import from .env file
netlify env:import .env
```

Access in code:
- Build time: `process.env.API_KEY`
- Functions: `process.env.API_KEY` or `Netlify.env.get("API_KEY")`

## Serverless Functions

For detailed function patterns, see [references/functions.md](references/functions.md).

### Quick Start

```bash
# Create function interactively
netlify functions:create

# Create with template
netlify functions:create --name hello
```

### Basic Function (netlify/functions/hello.js)

```javascript
export default async (req, context) => {
  const name = new URL(req.url).searchParams.get("name") || "World";

  return new Response(JSON.stringify({ message: `Hello, ${name}!` }), {
    headers: { "Content-Type": "application/json" }
  });
};
```

Invoke at: `/.netlify/functions/hello?name=Claude`

### TypeScript Function

```typescript
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  return new Response("Hello from TypeScript!");
};
```

## Edge Functions

Ultra-fast functions running at the edge (Deno runtime).

### Create Edge Function (netlify/edge-functions/geo.ts)

```typescript
import type { Context } from "@netlify/edge-functions";

export default async (request: Request, context: Context) => {
  return new Response(JSON.stringify({
    country: context.geo.country?.name,
    city: context.geo.city
  }), {
    headers: { "Content-Type": "application/json" }
  });
};

export const config = { path: "/api/geo" };
```

### Configure in netlify.toml

```toml
[[edge_functions]]
  path = "/api/geo"
  function = "geo"
```

## Netlify Forms

Add `netlify` attribute to any HTML form:

```html
<form name="contact" method="POST" data-netlify="true">
  <input type="hidden" name="form-name" value="contact" />
  <input type="text" name="name" required />
  <input type="email" name="email" required />
  <textarea name="message"></textarea>
  <button type="submit">Send</button>
</form>
```

### React Form

```jsx
<form name="contact" method="POST" data-netlify="true">
  <input type="hidden" name="form-name" value="contact" />
  {/* form fields */}
</form>
```

### Spam Protection

```html
<!-- Honeypot field -->
<form name="contact" data-netlify="true" netlify-honeypot="bot-field">
  <p style="display:none">
    <input name="bot-field" />
  </p>
  <!-- other fields -->
</form>

<!-- reCAPTCHA -->
<form data-netlify="true" data-netlify-recaptcha="true">
  <div data-netlify-recaptcha="true"></div>
  <!-- other fields -->
</form>
```

## Local Development

```bash
# Start dev server with functions
netlify dev

# Start on specific port
netlify dev --port 8888

# With live reload
netlify dev --live
```

## Common Patterns

### SPA with API Proxy

```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/api/*"
  to = "https://api.backend.com/:splat"
  status = 200
  force = true

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### Static Site with Custom 404

```toml
[build]
  publish = "public"

[[redirects]]
  from = "/*"
  to = "/404.html"
  status = 404
```

### Password-Protected Deploy Preview

```toml
[context.deploy-preview]
  [context.deploy-preview.environment]
    REQUIRE_AUTH = "true"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails | Check `netlify.toml` syntax, verify build command locally |
| Functions 404 | Ensure functions directory matches config |
| Redirects not working | Add `force = true` to override existing files |
| Env vars missing | Check context (production vs preview) |

## CLI Reference

```bash
netlify help              # All commands
netlify sites:list        # List all sites
netlify open              # Open site in browser
netlify open:admin        # Open admin dashboard
netlify logs              # View function logs
netlify logs:function     # View specific function logs
netlify build             # Run build locally
netlify status            # Site info and status
```
