# IQ Claude Config

Company-wide Claude Code configuration for consistent development across all projects.

## Installation

### As Plugin (Recommended)

```bash
# Add to marketplace
claude plugin marketplace add IQAIcom/iq-claude-config

# Install
claude plugin install iq-claude-config
```

### Manual Installation

```bash
git clone https://github.com/IQAIcom/iq-claude-config.git
cp -r iq-claude-config/* ~/.claude/
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
