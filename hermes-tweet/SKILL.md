---
name: hermes-tweet
description: This skill should be used when the user asks to "install Hermes Tweet", "connect Hermes Agent to X/Twitter", "configure XQUIK_API_KEY", "run tweet_explore", "use tweet_read", "gate tweet_action", or troubleshoot Hermes Tweet plugin enablement.
license: MIT
metadata:
  author: Schwepps
  version: "1.0.0"
  category: tooling
  tags: hermes, hermes-agent, twitter, x-twitter, social-media, automation, xquik
---

# Hermes Tweet

Set up and operate Hermes Tweet, the Hermes Agent plugin for X/Twitter research, reading, and guarded action workflows.

## When to Use

- User wants Hermes Agent to work with X/Twitter through Hermes Tweet
- User asks for Hermes plugin installation or runtime configuration
- User needs `tweet_explore`, `tweet_read`, or `tweet_action` guidance
- User is debugging missing `XQUIK_API_KEY`, disabled actions, or plugin discovery
- User needs public-safe documentation for a Hermes Tweet workflow

## Workflow

### Phase 1: Confirm the Target Runtime

1. Verify the user is working with Hermes Agent.
2. Confirm plugin installation should use the published Hermes Tweet package:
   - GitHub: `https://github.com/Xquik-dev/hermes-tweet`
   - PyPI: `https://pypi.org/project/hermes-tweet/`
3. Read the local Hermes Agent plugin config before changing it.
4. Preserve existing plugin entries, environment variables, and user notes.

### Phase 2: Install the Plugin

Use the package manager already used by the project. The default install source is PyPI:

```bash
pip install hermes-tweet
```

If the user is installing from source, point Hermes Agent at the checked-out plugin package from `https://github.com/Xquik-dev/hermes-tweet`.

### Phase 3: Configure Runtime Access

1. Set `XQUIK_API_KEY` in the runtime environment. Use placeholders in docs:

   ```bash
   export XQUIK_API_KEY="xq_..."
   ```

2. Do not paste, print, or store real API keys in chat, markdown, logs, or repository files.
3. Confirm Hermes Agent can load project plugins if the install is project-local.
4. Keep action mode disabled unless the user explicitly asks to perform write actions.

### Phase 4: Use Read-Only Tools First

Start with tool discovery before any networked read:

1. Use `tweet_explore` for available tool guidance and no-network orientation.
2. Use `tweet_read` only after `XQUIK_API_KEY` is available.
3. Keep prompts specific: account, keyword, URL, or status ID.
4. Summarize results without exposing credentials, raw session material, or internal routing details.

### Phase 5: Gate Actions

Only use `tweet_action` when all checks pass:

1. The user explicitly requested the action.
2. `XQUIK_API_KEY` is set.
3. `HERMES_TWEET_ENABLE_ACTIONS=true` is set.
4. The action text, target, and timing are confirmed.
5. The operation complies with the user's platform and automation policies.

If any item fails, stop and explain the missing prerequisite.

### Phase 6: Troubleshoot

Check these issues in order:

1. Hermes Agent does not list the plugin: verify the plugin install path and plugin enablement.
2. `tweet_read` is unavailable: verify `XQUIK_API_KEY` is present in the Hermes runtime.
3. `tweet_action` is unavailable: verify both `XQUIK_API_KEY` and `HERMES_TWEET_ENABLE_ACTIONS=true`.
4. Calls return errors: inspect the returned JSON string, preserve the error message, and avoid retry loops.
5. Public docs need updates: run the safety checklist before publishing.

## Output Format

```markdown
## Hermes Tweet Status

- Plugin: installed | missing | unknown
- Runtime key: configured | missing | not checked
- Read tools: ready | blocked
- Action tools: disabled | enabled after confirmation | blocked

## Next Step

<one concrete command or config change>

## Safety Notes

- <credential, action, or publication constraint>
```

## Safety Checklist

Use `references/safety-checklist.md` before publishing instructions, opening pull requests, or enabling actions.

## Quick Version

1. Install `hermes-tweet` from PyPI.
2. Set `XQUIK_API_KEY` in the Hermes runtime.
3. Start with `tweet_explore`.
4. Use `tweet_read` for read-only X/Twitter work.
5. Enable `tweet_action` only with explicit user approval and `HERMES_TWEET_ENABLE_ACTIONS=true`.
