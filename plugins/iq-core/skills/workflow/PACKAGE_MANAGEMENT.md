# Package Management

## Tools Overview

| Tool | Purpose |
|------|---------|
| **pnpm** | Package management (installing, updating dependencies) |
| **bun** | Quick script execution |
| **Turborepo** | Monorepo orchestration (if applicable) |

## pnpm

pnpm is the primary package manager. Use it for all dependency operations.

### Common Commands

```bash
# Install all dependencies
pnpm install

# Add a dependency
pnpm add <package>

# Add a dev dependency
pnpm add -D <package>

# Remove a dependency
pnpm remove <package>

# Update dependencies
pnpm update

# Update a specific package
pnpm update <package>

# Run a script
pnpm run <script>
# or shorthand
pnpm <script>

# Execute a package binary
pnpm exec <command>
# or shorthand
pnpm dlx <package>
```

### Workspace Commands (Monorepo)

```bash
# Run command in specific workspace
pnpm --filter <workspace-name> <command>

# Run command in all workspaces
pnpm -r <command>

# Add dependency to specific workspace
pnpm --filter <workspace-name> add <package>

# Run script in all workspaces that have it
pnpm -r run build
```

### pnpm-workspace.yaml

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

## bun

Use bun for quick script execution when you need speed. It's faster than Node.js for running scripts.

### When to Use Bun

- Running quick one-off scripts
- Development scripts that need fast startup
- Testing scripts during development

### Commands

```bash
# Run a script
bun run script.ts

# Run package.json script
bun run <script>

# Execute TypeScript directly
bun file.ts
```

**Note:** For production builds and deployments, stick with pnpm/Node.js for consistency. Use bun for local development speed.

## Turborepo

Turborepo is used for monorepo task orchestration. It provides caching, parallel execution, and task dependencies.

### When to Use

- Monorepo with multiple apps/packages
- Shared build/test pipelines
- Need for intelligent caching

### turbo.json

```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["build"]
    },
    "typecheck": {
      "dependsOn": ["^build"]
    }
  }
}
```

### Commands

```bash
# Run task across all workspaces
pnpm turbo run build

# Run task for specific workspace
pnpm turbo run build --filter=<workspace>

# Run multiple tasks
pnpm turbo run build lint test

# Force fresh run (no cache)
pnpm turbo run build --force

# See what would run (dry run)
pnpm turbo run build --dry-run
```

### Task Dependencies

- `dependsOn: ["^build"]` - Run `build` in dependencies first
- `dependsOn: ["build"]` - Run `build` in same package first
- `outputs` - Files to cache
- `cache: false` - Don't cache this task
- `persistent: true` - Long-running task (like dev server)

## Project Setup

### Single Project (Next.js/NestJS)

```bash
# Initialize
pnpm init

# Install dependencies
pnpm install
```

### Monorepo Setup

```bash
# Initialize root
pnpm init

# Create workspace config
# pnpm-workspace.yaml (see above)

# Install turborepo
pnpm add -D turbo

# Create turbo.json (see above)

# Create apps/packages structure
mkdir -p apps packages
```

## Quick Reference

```bash
# Install deps
pnpm install

# Add package
pnpm add <pkg>

# Add dev package
pnpm add -D <pkg>

# Run script
pnpm <script>

# Quick script run
bun run script.ts

# Monorepo build
pnpm turbo run build

# Filter to workspace
pnpm --filter <name> <cmd>
```
