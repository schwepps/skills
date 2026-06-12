# Hermes Tweet Safety Checklist

Use this checklist before publishing Hermes Tweet instructions or enabling write-capable workflows.

## Public Documentation

□ Uses placeholder secrets such as `XQUIK_API_KEY="xq_..."` only
□ Contains no real API keys, cookies, tokens, session data, or screenshots
□ Describes the public response contract, not private infrastructure details
□ Links only to public Hermes Tweet, PyPI, Hermes Agent, or Xquik documentation
□ Keeps action guidance gated behind explicit user approval

## Runtime Configuration

□ `XQUIK_API_KEY` is set in the runtime environment, not committed
□ `tweet_explore` is used before networked reads
□ `tweet_read` is used only after the API key is available
□ `tweet_action` remains unavailable unless `HERMES_TWEET_ENABLE_ACTIONS=true`
□ Action target, text, and timing are confirmed before execution

## Troubleshooting

□ Plugin discovery is checked before changing config
□ Returned JSON error strings are preserved for diagnosis
□ Retry loops are avoided unless the user requests a retry
□ Any exposed credential is treated as compromised and rotated
