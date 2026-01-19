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

## Component Structure Patterns

### Composition Over Ternaries

```tsx
// ❌ Bad - complex ternaries
function UserSection({ user, isLoading, error }) {
  return (
    <div>
      {isLoading ? <Spinner /> : error ? <Error /> : user ? <UserCard user={user} /> : <Empty />}
    </div>
  );
}

// ✅ Good - separate state components
function UserSection({ user, isLoading, error }) {
  if (isLoading) return <UserSection.Loading />;
  if (error) return <UserSection.Error error={error} />;
  if (!user) return <UserSection.Empty />;
  return <UserCard user={user} />;
}

UserSection.Loading = () => <Spinner />;
UserSection.Error = ({ error }) => <Alert>{error.message}</Alert>;
UserSection.Empty = () => <p>No user found</p>;
```

### Clean Component Hierarchy

```tsx
// ✅ Single responsibility with clear separation
// page.tsx - data fetching
async function UsersPage() {
  const users = await getUsers();
  return <UserList users={users} />;
}

// _components/user-list.tsx - list rendering
function UserList({ users }) {
  return (
    <ul>
      {users.map(user => <UserListItem key={user.id} user={user} />)}
    </ul>
  );
}

// _components/user-list-item.tsx - item rendering
function UserListItem({ user }) {
  return <li>{user.name}</li>;
}
```

### Explicit State Components

Create dedicated components for each UI state:

```tsx
// _components/users.loading.tsx
export function UsersLoading() {
  return <Skeleton count={5} />;
}

// _components/users.error.tsx
export function UsersError({ retry }: { retry: () => void }) {
  return (
    <Alert variant="error">
      <p>Failed to load users</p>
      <Button onClick={retry}>Retry</Button>
    </Alert>
  );
}

// _components/users.empty.tsx
export function UsersEmpty() {
  return <p>No users yet. Create your first user.</p>;
}
```

### Tailwind with cn() Utility

```tsx
import { cn } from '@/lib/utils';

interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

function Button({ variant = 'primary', size = 'md', className, ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        'rounded font-medium transition-colors',
        variant === 'primary' && 'bg-blue-500 text-white hover:bg-blue-600',
        variant === 'secondary' && 'bg-gray-200 text-gray-900 hover:bg-gray-300',
        size === 'sm' && 'px-2 py-1 text-sm',
        size === 'md' && 'px-4 py-2',
        size === 'lg' && 'px-6 py-3 text-lg',
        className
      )}
      {...props}
    />
  );
}
```

### Declarative Components

Components should express *what* they render, not *how*:

```tsx
// ❌ Imperative - focuses on how
function UserCard({ user }) {
  const formattedDate = new Date(user.createdAt).toLocaleDateString();
  const initials = user.name.split(' ').map(n => n[0]).join('');

  return (
    <div>
      <div className="avatar">{initials}</div>
      <div>{user.name}</div>
      <div>Joined {formattedDate}</div>
    </div>
  );
}

// ✅ Declarative - focuses on what
function UserCard({ user }) {
  return (
    <Card>
      <Avatar name={user.name} />
      <UserName name={user.name} />
      <JoinDate date={user.createdAt} />
    </Card>
  );
}
```
