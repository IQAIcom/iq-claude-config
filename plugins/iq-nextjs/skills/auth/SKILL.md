---
name: auth
description: Authentication with @everipedia/iq-login for Web3 wallet authentication. Use when implementing login, authentication, or user sessions in IQ projects.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(npm:*, pnpm:*)
---

# Auth Skill

Authentication for IQ projects using the `@everipedia/iq-login` library. This provides Web3 wallet authentication with Web3Auth and WalletConnect support.

## Stack

- **@everipedia/iq-login** - IQ.wiki login integration
- **wagmi** - React hooks for Ethereum
- **viem** - TypeScript Ethereum library
- **Web3Auth** - Social and wallet login

## Related Files

- [SETUP.md](./SETUP.md) - Installation and configuration
- [USAGE.md](./USAGE.md) - Hooks and components usage

## Quick Start

```bash
pnpm install @everipedia/iq-login wagmi@2.x viem@2.x @web3auth/modal @web3auth/ethereum-provider @web3auth/web3auth-wagmi-connector
```

## Environment Variables

```env
NEXT_PUBLIC_WEB3_AUTH_CLIENT_ID=your_web3auth_client_id
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_wallet_connect_project_id
```

## Key Features

- Web3 wallet authentication (MetaMask, WalletConnect, etc.)
- Social login via Web3Auth
- Token-based session management
- Support for any viem-compatible chain
- Pre-built Login component
- Tailwind/Shadcn styling

## When to Use

✅ All IQ projects requiring authentication
✅ Web3 wallet login
✅ Token-gated features

## Do NOT Use

❌ NextAuth.js - Use iq-login instead
❌ Custom auth implementations - Use iq-login
