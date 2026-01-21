---
name: iq-gateway
description: IQ Gateway (iq-ext-api) proxy service for external API requests. Use when making calls to CoinMarketCap, CoinGecko, Etherscan, Fraxscan, or any external API in IQ projects.
allowed-tools: Read, Grep, Glob, Edit, Write
---

# IQ Gateway Skill

IQ Gateway (`iq-ext-api`) is BrainDAO's centralized proxy service for managing external API requests across all projects. Instead of making direct API calls with exposed keys, all external requests are routed through this gateway.

## Overview

```
┌─────────────────────────────────────────────────────┐
│              BrainDAO Application                    │
│  (iq.wiki, iqgpt, iqai, dashboard, etc.)           │
└─────────────────────────────────────────────────────┘
                        │
                        ▼ (x-api-key header)
┌─────────────────────────────────────────────────────┐
│                  IQ Gateway                          │
│              gateway.braindao.org                   │
│  • Auth validation                                   │
│  • API key injection                                 │
│  • Caching (optional)                               │
│  • Logging & analytics                              │
└─────────────────────────────────────────────────────┘
                        │
                        ▼ (auto-injected API keys)
┌─────────────────────────────────────────────────────┐
│           External APIs                              │
│  CoinMarketCap, CoinGecko, Etherscan, Fraxscan     │
└─────────────────────────────────────────────────────┘
```

## Related Files

- [USAGE.md](./USAGE.md) - Implementation patterns and code examples

## Quick Reference

| Aspect | Value |
|--------|-------|
| Base URL | `https://gateway.braindao.org` |
| Auth Header | `x-api-key: <project-api-key>` |
| Request Method | `GET /` |
| URL Param | `url=<full-external-api-url>` |

## Supported External APIs

The gateway auto-injects credentials for:

| Provider | Domain | Key Injection |
|----------|--------|---------------|
| CoinMarketCap | `pro-api.coinmarketcap.com` | Header: `X-CMC_PRO_API_KEY` |
| CoinGecko | `api.coingecko.com` | Header: `X-CG-Pro-API-Key` |
| Etherscan | `api.etherscan.io` | Query: `apikey` |
| Fraxscan | `api.fraxscan.com` | Query: `apikey` |

## Key Features

- **Centralized Auth** - Projects authenticate via `x-api-key` header
- **Auto Key Injection** - External API keys injected automatically
- **Optional Caching** - Use `cacheDuration` param (seconds)
- **Retry Logic** - Automatic retries for flaky services
- **Analytics** - Request logging via PostHog

## When to Use

✅ All external API calls in BrainDAO projects
✅ CoinMarketCap price/listing data
✅ CoinGecko market data
✅ Etherscan/Fraxscan blockchain data
✅ Any third-party API that requires key management

## Do NOT Use

❌ Direct API calls with hardcoded keys
❌ Exposing external API keys in client-side code
❌ Internal BrainDAO service-to-service calls

## Environment Setup

Projects need their own gateway API key. Contact the team to get one registered:

```env
IQ_GATEWAY_API_KEY=your-project-api-key
```

## Security Notes

- Never expose the gateway in public-facing client code
- All requests should go through server-side code (API routes, server actions)
- The gateway is for internal BrainDAO use only
