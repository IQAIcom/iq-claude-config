# NestJS Folder Structure

## Recommended Structure

```
src/
├── main.ts                    # Entry point
├── app.module.ts              # Root module
│
├── config/                    # Configuration
│   ├── config.module.ts
│   ├── database.config.ts
│   └── app.config.ts
│
├── common/                    # Shared utilities
│   ├── decorators/
│   ├── filters/
│   │   └── http-exception.filter.ts
│   ├── guards/
│   │   └── auth.guard.ts
│   ├── interceptors/
│   │   └── logging.interceptor.ts
│   ├── pipes/
│   │   └── validation.pipe.ts
│   └── utils/
│
├── modules/                   # Feature modules
│   ├── indexer/              # Blockchain indexer module
│   │   ├── indexer.module.ts
│   │   ├── indexer.service.ts
│   │   ├── indexer.controller.ts
│   │   ├── dto/
│   │   │   └── index-request.dto.ts
│   │   └── entities/
│   │       └── block.entity.ts
│   │
│   └── jobs/                 # Background jobs module
│       ├── jobs.module.ts
│       ├── jobs.service.ts
│       └── processors/
│           └── sync.processor.ts
│
├── prisma/                   # Prisma
│   ├── prisma.module.ts
│   └── prisma.service.ts
│
└── types/                    # TypeScript types
    └── index.ts
```

## Module Structure

Each module follows this pattern:

```
modules/[feature]/
├── [feature].module.ts       # Module definition
├── [feature].controller.ts   # HTTP endpoints (if needed)
├── [feature].service.ts      # Business logic
├── dto/                      # Data transfer objects
│   ├── create-[feature].dto.ts
│   └── update-[feature].dto.ts
├── entities/                 # Database entities
│   └── [feature].entity.ts
└── interfaces/               # TypeScript interfaces
    └── [feature].interface.ts
```

## File Naming

| Type | Convention | Example |
|------|------------|---------|
| Modules | kebab-case | `user.module.ts` |
| Controllers | kebab-case | `user.controller.ts` |
| Services | kebab-case | `user.service.ts` |
| DTOs | kebab-case | `create-user.dto.ts` |
| Entities | kebab-case | `user.entity.ts` |
| Guards | kebab-case | `auth.guard.ts` |
| Filters | kebab-case | `http-exception.filter.ts` |

## Indexer-Specific Structure

For blockchain indexers:

```
src/modules/indexer/
├── indexer.module.ts
├── indexer.service.ts        # Main indexing orchestration
├── processors/
│   ├── block.processor.ts    # Process blocks
│   ├── transaction.processor.ts
│   └── event.processor.ts
├── providers/
│   └── rpc.provider.ts       # Blockchain RPC connection
├── entities/
│   ├── block.entity.ts
│   ├── transaction.entity.ts
│   └── event.entity.ts
└── interfaces/
    └── chain.interface.ts
```
