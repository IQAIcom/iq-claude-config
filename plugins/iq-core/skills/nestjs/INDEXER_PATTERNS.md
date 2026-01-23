# Indexer Patterns

## Overview

Patterns for building reliable blockchain indexers with NestJS. This document covers the cron-based event polling pattern used at IQ AI for the Agent Tokenization Platform.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Indexer Architecture                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │  Cron Jobs   │───▶│ JobQueueSvc  │───▶│EventEmitter  │       │
│  │  (Schedule)  │    │ (Dedup/Lock) │    │  (Dispatch)  │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│         │                                       │                │
│         ▼                                       ▼                │
│  ┌──────────────┐                      ┌──────────────┐         │
│  │  PM2/Manual  │                      │ IndexerSvc   │         │
│  │  Trigger     │                      │ (Job Logic)  │         │
│  └──────────────┘                      └──────────────┘         │
│                                               │                  │
│                    ┌──────────────────────────┼───────┐         │
│                    ▼                          ▼       ▼         │
│            ┌─────────────┐           ┌──────────┐ ┌────────┐   │
│            │ BlockchainSvc│           │ Factory  │ │Proposal│   │
│            │ (Viem + RPC) │           │ Service  │ │Service │   │
│            └─────────────┘           └──────────┘ └────────┘   │
│                    │                        │          │        │
│                    ▼                        ▼          ▼        │
│            ┌─────────────┐           ┌───────────────────┐     │
│            │getLogsChunked│           │   Repositories    │     │
│            │(999 blocks)  │           │     (Prisma)      │     │
│            └─────────────┘           └───────────────────┘     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**How it works:**
1. Cron job fires on schedule (e.g., EVERY_2_HOURS)
2. JobQueueService prevents concurrent execution of the same job
3. Job fetches events via `getLogs(fromBlock, toBlock)`
4. Events are processed and stored
5. Checkpoint is updated for next run

---

## Core Components

### 1. Blockchain Service (RPC Layer)

Handles multi-chain RPC connections with fallback support.

```typescript
// modules/common/blockchain.service.ts
import { Injectable, Logger } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import {
  createPublicClient,
  fallback,
  http,
  PublicClient,
  Chain,
  type Log,
} from 'viem'
import { fraxtal } from 'viem/chains'

interface ChainConfig {
  id: number
  name: string
  chain: Chain
  blockExplorerUrl: string
  apiUrl: string
}

@Injectable()
export class BlockchainService {
  private readonly logger = new Logger(BlockchainService.name)
  private readonly chunkSize = 999 // RPC limit for getLogs

  private chainConfigs: Map<number, ChainConfig> = new Map()
  private clients: Map<number, PublicClient> = new Map()
  private defaultChainId: number

  constructor(private configService: ConfigService) {
    this.initializeChainConfigs()
    this.defaultChainId = this.configService.get<number>('chain.defaultId')!
  }

  private initializeChainConfigs() {
    // Initialize default chain (Fraxtal)
    const fraxtalRpcUrls = this.configService.get<string[]>('chain.fraxtal.rpcUrls')!

    this.clients.set(
      fraxtal.id,
      createPublicClient({
        chain: fraxtal,
        transport: fallback(
          fraxtalRpcUrls.map((url) => http(url)),
          { rank: true }, // Auto-rank by latency/reliability
        ),
        batch: { multicall: true },
      }),
    )

    // Add additional chains from environment
    const chainIds = this.configService.get<string>('SUPPORTED_CHAIN_IDS')?.split(',') || []

    for (const chainIdStr of chainIds) {
      const chainId = Number(chainIdStr.trim())
      if (chainId === this.defaultChainId || Number.isNaN(chainId)) continue

      const prefix = `CHAIN_${chainId}`
      const rpcUrls = this.configService.get<string>(`${prefix}_RPC_URLS`)?.split(',') || []

      if (rpcUrls.length > 0) {
        const customChain = this.buildChainConfig(chainId, prefix)
        this.clients.set(
          chainId,
          createPublicClient({
            chain: customChain,
            transport: fallback(
              rpcUrls.map((url) => http(url)),
              { rank: true },
            ),
          }),
        )
      }
    }
  }

  getClient(chainId: number): PublicClient {
    const client = this.clients.get(chainId)
    if (!client) {
      throw new Error(`No client configured for chain ID ${chainId}`)
    }
    return client
  }

  /**
   * Fetch logs with automatic chunking to respect RPC limits.
   * Most RPCs limit getLogs to ~1000 blocks per request.
   */
  async getLogsChunked(
    params: Parameters<PublicClient['getLogs']>[0] & {
      fromBlock: bigint
      toBlock?: bigint | 'latest'
    },
    chainId: number = this.defaultChainId,
  ): Promise<Log[]> {
    const client = this.getClient(chainId)

    const resolvedToBlock =
      params.toBlock === 'latest' || params.toBlock === undefined
        ? await client.getBlockNumber()
        : params.toBlock

    const from = params.fromBlock
    const to = resolvedToBlock

    if (to < from) return []

    const totalRange = Number(to - from)

    // No chunking needed if within limit
    if (totalRange <= this.chunkSize) {
      return await client.getLogs({ ...params, toBlock: to })
    }

    // Chunk the request
    const allLogs: Log[] = []
    let currentFrom = from

    while (currentFrom <= to) {
      const currentTo = currentFrom + BigInt(this.chunkSize) - 1n > to
        ? to
        : currentFrom + BigInt(this.chunkSize) - 1n

      try {
        const logs = await client.getLogs({
          ...params,
          fromBlock: currentFrom,
          toBlock: currentTo,
        })
        allLogs.push(...logs)
      } catch (error) {
        this.logger.error(
          `getLogsChunked error: blocks ${currentFrom}-${currentTo} on chain ${chainId}`,
          error,
        )
        throw error
      }

      currentFrom = currentTo + 1n
    }

    return allLogs
  }
}
```

