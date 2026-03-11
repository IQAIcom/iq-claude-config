---
name: testing
description: Testing patterns with Vitest, React Testing Library, and Playwright. Use when writing unit tests, integration tests, component tests, or E2E tests.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(npm:test*, npx:vitest*, npx:playwright*)
---

# Testing Skill

Testing conventions and patterns for maintaining code quality.

## Stack

- **Vitest** - Unit and integration tests (fast, Vite-native)
- **React Testing Library** - Component testing
- **Playwright** - E2E testing
- **MSW** - API mocking

## Related Files

- [VITEST_SETUP.md](./VITEST_SETUP.md) - Vitest configuration and patterns
- [COMPONENT_TESTING.md](./COMPONENT_TESTING.md) - React Testing Library patterns

## Quick Start

```bash
# Install Vitest
npm install -D vitest @vitejs/plugin-react jsdom

# Install Testing Library
npm install -D @testing-library/react @testing-library/jest-dom @testing-library/user-event

# Install Playwright
npm install -D @playwright/test
npx playwright install
```

## Test File Naming

| Type | Convention | Location |
|------|------------|----------|
| Unit tests | `*.test.ts` | Colocated with source |
| Component tests | `*.test.tsx` | Colocated with component |
| E2E tests | `*.spec.ts` | `e2e/` directory |

## Principles

1. **Test behavior, not implementation** - Focus on what users see and do
2. **Colocate tests** - Keep tests next to the code they test
3. **Avoid testing implementation details** - Don't test internal state or methods
4. **Use realistic data** - Test with data that resembles production
