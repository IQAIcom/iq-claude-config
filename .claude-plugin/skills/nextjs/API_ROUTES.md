# API Routes (Route Handlers)

## When to Use

Use Route Handlers **only** when Server Actions won't work:

✅ Webhooks (Stripe, GitHub, etc.)
✅ Third-party integrations expecting REST endpoints
✅ File uploads/downloads
✅ Streaming responses
✅ Public API for external consumers

❌ Form submissions → Use Server Actions
❌ Data mutations → Use Server Actions
❌ Internal API calls → Use Server Actions

## Basic Route Handler

```tsx
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

export async function GET(request: NextRequest) {
  const users = await db.user.findMany();
  return NextResponse.json(users);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return NextResponse.json(user, { status: 201 });
}
```

## Dynamic Routes

```tsx
// app/api/users/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const user = await db.user.findUnique({
    where: { id: params.id },
  });

  if (!user) {
    return NextResponse.json(
      { error: 'User not found' },
      { status: 404 }
    );
  }

  return NextResponse.json(user);
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  await db.user.delete({ where: { id: params.id } });
  return new NextResponse(null, { status: 204 });
}
```

## Webhooks

```tsx
// app/api/webhooks/stripe/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { headers } from 'next/headers';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export async function POST(request: NextRequest) {
  const body = await request.text();
  const signature = headers().get('stripe-signature')!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    return NextResponse.json(
      { error: 'Invalid signature' },
      { status: 400 }
    );
  }

  switch (event.type) {
    case 'checkout.session.completed':
      // Handle successful checkout
      break;
    case 'invoice.payment_failed':
      // Handle failed payment
      break;
  }

  return NextResponse.json({ received: true });
}
```

## File Uploads

```tsx
// app/api/upload/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { writeFile } from 'fs/promises';
import { join } from 'path';

export async function POST(request: NextRequest) {
  const formData = await request.formData();
  const file = formData.get('file') as File;

  if (!file) {
    return NextResponse.json(
      { error: 'No file provided' },
      { status: 400 }
    );
  }

  const bytes = await file.arrayBuffer();
  const buffer = Buffer.from(bytes);

  const path = join(process.cwd(), 'uploads', file.name);
  await writeFile(path, buffer);

  return NextResponse.json({ path: `/uploads/${file.name}` });
}
```

## Streaming

```tsx
// app/api/stream/route.ts
export async function GET() {
  const encoder = new TextEncoder();
  const stream = new ReadableStream({
    async start(controller) {
      for (let i = 0; i < 10; i++) {
        controller.enqueue(encoder.encode(`data: ${i}\n\n`));
        await new Promise(r => setTimeout(r, 1000));
      }
      controller.close();
    },
  });

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
    },
  });
}
```

## Authentication

```tsx
// app/api/protected/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  const session = await auth();

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }

  return NextResponse.json({ user: session.user });
}
```

## Response Helpers

```tsx
// Success
return NextResponse.json(data);
return NextResponse.json(data, { status: 201 });

// Error
return NextResponse.json({ error: 'Message' }, { status: 400 });

// No content
return new NextResponse(null, { status: 204 });

// Redirect
return NextResponse.redirect(new URL('/login', request.url));

// Headers
return NextResponse.json(data, {
  headers: { 'X-Custom-Header': 'value' },
});
```
