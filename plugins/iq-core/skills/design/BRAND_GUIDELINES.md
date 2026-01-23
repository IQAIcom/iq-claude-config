# Brand Guidelines

## Colors

Define in `tailwind.config.ts` and `globals.css`:

```css
/* globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    /* ... dark mode values */
  }
}
```

## Usage

```tsx
// Use semantic colors
<div className="bg-background text-foreground" />
<button className="bg-primary text-primary-foreground" />
<p className="text-muted-foreground" />
```

## Typography

### Font Stack

```typescript
// tailwind.config.ts
fontFamily: {
  sans: ['Inter', 'system-ui', 'sans-serif'],
  mono: ['JetBrains Mono', 'monospace'],
}
```

### Scale

| Class | Size | Use |
|-------|------|-----|
| `text-xs` | 12px | Labels, captions |
| `text-sm` | 14px | Secondary text |
| `text-base` | 16px | Body text |
| `text-lg` | 18px | Lead text |
| `text-xl` | 20px | Section headings |
| `text-2xl` | 24px | Page headings |
| `text-3xl` | 30px | Hero headings |

### Font Weights

- `font-normal` (400) - Body text
- `font-medium` (500) - UI labels
- `font-semibold` (600) - Headings
- `font-bold` (700) - Emphasis

## Spacing

Use Tailwind's default scale consistently:

| Class | Value | Use |
|-------|-------|-----|
| `p-1` | 4px | Tight padding |
| `p-2` | 8px | Compact |
| `p-4` | 16px | Standard |
| `p-6` | 24px | Relaxed |
| `p-8` | 32px | Sections |

### Common Patterns

```tsx
// Card padding
<div className="p-6" />

// Button padding
<button className="px-4 py-2" />

// Section spacing
<section className="py-12 md:py-16" />

// Stack spacing
<div className="space-y-4" />
```

## Border Radius

```tsx
// Use design tokens
<div className="rounded-md" />    // Default
<div className="rounded-lg" />    // Cards
<div className="rounded-full" />  // Avatars, pills
```

## Shadows

```tsx
<div className="shadow-sm" />   // Subtle
<div className="shadow" />      // Default
<div className="shadow-md" />   // Elevated
<div className="shadow-lg" />   // Modal
```

## Icons

Use Lucide React for consistency:

```tsx
import { User, Settings, ChevronRight } from 'lucide-react';

<User className="h-4 w-4" />        // Small
<Settings className="h-5 w-5" />    // Default
<ChevronRight className="h-6 w-6" /> // Large
```
