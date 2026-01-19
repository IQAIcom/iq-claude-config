# TypeScript Skill

TypeScript conventions and patterns used across all projects.

## Related Files

- [CONVENTIONS.md](./CONVENTIONS.md) - Detailed TypeScript conventions

## Quick Reference

### Strict Mode

Always use strict TypeScript:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true
  }
}
```

### No `any`

```typescript
// ❌ Bad
function process(data: any) {}

// ✅ Good
function process(data: unknown) {}
function process(data: UserData) {}
```

### Explicit Return Types

```typescript
// ✅ For exported functions
export function getUser(id: string): Promise<User | null> {}
```

### Prefer Interfaces for Objects

```typescript
// ✅ Interface for object shapes
interface User {
  id: string;
  name: string;
}

// ✅ Type for unions, primitives, utilities
type Status = 'pending' | 'active' | 'deleted';
type Nullable<T> = T | null;
```
