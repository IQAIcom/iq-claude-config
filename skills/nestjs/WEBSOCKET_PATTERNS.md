# WebSocket Patterns

Patterns for building real-time WebSocket services with NestJS.

## Gateway Setup

```typescript
// modules/realtime/realtime.gateway.ts
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: process.env.CORS_ORIGIN ?? '*',
  },
  namespace: '/realtime',
})
export class RealtimeGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(RealtimeGateway.name);

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('subscribe')
  handleSubscribe(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { channel: string },
  ) {
    client.join(data.channel);
    this.logger.debug(`${client.id} joined ${data.channel}`);
    return { success: true, channel: data.channel };
  }

  @SubscribeMessage('unsubscribe')
  handleUnsubscribe(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { channel: string },
  ) {
    client.leave(data.channel);
    return { success: true };
  }

  // Broadcast to specific channel
  broadcastToChannel(channel: string, event: string, data: unknown) {
    this.server.to(channel).emit(event, data);
  }

  // Broadcast to all clients
  broadcastToAll(event: string, data: unknown) {
    this.server.emit(event, data);
  }
}
```

## Authentication

```typescript
// modules/realtime/guards/ws-auth.guard.ts
import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { WsException } from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { AuthService } from '@/modules/auth/auth.service';

@Injectable()
export class WsAuthGuard implements CanActivate {
  constructor(private readonly auth: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const client: Socket = context.switchToWs().getClient();
    const token = client.handshake.auth.token;

    if (!token) {
      throw new WsException('Unauthorized');
    }

    try {
      const user = await this.auth.validateToken(token);
      client.data.user = user;
      return true;
    } catch {
      throw new WsException('Invalid token');
    }
  }
}
```

Usage:

```typescript
@UseGuards(WsAuthGuard)
@SubscribeMessage('private-message')
handlePrivateMessage(
  @ConnectedSocket() client: Socket,
  @MessageBody() data: { to: string; message: string },
) {
  const user = client.data.user;
  // Handle authenticated message
}
```

## Room-Based Subscriptions

```typescript
// modules/realtime/services/room.service.ts
import { Injectable } from '@nestjs/common';
import { RealtimeGateway } from '../realtime.gateway';

@Injectable()
export class RoomService {
  constructor(private readonly gateway: RealtimeGateway) {}

  // Price feed example
  async subscribeToPriceFeed(clientId: string, tokens: string[]) {
    const client = this.gateway.server.sockets.sockets.get(clientId);
    if (!client) return;

    for (const token of tokens) {
      client.join(`price:${token}`);
    }
  }

  broadcastPrice(token: string, price: number) {
    this.gateway.broadcastToChannel(`price:${token}`, 'price-update', {
      token,
      price,
      timestamp: Date.now(),
    });
  }

  // Block updates example
  broadcastNewBlock(blockNumber: number, blockHash: string) {
    this.gateway.broadcastToAll('new-block', {
      number: blockNumber,
      hash: blockHash,
      timestamp: Date.now(),
    });
  }
}
```

## Event-Driven Updates

```typescript
// modules/realtime/listeners/block.listener.ts
import { Injectable } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { RoomService } from '../services/room.service';

interface BlockIndexedEvent {
  blockNumber: number;
  blockHash: string;
  transactions: number;
}

@Injectable()
export class BlockListener {
  constructor(private readonly room: RoomService) {}

  @OnEvent('block.indexed')
  handleBlockIndexed(event: BlockIndexedEvent) {
    this.room.broadcastNewBlock(event.blockNumber, event.blockHash);
  }
}
```

Emit from indexer:

```typescript
// In block processor
import { EventEmitter2 } from '@nestjs/event-emitter';

@Processor('blocks')
export class BlockProcessor {
  constructor(private readonly eventEmitter: EventEmitter2) {}

  @Process('process')
  async processBlock(job: Job<BlockJob>) {
    // ... process block ...

    this.eventEmitter.emit('block.indexed', {
      blockNumber: job.data.blockNumber,
      blockHash: block.hash,
      transactions: block.transactions.length,
    });
  }
}
```

## Rate Limiting

```typescript
// modules/realtime/interceptors/ws-throttle.interceptor.ts
import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { WsException } from '@nestjs/websockets';
import { Observable } from 'rxjs';
import { Socket } from 'socket.io';

@Injectable()
export class WsThrottleInterceptor implements NestInterceptor {
  private readonly limit = 100; // requests per window
  private readonly window = 60000; // 1 minute
  private readonly requests = new Map<string, number[]>();

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const client: Socket = context.switchToWs().getClient();
    const clientId = client.id;

    const now = Date.now();
    const windowStart = now - this.window;

    // Get client's request timestamps
    const timestamps = this.requests.get(clientId) ?? [];
    const recentRequests = timestamps.filter((t) => t > windowStart);

    if (recentRequests.length >= this.limit) {
      throw new WsException('Rate limit exceeded');
    }

    recentRequests.push(now);
    this.requests.set(clientId, recentRequests);

    return next.handle();
  }
}
```

## Heartbeat & Reconnection

```typescript
// modules/realtime/realtime.gateway.ts
@WebSocketGateway({
  cors: { origin: '*' },
  pingInterval: 10000,
  pingTimeout: 5000,
})
export class RealtimeGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private readonly connectedClients = new Map<string, { connectedAt: Date }>();

  handleConnection(client: Socket) {
    this.connectedClients.set(client.id, { connectedAt: new Date() });

    // Send initial state on connect
    client.emit('connected', {
      clientId: client.id,
      serverTime: Date.now(),
    });
  }

  handleDisconnect(client: Socket) {
    this.connectedClients.delete(client.id);
  }

  @SubscribeMessage('ping')
  handlePing(@ConnectedSocket() client: Socket) {
    return { event: 'pong', data: { timestamp: Date.now() } };
  }

  getConnectedCount(): number {
    return this.connectedClients.size;
  }
}
```

## Client Example

```typescript
// Client-side usage
import { io, Socket } from 'socket.io-client';

class RealtimeClient {
  private socket: Socket;

  connect(token: string) {
    this.socket = io('ws://localhost:3000/realtime', {
      auth: { token },
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000,
    });

    this.socket.on('connect', () => {
      console.log('Connected:', this.socket.id);
    });

    this.socket.on('disconnect', (reason) => {
      console.log('Disconnected:', reason);
    });

    this.socket.on('new-block', (data) => {
      console.log('New block:', data);
    });
  }

  subscribeToPrices(tokens: string[]) {
    for (const token of tokens) {
      this.socket.emit('subscribe', { channel: `price:${token}` });
    }

    this.socket.on('price-update', (data) => {
      console.log('Price update:', data);
    });
  }

  disconnect() {
    this.socket.disconnect();
  }
}
```

## Module Configuration

```typescript
// modules/realtime/realtime.module.ts
import { Module } from '@nestjs/common';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { RealtimeGateway } from './realtime.gateway';
import { RoomService } from './services/room.service';
import { BlockListener } from './listeners/block.listener';

@Module({
  imports: [EventEmitterModule.forRoot()],
  providers: [RealtimeGateway, RoomService, BlockListener],
  exports: [RoomService],
})
export class RealtimeModule {}
```
