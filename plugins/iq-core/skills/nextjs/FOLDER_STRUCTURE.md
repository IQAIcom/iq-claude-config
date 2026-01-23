# Next.js Folder Structure

## Recommended Structure

```
app/
├── layout.tsx                 # Root layout (ONLY here, not in groups)
├── loading.tsx                # Global loading
├── error.tsx                  # Global error
├── not-found.tsx              # 404 page
│
├── (layout)/                  # Layout components group
│   ├── client-providers.tsx   # Client-side providers (theme, query, etc.)
│   ├── navbar.tsx
│   ├── footer.tsx
│   └── _hooks/                # Layout-specific hooks if needed
│       └── use-navigation.ts
│
├── (landing)/                 # Homepage
│   ├── page.tsx
│   ├── _components/
│   │   ├── hero.tsx
│   │   ├── features.server.tsx
│   │   ├── features.loading.tsx
│   │   └── features.tsx
│   ├── _hooks/
│   │   └── use-scroll-animation.ts
│   └── _schema.ts
│
├── (auth)/                    # Auth pages group
│   ├── login/
│   │   ├── page.tsx
│   │   ├── _components/
│   │   └── _actions.ts
│   └── register/
│       ├── page.tsx
│       └── _components/
│
├── dashboard/                 # Dashboard pages
│   ├── page.tsx
│   ├── _components/
│   ├── _hooks/
│   ├── _schema.ts
│   ├── _actions.ts
│   └── settings/
│       ├── page.tsx
│       ├── _components/
│       └── _actions.ts
│
├── api/                       # Route Handlers (use sparingly)
│   └── webhooks/
│       └── route.ts
│
components/                    # Shared components
├── ui/                        # Shadcn UI components
│   ├── button.tsx
│   └── input.tsx
└── icons/                     # Icon components
    └── logo.tsx
│
lib/
├── integrations/              # External connections
│   ├── db.ts                  # Prisma client export
│   ├── safe-action.ts         # next-safe-action client
│   └── auth.ts                # Auth config
├── data/                      # Static data
│   ├── socials.ts             # Company social links
│   └── contracts.ts           # Contract ABIs, addresses
└── helpers/                   # Utility functions
    ├── range.ts
    ├── get-short-address.ts
    └── cn.ts                  # Tailwind class merge utility
│
messages/                      # i18n translations
├── en.json
└── es.json
```

## Core Principles

### 1. Colocation First
Keep related code together. If a component/hook is used in multiple places, keep it where it was first created and import from there.

```tsx
// First used in (landing), later needed in dashboard
import { PriceChart } from '@/app/(landing)/_components/price-chart';
```

Only move to `components/` when it's truly shared across many unrelated features.

### 2. No `src/` Directory
Everything lives at the root level - `app/`, `components/`, `lib/`, etc.

### 3. Root Layout Only
`layout.tsx` must be at the app root. Route groups cannot have their own layouts. Use the `(layout)` group for layout-related components.

```tsx
// app/layout.tsx
import { ClientProviders } from './(layout)/client-providers';
import { Navbar } from './(layout)/navbar';
import { Footer } from './(layout)/footer';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <ClientProviders>
          <Navbar />
          <main>{children}</main>
          <Footer />
        </ClientProviders>
      </body>
    </html>
  );
}
```

## Page Structure

Every page follows this pattern:

```
app/[page-name]/
├── page.tsx              # The page component
├── _components/          # Page-specific components
├── _hooks/               # Page-specific hooks
├── _schema.ts            # Zod schemas and types
└── _actions.ts           # Server actions and server functions
```

### `_actions.ts` Pattern

All server actions and server-only functions live in `_actions.ts`:

```ts
// app/users/_actions.ts
'use server';

import 'server-only';
import { db } from '@/lib/integrations/db';
import { actionClient } from '@/lib/integrations/safe-action';
import { z } from 'zod';
import { revalidatePath } from 'next/cache';

// Server action with next-safe-action
export const createUser = actionClient
  .schema(z.object({ name: z.string(), email: z.string().email() }))
  .action(async ({ parsedInput }) => {
    const user = await db.user.create({ data: parsedInput });
    revalidatePath('/users');
    return { user };
  });

// Server function (not an action, just server-only data fetching)
export async function getUsers() {
  return db.user.findMany();
}

export async function getUserById(id: string) {
  return db.user.findUnique({ where: { id } });
}
```

**Key points:**
- `'use server'` at the top marks all exports as server actions
- `import 'server-only'` prevents accidental client imports
- Contains both actions (mutations) and server functions (queries)
- Colocated with the page that uses them

### Example: Users Page

