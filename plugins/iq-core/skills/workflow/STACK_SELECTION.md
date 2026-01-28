# Stack Selection Rule

## Default Stack: Next.js

All new projects and features should use **Next.js** as the full-stack framework unless explicitly specified otherwise.

### Next.js is used for:
- Web applications
- APIs (via Route Handlers or Server Actions)
- Full-stack features
- SSR/SSG content
- Everything that doesn't fall into NestJS exceptions

### Use Server Components by default
- Only add 'use client' when you need interactivity
- Use Server Actions for data mutations
- Fetch data in Server Components

## Exception: NestJS

Use NestJS **ONLY** for:

1. **Blockchain Indexers** - Long-running processes that index blockchain data
2. **Heavy Background Processing** - Jobs that would block Next.js
3. **Persistent WebSocket Services** - Real-time services requiring constant connections
4. **Compute-Intensive Operations** - CPU-heavy tasks that would impact web performance

### When in doubt:
- Start with Next.js
- Ask if NestJS is actually needed
- Don't create a separate backend "just in case"

## Anti-patterns to Avoid

❌ Creating NestJS backend for simple CRUD
❌ Splitting into monorepo when Next.js would suffice
❌ Using API routes when Server Actions work
❌ Adding 'use client' to components that don't need it
