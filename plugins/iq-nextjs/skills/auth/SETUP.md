# IQ Login Setup

## Installation

```bash
pnpm install @everipedia/iq-login wagmi@2.x viem@2.x @web3auth/modal @web3auth/ethereum-provider @web3auth/web3auth-wagmi-connector
```

## Environment Variables

Create `.env.local`:

```env
NEXT_PUBLIC_WEB3_AUTH_CLIENT_ID=your_web3auth_client_id
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_wallet_connect_project_id
```

Get credentials from:
- Web3Auth: https://dashboard.web3auth.io
- WalletConnect: https://cloud.walletconnect.com

## Tailwind Configuration

Add the package to your `tailwind.config.ts` content array:

```typescript
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    // Add iq-login package for styling
    "./node_modules/@everipedia/iq-login/**/*.{js,jsx,ts,tsx}",
  ],
  // ... rest of config
};

export default config;
```

## Provider Setup

Wrap your app with `IqLoginProvider` in `app/layout.tsx`:

```typescript
import { IqLoginProvider } from "@everipedia/iq-login/client";
import { getWagmiConfig } from "@everipedia/iq-login";
import { headers } from "next/headers";
import { fraxtal } from "viem/chains";

// Configure wagmi with your chains
const wagmiConfig = getWagmiConfig([fraxtal]);

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const cookie = (await headers()).get("cookie");

  return (
    <html lang="en">
      <body>
        <IqLoginProvider
          projectName="your-project-name"
          cookie={cookie}
          wagmiConfig={wagmiConfig}
        >
          {children}
        </IqLoginProvider>
      </body>
    </html>
  );
}
```

### Provider Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `projectName` | `string` | Yes | Your application identifier |
| `cookie` | `string \| null` | Yes | Cookie from request headers |
| `wagmiConfig` | `Config` | Yes | Wagmi config from `getWagmiConfig()` |
| `chains` | `Chain[]` | No | Blockchain networks (defaults to mainnet) |
| `disableAuth` | `boolean` | No | Disable authentication requirement |

## Chain Configuration

Configure supported chains when creating the wagmi config:

```typescript
import { getWagmiConfig } from "@everipedia/iq-login";
import { mainnet, polygon, fraxtal } from "viem/chains";

// Single chain
const wagmiConfig = getWagmiConfig([fraxtal]);

// Multiple chains
const wagmiConfig = getWagmiConfig([mainnet, polygon, fraxtal]);
```

## Pages Router (Legacy)

If using the Pages Router, add transpile config to `next.config.js`:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@everipedia/iq-login"],
};

export default nextConfig;
```

## t3-env Integration

Add the auth environment variables to your `lib/env.ts`:

```typescript
import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  },
  client: {
    NEXT_PUBLIC_APP_URL: z.string().url(),
    NEXT_PUBLIC_WEB3_AUTH_CLIENT_ID: z.string().min(1),
    NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID: z.string().min(1),
  },
  experimental__runtimeEnv: {
    NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
    NEXT_PUBLIC_WEB3_AUTH_CLIENT_ID: process.env.NEXT_PUBLIC_WEB3_AUTH_CLIENT_ID,
    NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID,
  },
});
```
