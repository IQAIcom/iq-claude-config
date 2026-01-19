# Security Rules

## Secrets Management

### Never hardcode secrets
```typescript
// ❌ Bad
const apiKey = "sk_live_abc123";

// ✅ Good
const apiKey = process.env.API_KEY;
```

### Environment variables
- Use `.env.local` for local development
- Never commit `.env` files (ensure in `.gitignore`)
- Use platform secrets for production (Vercel, Railway, etc.)

## Input Validation

### Always validate user input
```typescript
// ✅ Use Zod for validation
const schema = z.object({
  email: z.string().email(),
  age: z.number().min(0).max(150),
});
```

### Sanitize before database queries
- Use Prisma (parameterized by default)
- Never interpolate user input into raw queries

## Authentication & Authorization

### Check auth on every protected route
```typescript
// ✅ Server Component
const session = await auth();
if (!session) redirect('/login');
```

### Check permissions, not just authentication
```typescript
// ✅ Verify ownership
if (resource.userId !== session.user.id) {
  throw new Error('Unauthorized');
}
```

## Data Exposure

### Never expose sensitive data
- Don't return password hashes, even if null
- Don't return internal IDs unnecessarily
- Use `select` in Prisma to limit fields

### Server-only code
```typescript
// ✅ Mark server-only modules
import 'server-only';
```

## Logging

### Never log sensitive data
```typescript
// ❌ Bad
console.log('User logged in:', { password, token });

// ✅ Good
console.log('User logged in:', { userId, email });
```

## Dependencies

### Keep dependencies updated
- Run `npm audit` regularly
- Update packages with known vulnerabilities
- Review new dependencies before adding
