# IQ Best Practices

Pick what applies to your project. Paste into `CLAUDE.md`.

- Order methods by abstraction level: caller before callee, so reading top-to-bottom flows from high-level to low-level.
- Use `unknown` instead of `any`. If you need a type escape hatch, add a type assertion with a comment explaining why.
- If Shadcn UI or Radix provides a component (modal, dropdown, button, etc.), use it. Never build custom equivalents from scratch — wrap or style the library primitive instead.
- Every UI element must justify its existence. If it has no clear purpose, remove it.
- Reject generic template-like layouts. If it looks like every other landing page or dashboard, rethink the design.
