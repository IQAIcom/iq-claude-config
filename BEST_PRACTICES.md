# IQ Team - CLAUDE.md Best Practices

Copy relevant sections into your project's `CLAUDE.md` file. Only include what matters for your project.

---

## Code Style

```markdown
## Code Style

- Order methods by abstraction level: caller before callee. Reading top-to-bottom should flow from high-level to low-level.
- Use `unknown` instead of `any`. If you need a type escape hatch, use a type assertion with a comment explaining why.
- Prefer interfaces for object shapes, types for unions and primitives.
- Explicit return types on exported functions.
```

## TypeScript Strictness

```markdown
## TypeScript

- Strict mode enabled. No implicit any, no unchecked index access.
- No `console.log` in production code — use a proper logger or remove after debugging.
- Prefer `const` assertions and `satisfies` over type annotations where possible.
```

## Prisma / Database

```markdown
## Database

- Use Prisma as the ORM. PostgreSQL in production, SQLite for local dev.
- Always use transactions for multi-step mutations.
- Never use raw SQL unless Prisma can't express the query.
- Run `npx prisma generate` after schema changes.
```

## Testing

```markdown
## Testing

- Use Vitest for unit/integration tests.
- Test behavior, not implementation details.
- Colocate test files next to source: `foo.test.ts` alongside `foo.ts`.
- Use MSW for mocking API calls, not manual fetch mocks.
```

## Auth

```markdown
## Auth

- Use Privy for authentication (wallet + social login).
- Legacy projects may use @everipedia/iq-login — do not migrate unless asked.
- Never use NextAuth.js.
```

## Tooling

```markdown
## Tooling

- Use Biome for formatting and linting (not ESLint/Prettier).
- Use pnpm as package manager.
- Use changesets for versioning in published packages.
```

## MCP Servers

```markdown
## MCP Server Conventions

- Package name: `@iqai/mcp-{name}`
- Tool names: snake_case
- Use FastMCP for simple servers, raw MCP SDK for complex ones.
- Validate env vars with Zod schemas.
- Keep tools thin — business logic goes in services/.
```

## Git

```markdown
## Git

- Conventional commits: feat, fix, docs, refactor, chore, test.
- Branch naming: feat/description, fix/description, docs/description.
```
