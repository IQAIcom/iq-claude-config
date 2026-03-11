---
name: testing
description: Testing patterns with Vitest and Playwright for NestJS backend services. Use when writing unit tests, integration tests, or E2E tests for controllers, services, guards, and pipes.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(npm:test*, npx:vitest*, npx:playwright*)
---

# Testing Skill (NestJS)

Testing conventions and patterns for NestJS backend services.

## Stack

- **Vitest** - Unit and integration tests (fast, Vite-native)
- **Playwright** - E2E testing
- **MSW** - External API mocking
- **supertest** - HTTP endpoint testing

## Related Files

- [VITEST_SETUP.md](./VITEST_SETUP.md) - Vitest configuration and patterns

## Quick Start

```bash
# Install Vitest
npm install -D vitest unplugin-swc

# Install supertest for HTTP testing
npm install -D supertest @types/supertest

# Install Playwright
npm install -D @playwright/test
npx playwright install
```

## Test File Naming

| Type | Convention | Location |
|------|------------|----------|
| Unit tests | `*.test.ts` | Colocated with source |
| Integration tests | `*.integration.test.ts` | Colocated or `test/` directory |
| E2E tests | `*.spec.ts` | `e2e/` or `test/` directory |

## Testing NestJS Services

```typescript
// users/users.service.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../prisma/prisma.service';

describe('UsersService', () => {
  let service: UsersService;
  let prisma: PrismaService;

  beforeEach(async () => {
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
              update: vi.fn(),
              delete: vi.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  it('should return all users', async () => {
    const mockUsers = [{ id: '1', name: 'Test User' }];
    vi.mocked(prisma.user.findMany).mockResolvedValue(mockUsers);

    const result = await service.findAll();

    expect(result).toEqual(mockUsers);
    expect(prisma.user.findMany).toHaveBeenCalledOnce();
  });
});
```

## Testing NestJS Controllers

```typescript
// users/users.controller.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

describe('UsersController', () => {
  let controller: UsersController;
  let service: UsersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        {
          provide: UsersService,
          useValue: {
            findAll: vi.fn(),
            findOne: vi.fn(),
            create: vi.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    service = module.get<UsersService>(UsersService);
  });

  it('should return all users', async () => {
    const mockUsers = [{ id: '1', name: 'Test' }];
    vi.mocked(service.findAll).mockResolvedValue(mockUsers);

    const result = await controller.findAll();

    expect(result).toEqual(mockUsers);
  });
});
```

## Testing Guards

```typescript
// auth/jwt-auth.guard.test.ts
import { describe, it, expect, vi } from 'vitest';
import { ExecutionContext } from '@nestjs/common';
import { JwtAuthGuard } from './jwt-auth.guard';

describe('JwtAuthGuard', () => {
  it('should allow authenticated requests', async () => {
    const guard = new JwtAuthGuard();
    const context = {
      switchToHttp: () => ({
        getRequest: () => ({ user: { id: '1' } }),
      }),
    } as unknown as ExecutionContext;

    const result = await guard.canActivate(context);

    expect(result).toBe(true);
  });
});
```

## Testing with Dependency Injection

When testing modules with complex DI trees, mock only direct dependencies:

```typescript
// Good - mock only what the service directly depends on
const module = await Test.createTestingModule({
  providers: [
    TargetService,
    { provide: DependencyA, useValue: { method: vi.fn() } },
    { provide: DependencyB, useValue: { method: vi.fn() } },
  ],
}).compile();

// Bad - importing the entire module brings unnecessary dependencies
const module = await Test.createTestingModule({
  imports: [EntireAppModule],
}).compile();
```

## Integration Testing with supertest

```typescript
// test/users.integration.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Users (integration)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = module.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /users returns 200', async () => {
    const response = await request(app.getHttpServer())
      .get('/users')
      .expect(200);

    expect(response.body).toBeInstanceOf(Array);
  });
});
```

## Principles

1. **Test behavior, not implementation** - Focus on inputs and outputs of services/controllers
2. **Colocate tests** - Keep tests next to the code they test
3. **Mock at the boundary** - Mock databases, external APIs, not internal services
4. **Use NestJS testing utilities** - Leverage `Test.createTestingModule` for proper DI
5. **Use realistic data** - Test with data that resembles production