**Key patterns:**
- **Fallback transport with ranking**: viem auto-selects the fastest/most reliable RPC
- **Chunked log fetching**: Respects RPC limits (typically 999-1000 blocks)
- **Multi-chain client map**: One client per chain, lazy initialization

---

### 2. Job Queue Service

In-memory job locking and deduplication. Prevents concurrent execution of the same job.

```typescript
// modules/indexer/job-queue.service.ts
import { Injectable, Logger } from '@nestjs/common'
import { EventEmitter2 } from '@nestjs/event-emitter'

export enum TriggerSource {
  Cron = 'cron',
  OnDemand = 'on-demand',
}

export interface JobTriggerContext {
  source: TriggerSource
}

interface JobQueueItem {
  jobName: string
  queuedAt: Date
  source: TriggerSource
}

@Injectable()
export class JobQueueService {
  private readonly logger = new Logger(JobQueueService.name)
  private runningJobs: Map<string, boolean> = new Map()
  private jobQueues: Map<string, JobQueueItem[]> = new Map()
  private readonly QUEUE_DELAY_MS = 5000

  constructor(private eventEmitter: EventEmitter2) {}

  async queueOrExecuteJob(
    jobName: string,
    source: TriggerSource = TriggerSource.OnDemand,
  ): Promise<void> {
    const isRunning = this.runningJobs.get(jobName)

    if (isRunning) {
      const queue = this.jobQueues.get(jobName) || []
      const alreadyQueued = queue.some((item) => item.jobName === jobName)

      if (!alreadyQueued) {
        queue.push({ jobName, queuedAt: new Date(), source })
        this.jobQueues.set(jobName, queue)
        this.logger.log(`Job "${jobName}" queued - already running`)
      }
    } else {
      await this.executeJob(jobName, source)
    }
  }

  private async executeJob(jobName: string, source: TriggerSource): Promise<void> {
    this.runningJobs.set(jobName, true)
    this.logger.log(`Starting job: ${jobName} (source: ${source})`)

    try {
      const context: JobTriggerContext = { source }
      await this.eventEmitter.emitAsync(jobName, context)
    } catch (error) {
      this.logger.error(`Job "${jobName}" failed:`, error)
    } finally {
      this.logger.log(`Completed job: ${jobName}`)
      await this.processQueue(jobName)
    }
  }

  private async processQueue(jobName: string): Promise<void> {
    const queue = this.jobQueues.get(jobName) || []

    if (queue.length > 0) {
      await new Promise((resolve) => setTimeout(resolve, this.QUEUE_DELAY_MS))

      const nextJob = queue.shift()
      this.jobQueues.set(jobName, queue)

      if (nextJob) {
        await this.executeJob(nextJob.jobName, nextJob.source)
      }
    } else {
      this.runningJobs.set(jobName, false)
    }
  }

  isJobRunning(jobName: string): boolean {
    return this.runningJobs.get(jobName) || false
  }
}
```

