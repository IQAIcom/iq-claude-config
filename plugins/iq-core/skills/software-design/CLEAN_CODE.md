# Clean Code Standards

## Naming Conventions

### General
- **Explicit over Implicit**: Names should reveal intent.
- **Consistent**: Use the same term for the same concept (e.g., don't mix `fetch`, `get`, `retrieve`).

### Specifics
- **Functions**: Verbs (`getUser`, `validateEmail`).
- **Variables**: Nouns (`user`, `isValid`).
- **Booleans**: `is`, `has`, `should` prefixes (`isActive`, `hasPermission`).
- **Interfaces**: PascalCase, nouns (`UserProfile`).
- **Types**: PascalCase (`UserId`).

## Functions

### Single Responsibility
- One function = one job.
- If you need "and" to describe what it does, split it.

### Size Limits
- **Functions**: ~50 lines max.
- **Files**: ~300 lines max.
- **Components**: ~200 lines max.

### Arguments
- Limit to 3 arguments max. Use an object/interface for more.

## Comments

### Don't Comment Obvious Code
```typescript
// ❌ Bad
// Increment counter
counter++;
```

### Explain "Why", not "What"
```typescript
// ✅ Good
// Offset by 1 because API uses 1-based indexing
const page = index + 1;
```

### JSDoc for Public APIs
Use JSDoc for exported functions and interfaces to provide hover documentation.

## File Structure

### Imports Order
1. External packages (`react`, `lodash`)
2. Internal aliases (`@/lib`, `@/components`)
3. Relative imports (`./Button`)
4. Types (`import type ...`)

### No Unused Imports
Always remove unused imports (use ESLint/Biome to automate).
