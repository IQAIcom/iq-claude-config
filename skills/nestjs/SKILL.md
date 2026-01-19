# NestJS Skill

NestJS is used **ONLY** for specific use cases where Next.js is not suitable.

## ⚠️ When to Use NestJS

**Use NestJS only for:**

1. **Blockchain Indexers** - Long-running processes that index blockchain data
2. **Heavy Background Processing** - CPU-intensive jobs that would block web requests
3. **Persistent WebSocket Services** - Real-time services requiring constant connections
4. **Compute-Intensive Operations** - Tasks that would impact Next.js performance

**Do NOT use NestJS for:**
- Standard CRUD APIs (use Next.js Server Actions)
- Web applications (use Next.js)
- Simple backends (use Next.js API routes)

## When in Doubt

Start with Next.js. Only reach for NestJS if you have a specific, justified need.

## Related Files

- [FOLDER_STRUCTURE.md](./FOLDER_STRUCTURE.md) - Project organization
- [BEST_PRACTICES.md](./BEST_PRACTICES.md) - Patterns and conventions

## Quick Start

```bash
npm i -g @nestjs/cli
nest new my-indexer
```

## Stack

- NestJS
- TypeScript
- Prisma (database)
- Bull (job queues)
- class-validator (validation)