**Key patterns:**
- **In-memory locking**: Prevents same job from running concurrently
- **Queue with delay**: If job triggered while running, queues for execution after completion
- **Deduplication**: Won't queue the same job twice
- **Trigger source tracking**: Distinguishes cron vs on-demand triggers

---

### 3. Indexer Service

Orchestrates cron schedules and job execution.

```typescript
// modules/indexer/indexer.service.ts
import { Injectable, Logger, OnModuleInit } from '@nestjs/common'
import { Cron, CronExpression } from '@nestjs/schedule'
import { OnEvent } from '@nestjs/event-emitter'
import { JobQueueService, JobTriggerContext, TriggerSource } from './job-queue.service'

export enum IndexerJobs {
  IndexAgentCreations = 'index-agent-creations',
  IndexTokenPrice = 'index-token-price',
  IndexAgentGraduation = 'index-agent-graduation',
  IndexGovernanceProposals = 'index-governance-proposals',
  IndexGovernanceVotes = 'index-governance-votes',
  UpdateProposalStatuses = 'update-proposal-statuses',
  IndexTokenUriUpdates = 'index-token-uri-updates',
  ScheduledPriceRefresh = 'scheduled-price-refresh',
}

@Injectable()
export class IndexerService implements OnModuleInit {
  private readonly logger = new Logger(IndexerService.name)
  private agentsByChain: Map<number, Agent[]> = new Map()
  private readonly supportedChainIds: number[]

  constructor(
    private jobQueueService: JobQueueService,
    private factoryService: FactoryService,
    private configService: ConfigService,
    // ... other services
  ) {
    const chainIdsStr = this.configService.get<string>('SUPPORTED_CHAIN_IDS') || ''
    this.supportedChainIds = chainIdsStr.split(',').map((id) => Number(id.trim()))
  }

  onModuleInit() {
    // Handle PM2 message triggers
    process.on('message', async (packet: any) => {
      const jobName = packet.data?.indexer as IndexerJobs
      if (Object.values(IndexerJobs).includes(jobName)) {
        await this.jobQueueService.queueOrExecuteJob(jobName)
      }
    })
  }

  async runInitialization() {
    try {
      this.logger.log('Initial agent indexing...')
      await this.factoryService.indexNewAgentCreations()

      for (const chainId of this.supportedChainIds) {
        const agents = await this.agentRepository.allAgentsByChain(chainId)
        this.agentsByChain.set(chainId, agents)
      }

      this.logger.log('Initialization complete - cron jobs active')
    } catch (error) {
      this.logger.error('Error during initialization:', error)
    }
  }

  /**
   * Random delay to prevent multiple instances from hitting rate limits.
   * Only applies to cron-triggered jobs.
   */
  private async randomDelay(maxDelaySeconds: number, context?: JobTriggerContext): Promise<void> {
    if (context?.source === TriggerSource.OnDemand) return

    const delayMs = Math.floor(Math.random() * maxDelaySeconds * 1000)
    await new Promise((resolve) => setTimeout(resolve, delayMs))
  }

  // Cron trigger
  @Cron(CronExpression.EVERY_2_HOURS, { name: IndexerJobs.IndexAgentCreations })
  async scheduleIndexAgentCreations() {
    await this.jobQueueService.queueOrExecuteJob(
      IndexerJobs.IndexAgentCreations,
      TriggerSource.Cron,
    )
  }

  // Job execution
  @OnEvent(IndexerJobs.IndexAgentCreations)
  async indexAgentCreations(context: JobTriggerContext) {
    await this.randomDelay(600, context) // 0-10 minutes
    await this.factoryService.indexNewAgentCreations()

    for (const chainId of this.supportedChainIds) {
      const agents = await this.agentRepository.allAgentsByChain(chainId)
      this.agentsByChain.set(chainId, agents)
    }
  }

  // ... other cron triggers and job handlers follow the same pattern
}
```

