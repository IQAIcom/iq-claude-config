# IQ Best Practices

Pick what applies to your project. Paste into `CLAUDE.md`.

- Order methods by abstraction level: caller before callee, so reading top-to-bottom flows from high-level to low-level.
- Use `unknown` instead of `any`. If you need a type escape hatch, add a type assertion with a comment explaining why.
- No `console.log` in committed code.
- Default to Next.js for all new projects. Only use NestJS for blockchain indexers, heavy background processing, persistent WebSocket services, or compute-intensive work that would block Next.js.
- Use Server Components by default. Only add `'use client'` when the component needs interactivity. Use Server Actions for data mutations.
- Use Privy for authentication. Legacy projects may use @everipedia/iq-login — do not migrate unless asked. Never use NextAuth.js.
- Validate all user input with Zod. Never interpolate user input into raw queries.
- Mark server-only modules with `import 'server-only'`.
- Never expose sensitive data (password hashes, internal IDs, tokens) in API responses or logs.
