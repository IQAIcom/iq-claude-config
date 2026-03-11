# Prisma Patterns

## Query Patterns

### Select specific fields

```typescript
// ✅ Only fetch what you need
const user = await db.user.findUnique({
  where: { id },
  select: {
    id: true,
    name: true,
    email: true,
    // password: false (omitted)
  },
});
```

### Include relations

```typescript
const user = await db.user.findUnique({
  where: { id },
  include: {
    posts: true,
    profile: true,
  },
});

// Nested includes
const user = await db.user.findUnique({
  where: { id },
  include: {
    posts: {
      include: {
        comments: true,
      },
    },
  },
});
```

### Filtering

```typescript
const users = await db.user.findMany({
  where: {
    AND: [
      { email: { contains: '@company.com' } },
      { role: 'ADMIN' },
    ],
    OR: [
      { name: { startsWith: 'A' } },
      { name: { startsWith: 'B' } },
    ],
    NOT: { status: 'DELETED' },
  },
});
```

### Pagination

```typescript
// Offset pagination
const users = await db.user.findMany({
  skip: (page - 1) * pageSize,
  take: pageSize,
  orderBy: { createdAt: 'desc' },
});

// Cursor pagination (better for large datasets)
const users = await db.user.findMany({
  take: 10,
  cursor: { id: lastUserId },
  skip: 1, // Skip the cursor
  orderBy: { id: 'asc' },
});
```

### Aggregations

```typescript
const stats = await db.user.aggregate({
  _count: true,
  _avg: { age: true },
  _max: { createdAt: true },
});

const grouped = await db.order.groupBy({
  by: ['status'],
  _count: true,
  _sum: { total: true },
});
```

## Write Patterns

### Create with relations

```typescript
const user = await db.user.create({
  data: {
    name: 'John',
    email: 'john@example.com',
    profile: {
      create: {
        bio: 'Hello world',
      },
    },
    posts: {
      create: [
        { title: 'First post' },
        { title: 'Second post' },
      ],
    },
  },
  include: { profile: true, posts: true },
});
```

### Upsert

```typescript
const user = await db.user.upsert({
  where: { email: 'john@example.com' },
  create: {
    email: 'john@example.com',
    name: 'John',
  },
  update: {
    name: 'John Updated',
  },
});
```

### Transactions

```typescript
// Automatic transaction
const [user, post] = await db.$transaction([
  db.user.create({ data: { name: 'John' } }),
  db.post.create({ data: { title: 'Hello' } }),
]);

// Interactive transaction
await db.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } });
  if (user.balance < amount) {
    throw new Error('Insufficient balance');
  }
  await tx.user.update({
    where: { id },
    data: { balance: { decrement: amount } },
  });
});
```

### Batch operations

```typescript
// Create many
await db.user.createMany({
  data: [
    { name: 'John', email: 'john@example.com' },
    { name: 'Jane', email: 'jane@example.com' },
  ],
  skipDuplicates: true,
});

// Update many
await db.user.updateMany({
  where: { role: 'USER' },
  data: { verified: true },
});

// Delete many
await db.user.deleteMany({
  where: { lastLogin: { lt: thirtyDaysAgo } },
});
```

## Performance Tips

### Avoid N+1

```typescript
// ❌ Bad - N+1 queries
const users = await db.user.findMany();
for (const user of users) {
  const posts = await db.post.findMany({ where: { authorId: user.id } });
}

// ✅ Good - single query with include
const users = await db.user.findMany({
  include: { posts: true },
});
```

### Use select over include

```typescript
// ✅ More efficient
const users = await db.user.findMany({
  select: {
    id: true,
    name: true,
    posts: {
      select: { id: true, title: true },
    },
  },
});
```

### Raw queries for complex operations

```typescript
const result = await db.$queryRaw`
  SELECT u.*, COUNT(p.id) as post_count
  FROM users u
  LEFT JOIN posts p ON p.author_id = u.id
  GROUP BY u.id
  HAVING COUNT(p.id) > 5
`;
```