**Key patterns:**
- **Cron + Event separation**: Cron method triggers queue, Event handler executes logic
- **Random delay for cron**: Prevents thundering herd on shared resources
- **PM2 message handling**: Allows on-demand job triggering
- **Agent cache by chain**: In-memory cache refreshed after indexing

---

### 4. Event Processing Service

Fetches and processes contract events.

```typescript
// modules/factory/factory.service.ts
import { Injectable, Logger } from '@nestjs/common'
import { decodeEventLog, type Address } from 'viem'
import { AGENT_FACTORY_ABI } from '../../lib/abi/agent-factory.abi'

interface ChainFactoryConfig {
  chainId: number
  factoryContract: Address
  startBlock: number
}

@Injectable()
export class FactoryService {
  private readonly logger = new Logger(FactoryService.name)
  private readonly BATCH_SIZE = 100
  private readonly chainFactories: Map<number, ChainFactoryConfig> = new Map()

  constructor(
    private blockchainService: BlockchainService,
    private agentRepository: AgentRepository,
    private configService: ConfigService,
  ) {
    this.initializeChainFactories()
  }

  private initializeChainFactories() {
    const chainIds = this.configService.get<string>('SUPPORTED_CHAIN_IDS')?.split(',') || []

    for (const chainIdStr of chainIds) {
      const chainId = Number(chainIdStr.trim())
      if (Number.isNaN(chainId)) continue

      const prefix = chainId === this.DEFAULT_CHAIN_ID ? '' : `CHAIN_${chainId}_`
      const factoryContract = this.configService.get<string>(`${prefix}AGENT_FACTORY_CONTRACT`)
      const startBlock = this.configService.get<number>(`chain.startBlock.${chainId}`, 0)

      if (factoryContract) {
        this.chainFactories.set(chainId, {
          chainId,
          factoryContract: factoryContract as Address,
          startBlock,
        })
      }
    }
  }

  async indexNewAgentCreations() {
    for (const [chainId] of this.chainFactories.entries()) {
      await this.indexChainAgentCreations(chainId)
    }
  }

  async indexChainAgentCreations(chainId: number) {
    const chainFactory = this.chainFactories.get(chainId)!
    const nextBlockToIndexFrom = await this.agentRepository.getNextBlockToIndexFrom(chainId)

    this.logger.log(`Indexing agents on chain ${chainId} from block ${nextBlockToIndexFrom}`)

    try {
      const logs = await this.blockchainService.getLogsChunked(
        {
          address: chainFactory.factoryContract,
          fromBlock: BigInt(nextBlockToIndexFrom),
          toBlock: 'latest',
        },
        chainId,
      )

      if (logs.length === 0) {
        this.logger.log(`No logs found for chain ${chainId}`)
        return
      }

      this.logger.log(`Found ${logs.length} logs on chain ${chainId}`)

      // Process in batches
      for (let i = 0; i < logs.length; i += this.BATCH_SIZE) {
        const batch = logs.slice(i, i + this.BATCH_SIZE)

        for (const log of batch) {
          try {
            const decoded = decodeEventLog({
              abi: AGENT_FACTORY_ABI,
              data: log.data,
              topics: log.topics,
            })

            if (decoded.eventName === 'AgentCreated') {
              await this.processAgentCreation(decoded, log.transactionHash, log.blockNumber, chainId)
            }
          } catch (error) {
            this.logger.error(`Error decoding event on chain ${chainId}:`, error)
          }
        }
      }
    } catch (error) {
      this.logger.error(`Error indexing agents on chain ${chainId}:`, error)
    }
  }
}
```

**Key patterns:**
- **Chain factory map**: Per-chain contract addresses and start blocks
- **Checkpoint from repository**: `getNextBlockToIndexFrom` tracks progress
- **Batch processing**: Process logs in configurable batch sizes
- **Error isolation**: Individual event failures don't stop batch processing

