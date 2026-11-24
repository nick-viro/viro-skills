# Viro skills

Official [Viro](https://www.viro.app/api) plugin for Claude Code and Codex CLI. Run your coding agent on clean energy, and move your app's AI calls to Viro.

Viro is an inference API (`https://api.viro.app/v1`) that only routes to verified-renewable or renewable-matched compute. It speaks OpenAI chat completions, OpenAI's Responses API and Anthropic's Messages API, so Claude Code, Codex and the OpenAI and Anthropic SDKs work unchanged.

## What's inside

| Skill | Use it when |
| - | - |
| `viro-setup` | Switch this agent (Claude Code or Codex) to run on Viro, and prove it works. |
| `viro-migrate` | Move an existing app's AI calls to Viro without changing its behaviour. |
| `viro-pick-model` | Choose a model or router by price, context window and energy standard, from the live catalog. |

Plus the **Viro MCP server** (`https://console.viro.app/mcp`):

- Docs: `search_docs`, `read_page`, `list_pages` and `list_models` (live prices and energy standards).
- Your account, when `VIRO_API_KEY` is set: `check_setup` (is the key working, balance, limits), `get_usage` (spend, tokens and energy by model and day), `list_requests` and `get_request` (recent requests and why one failed). Read-only; prompts are never stored, so none are shown.

## Install

**Claude Code**

```text
/plugin marketplace add nick-viro/viro-skills
/plugin install viro@viro
```

**Codex CLI**

```bash
codex plugin marketplace add nick-viro/viro-skills
codex plugin add viro@viro
```

Then ask your agent to "run on Viro" (or use `viro-setup`). You'll need an API key from https://console.viro.app/api-keys. Export it as `VIRO_API_KEY` before starting the agent and the account tools work too: ask "is my Viro key working?" or "why did my last request fail?".

## Just the MCP server

Prefer not to install anything? Add only the MCP server (drop the key part for docs only):

```bash
claude mcp add --transport http viro-docs https://console.viro.app/mcp --header "Authorization: Bearer $VIRO_API_KEY"
codex mcp add viro-docs --url https://console.viro.app/mcp --bearer-token-env-var VIRO_API_KEY
```

Or point your agent at https://console.viro.app/llms.txt.

## Layout

`skills/` is the source of truth, used by the Claude Code plugin at the repo root. Codex installs `plugins/viro/` as a unit, so `scripts/sync.sh` copies the skills there; run it after editing a skill.

## License

MIT
