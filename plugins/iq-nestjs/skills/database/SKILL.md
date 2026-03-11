---
name: database
description: Prisma ORM patterns within NestJS modules, database schema design, and query conventions. Use when working with databases, writing migrations, or defining Prisma schemas in NestJS services.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(npx:prisma*)
---

# Database Skill (NestJS)

Database conventions and patterns using Prisma within NestJS applications.

## Stack

- **Prisma** - ORM
- **PostgreSQL** - Primary database (production)
- **SQLite** - Local development (optional)

## Related Files

- [PRISMA_PATTERNS.md](./PRISMA_PATTERNS.md) - Query patterns and best practices
- [SCHEMA_CONVENTIONS.md](./SCHEMA_CONVENTIONS.md) - Schema design conventions

## Quick Start

```bash
# Install
npm install prisma @prisma/client

# Initialize
npx prisma init

# After schema changes
npx prisma db push

# Pull schema from existing DB
npx prisma db pull

# Generate client
npx prisma generate

# View data
npx prisma studio
```

## Prisma as a NestJS Module

Create a dedicated `PrismaModule` to manage the Prisma client lifecycle within NestJS dependency injection:

```typescript
// prisma/prisma.service.ts
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
```

```typescript
// prisma/prisma.module.ts
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

## Using PrismaService in NestJS Services

```typescript
// users/users.service.ts
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany();
  }

  async findOne(id: string) {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async create(data: CreateUserDto) {
    return this.prisma.user.create({ data });
  }
}
```

## Register PrismaModule in AppModule

```typescript
// app.module.ts
import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [PrismaModule, UsersModule],
})
export class AppModule {}
```

## Testing with Mocked PrismaService

```typescript
// users/users.service.test.ts
import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../prisma/prisma.service';

const module: TestingModule = await Test.createTestingModule({
  providers: [
    UsersService,
    {
      provide: PrismaService,
      useValue: {
        user: {
          findMany: vi.fn(),
          findUnique: vi.fn(),
          create: vi.fn(),
        },
      },
    },
  ],
}).compile();
```