---

### 5. Checkpoint Tracking

Track indexing progress via repository.

```typescript
// repositories/agent.repository.ts
@Injectable()
export class AgentRepository {
  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {}

  async getNextBlockToIndexFrom(chainId?: number): Promise<number> {
    const effectiveChainId = chainId ?? this.configService.get<number>('chain.defaultId')

    const lastLog = await this.prisma.agentLogs.findFirst({
      where: { chainId: effectiveChainId },
      orderBy: { blockNumber: 'desc' },
    })

    const startBlock = this.configService.get<number>(
      `chain.startBlock.${effectiveChainId}`,
      0,
    )

    return lastLog?.blockNumber ? lastLog.blockNumber + 1 : startBlock
  }

  async createAgentLogs(logs: Prisma.AgentLogsCreateManyInput[]) {
    return this.prisma.agentLogs.createMany({ data: logs })
  }
}
```

**Key patterns:**
- **Checkpoint from last log**: Query max blockNumber from logs table
- **Fallback to start block**: Use configured start block if no logs exist
- **Per-chain tracking**: Each chain has independent checkpoint

---

## Deployment Patterns

### Single-Chain-Per-Process (Production)

Run separate PM2 processes per chain with isolated environment files.

```javascript
// ecosystem.config.js
const dotenv = require('dotenv')
const fs = require('node:fs')

const apiEnv = dotenv.parse(fs.readFileSync('.env.api'))
const fraxtalEnv = dotenv.parse(fs.readFileSync('.env.fraxtal'))
const baseEnv = dotenv.parse(fs.readFileSync('.env.base'))

module.exports = {
  apps: [
    {
      name: 'ai-agent-indexer-api',
      script: 'dist/src/main.js',
      env: {
        ...apiEnv,
        PROCESS_MODE: 'api', // API only, no indexer
      },
      instances: 1,
      exec_mode: 'cluster',
      max_memory_restart: '512M',
    },
    {
      name: 'ai-agent-indexer-fraxtal',
      script: 'dist/src/console.js',
      args: '--env .env.fraxtal indexer:init',
      env: fraxtalEnv,
      instances: 1,
      exec_mode: 'cluster',
      max_memory_restart: '1024M',
    },
    {
      name: 'ai-agent-indexer-base',
      script: 'dist/src/console.js',
      args: '--env .env.base indexer:init',
      env: baseEnv,
      instances: 1,
      exec_mode: 'cluster',
      max_memory_restart: '1024M',
    },
  ],
}
```

**Benefits:**
- Process-level fault isolation
- Independent scaling/memory per chain
- Simpler debugging (logs per chain)
- No cross-chain error propagation

---

## Configuration

### Chain Configuration

```typescript
// config/chain.config.ts
import { registerAs } from '@nestjs/config'

export const DEFAULT_CHAIN_ID = '252'

export default registerAs('chain', () => {
  const isApiProcess = process.env.PROCESS_MODE === 'api'

  const supportedChainIds =
    process.env.SUPPORTED_CHAIN_IDS?.split(',')
      .map((id) => id.trim())
      .filter(Boolean) || []

  const startBlock: Record<string, number> = {
    [DEFAULT_CHAIN_ID]: Number.parseInt(process.env.START_BLOCK || '0', 10),
  }

  // Add start blocks for additional chains (indexer only)
  if (!isApiProcess) {
    for (const chainId of supportedChainIds) {
      if (chainId !== DEFAULT_CHAIN_ID) {
        startBlock[chainId] = Number.parseInt(
          process.env[`CHAIN_${chainId}_START_BLOCK`] || '0',
          10,
        )
      }
    }
  }

  return {
    defaultId: Number.parseInt(process.env.DEFAULT_CHAIN_ID ?? DEFAULT_CHAIN_ID, 10),
    startBlock,
    supportedChainIds,
    fraxtal: {
      rpcUrls: ['https://rpc.frax.com', 'https://fraxtal.gateway.tenderly.co'],
    },
  }
})
```

### Environment Validation

