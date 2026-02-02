# NestJS Best Practices

## Dependency Injection

### Always use constructor injection

```typescript
@Injectable()
export class UserService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {}
}
```

### Scope properly

```typescript
// Default: Singleton (shared across all requests)
@Injectable()
export class CacheService {}

// Request-scoped (new instance per request)
@Injectable({ scope: Scope.REQUEST })
export class RequestContextService {}
```

## Validation

### Use DTOs with class-validator

```typescript
// dto/create-user.dto.ts
import { IsEmail, IsString, MinLength } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  name: string;

  @IsEmail()
  email: string;
}
```

### Enable global validation pipe

```typescript
// main.ts
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,        // Strip unknown properties
  forbidNonWhitelisted: true,  // Throw on unknown properties
  transform: true,        // Transform to DTO class instance
}));
```

## Error Handling

> For general error handling strategies, see [Error Handling](../software-design/ERROR_HANDLING.md).

### Use built-in exceptions

```typescript
import { 
  NotFoundException, 
  BadRequestException,
  UnauthorizedException 
} from '@nestjs/common';

@Injectable()
export class UserService {
  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User ${id} not found`);
    }
    return user;
  }
}
```

### Create custom exceptions

```typescript
export class InsufficientFundsException extends HttpException {
  constructor() {
    super('Insufficient funds', HttpStatus.BAD_REQUEST);
  }
}
```

### Global exception filter

```typescript
// common/filters/http-exception.filter.ts
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    
    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      message: exception instanceof Error ? exception.message : 'Unknown error',
    });
  }
}
```

## Configuration

### Use ConfigModule

```typescript
// app.module.ts
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: Joi.object({
        DATABASE_URL: Joi.string().required(),
        PORT: Joi.number().default(3000),
      }),
    }),
  ],
})
export class AppModule {}
```

### Type-safe config

```typescript
// config/database.config.ts
export default registerAs('database', () => ({
  url: process.env.DATABASE_URL,
  logging: process.env.NODE_ENV !== 'production',
}));

// Usage
@Injectable()
export class DbService {
  constructor(
    @Inject('database') private dbConfig: ConfigType<typeof databaseConfig>,
  ) {
    console.log(this.dbConfig.url);
  }
}
```

## Background Jobs

### Use Bull for job queues

```typescript
// jobs/jobs.module.ts
@Module({
  imports: [
    BullModule.registerQueue({
      name: 'indexer',
    }),
  ],
})
export class JobsModule {}

// processors/sync.processor.ts
@Processor('indexer')
export class SyncProcessor {
  @Process('sync-block')
  async handleSync(job: Job<{ blockNumber: number }>) {
    // Process the job
  }
}

// Add job
@Injectable()
export class IndexerService {
  constructor(@InjectQueue('indexer') private queue: Queue) {}

  async queueBlock(blockNumber: number) {
    await this.queue.add('sync-block', { blockNumber });
  }
}
```

## Logging

### Use built-in logger

```typescript
import { Logger } from '@nestjs/common';

@Injectable()
export class IndexerService {
  private readonly logger = new Logger(IndexerService.name);

  async processBlock(number: number) {
    this.logger.log(`Processing block ${number}`);
    this.logger.debug('Debug info');
    this.logger.error('Error occurred', error.stack);
  }
}
```

## Testing

### Unit tests

```typescript
describe('UserService', () => {
  let service: UserService;
  let prisma: DeepMockProxy<PrismaService>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UserService,
        { provide: PrismaService, useValue: mockDeep<PrismaService>() },
      ],
    }).compile();

    service = module.get(UserService);
    prisma = module.get(PrismaService);
  });

  it('should find user', async () => {
    prisma.user.findUnique.mockResolvedValue({ id: '1', name: 'Test' });
    const user = await service.findOne('1');
    expect(user.name).toBe('Test');
  });
});
```
