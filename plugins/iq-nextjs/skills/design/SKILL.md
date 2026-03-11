---
name: design
description: UI design system with Tailwind CSS, Shadcn UI components, and brand guidelines. Use when building UI components, styling, or implementing design patterns.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(npx:shadcn*)
---

# Design Skill

Design system and UI component guidelines for consistent, beautiful interfaces.

## Stack

- **Tailwind CSS** - Utility-first styling
- **Shadcn UI** - Component library (copy-paste, customizable)
- **Lucide Icons** - Icon set
- **Radix UI** - Headless primitives (via Shadcn)

## Related Files

- [BRAND_GUIDELINES.md](./BRAND_GUIDELINES.md) - Colors, typography, spacing
- [SHADCN_SETUP.md](./SHADCN_SETUP.md) - Component library setup
- [TAILWIND_CONVENTIONS.md](./TAILWIND_CONVENTIONS.md) - CSS conventions

## Quick Start

```bash
# Initialize Shadcn
npx shadcn@latest init

# Add components
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add input
```

## Principles

- If Shadcn UI or Radix provides a component (modal, dropdown, button, etc.), use it. Never build custom equivalents from scratch. You may wrap or style library components for a custom look, but the underlying primitive must come from the library.
- Every element must justify its existence. If it has no clear purpose, remove it.
- Reject generic template-like layouts. If it looks like every other landing page or dashboard, rethink the design.
- Prefer bespoke layouts, intentional asymmetry, and distinctive typography over safe defaults.
- Use design tokens, not arbitrary values. No magic numbers for colors, spacing, or font sizes.
- Focus on micro-interactions, precise spacing, and invisible UX over flashy decoration.
- Mobile-first. Ensure keyboard navigation and proper contrast.
