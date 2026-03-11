# Vitest Setup

## Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./vitest.setup.ts'],
    include: ['**/*.test.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', '**/*.d.ts', '**/*.config.*'],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './'),
    },
  },
});
```

```typescript
// vitest.setup.ts
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

afterEach(() => {
  cleanup();
});
```

## Package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

## Unit Test Patterns

### Basic Test Structure

```typescript
// lib/helpers/format-date.test.ts
import { describe, it, expect } from 'vitest';
import { formatDate } from './format-date';

describe('formatDate', () => {
  it('formats date in US format', () => {
    const date = new Date('2024-01-15');
    expect(formatDate(date)).toBe('January 15, 2024');
  });

  it('handles invalid date', () => {
    expect(formatDate(null)).toBe('Invalid date');
  });
});
```

### Testing Async Functions

```typescript
// lib/api/users.test.ts
import { describe, it, expect, vi } from 'vitest';
import { fetchUser } from './users';

describe('fetchUser', () => {
  it('fetches user by id', async () => {
    const user = await fetchUser('123');
    expect(user).toHaveProperty('id', '123');
  });

  it('throws on not found', async () => {
    await expect(fetchUser('invalid')).rejects.toThrow('User not found');
  });
});
```

### Mocking

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { db } from '@/lib/integrations/db';
import { getUsers } from './users';

// Mock the database module
vi.mock('@/lib/integrations/db', () => ({
  db: {
    user: {
      findMany: vi.fn(),
    },
  },
}));

describe('getUsers', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns users from database', async () => {
    const mockUsers = [{ id: '1', name: 'Test' }];
    vi.mocked(db.user.findMany).mockResolvedValue(mockUsers);

    const users = await getUsers();

    expect(users).toEqual(mockUsers);
    expect(db.user.findMany).toHaveBeenCalledOnce();
  });
});
```

### Testing Server Actions

```typescript
// app/users/_actions.test.ts
import { describe, it, expect, vi } from 'vitest';
import { createUser } from './_actions';

vi.mock('@/lib/integrations/db', () => ({
  db: {
    user: {
      create: vi.fn().mockResolvedValue({ id: '1', name: 'Test', email: 'test@example.com' }),
    },
  },
}));

vi.mock('next/cache', () => ({
  revalidatePath: vi.fn(),
}));

describe('createUser', () => {
  it('creates user with valid input', async () => {
    const result = await createUser({ name: 'Test', email: 'test@example.com' });

    expect(result.data?.user).toHaveProperty('id');
  });

  it('fails with invalid email', async () => {
    const result = await createUser({ name: 'Test', email: 'invalid' });

    expect(result.validationErrors).toBeDefined();
  });
});
```

## Testing Hooks

```typescript
// app/dashboard/_hooks/use-user-filters.test.ts
import { describe, it, expect } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useUserFilters } from './use-user-filters';

describe('useUserFilters', () => {
  it('initializes with default filters', () => {
    const { result } = renderHook(() => useUserFilters());

    expect(result.current.filters).toEqual({
      search: '',
      status: 'all',
    });
  });

  it('updates search filter', () => {
    const { result } = renderHook(() => useUserFilters());

    act(() => {
      result.current.setSearch('test');
    });

    expect(result.current.filters.search).toBe('test');
  });
});
```

## Snapshot Testing

Use sparingly, only for stable UI:

```typescript
import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/react';
import { Badge } from '@/components/ui/badge';

describe('Badge', () => {
  it('matches snapshot', () => {
    const { container } = render(<Badge>Active</Badge>);
    expect(container).toMatchSnapshot();
  });
});
```
