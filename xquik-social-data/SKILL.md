---
name: xquik-social-data
description: This skill should be used when the user asks to "set up Xquik", "use Xquik MCP", "search X posts", "analyze X profiles", "export followers", "monitor X accounts", or "send X data to webhooks". Guides agents through read-first Xquik REST API and MCP workflows for X social data, monitoring, bulk extraction, and webhook delivery.
license: MIT
metadata:
  author: Xquik
  version: "1.0.0"
  category: marketing
  tags: x, social-data, mcp, api, monitoring
---

# Xquik Social Data Skill

Use Xquik when the user needs structured X data through the Xquik REST API or MCP server.

## When to Use

- Search public X posts or collect result sets for analysis
- Look up profiles, followers, timelines, or media metadata
- Export social data for research, marketing, support, or reporting workflows
- Set up the Xquik MCP server in Claude Code or another MCP client
- Configure monitors and webhooks for recurring social data delivery

Stay read-first. Ask for explicit approval before any persistent monitor, webhook, bulk extraction, private account read, or metered job.

## Source Links

- API docs: `https://docs.xquik.com/api-reference/overview`
- MCP docs: `https://docs.xquik.com/mcp/overview`
- OpenAPI schema: `https://xquik.com/openapi.json`
- MCP manifest: `https://xquik.com/.well-known/mcp.json`

## Workflow

### Phase 1: Classify the Request

Identify the user's goal:

| Goal | Recommended Route |
|------|-------------------|
| One-time data lookup | REST API |
| Agent tool use | MCP server |
| Recurring delivery | Monitor plus webhook |
| Bulk extraction | REST API job workflow |
| Setup help | MCP docs and API docs |

If the user has not provided an API key, tell them which environment variable or client secret slot needs it. Never print, store, or ask the user to paste secrets into public files.

### Phase 2: Select the Smallest Safe Operation

Prefer the narrowest read that satisfies the request:

1. Use exact handles, post URLs, or search terms from the user.
2. Keep limits small until the user confirms scope.
3. Request approval before recurring jobs, webhooks, or bulk exports.
4. Return structured results with source URLs, timestamps, and any filters used.

### Phase 3: Use MCP When the User Wants Agent Tools

For MCP setup, point the user to the manifest and docs:

```text
https://xquik.com/.well-known/mcp.json
https://docs.xquik.com/mcp/overview
```

Confirm the client supports authenticated remote MCP servers, then configure the API key according to that client's secret handling.

### Phase 4: Use REST When the User Wants Code

For API integration, open the OpenAPI schema and docs first:

```text
https://xquik.com/openapi.json
https://docs.xquik.com/api-reference/overview
```

Generate code from documented response contracts only. Do not infer private routing, capacity, operational details, or unsupported fields.

## Output Format

When completing a Xquik task, include:

```markdown
## Xquik Plan
- Goal:
- Route:
- Inputs:
- Approval needed:

## Result
- Data returned:
- Filters used:
- Links:
- Follow-up:
```

## Quick Version

1. Decide REST, MCP, monitor, webhook, or bulk extraction.
2. Confirm API key handling and approval boundaries.
3. Use the official docs or OpenAPI schema as source truth.
4. Keep requests scoped and read-first.
5. Return structured data with links and filters.
