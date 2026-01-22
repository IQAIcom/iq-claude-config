# React Hooks Patterns

Custom hooks for extracting and reusing logic across components.

## File Location

All hooks live in `_hooks/` colocated with each page:

```
app/users/
├── page.tsx
├── _components/
├── _hooks/           ← Hooks here
│   ├── use-user-filters.ts
│   └── use-user-selection.ts
├── _schema.ts
└── _actions.ts
```

**Colocation rule:** If a hook is needed in another page, import from the original location:

```tsx
// In app/dashboard/page.tsx, reusing a hook from users
import { useUserFilters } from '@/app/users/_hooks/use-user-filters';
```

Only move to a shared location when used across many unrelated features.

## Preferred Libraries

| Purpose | Library | When to Use |
|---------|---------|-------------|
| Async data | [TanStack Query](https://tanstack.com/query) | Server data fetching, caching, mutations |
| URL state | [nuqs](https://nuqs.dev) | Filters, pagination, search params |
| Complex state | [Zustand](https://zustand.docs.pmnd.rs) | Only when URL state isn't enough |
| Utility hooks | [usehooks-ts](https://usehooks-ts.com) | Common patterns (debounce, media query, etc.) |
| Schema validation | [Zod](https://zod.dev) | All input validation |

## Hook Structure Principles

1. **Custom Hooks for Logic** - Extract complex logic into custom hooks
2. **Single Responsibility** - Each hook handles one specific concern
3. **Clean API** - Return well-structured objects with named properties
4. **Reusability** - Design hooks for reuse across components
5. **Separation from UI** - Business logic lives in hooks, not components

## Basic Hook Pattern

```tsx
// _hooks/use-user.ts
import { useState, useEffect } from 'react';

interface UseUserReturn {
  user: User | null;
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}

export function useUser(userId: string): UseUserReturn {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const refetch = useCallback(() => {
    setIsLoading(true);
    setError(null);
    // fetch logic...
  }, [userId]);

  useEffect(() => {
    refetch();
  }, [refetch]);

  return { user, isLoading, error, refetch };
}
```

## URL State with nuqs (Preferred)

Use [nuqs](https://nuqs.dev) for URL-based state management. Keeps state in the URL for shareability and back/forward navigation.

```bash
npm install nuqs
```

### Basic Usage

```tsx
'use client';

import { useQueryState } from 'nuqs';

export function SearchInput() {
  const [search, setSearch] = useQueryState('q');

  return (
    <input
      value={search ?? ''}
      onChange={(e) => setSearch(e.target.value || null)}
      placeholder="Search..."
    />
  );
}
// URL: /users?q=john
```

### With Parsers

```tsx
import { useQueryState, parseAsInteger, parseAsStringEnum } from 'nuqs';

export function UserFilters() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1));
  const [sort, setSort] = useQueryState(
    'sort',
    parseAsStringEnum(['name', 'date', 'email']).withDefault('name')
  );
  const [status, setStatus] = useQueryState(
    'status',
    parseAsStringEnum(['active', 'inactive', 'all']).withDefault('all')
  );

  return (
    <div>
      <select value={sort} onChange={(e) => setSort(e.target.value)}>
        <option value="name">Name</option>
        <option value="date">Date</option>
      </select>
      <button onClick={() => setPage(page + 1)}>Next Page</button>
    </div>
  );
}
// URL: /users?page=2&sort=date&status=active
```

### Multiple Params with useQueryStates

```tsx
import { useQueryStates, parseAsInteger, parseAsString } from 'nuqs';

const filtersParsers = {
  page: parseAsInteger.withDefault(1),
  search: parseAsString.withDefault(''),
  category: parseAsString,
};

export function useFilters() {
  const [filters, setFilters] = useQueryStates(filtersParsers);

  const resetFilters = () => setFilters({
    page: 1,
    search: '',
    category: null,
  });

  return { filters, setFilters, resetFilters };
}
```

### Server Component Integration

```tsx
// app/users/page.tsx
import { searchParamsCache } from './search-params';

export default function UsersPage({
  searchParams,
}: {
  searchParams: { [key: string]: string | string[] | undefined };
}) {
  const { page, search } = searchParamsCache.parse(searchParams);

  const users = await getUsers({ page, search });

  return <UserList users={users} />;
}
```

---

## TanStack Query

Use TanStack Query for async data fetching:

```tsx
// _hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Query hook
export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => fetch('/api/users').then(r => r.json()),
  });
}

// Query with parameters
export function useUser(userId: string) {
  return useQuery({
    queryKey: ['users', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(r => r.json()),
    enabled: !!userId,
  });
}

// Mutation hook
export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateUserInput) =>
      fetch('/api/users', {
        method: 'POST',
        body: JSON.stringify(data),
      }).then(r => r.json()),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

---

## Zustand (Complex State Only)

Use [Zustand](https://zustand.docs.pmnd.rs) only when URL state (nuqs) isn't sufficient - e.g., complex nested state, cross-component state that shouldn't be in the URL.

```bash
npm install zustand
```

### Basic Store

```tsx
// stores/cart-store.ts
import { create } from 'zustand';

interface CartItem {
  id: string;
  name: string;
  quantity: number;
  price: number;
}

interface CartStore {
  items: CartItem[];
  addItem: (item: Omit<CartItem, 'quantity'>) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, quantity: number) => void;
  clearCart: () => void;
  total: () => number;
}

export const useCartStore = create<CartStore>((set, get) => ({
  items: [],

  addItem: (item) =>
    set((state) => {
      const existing = state.items.find((i) => i.id === item.id);
      if (existing) {
        return {
          items: state.items.map((i) =>
            i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i
          ),
        };
      }
      return { items: [...state.items, { ...item, quantity: 1 }] };
    }),

  removeItem: (id) =>
    set((state) => ({
      items: state.items.filter((i) => i.id !== id),
    })),

  updateQuantity: (id, quantity) =>
    set((state) => ({
      items: state.items.map((i) => (i.id === id ? { ...i, quantity } : i)),
    })),

  clearCart: () => set({ items: [] }),

  total: () => get().items.reduce((sum, i) => sum + i.price * i.quantity, 0),
}));
```

### Usage in Components

```tsx
'use client';

import { useCartStore } from '@/stores/cart-store';

export function CartSummary() {
  const items = useCartStore((state) => state.items);
  const total = useCartStore((state) => state.total());
  const clearCart = useCartStore((state) => state.clearCart);

  return (
    <div>
      <p>{items.length} items - ${total}</p>
      <button onClick={clearCart}>Clear</button>
    </div>
  );
}
```

### With Persistence

```tsx
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useCartStore = create<CartStore>()(
  persist(
    (set, get) => ({
      // ... store implementation
    }),
    { name: 'cart-storage' }
  )
);
```

### When to Use Zustand vs nuqs

| Use nuqs (URL state) | Use Zustand |
|---------------------|-------------|
| Filters, search, pagination | Shopping cart |
| Tab selection | Multi-step form wizard state |
| Sort order | Real-time collaboration state |
| Any state that should be shareable via URL | Complex nested objects |

---

## usehooks-ts Utility Hooks

Use [usehooks-ts](https://usehooks-ts.com) for common utility hooks instead of writing your own.

```bash
npm install usehooks-ts
```

### Common Hooks

```tsx
import {
  useDebounceValue,
  useLocalStorage,
  useMediaQuery,
  useCopyToClipboard,
  useOnClickOutside,
  useEventListener,
  useInterval,
} from 'usehooks-ts';

// Debounced search
const [debouncedSearch] = useDebounceValue(search, 300);

// Persistent state
const [theme, setTheme] = useLocalStorage('theme', 'light');

// Responsive design
const isMobile = useMediaQuery('(max-width: 768px)');

// Clipboard
const [copiedText, copy] = useCopyToClipboard();

// Click outside (for dropdowns/modals)
const ref = useRef(null);
useOnClickOutside(ref, () => setIsOpen(false));
```

---

## Form Hooks

```tsx
// _hooks/use-user-form.ts
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { userSchema, type UserFormData } from '../_schema/user';

export function useUserForm(defaultValues?: Partial<UserFormData>) {
  const form = useForm<UserFormData>({
    resolver: zodResolver(userSchema),
    defaultValues: {
      name: '',
      email: '',
      ...defaultValues,
    },
  });

  return form;
}
```

## State Management Hooks

> **Note:** Prefer nuqs for filter/pagination state - see "URL State with nuqs" section above.

For local component state that shouldn't be in the URL:

```tsx
// _hooks/use-selection.ts
import { useState, useCallback } from 'react';

export function useSelection<T extends string>() {
  const [selected, setSelected] = useState<Set<T>>(new Set());

  const toggle = useCallback((id: T) => {
    setSelected(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }, []);

  const selectAll = useCallback((ids: T[]) => {
    setSelected(new Set(ids));
  }, []);

  const clear = useCallback(() => {
    setSelected(new Set());
  }, []);

  return { selected, toggle, selectAll, clear, count: selected.size };
}
```

## Hook Composition

Compose smaller hooks into larger ones:

```tsx
// _hooks/use-user-management.ts
export function useUserManagement() {
  const users = useUsers();
  const createUser = useCreateUser();
  const deleteUser = useDeleteUser();
  const { value: isFormOpen, setTrue: openForm, setFalse: closeForm } = useToggle();
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);

  const selectedUser = useMemo(
    () => users.data?.find(u => u.id === selectedUserId),
    [users.data, selectedUserId]
  );

  return {
    // Data
    users: users.data ?? [],
    selectedUser,
    isLoading: users.isLoading,

    // Actions
    createUser: createUser.mutate,
    deleteUser: deleteUser.mutate,
    selectUser: setSelectedUserId,

    // UI State
    isFormOpen,
    openForm,
    closeForm,
  };
}
```

## Best Practices

### Do
- Use nuqs for URL-based state (filters, pagination, search)
- Use TanStack Query for async data fetching
- Use usehooks-ts for common utilities (debounce, toggle, etc.)
- Return objects with named properties (not arrays)
- Include loading and error states
- Use TypeScript for return types

### Don't
- Use Zustand when nuqs would work (prefer URL state)
- Write custom hooks that usehooks-ts already provides
- Fetch data in hooks when Server Components can do it
- Put UI logic in hooks
- Create hooks for simple one-liners
