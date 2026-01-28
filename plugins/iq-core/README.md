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
- `e2e-runner`: Runs Playwright E2E tests.
- `refactor-cleaner`: Identifies and removes dead code.

### Commands
- `/plan`: Trigger the planner agent.
- `/review`: Trigger the code reviewer.
- `/fix-build`: Trigger the build error resolver.
- `/refactor`: Trigger code cleanup.
- `/sync-docs`: Trigger documentation updates.

### Skills
- **Workflow**: Git conventions, PR templates, NPM publishing.
- **TypeScript**: Coding standards, best practices.
- **Next.js**: App Router patterns, Server Components, Actions.
- **NestJS**: Backend patterns for indexers and services.
- **Software Design**: Core principles (SOLID, DRY), clean code, error handling.
- **Testing**: Vitest, React Testing Library, Playwright patterns.
- **Auth**: Authentication setup and usage.
- **Database**: Prisma patterns and schema conventions.
- **Design**: Brand guidelines, Shadcn, Tailwind.
- **IQ Gateway**: Gateway integration patterns.
- **Agent Browser**: Browser automation capabilities.

## Hooks
- **Console Log Check**: Warns if `console.log` is left in code.
- **Secret Scanning**: Detects hardcoded secrets (e.g., API keys) before commit.
