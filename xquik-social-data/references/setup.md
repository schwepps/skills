# Xquik Setup Reference

## Required Inputs

| Item | Purpose |
|------|---------|
| Xquik API key | Authenticates REST API and MCP requests |
| Target handles, URLs, or queries | Scopes the data request |
| Output destination | Determines JSON, report, monitor, or webhook format |

## Setup Checklist

- Confirm the user wants X social data, not a general web search.
- Confirm whether the task is one-time or recurring.
- Keep the first request narrow and read-only.
- Use the API docs, MCP docs, OpenAPI schema, or MCP manifest as source truth.
- Ask for approval before enabling monitors, webhooks, private reads, or bulk jobs.

## REST API Path

1. Open `https://docs.xquik.com/api-reference/overview`.
2. Open `https://xquik.com/openapi.json` for exact schemas.
3. Select the endpoint that matches the user's data need.
4. Keep limits and filters explicit.
5. Return the request shape, response summary, and source links.

## MCP Path

1. Open `https://docs.xquik.com/mcp/overview`.
2. Use `https://xquik.com/.well-known/mcp.json` as the manifest.
3. Configure the API key through the MCP client's secret mechanism.
4. Test with a narrow read-only task before larger workflows.

## Safety Notes

- Do not expose API keys or runtime secrets.
- Do not document private infrastructure, routing, capacity, or operational details.
- Do not invent endpoint names or response fields.
- Do not create recurring or bulk work without approval.