```typescript
// config/env.validation.ts
import { DEFAULT_CHAIN_ID } from '../config/chain.config'

const REQUIRED_BASE_ENVS = ['DATABASE_URL']

const REQUIRED_INDEXER_ENVS = [
  'SUPPORTED_CHAIN_IDS',
  'IPFS_URL',
  'PROXY_BASE_URL',
  'PROXY_API_KEY',
]

const REQUIRED_DEFAULT_CHAIN_ENVS = [
  'AGENT_FACTORY_CONTRACT',
  'TOKEN_ROUTER_CONTRACT',
  'BASE_TOKEN_CONTRACT_ADDRESS',
]

const REQUIRED_CHAIN_SUFFIXES = [
  'NAME',
  'RPC_URLS',
  'BLOCK_EXPLORER_URL',
  'API_URL',
  'FACTORY_CONTRACT',
  'TOKEN_ROUTER_CONTRACT',
  'BASE_TOKEN_CONTRACT',
]

export function validate(config: Record<string, unknown>) {
  const missing: string[] = []
  const isApiProcess = config.PROCESS_MODE === 'api'

  for (const key of REQUIRED_BASE_ENVS) {
    if (!config[key]) missing.push(key)
  }

  if (!isApiProcess) {
    for (const key of REQUIRED_INDEXER_ENVS) {
      if (!config[key]) missing.push(key)
    }

    const chainIds = (config.SUPPORTED_CHAIN_IDS as string)
      .split(',')
      .map((id) => Number(id.trim()))
      .filter((id) => !Number.isNaN(id))

    for (const chainId of chainIds) {
      if (chainId === Number(DEFAULT_CHAIN_ID)) {
        for (const key of REQUIRED_DEFAULT_CHAIN_ENVS) {
          if (!config[key]) missing.push(key)
        }
      } else {
        const prefix = `CHAIN_${chainId}`
        for (const suffix of REQUIRED_CHAIN_SUFFIXES) {
          const key = `${prefix}_${suffix}`
          if (!config[key]) missing.push(key)
        }
      }
    }
  }

  if (missing.length > 0) {
    throw new Error(`Missing required env vars: ${missing.join(', ')}`)
  }

  return config
}
```

### Example Environment Files

```bash
# .env.fraxtal
DATABASE_URL=postgresql://...
SUPPORTED_CHAIN_IDS=252

# Default chain (Fraxtal)
START_BLOCK=12345678
AGENT_FACTORY_CONTRACT=0x...
TOKEN_ROUTER_CONTRACT=0x...
BASE_TOKEN_CONTRACT_ADDRESS=0x...

# External services
IPFS_URL=https://ipfs.io/ipfs/
PROXY_BASE_URL=https://...
PROXY_API_KEY=...
```

```bash
# .env.base
DATABASE_URL=postgresql://...
SUPPORTED_CHAIN_IDS=8453

# Base chain
CHAIN_8453_NAME=Base
CHAIN_8453_RPC_URLS=...
CHAIN_8453_BLOCK_EXPLORER_URL=https://basescan.org
CHAIN_8453_API_URL=https://api.basescan.org/api
CHAIN_8453_START_BLOCK=12345678
CHAIN_8453_FACTORY_CONTRACT=0x...
CHAIN_8453_TOKEN_ROUTER_CONTRACT=0x...
CHAIN_8453_BASE_TOKEN_CONTRACT=0x...

# External services
IPFS_URL=https://ipfs.io/ipfs/
PROXY_BASE_URL=https://...
PROXY_API_KEY=...
```

---

## Best Practices

1. **Chunk log requests** - Respect RPC limits (typically 999-1000 blocks)
2. **Use fallback RPCs with ranking** - viem's `fallback({ rank: true })` auto-selects best RPC
3. **Add random delays for cron jobs** - Prevent thundering herd on shared resources
4. **Batch process events** - Don't overwhelm the database with individual inserts
5. **Log checkpoint progress** - Essential for debugging indexing issues
6. **Isolate errors per event** - Individual event failures shouldn't stop batch processing
7. **Use separate processes per chain** - Process-level fault isolation in production
8. **Validate environment on startup** - Fail fast with clear error messages