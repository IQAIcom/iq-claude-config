# E2E Testing with Playwright

End-to-end testing for critical user flows.

## Setup

```bash
npm install -D @playwright/test
npx playwright install
```

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

## Package.json Scripts

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug"
  }
}
```

## Test Structure

```
e2e/
├── auth.spec.ts           # Authentication flows
├── dashboard.spec.ts      # Dashboard features
├── users.spec.ts          # User management
└── fixtures/
    ├── auth.ts            # Auth helpers
    └── test-data.ts       # Test data
```

## Basic E2E Test

```typescript
// e2e/home.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Home page', () => {
  test('displays hero section', async ({ page }) => {
    await page.goto('/');

    await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
    await expect(page.getByRole('link', { name: /get started/i })).toBeVisible();
  });

  test('navigates to features on click', async ({ page }) => {
    await page.goto('/');

    await page.getByRole('link', { name: /features/i }).click();

    await expect(page).toHaveURL(/.*#features/);
  });
});
```

## Authentication Flow

```typescript
// e2e/fixtures/auth.ts
import { test as base, Page } from '@playwright/test';

export const test = base.extend<{ authenticatedPage: Page }>({
  authenticatedPage: async ({ page }, use) => {
    // Login before test
    await page.goto('/login');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await page.waitForURL('/dashboard');

    await use(page);
  },
});

export { expect } from '@playwright/test';
```

```typescript
// e2e/dashboard.spec.ts
import { test, expect } from './fixtures/auth';

test.describe('Dashboard', () => {
  test('shows user data after login', async ({ authenticatedPage: page }) => {
    await expect(page.getByText('Welcome back')).toBeVisible();
    await expect(page.getByRole('navigation')).toContainText('Dashboard');
  });

  test('can update profile', async ({ authenticatedPage: page }) => {
    await page.getByRole('link', { name: 'Settings' }).click();
    await page.getByLabel('Display Name').fill('New Name');
    await page.getByRole('button', { name: 'Save' }).click();

    await expect(page.getByText('Profile updated')).toBeVisible();
  });
});
```

## Form Testing

```typescript
// e2e/users.spec.ts
import { test, expect } from './fixtures/auth';

test.describe('User management', () => {
  test('creates a new user', async ({ authenticatedPage: page }) => {
    await page.goto('/users');
    await page.getByRole('button', { name: 'Add User' }).click();

    // Fill form
    await page.getByLabel('Name').fill('Jane Doe');
    await page.getByLabel('Email').fill('jane@example.com');
    await page.getByLabel('Role').selectOption('editor');

    // Submit
    await page.getByRole('button', { name: 'Create' }).click();

    // Verify
    await expect(page.getByText('User created successfully')).toBeVisible();
    await expect(page.getByRole('row', { name: /jane doe/i })).toBeVisible();
  });

  test('shows validation errors', async ({ authenticatedPage: page }) => {
    await page.goto('/users');
    await page.getByRole('button', { name: 'Add User' }).click();

    // Submit empty form
    await page.getByRole('button', { name: 'Create' }).click();

    await expect(page.getByText('Name is required')).toBeVisible();
    await expect(page.getByText('Email is required')).toBeVisible();
  });
});
```

## API Mocking

```typescript
// e2e/dashboard.spec.ts
import { test, expect } from '@playwright/test';

test('handles API errors gracefully', async ({ page }) => {
  // Mock API to return error
  await page.route('**/api/users', (route) => {
    route.fulfill({
      status: 500,
      body: JSON.stringify({ error: 'Internal server error' }),
    });
  });

  await page.goto('/users');

  await expect(page.getByText(/something went wrong/i)).toBeVisible();
  await expect(page.getByRole('button', { name: /retry/i })).toBeVisible();
});

test('shows loading state', async ({ page }) => {
  // Delay API response
  await page.route('**/api/users', async (route) => {
    await new Promise((r) => setTimeout(r, 2000));
    route.continue();
  });

  await page.goto('/users');

  await expect(page.getByRole('status', { name: /loading/i })).toBeVisible();
});
```

## Visual Testing

```typescript
// e2e/visual.spec.ts
import { test, expect } from '@playwright/test';

test('homepage matches snapshot', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png', {
    fullPage: true,
    maxDiffPixels: 100,
  });
});

test('dark mode renders correctly', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: /theme/i }).click();
  await page.getByRole('menuitem', { name: /dark/i }).click();

  await expect(page).toHaveScreenshot('homepage-dark.png');
});
```

## Mobile Testing

```typescript
// e2e/mobile.spec.ts
import { test, expect, devices } from '@playwright/test';

test.use({ ...devices['iPhone 13'] });

test('mobile navigation works', async ({ page }) => {
  await page.goto('/');

  // Open mobile menu
  await page.getByRole('button', { name: /menu/i }).click();

  await expect(page.getByRole('navigation')).toBeVisible();
  await page.getByRole('link', { name: /features/i }).click();

  await expect(page).toHaveURL(/.*features/);
});
```

## Debugging Tips

```typescript
// Pause execution for debugging
await page.pause();

// Take screenshot at any point
await page.screenshot({ path: 'debug.png' });

// Log page content
console.log(await page.content());

// Slow down execution
test.use({ launchOptions: { slowMo: 500 } });
```

## Best Practices

1. **Test critical paths** - Focus on user journeys that matter (auth, checkout, etc.)
2. **Keep tests independent** - Each test should work in isolation
3. **Use page objects for complex pages** - Encapsulate selectors and actions
4. **Avoid flaky selectors** - Use roles, labels, and test IDs
5. **Run in CI** - Catch regressions before deployment
