# Server Components

Server Components are the default in Next.js App Router. Use them unless you need client-side interactivity.

## When to Use Server vs Client

### Server Components (default)
- Fetch data
- Access backend resources
- Keep sensitive info on server
- Large dependencies
- No interactivity needed

### Client Components ('use client')
- useState, useEffect
- Event handlers (onClick, onChange)
- Browser APIs
- Interactive UI (forms, modals)
- Third-party client libraries

## Patterns

### Data Fetching in Server Components

```tsx
// app/users/page.tsx
async function UsersPage() {
  const users = await db.user.findMany();  // Direct DB access!
  
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### Mixing Server and Client

```tsx
// app/dashboard/page.tsx (Server Component)
import { InteractiveChart } from './chart';  // Client Component

async function DashboardPage() {
  const data = await fetchAnalytics();  // Server-side fetch
  
  return (
    <div>
      <h1>Dashboard</h1>
      <InteractiveChart data={data} />  {/* Pass data to client */}
    </div>
  );
}
```

```tsx
// app/dashboard/chart.tsx
'use client';

export function InteractiveChart({ data }) {
  const [filter, setFilter] = useState('all');
  // Interactive client logic
}
```

### Composing Server in Client

```tsx
// Server Component as child of Client Component
'use client';

export function Modal({ children }) {
  const [open, setOpen] = useState(false);
  return open ? <div className="modal">{children}</div> : null;
}

// Usage in Server Component
<Modal>
  <ServerComponent />  {/* This works! */}
</Modal>
```

## Common Mistakes

### ❌ Adding 'use client' unnecessarily

```tsx
// ❌ Bad - no interactivity needed
'use client';
export function UserCard({ user }) {
  return <div>{user.name}</div>;
}

// ✅ Good - keep as Server Component
export function UserCard({ user }) {
  return <div>{user.name}</div>;
}
```

### ❌ Fetching in Client Components

```tsx
// ❌ Bad - fetch in useEffect
'use client';
function Users() {
  const [users, setUsers] = useState([]);
  useEffect(() => {
    fetch('/api/users').then(r => r.json()).then(setUsers);
  }, []);
}

// ✅ Good - fetch in Server Component
async function Users() {
  const users = await db.user.findMany();
  return <UserList users={users} />;
}
```

### ❌ Passing functions to Client Components

```tsx
// ❌ Bad - can't serialize functions
<ClientComponent onSubmit={async (data) => {
  'use server';
  await db.user.create({ data });
}} />

// ✅ Good - use Server Actions
<ClientComponent action={createUser} />
```

## Performance Tips

1. **Push 'use client' down** - Keep it as low as possible in the tree
2. **Fetch early** - Fetch data as high up as possible
3. **Parallel fetching** - Use Promise.all for independent fetches
4. **Streaming** - Use loading.tsx and Suspense for better UX
