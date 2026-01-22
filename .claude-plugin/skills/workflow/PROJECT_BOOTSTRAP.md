# Project Bootstrap

## Next.js Project (Default)

### Quick Start

Use the shadcn CLI to scaffold a new Next.js project with Tailwind and shadcn pre-configured:

```bash
npx shadcn@latest init my-app
cd my-app
```

This automatically sets up:
- Next.js 16 with App Router
- TypeScript
- Tailwind CSS
- Shadcn UI configured
- Path aliases (`@/`)

### Post-Creation Setup

```bash
# Add common shadcn components
npx shadcn@latest add button card input form toast skeleton

# Install Biome (replaces ESLint + Prettier)
npm install -D @biomejs/biome
npx biome init

# Type-safe environment variables
npm install @t3-oss/env-nextjs

# Prisma
npm install prisma @prisma/client
npx prisma init

# Validation (already included with shadcn, but ensure it's there)
npm install zod

# Server actions
npm install next-safe-action server-only

# Auth (IQ Login)
pnpm install @everipedia/iq-login wagmi@2.x viem@2.x @web3auth/modal @web3auth/ethereum-provider @web3auth/web3auth-wagmi-connector
```

### Biome Configuration

Update `biome.json` after init:

```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.4/schema.json",
  "organizeImports": { "enabled": true },
  "linter": {
    "enabled": true,
    "rules": { "recommended": true }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "tab",
    "lineWidth": 100
  },
  "javascript": {
    "formatter": { "quoteStyle": "single" }
  }
}
```

Update `package.json` scripts:

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "format": "biome format --write ."
  }
}
```

Remove ESLint if present:

```bash
npm uninstall eslint eslint-config-next @eslint/eslintrc
rm -f .eslintrc.json eslint.config.mjs
```

### Environment Variables (t3-env)

Create `lib/env.ts` for type-safe environment variables:

```typescript
// lib/env.ts
import { createEnv } from '@t3-oss/env-nextjs';
import { z } from 'zod';

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  },
  client: {
    NEXT_PUBLIC_APP_URL: z.string().url(),
  },
  // For Next.js >= 13.4.4, only need to destructure client vars
  experimental__runtimeEnv: {
    NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
  },
});
```

Import in `app/layout.tsx` to validate on startup:

```typescript
import { env } from '@/lib/env';
```

### Essential Files

```bash
# Create lib structure
mkdir -p src/lib src/actions src/types

# Prisma client
cat > src/lib/db.ts << 'EOF'
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const db = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = db;
}
EOF

# Utils
cat > src/lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
EOF
```

### .env.local

```env
DATABASE_URL="postgresql://..."
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NEXT_PUBLIC_WEB3_AUTH_CLIENT_ID="your_web3auth_client_id"
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID="your_wallet_connect_project_id"
```

## NestJS Project (Indexer/Service)

### Quick Start

```bash
npm i -g @nestjs/cli
nest new my-service --strict
cd my-service
```

### Post-Creation Setup

```bash
# Prisma
npm install prisma @prisma/client
npx prisma init

# Config
npm install @nestjs/config

# Validation
npm install class-validator class-transformer

# Bull (for jobs)
npm install @nestjs/bull bull

# Dev
npm install -D @types/bull
```

## Checklist

### New Project

- [ ] Repository created
- [ ] `.gitignore` configured
- [ ] Environment variables documented
- [ ] README.md with setup instructions
- [ ] CI/CD configured
- [ ] Linting/formatting setup
- [ ] TypeScript strict mode

### First PR

- [ ] Basic folder structure
- [ ] Database schema (if applicable)
- [ ] Auth setup (if applicable)
- [ ] Base components/modules
- [ ] Dev environment instructions

## Project README Template

```markdown
# Project Name

Brief description.

## Getting Started

### Prerequisites

- Node.js 20+
- PostgreSQL (or Docker)

### Installation

\`\`\`bash
git clone <repo>
cd <project>
npm install
cp .env.example .env.local
# Edit .env.local with your values
npx prisma migrate dev
npm run dev
\`\`\`

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| DATABASE_URL | PostgreSQL connection | Yes |
| NEXT_PUBLIC_WEB3_AUTH_CLIENT_ID | Web3Auth client ID | Yes |
| NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID | WalletConnect project ID | Yes |

## Development

\`\`\`bash
npm run dev      # Start dev server
npm run build    # Build for production
npm run lint     # Run linter
npm run test     # Run tests
\`\`\`

## Deployment

Deployed via Vercel/Railway/etc.

## Contributing

See CONTRIBUTING.md
```

## .env.example

Always commit an example:

```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/mydb"

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"

# Auth (IQ Login)
NEXT_PUBLIC_WEB3_AUTH_CLIENT_ID="get-from-dashboard.web3auth.io"
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID="get-from-cloud.walletconnect.com"

# Third-party (example)
STRIPE_SECRET_KEY=""
STRIPE_WEBHOOK_SECRET=""
```
