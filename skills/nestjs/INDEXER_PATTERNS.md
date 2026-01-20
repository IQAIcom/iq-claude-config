# Blockchain Indexer Patterns

Patterns for building reliable blockchain indexers with NestJS.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Indexer Service                         │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  RPC Provider │  │  Block Queue │  │   Database   │      │
│  │  (ethers.js)  │  │    (Bull)    │  │   (Prisma)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                 │                 │               │
│         ▼                 ▼                 ▼               │
│  ┌──────────────────────────────────────────────────┐      │
│  │              Block Processor                      │      │
│  │  - Fetch block data                               │      │
│  │  - Parse transactions                             │      │
│  │  - Extract events                                 │      │
│  │  - Store in database                              │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## RPC Provider Setup

```typescript
// providers/rpc.provider.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ethers } from 'ethers';

@Injectable()
export class RpcProvider implements OnModuleInit {
  private provider: ethers.JsonRpcProvider;

  constructor(private readonly config: ConfigService) {}

  onModuleInit() {
    this.provider = new ethers.JsonRpcProvider(
      this.config.get('RPC_URL'),
    );
  }

  getProvider(): ethers.JsonRpcProvider {
    return this.provider;
  }

  async getBlock(blockNumber: number) {
    return this.provider.getBlock(blockNumber, true);
  }

  async getLatestBlockNumber(): Promise<number> {
    return this.provider.getBlockNumber();
  }
}
```

## Indexer Service

```typescript
// modules/indexer/indexer.service.ts
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { PrismaService } from '@/prisma/prisma.service';
import { RpcProvider } from '@/providers/rpc.provider';

@Injectable()
export class IndexerService implements OnModuleInit {
  private readonly logger = new Logger(IndexerService.name);
  private isRunning = false;

  constructor(
    private readonly rpc: RpcProvider,
    private readonly prisma: PrismaService,
    @InjectQueue('blocks') private readonly blockQueue: Queue,
  ) {}

  async onModuleInit() {
    await this.startIndexing();
  }

  async startIndexing() {
    if (this.isRunning) return;
    this.isRunning = true;

    const lastIndexed = await this.getLastIndexedBlock();
    const latestBlock = await this.rpc.getLatestBlockNumber();

    this.logger.log(`Starting from block ${lastIndexed + 1} to ${latestBlock}`);

    // Queue historical blocks
    for (let i = lastIndexed + 1; i <= latestBlock; i++) {
      await this.queueBlock(i);
    }

    // Subscribe to new blocks
    this.rpc.getProvider().on('block', (blockNumber: number) => {
      this.queueBlock(blockNumber);
    });
  }

  async queueBlock(blockNumber: number) {
    await this.blockQueue.add(
      'process',
      { blockNumber },
      {
        jobId: `block-${blockNumber}`, // Prevent duplicates
        attempts: 5,
        backoff: { type: 'exponential', delay: 1000 },
        removeOnComplete: 100,
        removeOnFail: 1000,
      },
    );
  }

  private async getLastIndexedBlock(): Promise<number> {
    const last = await this.prisma.block.findFirst({
      orderBy: { number: 'desc' },
    });
    return last?.number ?? 0;
  }
}
```

## Block Processor

```typescript
// modules/indexer/processors/block.processor.ts
import { Processor, Process, OnQueueFailed, OnQueueCompleted } from '@nestjs/bull';
import { Logger } from '@nestjs/common';
import { Job } from 'bull';
import { PrismaService } from '@/prisma/prisma.service';
import { RpcProvider } from '@/providers/rpc.provider';

interface BlockJob {
  blockNumber: number;
}

@Processor('blocks')
export class BlockProcessor {
  private readonly logger = new Logger(BlockProcessor.name);

  constructor(
    private readonly rpc: RpcProvider,
    private readonly prisma: PrismaService,
  ) {}

  @Process('process')
  async processBlock(job: Job<BlockJob>) {
    const { blockNumber } = job.data;

    // Fetch block with transactions
    const block = await this.rpc.getBlock(blockNumber);
    if (!block) {
      throw new Error(`Block ${blockNumber} not found`);
    }

    // Store block and transactions in a transaction
    await this.prisma.$transaction(async (tx) => {
      // Store block
      await tx.block.upsert({
        where: { number: blockNumber },
        create: {
          number: blockNumber,
          hash: block.hash!,
          timestamp: new Date(block.timestamp * 1000),
          transactionCount: block.transactions.length,
        },
        update: {},
      });

      // Process transactions
      for (const txHash of block.transactions) {
        if (typeof txHash === 'string') continue;

        await tx.transaction.upsert({
          where: { hash: txHash.hash },
          create: {
            hash: txHash.hash,
            blockNumber,
            from: txHash.from,
            to: txHash.to ?? null,
            value: txHash.value.toString(),
          },
          update: {},
        });
      }
    });

    this.logger.debug(`Processed block ${blockNumber}`);
  }

  @OnQueueCompleted()
  onCompleted(job: Job<BlockJob>) {
    this.logger.verbose(`Block ${job.data.blockNumber} completed`);
  }

  @OnQueueFailed()
  onFailed(job: Job<BlockJob>, error: Error) {
    this.logger.error(
      `Block ${job.data.blockNumber} failed: ${error.message}`,
      error.stack,
    );
  }
}
```

