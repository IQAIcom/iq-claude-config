# iq-adk-ts

ADK-TS framework documentation, style guide, and content management tools for Claude Code.

## Components

### Skills

- **adk-ts-docs-writer** - Write and update ADK-TS documentation
- **adk-ts-readme-writer** - Generate README files for ADK-TS projects
- **adk-ts-style-guide** - Apply ADK-TS style guide conventions

### Agents

- **docs-freshness-checker** - Check documentation for staleness and outdated content
- **docs-reviewer** - Review documentation for quality and accuracy
- **docs-writer** - Write new documentation following ADK-TS conventions
- **mcp-docs-generator** - Generate MCP server documentation

### Commands

- **adk-ts-changelog** - Generate changelogs for ADK-TS releases
- **adk-ts-docs-audit** - Audit existing documentation for issues
- **adk-ts-starter-sync** - Sync starter template documentation

## Installation

Add this plugin to your Claude Code configuration:

```json
{
  "plugins": ["./plugins/iq-adk-ts"]
}
```
