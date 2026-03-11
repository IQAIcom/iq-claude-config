# Schema Conventions

## Naming

### Models

```prisma
// PascalCase, singular
model User { }
model BlogPost { }
model OrderItem { }
```

### Fields

```prisma
model User {
  // camelCase
  id        String   @id
  email     String
  firstName String
  createdAt DateTime
  updatedAt DateTime
}
```

### Relations

```prisma
model Post {
  // Relation field: singular (one) or plural (many)
  author   User   @relation(fields: [authorId], references: [id])
  authorId String

  comments Comment[]  // Plural for array
}
```

## Standard Fields

### Every model should have

```prisma
model User {
  id        String   @id @default(cuid())
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  // ... other fields
}
```

### ID strategies

```prisma
// CUID (recommended - URL safe, sortable)
id String @id @default(cuid())

// UUID
id String @id @default(uuid())

// Auto-increment (avoid for distributed systems)
id Int @id @default(autoincrement())
```

## Relations

### One-to-One

```prisma
model User {
  id      String   @id @default(cuid())
  profile Profile?
}

model Profile {
  id     String @id @default(cuid())
  bio    String
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId String @unique
}
```

### One-to-Many

```prisma
model User {
  id    String @id @default(cuid())
  posts Post[]
}

model Post {
  id       String @id @default(cuid())
  author   User   @relation(fields: [authorId], references: [id])
  authorId String
}
```

### Many-to-Many

```prisma
// Implicit (Prisma manages join table)
model Post {
  id       String     @id @default(cuid())
  tags     Tag[]
}

model Tag {
  id    String @id @default(cuid())
  name  String
  posts Post[]
}

// Explicit (when you need extra fields)
model Post {
  id       String     @id @default(cuid())
  tags     PostTag[]
}

model Tag {
  id    String    @id @default(cuid())
  name  String
  posts PostTag[]
}

model PostTag {
  post      Post     @relation(fields: [postId], references: [id])
  postId    String
  tag       Tag      @relation(fields: [tagId], references: [id])
  tagId     String
  assignedAt DateTime @default(now())

  @@id([postId, tagId])
}
```

## Indexes

```prisma
model User {
  id    String @id @default(cuid())
  email String @unique
  name  String

  // Single field index
  @@index([name])
}

model Post {
  id        String   @id @default(cuid())
  authorId  String
  status    String
  createdAt DateTime @default(now())

  // Composite index
  @@index([authorId, status])
  @@index([createdAt])
}
```

## Enums

```prisma
enum Role {
  USER
  ADMIN
  MODERATOR
}

enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}

model User {
  id   String @id @default(cuid())
  role Role   @default(USER)
}
```

## Soft Deletes

```prisma
model User {
  id        String    @id @default(cuid())
  deletedAt DateTime?

  // Filter in queries:
  // where: { deletedAt: null }
}
```

## Cascade Deletes

```prisma
model User {
  id    String @id @default(cuid())
  posts Post[]
}

model Post {
  id       String @id @default(cuid())
  author   User   @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId String
  
  // When user is deleted, their posts are also deleted
}
```

## Example Schema

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  role      Role     @default(USER)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  posts    Post[]
  profile  Profile?
  accounts Account[]
}

model Profile {
  id     String  @id @default(cuid())
  bio    String?
  avatar String?
  
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId String @unique
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  author   User   @relation(fields: [authorId], references: [id])
  authorId String

  @@index([authorId])
}

enum Role {
  USER
  ADMIN
}
```
