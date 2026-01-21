# IQ Development Skills

This folder contains company-wide development knowledge and best practices.

## Stack Selection

```
┌─────────────────────────────────────────────────────┐
│                   New Project?                       │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
         ┌──────────────────────────────┐
         │  Is it an indexer or heavy   │
         │  background service?         │
         └──────────────────────────────┘
                  │           │
                 YES          NO
                  │           │
                  ▼           ▼
            ┌─────────┐  ┌─────────┐
            │ NestJS  │  │ Next.js │
            └─────────┘  └─────────┘
```

## Available Skills

### Core Stack
- **[nextjs/](./nextjs/SKILL.md)** - Next.js App Router, RSC, Server Actions
- **[nestjs/](./nestjs/SKILL.md)** - NestJS for indexers and heavy services

### Frontend
- **[design/](./design/SKILL.md)** - Shadcn UI, Tailwind, brand guidelines

### Data
- **[database/](./database/SKILL.md)** - Prisma patterns and schema conventions

### Auth
- **[auth/](./auth/SKILL.md)** - IQ Login for Web3 authentication

### Infrastructure
- **[iq-gateway/](./iq-gateway/SKILL.md)** - Centralized proxy for external APIs (CMC, CoinGecko, Etherscan)

### Testing
- **[testing/](./testing/SKILL.md)** - Vitest, Testing Library, Playwright

### Automation
- **[agent-browser/](./agent-browser/SKILL.md)** - Browser automation for testing and scraping

### Process
- **[workflow/](./workflow/SKILL.md)** - Git, NPM publishing, PR templates
- **[typescript/](./typescript/SKILL.md)** - TypeScript conventions

## Quick Reference

| Task | Skill |
|------|-------|
| New web app | nextjs/ |
| Blockchain indexer | nestjs/ |
| UI components | design/ |
| Database schema | database/ |
| Authentication | auth/ |
| External APIs (CMC, CG) | iq-gateway/ |
| Writing tests | testing/ |
| Browser automation | agent-browser/ |
| Publishing package | workflow/NPM_PUBLISHING.md |
| Commit message | workflow/GIT_CONVENTIONS.md |
