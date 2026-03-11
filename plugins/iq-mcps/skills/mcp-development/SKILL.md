---
name: mcp-development
description: Use when building MCP servers, defining MCP tools, or working on @iqai/ MCP packages
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# MCP Server Development Skill

IQ conventions for building MCP (Model Context Protocol) servers, based on patterns from IQ's 19 MCP server packages.

## Two Patterns — When to Use Which

### FastMCP (Preferred for Most Servers)

Higher-level, simpler API. Best for: simple API wrappers, data fetchers, single-concern servers.

```typescript
import { FastMCP } from "fastmcp";
import { z } from "zod";

const server = new FastMCP({ name: "mcp-example", version: "1.0.0" });

server.addTool({
  name: "tool_name",
  description: "What this tool does",
  parameters: z.object({
    param: z.string().describe("Description of param"),
  }),
  execute: async (params) => {
    const service = new SomeService();
    const result = await service.doThing(params.param);
    return JSON.stringify(result, null, 2);
  },
});

server.start({ transportType: "stdio" });
```

### MCP SDK Directly (`@modelcontextprotocol/sdk`)

Lower-level, more control. Use for: servers needing sampling, resources, complex state, or bi-directional communication.

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  { name: "mcp-example", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: toolList,
}));

server.setRequestHandler(CallToolRequestSchema, async (req) => {
  switch (req.params.name) {
    case "tool_name":
      return handleTool(req.params.arguments);
    default:
      throw new Error(`Unknown tool: ${req.params.name}`);
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

## Project Structure

```
mcp-{name}/
├── src/
│   ├── index.ts          # Entry point — server init
│   ├── tools/            # Tool definitions
│   │   ├── index.ts      # Tool exports
│   │   └── {tool-name}.ts
│   ├── services/         # Business logic
│   ├── config.ts         # Configuration
│   └── types.ts          # Type definitions
├── package.json
├── tsconfig.json
├── biome.jsonc
└── .changeset/
```

## Tool Definition Pattern (FastMCP)

```typescript
import { z } from "zod";

const schema = z.object({
  param: z.string().describe("Description"),
});

export const toolName = {
  name: "tool_name", // snake_case always
  description: "What this tool does",
  parameters: schema,
  execute: async (params: z.infer<typeof schema>) => {
    const service = new SomeService();
    const result = await service.doThing(params.param);
    return JSON.stringify(result, null, 2);
  },
} as const;
```

## Tool Definition Pattern (MCP SDK)

```typescript
// tool-list.ts
export const toolList = [
  {
    name: "tool_name",
    description: "Description",
    inputSchema: {
      type: "object" as const,
      properties: {
        param: { type: "string", description: "Description" },
      },
      required: ["param"],
    },
  },
];

// server.ts — handler
server.setRequestHandler(CallToolRequestSchema, async (req) => {
  switch (req.params.name) {
    case "tool_name":
      return handleTool(req.params.arguments);
  }
});
```

## Naming and Package Conventions

- **Package name:** `@iqai/mcp-{name}`
- **Tool names:** always `snake_case`
- **CLI bin:** `mcp-{name}`
- **ES modules:** `"type": "module"` in package.json
- **TypeScript:** ES2022 target, NodeNext modules, strict mode
- **Validation:** Zod for all parameter validation AND environment variable validation
- **Formatting/Linting:** Biome (NOT ESLint/Prettier)
- **Versioning:** Changesets
- **Pre-commit:** Husky + lint-staged

## Environment Configuration

Always validate environment variables with Zod:

```typescript
import { z } from "zod";

const envSchema = z.object({
  API_KEY: z.string().optional(),
  TRANSPORT: z.enum(["stdio", "http"]).default("stdio"),
});

export const env = envSchema.parse(process.env);
```

## Transport

- **Default:** stdio (`server.start({ transportType: "stdio" })`)
- **Optional:** HTTP for servers that need it

## Build and Publish Scripts

```json
{
  "scripts": {
    "build": "tsc && shx chmod +x dist/index.js",
    "start": "node dist/index.js",
    "format": "biome format . --write",
    "lint": "biome check .",
    "publish-packages": "pnpm run build && changeset publish"
  }
}
```

## Key Rules

1. **Separate business logic into `services/`** — tools should be thin wrappers that delegate to service classes.
2. **Return `JSON.stringify(result, null, 2)`** from tool execute functions.
3. **Never expose secrets** in tool responses.
4. **Use `shx chmod +x dist/index.js`** in the build script to ensure CLI executability.
5. **Include a `"bin"` field** in package.json for npx usage:
   ```json
   {
     "bin": {
       "mcp-{name}": "dist/index.js"
     }
   }
   ```
6. **Add `#!/usr/bin/env node`** at the top of `src/index.ts`.
