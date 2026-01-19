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

### Colocation
Keep related files together:
```
app/users/
├── page.tsx           # Route
├── loading.tsx        # Loading UI
├── error.tsx          # Error UI
├── actions.ts         # Server actions for this route
└── components/        # Route-specific components
    └── user-table.tsx
```

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
| Server Actions | `actions/` or colocated |
| Shared components | `components/` |
| Route-specific components | `app/**/components/` |
| Database queries | `lib/db/` or in actions |
| Validation schemas | `lib/validations/` |
| Types | `types/` or colocated |
