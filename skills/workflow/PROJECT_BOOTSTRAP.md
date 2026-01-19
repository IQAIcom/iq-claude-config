# Project Bootstrap

## Next.js Project (Default)

### Quick Start

```bash
npx create-next-app@latest my-app --typescript --tailwind --eslint --app --src-dir
cd my-app
```

### Post-Creation Setup

```bash
# Shadcn UI
npx shadcn-ui@latest init
npx shadcn-ui@latest add button card input form toast

# Prisma
npm install prisma @prisma/client
npx prisma init

# Auth (if needed)
npm install next-auth@beta

# Validation
npm install zod

# Dev tools
npm install -D prettier prettier-plugin-tailwindcss
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
NEXTAUTH_SECRET=""
NEXTAUTH_URL="http://localhost:3000"
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
| NEXTAUTH_SECRET | Auth secret | Yes |

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
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"

# Auth
NEXTAUTH_SECRET="generate-with-openssl-rand-base64-32"
NEXTAUTH_URL="http://localhost:3000"

# Third-party (example)
STRIPE_SECRET_KEY=""
STRIPE_WEBHOOK_SECRET=""
```
