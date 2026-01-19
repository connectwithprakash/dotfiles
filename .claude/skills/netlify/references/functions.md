# Netlify Functions Reference

Comprehensive guide for serverless and edge functions.

## Table of Contents
- [Function Types](#function-types)
- [Serverless Functions](#serverless-functions)
- [Edge Functions](#edge-functions)
- [Scheduled Functions](#scheduled-functions)
- [Background Functions](#background-functions)
- [Common Patterns](#common-patterns)

## Function Types

| Type | Runtime | Location | Timeout | Use Case |
|------|---------|----------|---------|----------|
| Serverless | Node.js | `netlify/functions/` | 10-26s | API routes, webhooks |
| Edge | Deno | `netlify/edge-functions/` | 50ms | Auth, A/B testing, geo |
| Scheduled | Node.js | `netlify/functions/` | 15min | Cron jobs |
| Background | Node.js | `netlify/functions/` | 15min | Long tasks |

## Serverless Functions

### Directory Structure

```
netlify/
└── functions/
    ├── hello.js           # Single file
    ├── api/
    │   └── users.js       # Nested route: /.netlify/functions/api-users
    └── complex/
        ├── complex.js     # Main handler (same name as folder)
        └── helpers.js     # Support files
```

### Basic Handler (ES Modules)

```javascript
// netlify/functions/hello.js
export default async (req, context) => {
  const { name = "World" } = Object.fromEntries(new URL(req.url).searchParams);

  return new Response(JSON.stringify({ message: `Hello, ${name}!` }), {
    status: 200,
    headers: { "Content-Type": "application/json" }
  });
};
```

### TypeScript Handler

```typescript
// netlify/functions/users.ts
import type { Context } from "@netlify/functions";

interface User {
  id: string;
  name: string;
  email: string;
}

export default async (req: Request, context: Context): Promise<Response> => {
  if (req.method === "GET") {
    const users: User[] = [{ id: "1", name: "Alice", email: "alice@example.com" }];
    return Response.json(users);
  }

  if (req.method === "POST") {
    const body = await req.json();
    return Response.json({ created: body }, { status: 201 });
  }

  return new Response("Method not allowed", { status: 405 });
};
```

### REST API Pattern

```typescript
// netlify/functions/api.ts
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const url = new URL(req.url);
  const path = url.pathname.replace("/.netlify/functions/api", "");
  const method = req.method;

  // Router
  if (path === "/users" && method === "GET") {
    return handleGetUsers();
  }
  if (path.match(/^\/users\/\w+$/) && method === "GET") {
    const id = path.split("/")[2];
    return handleGetUser(id);
  }
  if (path === "/users" && method === "POST") {
    const body = await req.json();
    return handleCreateUser(body);
  }

  return new Response("Not Found", { status: 404 });
};

async function handleGetUsers() {
  return Response.json([]);
}

async function handleGetUser(id: string) {
  return Response.json({ id });
}

async function handleCreateUser(data: unknown) {
  return Response.json(data, { status: 201 });
}
```

### Database Connection (MongoDB)

```typescript
// netlify/functions/db.ts
import { MongoClient } from "mongodb";
import type { Context } from "@netlify/functions";

let cachedClient: MongoClient | null = null;

async function connectToDatabase() {
  if (cachedClient) return cachedClient;

  const client = new MongoClient(process.env.MONGODB_URI!);
  await client.connect();
  cachedClient = client;
  return client;
}

export default async (req: Request, context: Context) => {
  const client = await connectToDatabase();
  const db = client.db("myapp");
  const collection = db.collection("items");

  if (req.method === "GET") {
    const items = await collection.find({}).limit(100).toArray();
    return Response.json(items);
  }

  if (req.method === "POST") {
    const body = await req.json();
    const result = await collection.insertOne(body);
    return Response.json({ id: result.insertedId }, { status: 201 });
  }

  return new Response("Method not allowed", { status: 405 });
};
```

### Authentication Check

```typescript
// netlify/functions/protected.ts
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const authHeader = req.headers.get("authorization");

  if (!authHeader?.startsWith("Bearer ")) {
    return new Response("Unauthorized", { status: 401 });
  }

  const token = authHeader.slice(7);

  try {
    // Verify JWT or check against your auth service
    const user = await verifyToken(token);
    return Response.json({ user, data: "protected content" });
  } catch {
    return new Response("Invalid token", { status: 403 });
  }
};

async function verifyToken(token: string) {
  // Implement your token verification
  return { id: "user-123" };
}
```

### File Upload

```typescript
// netlify/functions/upload.ts
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const formData = await req.formData();
  const file = formData.get("file") as File;

  if (!file) {
    return new Response("No file uploaded", { status: 400 });
  }

  const buffer = await file.arrayBuffer();
  // Upload to S3, Cloudinary, etc.

  return Response.json({
    filename: file.name,
    size: file.size,
    type: file.type
  });
};
```

## Edge Functions

Edge functions run on Deno at the edge (closer to users).

### Basic Edge Function

```typescript
// netlify/edge-functions/hello.ts
import type { Context } from "@netlify/edge-functions";

export default async (request: Request, context: Context) => {
  return new Response(`Hello from ${context.geo.city}, ${context.geo.country?.name}!`);
};

export const config = { path: "/hello" };
```

### Geolocation Redirect

```typescript
// netlify/edge-functions/geo-redirect.ts
import type { Context } from "@netlify/edge-functions";

const COUNTRY_SITES: Record<string, string> = {
  DE: "https://de.example.com",
  FR: "https://fr.example.com",
  JP: "https://jp.example.com"
};

export default async (request: Request, context: Context) => {
  const countryCode = context.geo.country?.code;

  if (countryCode && COUNTRY_SITES[countryCode]) {
    const url = new URL(request.url);
    return Response.redirect(`${COUNTRY_SITES[countryCode]}${url.pathname}`);
  }

  return context.next();
};

export const config = { path: "/*" };
```

### A/B Testing

```typescript
// netlify/edge-functions/ab-test.ts
import type { Context } from "@netlify/edge-functions";

export default async (request: Request, context: Context) => {
  const cookies = request.headers.get("cookie") || "";
  let variant = cookies.match(/ab-variant=(\w+)/)?.[1];

  if (!variant) {
    variant = Math.random() < 0.5 ? "control" : "experiment";
  }

  const response = await context.next();
  const html = await response.text();

  const modified = variant === "experiment"
    ? html.replace('<button>Buy Now</button>', '<button>Get Started Free</button>')
    : html;

  return new Response(modified, {
    headers: {
      ...Object.fromEntries(response.headers),
      "Set-Cookie": `ab-variant=${variant}; path=/; max-age=86400`,
      "Content-Type": "text/html"
    }
  });
};

export const config = { path: "/" };
```

### Auth Middleware

```typescript
// netlify/edge-functions/auth.ts
import type { Context } from "@netlify/edge-functions";

export default async (request: Request, context: Context) => {
  const token = request.headers.get("authorization")?.replace("Bearer ", "");

  if (!token) {
    return new Response("Unauthorized", { status: 401 });
  }

  // Verify token (use edge-compatible JWT library)
  const isValid = await verifyToken(token);

  if (!isValid) {
    return new Response("Forbidden", { status: 403 });
  }

  return context.next();
};

export const config = { path: "/api/*" };

async function verifyToken(token: string): Promise<boolean> {
  // Implement verification
  return true;
}
```

### Response Transformation

```typescript
// netlify/edge-functions/transform.ts
import type { Context } from "@netlify/edge-functions";

export default async (request: Request, context: Context) => {
  const response = await context.next();

  // Clone and modify response
  const html = await response.text();
  const modified = html.replace(
    "</head>",
    `<script>window.FEATURE_FLAGS = ${JSON.stringify({ newUI: true })};</script></head>`
  );

  return new Response(modified, response);
};

export const config = { path: "/*.html" };
```

## Scheduled Functions

Run functions on a schedule using cron syntax.

```typescript
// netlify/functions/daily-cleanup.ts
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  // Runs daily at midnight UTC
  console.log("Running daily cleanup...");

  // Your cleanup logic
  await cleanupOldRecords();

  return new Response("Cleanup complete");
};

// Configure schedule in netlify.toml
export const config = {
  schedule: "0 0 * * *"  // Every day at midnight
};

async function cleanupOldRecords() {
  // Implementation
}
```

Configure in `netlify.toml`:

```toml
[functions."daily-cleanup"]
  schedule = "0 0 * * *"
```

### Cron Syntax Reference

| Expression | Description |
|------------|-------------|
| `* * * * *` | Every minute |
| `0 * * * *` | Every hour |
| `0 0 * * *` | Every day at midnight |
| `0 0 * * 0` | Every Sunday |
| `0 0 1 * *` | First of every month |
| `*/15 * * * *` | Every 15 minutes |
| `0 9-17 * * 1-5` | Hourly, 9am-5pm, Mon-Fri |

## Background Functions

Long-running async tasks (up to 15 minutes).

```typescript
// netlify/functions/process-video-background.ts
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const { videoUrl } = await req.json();

  // This runs in background - response returns immediately
  console.log(`Processing video: ${videoUrl}`);

  // Long-running task
  await processVideo(videoUrl);
  await sendNotification("Video processing complete");

  return new Response("Background task completed");
};

export const config = {
  type: "background"  // Mark as background function
};

async function processVideo(url: string) {
  // Long-running processing
}

async function sendNotification(message: string) {
  // Send webhook/email notification
}
```

Invoke background functions with `-background` suffix:

```javascript
// Client-side
fetch("/.netlify/functions/process-video-background", {
  method: "POST",
  body: JSON.stringify({ videoUrl: "..." })
});
// Returns immediately with 202 Accepted
```

## Common Patterns

### CORS Handler

```typescript
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization"
};

export default async (req: Request, context: Context) => {
  // Handle preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  // Your logic
  const data = { message: "Hello" };

  return Response.json(data, { headers: corsHeaders });
};
```

### Error Handling Wrapper

```typescript
type Handler = (req: Request, context: Context) => Promise<Response>;

function withErrorHandling(handler: Handler): Handler {
  return async (req, context) => {
    try {
      return await handler(req, context);
    } catch (error) {
      console.error("Function error:", error);

      return Response.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  };
}

export default withErrorHandling(async (req, context) => {
  // Your handler logic
  return Response.json({ success: true });
});
```

### Rate Limiting (with KV)

```typescript
// Using Netlify Blobs for rate limiting
import { getStore } from "@netlify/blobs";
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const ip = context.ip;
  const store = getStore("rate-limits");

  const key = `rate:${ip}`;
  const current = await store.get(key, { type: "json" }) as { count: number; reset: number } | null;
  const now = Date.now();

  if (current && now < current.reset) {
    if (current.count >= 100) {
      return new Response("Rate limit exceeded", { status: 429 });
    }
    await store.setJSON(key, { count: current.count + 1, reset: current.reset });
  } else {
    await store.setJSON(key, { count: 1, reset: now + 60000 }); // 1 minute window
  }

  // Your handler logic
  return Response.json({ success: true });
};
```

### Webhook Handler

```typescript
import type { Context } from "@netlify/functions";
import crypto from "crypto";

export default async (req: Request, context: Context) => {
  const signature = req.headers.get("x-webhook-signature");
  const body = await req.text();

  // Verify signature
  const expectedSig = crypto
    .createHmac("sha256", process.env.WEBHOOK_SECRET!)
    .update(body)
    .digest("hex");

  if (signature !== `sha256=${expectedSig}`) {
    return new Response("Invalid signature", { status: 401 });
  }

  const payload = JSON.parse(body);

  // Process webhook
  switch (payload.event) {
    case "order.created":
      await handleOrderCreated(payload.data);
      break;
    case "order.updated":
      await handleOrderUpdated(payload.data);
      break;
  }

  return new Response("OK", { status: 200 });
};

async function handleOrderCreated(data: unknown) { /* ... */ }
async function handleOrderUpdated(data: unknown) { /* ... */ }
```
