# IQ Claude Config

Modular Claude Code plugins for IQ development. Install only what your project needs.

## Plugins

| Plugin | For | Skills |
|--------|-----|--------|
| **iq-nextjs** | Next.js full-stack apps | nextjs, design, database, auth, iq-gateway, testing, agent-browser |
| **iq-nestjs** | NestJS backend/indexers | nestjs, database, testing |
| **iq-mcps** | MCP server development | mcp-development |
| **iq-adk-ts** | ADK-TS framework | adk-ts-docs-writer, adk-ts-readme-writer, adk-ts-style-guide |

## Installation

Run these inside a Claude Code session:

```
/plugin marketplace add IQAIcom/iq-claude-config
```

Then install the plugin(s) you need:

```
/plugin install iq-claude-config@iq-nextjs
/plugin install iq-claude-config@iq-nestjs
/plugin install iq-claude-config@iq-mcps
/plugin install iq-claude-config@iq-adk-ts
```

When prompted, choose your scope:
- **User scope** — available in all your projects
- **Project scope** — shared with collaborators
- **Local scope** — only for you, in this repo

### Which plugins do I need?

| Project Type | Install |
|---|---|
| Next.js app | `iq-nextjs` |
| NestJS indexer | `iq-nestjs` |
| Turborepo monorepo | `iq-nextjs` + `iq-nestjs` |
| MCP server | `iq-mcps` |
| ADK-TS framework | `iq-adk-ts` |
| TypeScript library | None — use Claude defaults + `CLAUDE.md` |

### Update

```
/plugin marketplace update iq-claude-config
```

### Uninstall

```
/plugin uninstall iq-claude-config@iq-nextjs
```

## Best Practices

See [BEST_PRACTICES.md](./BEST_PRACTICES.md) for copy-paste snippets to add to your project's `CLAUDE.md`.

## Contributing

1. Create a branch
2. Make changes
3. Test with Claude Code
4. Submit PR

## License

MIT
