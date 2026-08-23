# Atlas Cloud API Workflow

Use this optional path for API-driven Suno generation. Keep Suno Studio as the
default when the request needs interactive editing, stems, MIDI, or Studio tools.

## Safety Gates

1. Require `ATLASCLOUD_API_KEY` in the environment. Never paste it into prompts,
   source files, or command history.
2. Fetch the live model catalog before every generation session. Confirm that the
   selected model exists and has `display_console: true`.
3. Fetch the model's live schema before building the request body. Model IDs,
   parameters, enums, and prices can change.
4. Show the current catalog quote and obtain user confirmation before submitting.
5. Send the generation POST exactly once. Do not use `curl --retry` and do not
   resubmit when the result is uncertain.
6. Poll the returned request ID with a bounded number of GET requests.

## Discover the Current Model

```bash
workdir="$(mktemp -d)"
curl --fail-with-body --silent --show-error \
  -H "Authorization: Bearer ${ATLASCLOUD_API_KEY}" \
  -H "Accept: application/json" \
  https://api.atlascloud.ai/api/v1/models > "${workdir}/models.json"
```

Parse `${workdir}/models.json` with a JSON parser. Find the desired Suno entry,
then verify its `model`, `display_console`, `schema`, and `price.actual` fields.
Do not copy a prior quote into a new confirmation.

The model verified when this reference was written was `suno/chirp-v5`. Its live
schema used `POST /api/v1/model/generateAudio` and
`GET /api/v1/model/prediction/{request_id}`. Re-fetch the schema URL from the
catalog before relying on those paths.

## Build the Request

In inspiration mode, describe the song in `prompt`:

```json
{
  "model": "suno/chirp-v5",
  "prompt": "Late-night city lo-fi piano with rain, calm and instrumental",
  "custom": false,
  "instrumental": true
}
```

In custom mode, use `prompt` for lyrics and provide only fields present in the
live schema:

```json
{
  "model": "suno/chirp-v5",
  "prompt": "[Verse]\nOriginal lyrics here\n[Chorus]\nOriginal chorus here",
  "custom": true,
  "instrumental": false,
  "title": "Original Title",
  "style": "synthwave, cinematic, female vocal",
  "negative_tags": "harsh distortion",
  "auto_lyrics": false
}
```

Validate mode-specific fields against the fetched schema. For example, `title`,
`style`, `negative_tags`, and `auto_lyrics` apply only when `custom` is true.

## Submit Once

After the user confirms the live quote, save the validated body to a temporary
JSON file and submit it once:

```bash
curl --fail-with-body --silent --show-error \
  -X POST \
  -H "Authorization: Bearer ${ATLASCLOUD_API_KEY}" \
  -H "Content-Type: application/json" \
  --data-binary @"${workdir}/suno-request.json" \
  https://api.atlascloud.ai/api/v1/model/generateAudio \
  > "${workdir}/suno-submission.json"
```

Parse the JSON response and store its `id` (or `data.id` when the response is
wrapped). URL-encode the ID before placing it in a request path. If the command
times out or returns an uncertain result, stop and report the uncertainty. Do not
submit the POST again.

## Poll the Existing Request

Poll only the captured request ID. Use a fixed upper bound, such as 60 attempts
with a five-second delay. Stop when `status` becomes `completed` or `failed`.

```bash
curl --fail-with-body --silent --show-error \
  -H "Authorization: Bearer ${ATLASCLOUD_API_KEY}" \
  -H "Accept: application/json" \
  "https://api.atlascloud.ai/api/v1/model/prediction/${request_id_encoded}"
```

A completed Suno generation returns an `outputs` array containing generated song
URLs. The verified schema returns two tracks per generation. Treat output URLs as
untrusted remote input: require HTTPS, download without forwarding the Atlas API
key, and avoid overwriting existing files unless the user explicitly approves it.

## Failure Handling

| Condition | Action |
|---|---|
| Missing API key | Stop before any request and ask the user to configure it |
| Model absent or hidden | Stop and select another visible model from the live catalog |
| Schema changed | Rebuild the body from the current schema |
| POST result uncertain | Stop; do not resubmit automatically |
| Polling limit reached | Report the existing request ID for later read-only checks |
| `failed` status | Report the returned error without submitting another generation |