## Event Parsing

```typescript
// modules/indexer/services/event-parser.service.ts
import { Injectable } from '@nestjs/common';
import { ethers, Interface, Log } from 'ethers';

const ERC20_ABI = [
  'event Transfer(address indexed from, address indexed to, uint256 value)',
  'event Approval(address indexed owner, address indexed spender, uint256 value)',
];

@Injectable()
export class EventParserService {
  private readonly erc20Interface = new Interface(ERC20_ABI);

  parseTransferEvent(log: Log) {
    try {
      const parsed = this.erc20Interface.parseLog({
        topics: log.topics as string[],
        data: log.data,
      });

      if (parsed?.name !== 'Transfer') return null;

      return {
        from: parsed.args.from,
        to: parsed.args.to,
        value: parsed.args.value.toString(),
        contractAddress: log.address,
        blockNumber: log.blockNumber,
        transactionHash: log.transactionHash,
      };
    } catch {
      return null;
    }
  }
}
```

## Health Check

```typescript
// modules/indexer/indexer.controller.ts
import { Controller, Get } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { PrismaService } from '@/prisma/prisma.service';
import { RpcProvider } from '@/providers/rpc.provider';

@Controller('indexer')
export class IndexerController {
  constructor(
    private readonly rpc: RpcProvider,
    private readonly prisma: PrismaService,
    @InjectQueue('blocks') private readonly blockQueue: Queue,
  ) {}

  @Get('health')
  async health() {
    const [latestBlock, lastIndexed, queueStatus] = await Promise.all([
      this.rpc.getLatestBlockNumber(),
      this.prisma.block.findFirst({ orderBy: { number: 'desc' } }),
      this.blockQueue.getJobCounts(),
    ]);

    const lag = latestBlock - (lastIndexed?.number ?? 0);

    return {
      status: lag < 100 ? 'healthy' : 'catching_up',
      latestBlock,
      lastIndexed: lastIndexed?.number ?? 0,
      lag,
      queue: queueStatus,
    };
  }
}
```

## Error Recovery

```typescript
// modules/indexer/services/recovery.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { PrismaService } from '@/prisma/prisma.service';
import { IndexerService } from '../indexer.service';

@Injectable()
export class RecoveryService {
  private readonly logger = new Logger(RecoveryService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly indexer: IndexerService,
  ) {}

  // Check for gaps every 5 minutes
  @Cron('*/5 * * * *')
  async checkForGaps() {
    const gaps = await this.findGaps();

    if (gaps.length > 0) {
      this.logger.warn(`Found ${gaps.length} gaps, re-indexing...`);
      for (const blockNumber of gaps) {
        await this.indexer.queueBlock(blockNumber);
      }
    }
  }

  private async findGaps(): Promise<number[]> {
    // Find missing block numbers
    const result = await this.prisma.$queryRaw<{ missing: number }[]>`
      WITH block_range AS (
        SELECT generate_series(
          (SELECT MIN(number) FROM "Block"),
          (SELECT MAX(number) FROM "Block")
        ) AS number
      )
      SELECT number AS missing
      FROM block_range
      WHERE number NOT IN (SELECT number FROM "Block")
      LIMIT 1000
    `;

    return result.map((r) => r.missing);
  }
}
```

## Configuration

```typescript
// config/indexer.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('indexer', () => ({
  rpcUrl: process.env.RPC_URL,
  startBlock: parseInt(process.env.START_BLOCK ?? '0', 10),
  batchSize: parseInt(process.env.BATCH_SIZE ?? '100', 10),
  confirmations: parseInt(process.env.CONFIRMATIONS ?? '12', 10),
}));
```
