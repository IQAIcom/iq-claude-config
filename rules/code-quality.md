# Code Quality Rules

## TypeScript

### No `any` type
```typescript
// ❌ Bad
function process(data: any) {}

// ✅ Good
function process(data: UserData) {}
function process(data: unknown) {} // if truly unknown
```

### Explicit return types for exports
```typescript
// ✅ Good
export function getUser(id: string): Promise<User | null> {}
```

### Use strict mode
```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true
  }
}
```

## Functions

### Single responsibility
- One function = one job
- If you need "and" to describe it, split it

### Size limits
- Functions: ~50 lines max
- Files: ~300 lines max
- Components: ~200 lines max

### Naming
```typescript
// ✅ Verbs for functions
function getUserById() {}
function validateEmail() {}
function handleSubmit() {}

// ✅ Nouns for variables
const user = {};
const isValid = true;
const userCount = 5;
```

## Error Handling

### Always handle errors
```typescript
// ✅ Good
try {
  await riskyOperation();
} catch (error) {
  logger.error('Operation failed', { error });
  throw new AppError('Failed to complete operation');
}
```

### Use custom error classes
```typescript
class AppError extends Error {
  constructor(message: string, public code: string) {
    super(message);
  }
}
```

## Imports

### Order imports
1. External packages
2. Internal aliases (@/)
3. Relative imports
4. Types

```typescript
import { useState } from 'react';
import { db } from '@/lib/db';
import { Button } from './Button';
import type { User } from '@/types';
```

### No unused imports
Run `eslint --fix` to auto-remove.

## Comments

### Don't comment obvious code
```typescript
// ❌ Bad
// Increment counter
counter++;

// ✅ Good - explain WHY
// Offset by 1 because API uses 1-based indexing
const page = index + 1;
```

### Use JSDoc for public APIs
```typescript
/**
 * Fetches user by ID from the database.
 * @param id - The user's unique identifier
 * @returns The user object or null if not found
 */
export async function getUser(id: string): Promise<User | null> {}
```

## No Debug Code in Commits

- Remove `console.log`
- Remove `debugger`
- Remove commented-out code
- Remove `// TODO` for completed items
