---
name: viro-setup
description: Switch this coding agent (Claude Code or Codex CLI) to run on the Viro API, so its model calls go to renewable-verified or energy-matched compute. Use when the user asks to run their agent on Viro, on clean energy, or to set Viro as the default provider for Claude Code or Codex.
---

# Run this agent on Viro

Viro (https://api.viro.app) is an inference API that only routes to verified-renewable or renewable-matched compute. It speaks Anthropic's Messages API (for Claude Code) and OpenAI's Responses API (for Codex), so the agent itself works unchanged: only its provider settings change.

This skill changes the user's own agent configuration, not the project's code.

## 1. Work out which agent you are

- **Claude Code**: settings live in `~/.claude/settings.json`.
- **Codex CLI**: settings live in `~/.codex/config.toml` (or `$CODEX_HOME/config.toml`).
- Anything else (OpenCode, Hermes Agent, Cline, Aider, Continue, Cursor, OpenClaw): don't guess. Read that tool's guide with the `viro-docs` MCP server (`read_page` with `/docs/integrations/<tool>`) or at https://console.viro.app/docs/integrations and follow it exactly.

## 2. Get an API key

Ask the user for their Viro API key (it starts with `viro_sk_live_` or `viro_sk_test_`), or tell them to create one at https://console.viro.app/api-keys. Never print the key back, never write it into a file inside the project, and never commit it.

## 3. Configure the agent

Read the existing file first and merge: keep every other setting and provider the user has. Show the user the change before writing it.

### Claude Code

Merge this `env` block into `~/.claude/settings.json` (create the file if it doesn't exist):

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.viro.app",
    "ANTHROPIC_AUTH_TOKEN": "<the user's Viro key>",
    "ANTHROPIC_MODEL": "viro/clean",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "viro/gpt-oss-20b",
    "CLAUDE_CODE_MAX_CONTEXT_TOKENS": "200000"
  }
}
```

- The base URL has no `/v1`; Claude Code adds `/v1/messages`.
- `viro/clean` only runs on renewable-verified infrastructure. If the user wants the strongest model regardless of energy source, use `viro/frontier`; for the cheapest that clears the task, `viro/optimized`.
- `CLAUDE_CODE_MAX_CONTEXT_TOKENS` is needed because Claude Code doesn't know Viro's model names.

### Codex CLI

Add a `viro` provider to `~/.codex/config.toml` and make it the default (replace existing `model` and `model_provider` lines; keep other providers):

```toml
model = "viro/clean"
model_provider = "viro"
model_context_window = 200000

[model_providers.viro]
name = "Viro"
base_url = "https://api.viro.app/v1"
env_key = "VIRO_API_KEY"
wire_api = "responses"
```

Codex reads the key from the `VIRO_API_KEY` environment variable. Tell the user to add `export VIRO_API_KEY=<their key>` to their shell profile (`~/.zshrc` or `~/.bashrc`); offer to add it for them.

## 4. Prove it works

Send one request with the key before finishing, and report the model that answered:

```bash
# Claude Code (Messages API)
curl -s https://api.viro.app/v1/messages \
  -H "x-api-key: $VIRO_API_KEY" -H "content-type: application/json" \
  -d '{"model":"viro/clean","max_tokens":300,"messages":[{"role":"user","content":"Reply with exactly the word: pong"}]}'

# Codex (Responses API)
curl -s https://api.viro.app/v1/responses \
  -H "Authorization: Bearer $VIRO_API_KEY" -H "content-type: application/json" \
  -d '{"model":"viro/clean","input":"Reply with exactly the word: pong","max_output_tokens":300}'
```

A `401` means the key is wrong; a `402` means the account needs credit (https://console.viro.app/billing).

## 5. Tell the user how to switch over

You cannot change the model of the session you are running in. End by saying exactly what to do:

- **Claude Code**: quit and start a new `claude` session. It will note that it doesn't recognise `viro/clean`; that's expected.
- **Codex**: open a new terminal (so `VIRO_API_KEY` is set) and run `codex`. It will warn there's no metadata for `viro/clean`; that's expected and harmless.

Each request then shows up at https://console.viro.app/usage with its energy and cost.
