---
name: nextjs
description: Next.js App Router patterns, Server Components, Server Actions, and data fetching. Use when building web applications, APIs, or full-stack features with Next.js.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(npm:*, npx:*, pnpm:*, bun:*)
---

# Next.js Skill

Next.js is our primary full-stack framework. Use it for all web applications.

## When to Use

✅ Web applications
✅ APIs (Server Actions or Route Handlers)
✅ SSR/SSG content sites
✅ Full-stack features
✅ Everything except indexers/heavy background services

## Key Principles

1. **Server Components by default** - Only add 'use client' when needed
2. **Server Actions for mutations** - Not API routes
3. **Colocation** - Keep related files together
4. **Type safety** - Full TypeScript, no `any`

## Related Files

- [FOLDER_STRUCTURE.md](./FOLDER_STRUCTURE.md) - Project organization
- [SERVER_COMPONENTS.md](./SERVER_COMPONENTS.md) - RSC patterns and component structure
- [SERVER_ACTIONS.md](./SERVER_ACTIONS.md) - Data mutations
- [DATA_FETCHING.md](./DATA_FETCHING.md) - Fetching and caching
- [API_ROUTES.md](./API_ROUTES.md) - When to use Route Handlers
- [HOOKS.md](./HOOKS.md) - Custom hooks and TanStack Query patterns

## Quick Start

```bash
# Creates Next.js app with Tailwind + Shadcn pre-configured
npx shadcn@latest init my-app
cd my-app

# Then add Biome and common packages
npm install -D @biomejs/biome && npx biome init
npx shadcn@latest add button card input form toast
```

## Stack

- Next.js 15+ (App Router)
- TypeScript
- Tailwind CSS
- Shadcn UI
- Prisma (database)
- @everipedia/iq-login (auth)
