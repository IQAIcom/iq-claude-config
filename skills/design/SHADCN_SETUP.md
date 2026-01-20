# Shadcn UI Setup

## Installation

```bash
npx shadcn@latest init
```

Configuration prompts:
- Style: Default
- Base color: Slate (or your preference)
- CSS variables: Yes
- Tailwind config: `tailwind.config.ts`
- Components path: `@/components/ui`
- Utils path: `@/lib/utils`

## Adding Components

```bash
# Single component
npx shadcn@latest add button

# Multiple components
npx shadcn@latest add button card input

# All components (not recommended)
npx shadcn@latest add --all
```

## Recommended Components

Essential for most projects:

```bash
npx shadcn@latest add button
npx shadcn@latest add input
npx shadcn@latest add label
npx shadcn@latest add card
npx shadcn@latest add dialog
npx shadcn@latest add dropdown-menu
npx shadcn@latest add form
npx shadcn@latest add toast
npx shadcn@latest add skeleton
npx shadcn@latest add avatar
npx shadcn@latest add badge
npx shadcn@latest add separator
```

## Usage

```tsx
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';

export function MyComponent() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Title</CardTitle>
      </CardHeader>
      <CardContent>
        <Input placeholder="Enter text" />
        <Button>Submit</Button>
      </CardContent>
    </Card>
  );
}
```

## Customization

### Extend variants

```tsx
// components/ui/button.tsx
const buttonVariants = cva(
  '...base styles...',
  {
    variants: {
      variant: {
        default: '...',
        destructive: '...',
        // Add custom variant
        gradient: 'bg-gradient-to-r from-purple-500 to-blue-500 text-white',
      },
    },
  }
);
```

### Override styles

```tsx
// Keep component props, add custom classes
<Button className="w-full">Full Width</Button>
<Card className="border-none shadow-lg">No Border</Card>
```

## Form Pattern

Use with react-hook-form and zod:

```tsx
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export function LoginForm() {
  const form = useForm({
    resolver: zodResolver(schema),
    defaultValues: { email: '', password: '' },
  });

  const onSubmit = (data: z.infer<typeof schema>) => {
    // Handle submit
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input {...field} type="email" />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Login</Button>
      </form>
    </Form>
  );
}
```

## Toast Notifications

```tsx
// Setup in layout
import { Toaster } from '@/components/ui/toaster';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Toaster />
      </body>
    </html>
  );
}

// Usage anywhere
import { useToast } from '@/components/ui/use-toast';

export function MyComponent() {
  const { toast } = useToast();

  return (
    <Button
      onClick={() => toast({ 
        title: 'Success', 
        description: 'Operation completed' 
      })}
    >
      Show Toast
    </Button>
  );
}
```

## Dark Mode

```tsx
// Use next-themes
import { ThemeProvider } from 'next-themes';

export default function RootLayout({ children }) {
  return (
    <html suppressHydrationWarning>
      <body>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
```
