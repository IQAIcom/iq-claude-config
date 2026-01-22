# Tailwind Conventions

## Class Order

Follow this order for consistency:

1. Layout (display, position, grid, flex)
2. Sizing (width, height)
3. Spacing (margin, padding)
4. Typography (font, text)
5. Visual (bg, border, shadow)
6. Interactive (hover, focus)

```tsx
// ✅ Good - consistent order
<div className="flex items-center justify-between w-full p-4 text-sm bg-white border rounded-lg hover:bg-gray-50" />

// ❌ Bad - random order
<div className="rounded-lg hover:bg-gray-50 text-sm flex p-4 border w-full bg-white items-center justify-between" />
```

## Responsive Design

### Mobile-first approach

```tsx
// Base styles apply to mobile, then scale up
<div className="p-4 md:p-6 lg:p-8" />
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3" />
<div className="text-base md:text-lg" />
```

### Breakpoints

| Prefix | Min Width | Use |
|--------|-----------|-----|
| (none) | 0px | Mobile |
| `sm:` | 640px | Small tablets |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | Laptops |
| `xl:` | 1280px | Desktops |
| `2xl:` | 1536px | Large screens |

## Common Patterns

### Centering

```tsx
// Flexbox
<div className="flex items-center justify-center" />

// Grid
<div className="grid place-items-center" />

// Absolute
<div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
```

### Truncate Text

```tsx
// Single line
<p className="truncate" />

// Multi-line (line-clamp)
<p className="line-clamp-2" />
<p className="line-clamp-3" />
```

### Cards

```tsx
<div className="rounded-lg border bg-card p-6 shadow-sm" />
```

### Stacks

```tsx
// Vertical stack
<div className="flex flex-col space-y-4" />
// or
<div className="space-y-4" />

// Horizontal stack
<div className="flex space-x-4" />
```

### Container

```tsx
<div className="container mx-auto px-4" />
// or with max-width
<div className="mx-auto max-w-4xl px-4" />
```

## Avoid

### Arbitrary values

```tsx
// ❌ Bad
<div className="w-[347px] p-[13px]" />

// ✅ Good - use scale
<div className="w-80 p-4" />
```

### Too many classes

```tsx
// ❌ Bad - extract to component
<button className="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2" />

// ✅ Good - use Shadcn Button
<Button>Click me</Button>
```

### Inline styles

```tsx
// ❌ Bad
<div style={{ marginTop: '20px' }} />

// ✅ Good
<div className="mt-5" />
```

## Dark Mode

### With CSS variables (recommended)

```tsx
// Uses CSS variables from Shadcn
<div className="bg-background text-foreground" />
<div className="bg-card text-card-foreground" />
```

### With dark: prefix

```tsx
<div className="bg-white dark:bg-gray-900" />
<p className="text-gray-900 dark:text-gray-100" />
```

## Animation

### Built-in

```tsx
<div className="animate-spin" />      // Spinner
<div className="animate-pulse" />     // Skeleton
<div className="animate-bounce" />    // Attention
```

### Transitions

```tsx
<button className="transition-colors hover:bg-gray-100" />
<div className="transition-transform hover:scale-105" />
<div className="transition-all duration-200" />
```

## Group and Peer

```tsx
// Parent hover affects child
<div className="group">
  <span className="group-hover:text-blue-500">Hover parent</span>
</div>

// Sibling state affects element
<input className="peer" />
<span className="peer-invalid:text-red-500">Error message</span>
```
