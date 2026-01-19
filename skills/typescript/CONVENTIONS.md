# TypeScript Conventions

## Code Style Principles

### Readability First
- Easy to understand at a glance
- Explicit over implicit - descriptive code over clever tricks
- Consistent patterns for similar functionality

### Modular Design
- Break complex features into composable pieces
- Avoid repetition through composition and abstraction
- Single responsibility - one function/class = one job

### Simplicity
- Prefer the simplest solution that works
- Don't over-engineer or add unnecessary abstractions
- Three similar lines is better than a premature abstraction

## Configuration

### tsconfig.json (Next.js)

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "noUncheckedIndexedAccess": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

## Type Definitions

### Interfaces vs Types

```typescript
// ✅ Interface - for object shapes (extendable)
interface User {
  id: string;
  name: string;
  email: string;
}

interface AdminUser extends User {
  permissions: string[];
}

// ✅ Type - for unions, intersections, primitives
type Status = 'pending' | 'active' | 'deleted';
type ID = string | number;
type Nullable<T> = T | null;
type UserOrAdmin = User | AdminUser;
```

### Naming

```typescript
// Interfaces: PascalCase, noun
interface UserProfile {}
interface ApiResponse {}

// Types: PascalCase
type UserId = string;
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';

// Enums: PascalCase, singular
enum Role {
  User = 'USER',
  Admin = 'ADMIN',
}

// Generic parameters: T, K, V or descriptive
type Container<TItem> = { item: TItem };
type Record<TKey extends string, TValue> = { [K in TKey]: TValue };
```

## Function Types

### Explicit Return Types for Exports

```typescript
// ✅ Explicit for public API
export function getUser(id: string): Promise<User | null> {
  return db.user.findUnique({ where: { id } });
}

export async function createUser(data: CreateUserInput): Promise<User> {
  return db.user.create({ data });
}

// Implicit OK for internal/simple functions
const double = (n: number) => n * 2;
```

### Function Signatures

```typescript
// ✅ Arrow function type
type Formatter = (value: string) => string;

// ✅ Function with overloads
function parse(input: string): number;
function parse(input: number): string;
function parse(input: string | number): number | string {
  return typeof input === 'string' ? parseInt(input) : input.toString();
}
```

## Avoiding `any`

### Use `unknown` for Truly Unknown

```typescript
// ❌ Bad
function process(data: any) {
  return data.value;
}

// ✅ Good - validate first
function process(data: unknown) {
  if (isValidData(data)) {
    return data.value;
  }
  throw new Error('Invalid data');
}

function isValidData(data: unknown): data is { value: string } {
  return typeof data === 'object' && data !== null && 'value' in data;
}
```

### Type Guards

```typescript
// Type predicate
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value
  );
}

// Usage
if (isUser(data)) {
  console.log(data.name); // TypeScript knows it's User
}
```

### Assertions (use sparingly)

```typescript
// ✅ When you know more than TypeScript
const element = document.getElementById('root') as HTMLDivElement;

// ✅ Non-null assertion (when you're certain)
const value = map.get(key)!;

// ❌ Avoid - bypasses type checking
const data = response as any;
```

## Utility Types

### Common Patterns

```typescript
// Partial - all properties optional
type UpdateUser = Partial<User>;

// Required - all properties required
type CompleteUser = Required<User>;

// Pick - select properties
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit - exclude properties
type CreateUser = Omit<User, 'id' | 'createdAt'>;

// Record - key-value map
type UserMap = Record<string, User>;

// ReturnType - extract return type
type UserResponse = ReturnType<typeof getUser>;

// Parameters - extract parameter types
type GetUserParams = Parameters<typeof getUser>;
```

### Custom Utility Types

```typescript
// Nullable
type Nullable<T> = T | null;

// NonNullable values of object
type NonNullableFields<T> = {
  [K in keyof T]: NonNullable<T[K]>;
};

// Deep partial
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K];
};
```

## Generic Patterns

### Constrained Generics

```typescript
// Constrain to objects with id
function findById<T extends { id: string }>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id);
}

// Constrain to keys of object
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

### Default Generic Parameters

```typescript
interface ApiResponse<T = unknown> {
  data: T;
  status: number;
}

// Usage
const response: ApiResponse<User> = { data: user, status: 200 };
const unknownResponse: ApiResponse = { data: {}, status: 200 };
```

## React Patterns

### Component Props

```typescript
// ✅ Interface for props
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  onClick?: () => void;
}

// ✅ Extend HTML attributes
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary';
}

// Usage
function Button({ variant = 'primary', children, ...props }: ButtonProps) {
  return <button {...props}>{children}</button>;
}
```

### Event Handlers

```typescript
// ✅ Typed event handlers
const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {};
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {};
const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {};
```

### Refs

```typescript
// ✅ Typed refs
const inputRef = useRef<HTMLInputElement>(null);
const divRef = useRef<HTMLDivElement>(null);
```

## Zod Integration

### Schema to Type

```typescript
import { z } from 'zod';

const userSchema = z.object({
  id: z.string(),
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(['user', 'admin']),
});

// Infer type from schema
type User = z.infer<typeof userSchema>;
```
