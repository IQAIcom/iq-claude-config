# Error Handling Strategy

## Core Principles

### 1. Always Handle Errors
Never leave a promise unhandled or an error swallowed silently.
```typescript
// ✅ Good
try {
  await riskyOperation();
} catch (error) {
  logger.error('Operation failed', { error });
  // Handle or rethrow
}
```

### 2. Use Custom Error Classes
Extend `Error` to create meaningful, typed exceptions.
```typescript
class AppError extends Error {
  constructor(message: string, public code: string, public statusCode: number = 500) {
    super(message);
    this.name = 'AppError';
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 'NOT_FOUND', 404);
  }
}
```

### 3. Fail Fast
Validate inputs and preconditions early.
```typescript
if (!input) throw new BadRequestError('Input required');
```

## Context-Specific Patterns

### API / Backend (NestJS/Next.js API)
- Catch errors at the controller/route handler level.
- Convert domain errors (e.g., `UserNotFound`) to HTTP responses (404).
- Use Global Exception Filters (NestJS) or middleware.

### Frontend (Next.js/React)
- Use Error Boundaries for UI crashes.
- Display user-friendly messages, log technical details.
- Handle loading/error states explicitly in components.
