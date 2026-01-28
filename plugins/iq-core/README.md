# IQ Core Plugin

Core IQ development standards and tools for Claude Code.

## Overview
This plugin provides the foundational configuration, agents, and skills for IQAI development. It enforces consistent coding standards, workflow practices, and security rules across all projects.

## Components

### Agents
- `planner`: Creates detailed implementation plans.
- `code-reviewer`: Reviews code for quality and security.
- `build-error-resolver`: Helper to fix build and type errors.
- `pr-writer`: Generates PR descriptions.
- `doc-updater`: Keeps documentation in sync.

### Commands
- `/plan`: Trigger the planner agent.
- `/review`: Trigger the code reviewer.
- `/fix-build`: Trigger the build error resolver.
- `/refactor`: Trigger code cleanup.
- `/sync-docs`: Trigger documentation updates.

### Skills
- **Workflow**: Git conventions, PR templates, NPM publishing.
- **TypeScript**: Coding standards, best practices.
- **Next.js / NestJS**: Framework-specific patterns.
- **Security**: Secret scanning and best practices.
- **Design**: Brand guidelines and UI patterns.

## Hooks
- **Console Log Check**: Warns if `console.log` is left in code.
- **Secret Scanning**: Checks for hardcoded secrets in committed files.
