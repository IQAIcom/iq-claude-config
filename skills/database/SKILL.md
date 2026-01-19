# Database Skill

Database conventions and patterns using Prisma.

## Stack

- **Prisma** - ORM
- **PostgreSQL** - Primary database (production)
- **SQLite** - Local development (optional)

## Related Files

- [PRISMA_PATTERNS.md](./PRISMA_PATTERNS.md) - Query patterns and best practices
- [SCHEMA_CONVENTIONS.md](./SCHEMA_CONVENTIONS.md) - Schema design conventions

## Quick Start

```bash
# Install
npm install prisma @prisma/client

# Initialize
npx prisma init

# After schema changes
npx prisma migrate dev

# Generate client
npx prisma generate

# View data
npx prisma studio
```

## Prisma Client Setup

```typescript
// lib/db.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const db = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = db;
}
```
