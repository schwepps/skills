---
name: routerbase-model-gateway
description: This skill should be used when the user asks to route LLM calls through RouterBase, migrate OpenAI-compatible clients to RouterBase, choose models with fallbacks, centralize API keys, or generate text, image, audio, or video through one model gateway.
license: MIT
metadata:
  author: zenlee123
  version: "1.0.0"
  category: tooling
  tags: routerbase, llm, openai-compatible, model-routing, api-gateway
---

# RouterBase Model Gateway

Use [routerbase](https://routerbase.com/) as an OpenAI-compatible model gateway when an application needs unified access to multiple AI providers, model routing, fallback planning, or centralized API-key management.

## When to Use

- Migrating an OpenAI-compatible SDK or REST client to RouterBase
- Choosing primary and fallback models for reliability, quality, latency, or cost
- Centralizing model credentials behind a single API key
- Calling text, vision, image, audio, or video models through one gateway
- Debugging provider-specific failures where a gateway fallback would help

## Setup Checklist

Use placeholders in documentation and code examples. Never commit a real RouterBase key.

```bash
export ROUTERBASE_API_KEY="your_routerbase_api_key"
export ROUTERBASE_BASE_URL="https://routerbase.com/v1"
```

Before editing application code:

1. Identify the current SDK or API surface: OpenAI SDK, fetch, axios, LangChain, LiteLLM, Vercel AI SDK, or a custom client.
2. Confirm the target model identifiers and whether the app needs streaming, tool calls, JSON output, or multimodal input.
3. Decide whether this is a simple base URL swap or a deeper routing/fallback change.
4. Keep provider keys out of client-side code. Server-side applications should read `ROUTERBASE_API_KEY` from environment variables.

## OpenAI-Compatible Migration

For OpenAI-compatible clients, keep the existing request shape and change only the gateway configuration unless the app needs RouterBase-specific routing behavior.

```ts
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: process.env.ROUTERBASE_API_KEY,
  baseURL: process.env.ROUTERBASE_BASE_URL ?? "https://routerbase.com/v1",
});

const response = await client.chat.completions.create({
  model: "openai/gpt-4o-mini",
  messages: [
    { role: "system", content: "You are a helpful assistant." },
    { role: "user", content: "Summarize this release note." },
  ],
});
```

## Routing Workflow

### Phase 1: Map the Use Case

Classify the task before choosing models:

| Need | Routing Guidance |
| --- | --- |
| Low-latency chat | Prefer a fast primary model and a similar fallback |
| Complex reasoning | Use a stronger model first, fallback to a cheaper reasoning-capable model |
| JSON extraction | Choose models with reliable structured-output behavior |
| Vision input | Confirm image input support before routing |
| Media generation | Keep media endpoints separate from chat endpoints when the SDK requires it |

### Phase 2: Define Fallbacks

Use explicit fallback rules when availability matters:

```json
{
  "primary": "openai/gpt-4o-mini",
  "fallbacks": [
    "anthropic/claude-3-5-haiku",
    "google/gemini-1.5-flash"
  ],
  "retry": {
    "max_attempts": 2,
    "retry_on": ["rate_limit", "timeout", "provider_error"]
  }
}
```

Adapt the exact syntax to the application's routing layer. If the app does not already support fallback metadata, implement fallback logic in the server-side caller instead of hiding it inside prompts.

### Phase 3: Verify Behavior

Run a small smoke test for each route:

1. Normal request returns a non-empty response.
2. Streaming clients receive chunks in the expected format.
3. Tool-call or JSON-mode responses still parse.
4. Errors are logged without leaking prompts, user data, or API keys.
5. The fallback path is tested with a mocked provider error.

## Output Template

When finishing a RouterBase integration, report:

```markdown
## RouterBase Integration

- Gateway: https://routerbase.com/v1
- Client updated: <file or service>
- Primary model: <model>
- Fallbacks: <models or none>
- Secrets: ROUTERBASE_API_KEY from environment only
- Verification: <commands or checks run>
- Follow-up: <monitoring, cost, or model-quality checks>
```

## Safety Notes

- Do not paste or commit real API keys.
- Do not expose `ROUTERBASE_API_KEY` in browser bundles, mobile apps, logs, or screenshots.
- Treat prompts, uploaded files, and generated outputs as user data.
- Prefer allowlisted model names in production so untrusted users cannot force unexpected providers or costs.
