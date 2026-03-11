# Component Testing

Testing React components with React Testing Library.

## Core Principles

1. **Test what users see** - Query by accessible roles, labels, and text
2. **Avoid implementation details** - Don't test internal state or component instances
3. **Simulate real interactions** - Use userEvent over fireEvent

## Query Priority

Prefer queries in this order:

1. `getByRole` - Accessible roles (button, textbox, heading)
2. `getByLabelText` - Form inputs with labels
3. `getByPlaceholderText` - Inputs without labels
4. `getByText` - Non-interactive text content
5. `getByTestId` - Last resort

```typescript
// ✅ Good - uses accessible queries
const button = screen.getByRole('button', { name: 'Submit' });
const emailInput = screen.getByLabelText('Email');

// ❌ Bad - uses implementation details
const button = container.querySelector('.submit-btn');
const emailInput = screen.getByTestId('email-input');
```

## Basic Component Test

```typescript
// app/users/_components/user-card.test.tsx
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { UserCard } from './user-card';

const mockUser = {
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
  role: 'admin',
};

describe('UserCard', () => {
  it('renders user information', () => {
    render(<UserCard user={mockUser} />);

    expect(screen.getByRole('heading', { name: 'John Doe' })).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
    expect(screen.getByText('admin')).toBeInTheDocument();
  });

  it('shows admin badge for admin users', () => {
    render(<UserCard user={mockUser} />);

    expect(screen.getByRole('status', { name: /admin/i })).toBeInTheDocument();
  });
});
```

## Testing User Interactions

```typescript
// app/users/_components/user-form.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserForm } from './user-form';

describe('UserForm', () => {
  it('submits form with user data', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();

    render(<UserForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText('Name'), 'John Doe');
    await user.type(screen.getByLabelText('Email'), 'john@example.com');
    await user.click(screen.getByRole('button', { name: 'Create User' }));

    expect(onSubmit).toHaveBeenCalledWith({
      name: 'John Doe',
      email: 'john@example.com',
    });
  });

  it('shows validation error for invalid email', async () => {
    const user = userEvent.setup();

    render(<UserForm onSubmit={vi.fn()} />);

    await user.type(screen.getByLabelText('Email'), 'invalid');
    await user.click(screen.getByRole('button', { name: 'Create User' }));

    expect(screen.getByText(/invalid email/i)).toBeInTheDocument();
  });

  it('disables submit button while loading', async () => {
    render(<UserForm onSubmit={vi.fn()} isLoading />);

    expect(screen.getByRole('button', { name: /creating/i })).toBeDisabled();
  });
});
```

## Testing Async Components

```typescript
// app/users/_components/user-list.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { UserList } from './user-list';

// Mock the fetch function
vi.mock('../_actions', () => ({
  getUsers: vi.fn().mockResolvedValue([
    { id: '1', name: 'User 1' },
    { id: '2', name: 'User 2' },
  ]),
}));

describe('UserList', () => {
  it('renders users after loading', async () => {
    render(<UserList />);

    // Wait for loading to complete
    await waitFor(() => {
      expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
    });

    expect(screen.getByText('User 1')).toBeInTheDocument();
    expect(screen.getByText('User 2')).toBeInTheDocument();
  });

  it('shows empty state when no users', async () => {
    const { getUsers } = await import('../_actions');
    vi.mocked(getUsers).mockResolvedValueOnce([]);

    render(<UserList />);

    await waitFor(() => {
      expect(screen.getByText(/no users found/i)).toBeInTheDocument();
    });
  });
});
```

## Testing with Providers

```typescript
// test/utils.tsx
import { ReactNode } from 'react';
import { render, RenderOptions } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'next-themes';

const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

interface WrapperProps {
  children: ReactNode;
}

function AllProviders({ children }: WrapperProps) {
  const queryClient = createTestQueryClient();

  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider attribute="class" defaultTheme="light">
        {children}
      </ThemeProvider>
    </QueryClientProvider>
  );
}

export function renderWithProviders(
  ui: React.ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) {
  return render(ui, { wrapper: AllProviders, ...options });
}

export * from '@testing-library/react';
export { renderWithProviders as render };
```

Usage:

```typescript
import { render, screen } from '@/test/utils';
import { Dashboard } from './dashboard';

describe('Dashboard', () => {
  it('renders with providers', () => {
    render(<Dashboard />);
    // Components have access to QueryClient, Theme, etc.
  });
});
```

## Testing Modals and Dialogs

```typescript
import { describe, it, expect, vi } from 'vitest';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { DeleteUserDialog } from './delete-user-dialog';

describe('DeleteUserDialog', () => {
  it('opens and confirms deletion', async () => {
    const user = userEvent.setup();
    const onDelete = vi.fn();

    render(<DeleteUserDialog userId="123" onDelete={onDelete} />);

    // Open dialog
    await user.click(screen.getByRole('button', { name: /delete/i }));

    // Find dialog
    const dialog = screen.getByRole('dialog');
    expect(dialog).toBeInTheDocument();

    // Confirm within dialog
    await user.click(within(dialog).getByRole('button', { name: /confirm/i }));

    expect(onDelete).toHaveBeenCalledWith('123');
  });

  it('closes on cancel', async () => {
    const user = userEvent.setup();

    render(<DeleteUserDialog userId="123" onDelete={vi.fn()} />);

    await user.click(screen.getByRole('button', { name: /delete/i }));
    await user.click(screen.getByRole('button', { name: /cancel/i }));

    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });
});
```

## Testing Accessibility

```typescript
import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import { UserForm } from './user-form';

expect.extend(toHaveNoViolations);

describe('UserForm accessibility', () => {
  it('has no accessibility violations', async () => {
    const { container } = render(<UserForm onSubmit={vi.fn()} />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```
