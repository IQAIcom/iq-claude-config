# IQ Best Practices

Pick what applies to your project. Paste into `CLAUDE.md`.

- Order methods by abstraction level: caller before callee, so reading top-to-bottom flows from high-level to low-level.
- Use `unknown` instead of `any`. If you need a type escape hatch, add a type assertion with a comment explaining why.
- No `console.log` in committed code.
