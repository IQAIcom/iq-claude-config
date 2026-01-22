---
name: nestjs
description: NestJS patterns for blockchain indexers, background processing, and compute-intensive services. Use only for indexers, heavy background jobs, or persistent WebSocket services.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(npm:*, npx:*, nest:*)
---

# NestJS Skill

NestJS is used **ONLY** for specific use cases where Next.js is not suitable.

## ⚠️ When to Use NestJS

**Use NestJS only for:**

1. **Blockchain Indexers** - Long-running processes that index blockchain data
2. **Heavy Background Processing** - CPU-intensive jobs that would block web requests
3. **Persistent WebSocket Services** - Real-time services requiring constant connections
4. **Compute-Intensive Operations** - Tasks that would impact Next.js performance

**Do NOT use NestJS for:**
- Standard CRUD APIs (use Next.js Server Actions)
- Web applications (use Next.js)
- Simple backends (use Next.js API routes)

## When in Doubt

Start with Next.js. Only reach for NestJS if you have a specific, justified need.

## Related Files

- [FOLDER_STRUCTURE.md](./FOLDER_STRUCTURE.md) - Project organization
- [BEST_PRACTICES.md](./BEST_PRACTICES.md) - Patterns and conventions
- [INDEXER_PATTERNS.md](./INDEXER_PATTERNS.md) - Blockchain indexer patterns
- [WEBSOCKET_PATTERNS.md](./WEBSOCKET_PATTERNS.md) - WebSocket service patterns

## Quick Start

```bash
npm i -g @nestjs/cli
nest new my-indexer
```

## Stack

- NestJS
- TypeScript
- Prisma (database)
- Bull (job queues)
- class-validator (validation)

## Key Concepts

### Module Structure

```typescript
// modules/indexer/indexer.module.ts
@Module({
  imports: [
    BullModule.registerQueue({ name: 'blocks' }),
    PrismaModule,
  ],
  controllers: [IndexerController],
  providers: [IndexerService, BlockProcessor],
  exports: [IndexerService],
})
export class IndexerModule {}
```

### Service Pattern

```typescript
// modules/indexer/indexer.service.ts
@Injectable()
export class IndexerService {
  private readonly logger = new Logger(IndexerService.name);

  constructor(
    private readonly prisma: PrismaService,
    @InjectQueue('blocks') private readonly queue: Queue,
  ) {}

  async queueBlock(blockNumber: number) {
    await this.queue.add('process', { blockNumber }, {
      attempts: 3,
      backoff: { type: 'exponential', delay: 1000 },
    });
  }
}
```

### Processor Pattern

```typescript
// modules/indexer/processors/block.processor.ts
@Processor('blocks')
export class BlockProcessor {
  private readonly logger = new Logger(BlockProcessor.name);

  @Process('process')
  async handleBlock(job: Job<{ blockNumber: number }>) {
    this.logger.log(`Processing block ${job.data.blockNumber}`);
    // Process block...
  }

  @OnQueueFailed()
  onFailed(job: Job, error: Error) {
    this.logger.error(`Job ${job.id} failed: ${error.message}`);
  }
}
```
