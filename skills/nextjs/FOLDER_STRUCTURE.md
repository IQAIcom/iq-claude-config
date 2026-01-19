# Next.js Folder Structure

## Recommended Structure

```
src/
├── app/                      # App Router
│   ├── (auth)/              # Route group: auth pages
│   │   ├── login/
│   │   │   └── page.tsx
│   │   └── register/
│   │       └── page.tsx
│   ├── (dashboard)/         # Route group: protected pages
│   │   ├── layout.tsx       # Shared dashboard layout
│   │   ├── page.tsx         # Dashboard home
│   │   └── settings/
│   │       └── page.tsx
│   ├── api/                 # Route Handlers (use sparingly)
│   │   └── webhooks/
│   │       └── route.ts
│   ├── layout.tsx           # Root layout
│   ├── page.tsx             # Home page
│   ├── loading.tsx          # Global loading
│   ├── error.tsx            # Global error
│   └── not-found.tsx        # 404 page
│
├── components/              # React components
│   ├── ui/                  # Shadcn UI components
│   │   ├── button.tsx
│   │   └── input.tsx
│   ├── forms/              # Form components
│   │   └── login-form.tsx
│   ├── layouts/            # Layout components
│   │   └── sidebar.tsx
│   └── [feature]/          # Feature-specific components
│       └── user-card.tsx
│
├── lib/                    # Utilities and config
│   ├── db.ts              # Prisma client
│   ├── auth.ts            # Auth config
│   ├── utils.ts           # Helper functions
│   └── validations/       # Zod schemas
│       └── user.ts
│
├── actions/               # Server Actions
│   ├── user.ts
│   └── auth.ts
│
├── hooks/                 # Custom React hooks
│   └── use-user.ts
│
├── types/                 # TypeScript types
│   └── index.ts
│
└── styles/               # Global styles
    └── globals.css
```

## Conventions

### Route Groups `(folder)`
- Use for organizing without affecting URL
- `(auth)` → `/login`, `/register`
- `(dashboard)` → `/`, `/settings`

### Private Folders `_folder`
- Not accessible via routing
- For internal components within app/
- Use underscore prefix for co-located page resources

### Page Co-location Pattern
Keep related files together within each page:
```
app/users/
├── page.tsx           # Route
├── loading.tsx        # Loading UI
├── error.tsx          # Error UI
├── _actions.ts        # Server actions for this route
├── _components/       # Page-specific UI components
│   ├── user-table.tsx
│   └── user-filters.tsx
├── _hooks/            # Page-specific custom hooks
│   └── use-user-filters.ts
└── _schema/           # Zod schemas and TypeScript types
    └── user-filters.ts
```

### Component Naming Conventions
```
ComponentName.tsx          # Default (can be server or client)
ComponentName.server.tsx   # Explicit server component
ComponentName.loading.tsx  # Loading state component
ComponentName.error.tsx    # Error state component
```

- Name by functionality, not appearance (`UserActions` not `BlueButtons`)
- Group related variants with consistent naming
- Keep files under 500 lines - split if larger

### Feature Organization
For complex features, use nested directories:
```
app/dashboard/
├── page.tsx
├── layout.tsx              # Shared UI elements
├── analytics/
│   ├── page.tsx
│   ├── _components/
│   └── _hooks/
└── settings/
    ├── page.tsx
    ├── _components/
    └── _actions.ts
```

### Internationalization
```
src/
├── messages/
│   ├── en.json
│   └── es.json
└── app/
    └── [locale]/
        └── page.tsx
```

- Wrap user-facing text in translation functions
- Store translations in `src/messages/{locale}.json`
- Keep translation keys organized by feature/page
- Update all language files when adding text

### File Naming

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserCard.tsx` |
| Utilities | camelCase | `formatDate.ts` |
| Hooks | camelCase, use- prefix | `useUser.ts` |
| Actions | camelCase | `createUser.ts` |
| Types | PascalCase | `User.ts` |

## What Goes Where

| File Type | Location |
|-----------|----------|
| Pages | `app/**/page.tsx` |
| Layouts | `app/**/layout.tsx` |
| Server Actions | `app/**/_actions.ts` (colocated) or `actions/` |
| Page-specific components | `app/**/_components/` |
| Page-specific hooks | `app/**/_hooks/` |
| Page-specific schemas | `app/**/_schema/` |
| Shared components | `components/` |
| UI primitives | `components/ui/` (Shadcn) |
| Shared business components | `components/shared/` |
| Icons | `components/icons/` |
| Database queries | `lib/db/` or in actions |
| Validation schemas | `lib/validations/` |
| Types | `types/` or colocated |

## Code Organization Principles

1. **Prefer co-location over centralization** - Keep related code close in the file tree
2. **Maintain consistent patterns** - Same structure at each nesting level
3. **Split over grow** - Split complex components rather than creating large files
4. **Explicit naming** - Use descriptive names over abbreviations
5. **Single responsibility** - One component/hook = one job
