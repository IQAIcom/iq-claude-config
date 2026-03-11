# Data Fetching

## File Location

Data fetching functions live in `_actions.ts` colocated with each page:

```
app/users/
├── page.tsx
├── _components/
├── _hooks/
├── _schema.ts
└── _actions.ts    ← Data fetching functions here
```

```ts
// app/users/_actions.ts
'use server';

import 'server-only';
import { db } from '@/lib/integrations/db';

export async function getUsers() {
  return db.user.findMany({
    orderBy: { createdAt: 'desc' },
  });
}

export async function getUserById(id: string) {
  return db.user.findUnique({ where: { id } });
}
```

## Fetching in Server Components

### Using _actions.ts Functions

```tsx
// app/users/page.tsx
import { getUsers } from './_actions';

async function UsersPage() {
  const users = await getUsers();
  return <UserList users={users} />;
}
```

### Direct Database Access (simple cases)

```tsx
// app/users/page.tsx
import { db } from '@/lib/integrations/db';

async function UsersPage() {
  const users = await db.user.findMany({
    orderBy: { createdAt: 'desc' },
    take: 10,
  });

  return <UserList users={users} />;
}
```

### External API

```tsx
async function ProductsPage() {
  const res = await fetch('https://api.example.com/products', {
    next: { revalidate: 3600 }, // Cache for 1 hour
  });
  const products = await res.json();

  return <ProductList products={products} />;
}
```

## Caching Strategies

### Static (default)
```tsx
// Cached indefinitely (until revalidation)
const data = await fetch('https://api.example.com/data');
```

### Time-based Revalidation
```tsx
// Revalidate every hour
const data = await fetch('https://api.example.com/data', {
  next: { revalidate: 3600 },
});
```

### On-demand Revalidation
```tsx
// In your Server Action
import { revalidatePath, revalidateTag } from 'next/cache';

// Revalidate by path
revalidatePath('/products');

// Revalidate by tag
revalidateTag('products');

// Tag your fetches
const data = await fetch('https://api.example.com/products', {
  next: { tags: ['products'] },
});
```

### No Cache
```tsx
// Always fresh
const data = await fetch('https://api.example.com/data', {
  cache: 'no-store',
});
```

## Parallel Fetching

### Promise.all for independent data

```tsx
async function DashboardPage() {
  // ✅ Parallel - both start immediately
  const [users, products, orders] = await Promise.all([
    db.user.count(),
    db.product.count(),
    db.order.findMany({ take: 5 }),
  ]);

  return (
    <div>
      <Stats users={users} products={products} />
      <RecentOrders orders={orders} />
    </div>
  );
}
```

### Avoid waterfalls

```tsx
// ❌ Bad - sequential (waterfall)
async function Page() {
  const user = await getUser();
  const posts = await getPosts(user.id);  // Waits for user
  const comments = await getComments(posts[0].id);  // Waits for posts
}

// ✅ Good - parallel where possible
async function Page() {
  const user = await getUser();
  const [posts, notifications] = await Promise.all([
    getPosts(user.id),
    getNotifications(user.id),
  ]);
}
```

## Streaming with Suspense

### Loading states

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react';

async function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      
      <Suspense fallback={<StatsSkeleton />}>
        <Stats />
      </Suspense>
      
      <Suspense fallback={<ChartSkeleton />}>
        <AnalyticsChart />
      </Suspense>
    </div>
  );
}

// Each component fetches its own data
async function Stats() {
  const stats = await getStats();  // Slow query
  return <StatsDisplay stats={stats} />;
}
```

### loading.tsx (route-level)

```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return <DashboardSkeleton />;
}
```

## Data Fetching Patterns

### Colocated data functions (preferred)

```tsx
// app/users/_actions.ts
'use server';

import 'server-only';
import { db } from '@/lib/integrations/db';
import { cache } from 'react';

// Deduplicated within a single render
export const getUserById = cache(async (id: string) => {
  return db.user.findUnique({ where: { id } });
});

export async function getUsers() {
  return db.user.findMany({
    orderBy: { createdAt: 'desc' },
  });
}
```

### Use in page components

```tsx
// app/users/[id]/page.tsx
import { getUserById } from '../_actions';
import { notFound } from 'next/navigation';

async function UserPage({ params }: { params: { id: string } }) {
  const user = await getUserById(params.id);
  if (!user) notFound();

  return <UserProfile user={user} />;
}
```

## Error Handling

### error.tsx

```tsx
// app/users/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

### not-found.tsx

```tsx
// app/users/[id]/not-found.tsx
export default function NotFound() {
  return <div>User not found</div>;
}

// In page.tsx
import { notFound } from 'next/navigation';

async function UserPage({ params }) {
  const user = await getUser(params.id);
  if (!user) notFound();
}
```
