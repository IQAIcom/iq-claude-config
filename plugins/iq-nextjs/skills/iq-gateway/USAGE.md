# IQ Gateway Usage

Implementation patterns for using IQ Gateway in BrainDAO projects.

## Basic Request Pattern

All requests follow this structure:

```typescript
const response = await fetch(
  `https://gateway.braindao.org/?url=${encodeURIComponent(externalApiUrl)}`,
  {
    headers: {
      "x-api-key": process.env.IQ_GATEWAY_API_KEY!,
    },
  }
);
```

## Next.js Server Action

```typescript
// app/actions/market.ts
"use server";

const IQ_GATEWAY = "https://gateway.braindao.org";

interface CryptoListing {
  id: number;
  name: string;
  symbol: string;
  quote: {
    USD: {
      price: number;
      percent_change_24h: number;
    };
  };
}

export async function getCryptoListings(): Promise<CryptoListing[]> {
  const externalUrl =
    "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=100";

  const response = await fetch(
    `${IQ_GATEWAY}/?url=${encodeURIComponent(externalUrl)}&cacheDuration=300`,
    {
      headers: {
        "x-api-key": process.env.IQ_GATEWAY_API_KEY!,
      },
      next: { revalidate: 300 }, // Match cache duration
    }
  );

  if (!response.ok) {
    throw new Error(`Gateway error: ${response.status}`);
  }

  const data = await response.json();
  return data.data;
}
```

## Next.js API Route

```typescript
// app/api/price/[symbol]/route.ts
import { NextRequest, NextResponse } from "next/server";

const IQ_GATEWAY = "https://gateway.braindao.org";

export async function GET(
  request: NextRequest,
  { params }: { params: { symbol: string } }
) {
  const { symbol } = params;

  const externalUrl = `https://api.coingecko.com/api/v3/simple/price?ids=${symbol}&vs_currencies=usd`;

  const response = await fetch(
    `${IQ_GATEWAY}/?url=${encodeURIComponent(externalUrl)}&cacheDuration=60`,
    {
      headers: {
        "x-api-key": process.env.IQ_GATEWAY_API_KEY!,
      },
    }
  );

  if (!response.ok) {
    return NextResponse.json(
      { error: "Failed to fetch price" },
      { status: response.status }
    );
  }

  const data = await response.json();
  return NextResponse.json(data);
}
```

## Gateway Client Utility

Create a reusable client for cleaner code:

```typescript
// lib/iq-gateway.ts

const IQ_GATEWAY_URL = "https://gateway.braindao.org";

interface GatewayOptions {
  cacheDuration?: number;
  userId?: string;
}

export async function fetchViaGateway<T>(
  externalUrl: string,
  options: GatewayOptions = {}
): Promise<T> {
  const params = new URLSearchParams({
    url: externalUrl,
  });

  if (options.cacheDuration) {
    params.set("cacheDuration", options.cacheDuration.toString());
  }

  if (options.userId) {
    params.set("userId", options.userId);
  }

  const response = await fetch(`${IQ_GATEWAY_URL}/?${params.toString()}`, {
    headers: {
      "x-api-key": process.env.IQ_GATEWAY_API_KEY!,
    },
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Gateway error ${response.status}: ${error}`);
  }

  return response.json();
}
```

Usage:

```typescript
// Using the utility
const listings = await fetchViaGateway<CMCResponse>(
  "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest",
  { cacheDuration: 300 }
);

const etherscanData = await fetchViaGateway<EtherscanResponse>(
  "https://api.etherscan.io/api?module=account&action=balance&address=0x...",
  { cacheDuration: 60 }
);
```

## Common Use Cases

### CoinMarketCap - Token Listings

```typescript
const url =
  "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=100&sort=market_cap";

const data = await fetchViaGateway(url, { cacheDuration: 300 });
```

### CoinGecko - Token Price

```typescript
const url =
  "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,iq&vs_currencies=usd";

const data = await fetchViaGateway(url, { cacheDuration: 60 });
```

### Etherscan - Token Balance

```typescript
const url = `https://api.etherscan.io/api?module=account&action=tokenbalance&contractaddress=${tokenAddress}&address=${walletAddress}&tag=latest`;

const data = await fetchViaGateway(url, { cacheDuration: 30 });
```

### Fraxscan - Transaction History

```typescript
const url = `https://api.fraxscan.com/api?module=account&action=txlist&address=${address}&startblock=0&endblock=99999999&sort=desc`;

const data = await fetchViaGateway(url, { cacheDuration: 60 });
```

## Error Handling

```typescript
try {
  const data = await fetchViaGateway(url, { cacheDuration: 300 });
  return data;
} catch (error) {
  if (error instanceof Error) {
    // Gateway returns descriptive errors
    if (error.message.includes("401")) {
      console.error("Invalid API key");
    } else if (error.message.includes("429")) {
      console.error("Rate limited - try again later");
    } else if (error.message.includes("502") || error.message.includes("503")) {
      console.error("External API unavailable");
    }
  }
  throw error;
}
```

## Cache Duration Guidelines

| Data Type | Recommended TTL |
|-----------|-----------------|
| Price data | 30-60 seconds |
| Listings | 300 seconds (5 min) |
| Historical data | 3600 seconds (1 hour) |
| Static metadata | 86400 seconds (1 day) |

## NestJS Service Example

```typescript
// market.service.ts
import { Injectable, HttpException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";

@Injectable()
export class MarketService {
  private readonly gatewayUrl = "https://gateway.braindao.org";
  private readonly apiKey: string;

  constructor(private config: ConfigService) {
    this.apiKey = this.config.getOrThrow("IQ_GATEWAY_API_KEY");
  }

  async fetchViaGateway<T>(
    externalUrl: string,
    cacheDuration?: number
  ): Promise<T> {
    const params = new URLSearchParams({ url: externalUrl });
    if (cacheDuration) {
      params.set("cacheDuration", cacheDuration.toString());
    }

    const response = await fetch(`${this.gatewayUrl}/?${params}`, {
      headers: { "x-api-key": this.apiKey },
    });

    if (!response.ok) {
      throw new HttpException(
        `Gateway error: ${response.statusText}`,
        response.status
      );
    }

    return response.json();
  }

  async getTokenPrice(symbol: string): Promise<number> {
    const url = `https://api.coingecko.com/api/v3/simple/price?ids=${symbol}&vs_currencies=usd`;
    const data = await this.fetchViaGateway<Record<string, { usd: number }>>(
      url,
      60
    );
    return data[symbol]?.usd ?? 0;
  }
}
```

## Best Practices

1. **Always use server-side** - Never expose gateway calls in client components
2. **Set appropriate cache durations** - Reduce load on external APIs
3. **Handle errors gracefully** - Gateway returns standard HTTP status codes
4. **Use the utility pattern** - Create a `fetchViaGateway` helper
5. **URL encode properly** - Always use `encodeURIComponent` for the external URL