```
app/users/
├── page.tsx
├── _components/
│   ├── user-list.server.tsx    # Server component with data fetching
│   ├── user-list.loading.tsx   # Skeleton for suspense
│   ├── user-list.tsx           # Client component
│   ├── user-card.tsx
│   └── user-filters.tsx
├── _hooks/
│   └── use-user-filters.ts
├── _schema.ts
└── _actions.ts
```

## Component Naming Convention

For components with server/client split and loading states:

| File | Purpose |
|------|---------|
| `component.server.tsx` | Server component with data fetching, wrapped in Suspense |
| `component.loading.tsx` | Skeleton/loading UI shown during suspense |
| `component.tsx` | Client component with interactivity |

### Example: Feature with Suspense

```tsx
// _components/user-list.server.tsx
import { Suspense } from 'react';
import { UserList } from './user-list';
import { UserListLoading } from './user-list.loading';
import { getUsers } from '../_actions';

export async function UserListServer() {
  const users = await getUsers();

  return (
    <Suspense fallback={<UserListLoading />}>
      <UserList users={users} />
    </Suspense>
  );
}

// _components/user-list.loading.tsx
export function UserListLoading() {
  return (
    <div className="space-y-4">
      {Array.from({ length: 5 }).map((_, i) => (
        <Skeleton key={i} className="h-16 w-full" />
      ))}
    </div>
  );
}

// _components/user-list.tsx
'use client';

export function UserList({ users }: { users: User[] }) {
  // Interactive client component
}
```

## Route Groups

Use route groups `(folder)` for organization without affecting URLs:

| Group | Purpose | URL |
|-------|---------|-----|
| `(layout)` | Layout components (navbar, footer, providers) | N/A |
| `(landing)` | Homepage | `/` |
| `(auth)` | Auth pages | `/login`, `/register` |
| `(marketing)` | Marketing pages | `/about`, `/pricing` |

## lib/ Directory

### `lib/integrations/`
External service connections:

```tsx
// lib/integrations/db.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };
export const db = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db;

// lib/integrations/safe-action.ts
import { createSafeActionClient } from 'next-safe-action';
export const actionClient = createSafeActionClient();
```

### `lib/data/`
Static data and constants. Prefer colocation in components when possible:

```tsx
// Prefer: colocated in footer.tsx
const SOCIALS = [{ name: 'Twitter', url: '...' }];

// Only use lib/data/ for truly shared data:
// lib/data/contracts.ts
export const CONTRACTS = {
  mainnet: { token: '0x...' },
  testnet: { token: '0x...' },
};
```

### `lib/helpers/`
Small, reusable utility functions:

```tsx
// lib/helpers/range.ts
export const range = (start: number, end: number) =>
  Array.from({ length: end - start }, (_, i) => start + i);

// lib/helpers/get-short-address.ts
export const getShortAddress = (address: string) =>
  `${address.slice(0, 6)}...${address.slice(-4)}`;

// lib/helpers/cn.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
export const cn = (...inputs: ClassValue[]) => twMerge(clsx(inputs));
```

## File Naming

| Type | Convention | Example |
|------|------------|---------|
| Components | kebab-case | `user-card.tsx` |
| Server components | `.server.tsx` suffix | `user-list.server.tsx` |
| Loading components | `.loading.tsx` suffix | `user-list.loading.tsx` |
| Hooks | kebab-case, use- prefix | `use-user-filters.ts` |
| Schemas | `_schema.ts` | `_schema.ts` |
| Actions | `_actions.ts` | `_actions.ts` |
| Helpers | kebab-case | `get-short-address.ts` |

## What Goes Where

| File Type | Location |
|-----------|----------|
| Pages | `app/**/page.tsx` |
| Root layout | `app/layout.tsx` (only here) |
| Layout components | `app/(layout)/` |
| Page components | `app/**/_components/` |
| Page hooks | `app/**/_hooks/` |
| Page schemas | `app/**/_schema.ts` |
| Server actions | `app/**/_actions.ts` |
| Shared UI components | `components/ui/` |
| Icons | `components/icons/` |
| External integrations | `lib/integrations/` |
| Shared data | `lib/data/` |
| Helper utilities | `lib/helpers/` |
| i18n translations | `messages/` |

## Code Organization Principles

1. **Colocation over centralization** - Keep code where it's used, import when needed elsewhere
2. **No premature abstraction** - Only move to shared folders when truly needed
3. **Consistent page structure** - Every page has `_components/`, `_hooks/`, `_schema.ts`, `_actions.ts`
4. **Clear component roles** - `.server.tsx`, `.loading.tsx`, `.tsx` pattern
5. **Keep files under 500 lines** - Split into smaller components
