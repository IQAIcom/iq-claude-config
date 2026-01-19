# Server Actions

Server Actions are the primary way to handle data mutations in Next.js. Use them instead of API routes for form submissions and data changes.

## Defining Server Actions

### In a separate file (recommended)

```tsx
// actions/user.ts
'use server';

import { db } from '@/lib/db';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
});

export async function createUser(formData: FormData) {
  const parsed = createUserSchema.safeParse({
    name: formData.get('name'),
    email: formData.get('email'),
  });

  if (!parsed.success) {
    return { error: parsed.error.flatten() };
  }

  const user = await db.user.create({
    data: parsed.data,
  });

  revalidatePath('/users');
  return { user };
}
```

### Inline in Server Component

```tsx
// app/users/page.tsx
async function UsersPage() {
  async function create(formData: FormData) {
    'use server';
    await db.user.create({
      data: { name: formData.get('name') as string },
    });
    revalidatePath('/users');
  }

  return (
    <form action={create}>
      <input name="name" />
      <button type="submit">Create</button>
    </form>
  );
}
```

## Using with Forms

### Basic Form

```tsx
import { createUser } from '@/actions/user';

export function CreateUserForm() {
  return (
    <form action={createUser}>
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit">Create</button>
    </form>
  );
}
```

### With useFormState (for feedback)

```tsx
'use client';

import { useFormState, useFormStatus } from 'react-dom';
import { createUser } from '@/actions/user';

function SubmitButton() {
  const { pending } = useFormStatus();
  return <button disabled={pending}>{pending ? 'Creating...' : 'Create'}</button>;
}

export function CreateUserForm() {
  const [state, action] = useFormState(createUser, null);

  return (
    <form action={action}>
      <input name="name" required />
      {state?.error?.name && <span>{state.error.name}</span>}
      <SubmitButton />
    </form>
  );
}
```

### With useTransition (programmatic)

```tsx
'use client';

import { useTransition } from 'react';
import { deleteUser } from '@/actions/user';

export function DeleteButton({ userId }) {
  const [isPending, startTransition] = useTransition();

  return (
    <button
      disabled={isPending}
      onClick={() => startTransition(() => deleteUser(userId))}
    >
      {isPending ? 'Deleting...' : 'Delete'}
    </button>
  );
}
```

## Patterns

### Return typed responses

```tsx
'use server';

type ActionResult<T> = 
  | { success: true; data: T }
  | { success: false; error: string };

export async function createUser(formData: FormData): Promise<ActionResult<User>> {
  try {
    const user = await db.user.create({ ... });
    revalidatePath('/users');
    return { success: true, data: user };
  } catch (error) {
    return { success: false, error: 'Failed to create user' };
  }
}
```

### Revalidation

```tsx
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';

export async function updateUser(id: string, data: UserData) {
  await db.user.update({ where: { id }, data });
  
  // Revalidate specific path
  revalidatePath('/users');
  revalidatePath(`/users/${id}`);
  
  // Or revalidate by tag
  revalidateTag('users');
}
```

### Redirect after action

```tsx
'use server';

import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const post = await db.post.create({ ... });
  redirect(`/posts/${post.id}`);
}
```

## Security

### Always validate input

```tsx
'use server';

import { z } from 'zod';

const schema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(1),
});

export async function createPost(formData: FormData) {
  const result = schema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
  });

  if (!result.success) {
    throw new Error('Invalid input');
  }

  // Safe to use result.data
}
```

### Check authorization

```tsx
'use server';

import { auth } from '@/lib/auth';

export async function deletePost(postId: string) {
  const session = await auth();
  if (!session) throw new Error('Unauthorized');

  const post = await db.post.findUnique({ where: { id: postId } });
  if (post.authorId !== session.user.id) {
    throw new Error('Forbidden');
  }

  await db.post.delete({ where: { id: postId } });
}
```
