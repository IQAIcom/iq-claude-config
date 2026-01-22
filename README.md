# IQ Claude Config

Company-wide Claude Code configuration for consistent development across all projects.

## Installation

### As Plugin (Recommended)

Run these commands inside a Claude Code session (these are slash commands, not terminal commands):

```
/plugin marketplace add IQAIcom/iq-claude-config
/plugin install iq-claude-config@iq-claude-config
```

When prompted, choose your installation scope:
- **User scope** - Available in all your projects
- **Project scope** - Shared with collaborators on this repo
- **Local scope** - Only for you, in this repo only

### Verify Installation

```
/plugin
```

Navigate to the "Installed" tab to see the plugin and its components.

### Update Plugin

```
/plugin marketplace update iq-claude-config
```

### Uninstall

```
/plugin uninstall iq-claude-config@iq-claude-config
```

## What's Included

### Agents
Task-specific sub-agents for delegation:
- `build-error-resolver` - Fixes build/type errors
- `refactor-cleaner` - Dead code cleanup
- `doc-updater` - Documentation sync
- `code-reviewer` - Quality and security review
- `planner` - Feature implementation planning
- `pr-writer` - PR description generation
- `e2e-runner` - Playwright E2E testing

### Commands
Slash commands for quick actions:
- `/plan` - Create implementation plan
- `/review` - Trigger code review
- `/fix-build` - Fix build errors
- `/sync-docs` - Sync documentation
- `/refactor` - Clean up code

### Rules
Always-active guidelines:
- `stack-selection` - Default Next.js, NestJS only for indexers
- `security` - Security best practices
- `git-conventions` - Commit format, branching
- `code-quality` - Code standards

### Skills
Domain knowledge and best practices:
- `nextjs/` - RSC, Server Actions, folder structure
- `nestjs/` - Indexer/service patterns
- `design/` - Shadcn, Tailwind, brand guidelines
- `database/` - Prisma patterns
- `workflow/` - Git, NPM publishing, PR templates
- `typescript/` - Type conventions

## Stack Selection

```
Default: Next.js (full-stack with server actions)

Use NestJS ONLY when:
- Building a blockchain indexer
- Service requires heavy background processing
- Needs persistent WebSocket connections
- Compute-intensive operations that would block Next.js
```

## Contributing

1. Create a branch
2. Make changes
3. Test with Claude Code
4. Submit PR

## License

MIT
