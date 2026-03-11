# IQ Best Practices

Company coding standards and conventions. Copy relevant sections into your project's `CLAUDE.md`.

## Code Quality

### TypeScript
- Strict mode always. No `any` — use `unknown` if truly unknown.
- Explicit return types on exported functions.
- Prefer interfaces for object shapes, types for unions and primitives.

```typescript
// ❌ Bad
function process(data: any) {}

// ✅ Good
function process(data: UserData) {}
function process(data: unknown) {}
```

### Functions
- Order methods by abstraction: caller before callee (top-to-bottom readability).
- One function = one job. If you need "and" to describe it, split it.
- Functions: ~50 lines max. Files: ~300 lines max. Components: ~200 lines max.

### Naming
```typescript
// Verbs for functions
function getUserById() {}
function validateEmail() {}

// Nouns for variables
const user = {};
const isValid = true;
```

### Imports
Order: external packages → internal aliases (`@/`) → relative imports → types.

```typescript
import { useState } from 'react';
import { db } from '@/lib/db';
import { Button } from './Button';
import type { User } from '@/types';
```

### Comments
Don't comment obvious code. Explain *why*, not *what*.

```typescript
// ❌ counter++;  // Increment counter
// ✅ const page = index + 1; // API uses 1-based indexing
```

### No Debug Code in Commits
Remove `console.log`, `debugger`, commented-out code, and completed `// TODO`s.

## Error Handling

```typescript
try {
  await riskyOperation();
} catch (error) {
  logger.error('Operation failed', { error });
  throw new AppError('Failed to complete operation');
}
```

Use custom error classes:
```typescript
class AppError extends Error {
  constructor(message: string, public code: string) {
    super(message);
  }
}
```

## Security

- Never hardcode secrets — use `process.env` and `.env.local`.
- Never commit `.env` files.
- Always validate user input with Zod.
- Use Prisma (parameterized queries) — never interpolate user input into raw queries.
- Check auth on every protected route. Check permissions, not just authentication.
- Never expose sensitive data (password hashes, internal IDs, tokens) in responses or logs.
- Mark server-only modules with `import 'server-only'`.

## Stack Selection

**Default: Next.js** for all new projects.

Use NestJS **only** for:
- Blockchain indexers
- Heavy background processing
- Persistent WebSocket services
- Compute-intensive operations that would block Next.js

When in doubt, start with Next.js.

## Tooling

- **Biome** for formatting and linting (not ESLint/Prettier).
- **pnpm** as package manager.
- **Vitest** for testing. Test behavior, not implementation. Colocate test files.
- **Prisma** as ORM. PostgreSQL in production, SQLite for local dev.
- **Changesets** for versioning in published packages.

## Git

Conventional commits: `feat`, `fix`, `docs`, `refactor`, `chore`, `test`.

```
feat(auth): add social login with Google
fix(api): handle null response from external service
```

Rules: lowercase, no period, under 72 chars, imperative mood ("add" not "added").

Branch naming: `feat/short-description`, `fix/short-description`.
