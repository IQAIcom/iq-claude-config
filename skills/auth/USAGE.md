# IQ Login Usage

## Login Page

Create a login page using the pre-built `Login` component:

```typescript
// app/login/page.tsx
import { Login } from "@everipedia/iq-login";

export default function LoginPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <Login />
    </div>
  );
}
```

## useAuth Hook

The `useAuth` hook provides authentication state and methods:

```typescript
"use client";

import { useAuth } from "@everipedia/iq-login";

export function AuthStatus() {
  const { token, loading, error, logout, reSignToken, web3AuthUser } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  if (!token) {
    return (
      <div>
        <p>Not authenticated</p>
        <button onClick={reSignToken}>Sign In</button>
      </div>
    );
  }

  return (
    <div>
      <p>Authenticated!</p>
      {web3AuthUser && <p>User: {web3AuthUser.email}</p>}
      <button onClick={logout}>Logout</button>
    </div>
  );
}
```

### Hook Return Values

| Value | Type | Description |
|-------|------|-------------|
| `token` | `string \| null` | JWT authentication token |
| `loading` | `boolean` | Loading state |
| `error` | `string \| null` | Error message if any |
| `logout` | `() => void` | Logout function |
| `reSignToken` | `() => void` | Re-sign/refresh token |
| `web3AuthUser` | `object \| null` | Web3Auth user info |

## getAuth Helper

For server-side authentication checks, use `getAuth`:

```typescript
// In Server Components or Server Actions
import { getAuth } from "@everipedia/iq-login";

export async function getServerSideData() {
  const { token, address } = await getAuth();

  if (!token || !address) {
    throw new Error("Unauthorized");
  }

  // User is authenticated
  console.log("Address:", address);
  console.log("Token:", token);

  // Fetch user-specific data...
}
```

## Protected Routes

### Client-Side Protection

```typescript
"use client";

import { useAuth } from "@everipedia/iq-login";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

export function ProtectedPage({ children }: { children: React.ReactNode }) {
  const { token, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !token) {
      router.push("/login");
    }
  }, [token, loading, router]);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!token) {
    return null;
  }

  return <>{children}</>;
}
```

### Server-Side Protection

```typescript
// app/dashboard/page.tsx
import { getAuth } from "@everipedia/iq-login";
import { redirect } from "next/navigation";

export default async function DashboardPage() {
  const { token, address } = await getAuth();

  if (!token) {
    redirect("/login");
  }

  return (
    <div>
      <h1>Dashboard</h1>
      <p>Welcome, {address}</p>
    </div>
  );
}
```

## Server Actions with Auth

```typescript
// app/dashboard/_actions.ts
"use server";

import { getAuth } from "@everipedia/iq-login";
import { db } from "@/lib/integrations/db";

export async function getUserProfile() {
  const { token, address } = await getAuth();

  if (!token || !address) {
    throw new Error("Unauthorized");
  }

  const user = await db.user.findUnique({
    where: { address },
  });

  return user;
}

export async function updateProfile(data: { name: string }) {
  const { address } = await getAuth();

  if (!address) {
    throw new Error("Unauthorized");
  }

  return db.user.update({
    where: { address },
    data,
  });
}
```

## With next-safe-action

```typescript
// lib/integrations/safe-action.ts
import { createSafeActionClient } from "next-safe-action";
import { getAuth } from "@everipedia/iq-login";

export const actionClient = createSafeActionClient();

export const authActionClient = createSafeActionClient({
  middleware: async () => {
    const { token, address } = await getAuth();

    if (!token || !address) {
      throw new Error("Unauthorized");
    }

    return { address };
  },
});
```

```typescript
// app/dashboard/_actions.ts
"use server";

import { z } from "zod";
import { authActionClient } from "@/lib/integrations/safe-action";
import { db } from "@/lib/integrations/db";

export const updateProfile = authActionClient
  .schema(z.object({ name: z.string().min(1) }))
  .action(async ({ parsedInput, ctx }) => {
    const user = await db.user.update({
      where: { address: ctx.address },
      data: parsedInput,
    });

    return { user };
  });
```

## Wallet Address Display

```typescript
"use client";

import { useAccount } from "wagmi";

export function WalletAddress() {
  const { address, isConnected } = useAccount();

  if (!isConnected || !address) {
    return null;
  }

  // Shorten address: 0x1234...5678
  const shortAddress = `${address.slice(0, 6)}...${address.slice(-4)}`;

  return <span className="font-mono">{shortAddress}</span>;
}
```

## Chain Switching

Use `useEnsureCorrectChain` to ensure the user is on the correct network before performing chain-specific operations:

```typescript
// hooks/use-ensure-correct-chain.ts
"use client";

import { toast } from "sonner";
import { useAccount, useSwitchChain } from "wagmi";

export const useEnsureCorrectChain = (chainId: number) => {
  const { chain } = useAccount();
  const { switchChainAsync, chains } = useSwitchChain();

  const ensureCorrectChain = async () => {
    if (chain?.id !== chainId) {
      const targetChain = chains.find((c) => c.id === chainId);
      if (!targetChain) {
        throw new Error("Target chain not supported by wallet");
      }

      const toastId = toast.loading(`Switching to ${targetChain.name}...`, {
        description: "Please confirm the network switch in your wallet",
      });

      try {
        await switchChainAsync({ chainId });
        toast.success(`Connected to ${targetChain.name}`, {
          id: toastId,
          description: "You're now on the correct network",
        });
      } catch (error) {
        toast.error("Network switch declined", {
          id: toastId,
          description: "Please switch your network to continue",
        });
        throw error;
      }
    }
  };

  return { ensureCorrectChain };
};
```

### Usage Example

```typescript
"use client";

import { useEnsureCorrectChain } from "@/hooks/use-ensure-correct-chain";
import { fraxtal } from "viem/chains";

export function StakeButton() {
  const { ensureCorrectChain } = useEnsureCorrectChain(fraxtal.id);

  const handleStake = async () => {
    try {
      // Ensure user is on the correct chain first
      await ensureCorrectChain();

      // Now safe to proceed with chain-specific operation
      // await stakeTokens(...);
    } catch (error) {
      // User declined chain switch or other error
      console.error(error);
    }
  };

  return <button onClick={handleStake}>Stake</button>;
}
```

## Styling Customization

The Login component uses Tailwind CSS with Shadcn UI theming. Customize by updating your theme configuration:

- Theme generator: https://ui.shadcn.com/themes
- Update CSS variables in your global styles
