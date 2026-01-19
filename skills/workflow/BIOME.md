# Biome

Biome is used for linting and formatting. We use the base/recommended configuration with minimal customization.

## Setup

```bash
pnpm add -D @biomejs/biome
pnpm biome init
```

This generates a `biome.json` with recommended defaults. Don't modify unless necessary.

## NestJS Exception

For NestJS projects, disable the `useImportType` rule:

```json
{
  "linter": {
    "rules": {
      "style": {
        "useImportType": "off"
      }
    }
  }
}
```

**Why:** NestJS relies on runtime reflection for dependency injection. When imports are marked as `type`, they're erased at compile time, breaking DI and decorators like `@Injectable()`, `@Controller()`, etc.

```ts
// ❌ Breaks NestJS DI
import type { UserService } from './user.service';

// ✅ Works with NestJS
import { UserService } from './user.service';
```

## Commands

```bash
# Check linting
pnpm biome check .

# Fix auto-fixable issues
pnpm biome check --write .

# Format only
pnpm biome format --write .

# Lint only
pnpm biome lint .
```

## VS Code Integration

Install the Biome extension. Add to `.vscode/settings.json`:

```json
{
  "editor.defaultFormatter": "biomejs.biome",
  "editor.formatOnSave": true
}
```

## Ignoring

Inline ignore:

```ts
// biome-ignore lint/suspicious/noExplicitAny: reason here
const data: any = fetchData();
```

File patterns in `biome.json`:

```json
{
  "files": {
    "ignore": ["**/generated/**", "**/dist/**"]
  }
}
```
