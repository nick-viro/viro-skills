---
name: viro-migrate
description: Move an app's AI model calls to the Viro API (OpenAI-, Anthropic- and Responses-compatible, renewable-verified or energy-matched compute) while keeping its behaviour. Use when the user asks to migrate their code from OpenAI, Anthropic, OpenRouter or another provider to Viro, or to run their app's AI on clean energy.
---

# Migrate an app to Viro

Viro's base URL is `https://api.viro.app/v1`. It serves OpenAI chat completions, OpenAI's Responses API, Anthropic's Messages API, embeddings and image generation, so a migration is normally three changes: base URL, API key, model names. This skill is about the project's code, not the agent's own settings (for that, use `viro-setup`).

Use the `viro-docs` MCP server for anything not covered here (`search_docs`, `read_page`, `list_models`), or https://console.viro.app/llms.txt.

## 1. Find every AI call

Search the project for SDK clients and raw HTTP calls: `OpenAI(`, `new OpenAI`, `Anthropic(`, `base_url`, `baseURL`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `api.openai.com`, `api.anthropic.com`, `openrouter.ai`, and any LangChain/LlamaIndex/Vercel AI SDK provider setup. List what you found (file, SDK, model, features used: streaming, tools, structured output, embeddings, images) and confirm the plan with the user before editing.

## 2. Point clients at Viro

- **OpenAI SDK**: `base_url="https://api.viro.app/v1"`, `api_key` from `VIRO_API_KEY`. If the code reads `OPENAI_BASE_URL` and `OPENAI_API_KEY`, setting those is enough.
- **Anthropic SDK**: `base_url="https://api.viro.app"` (no `/v1`), key from `VIRO_API_KEY`.
- **Responses API callers**: same as the OpenAI SDK. Viro is stateless: send the full conversation each turn; `previous_response_id` and `store: true` are refused.

Add `VIRO_API_KEY` to the project's env handling (`.env.example`, secrets manager, CI) without committing a real key. Keys come from https://console.viro.app/api-keys.

## 3. Rename models

Viro IDs say where a model runs: `viro/*` is an open-weight model on 100% renewable infrastructure; `openai/*`, `anthropic/*`, `google/*`, `xai/*` are frontier models with energy matched.

| Model used now | On Viro |
| - | - |
| `gpt-5.6-terra` | `openai/gpt-5.6-terra` |
| `claude-sonnet-5` | `anthropic/claude-sonnet-5` |
| `gemini-3.6-flash` | `google/gemini-3.6-flash` |
| `grok-4.5` | `xai/grok-4.5` |
| DeepSeek / Kimi / GLM / GPT-OSS on any host | `viro/deepseek-v4-pro`, `viro/kimi-k2.5`, `viro/glm-5.3`, `viro/gpt-oss-120b` |
| not sure | `viro/clean` (router, renewable-only) |

Call `list_models` (or `GET https://api.viro.app/v1/models`) for the current list instead of assuming; use the `viro-pick-model` skill when the choice matters.

## 4. Keep behaviour the same

Streaming, tool calling, structured outputs and error handling work unchanged (OpenAI error envelope on the OpenAI endpoints, Anthropic's on `/v1/messages`). Things that differ:

- Rate limit: 60 requests a minute per key by default; handle `429` and `402` (out of credit) distinctly.
- On GPT-5.6 models, tool calls run with reasoning turned off.
- Every response has an extra `viro` object (where it ran, energy). Safe to ignore; worth logging.
- `{"type": "viro:web_search"}` in `tools` makes Viro run web search server-side. Don't also send your own function named `web_search` in the same request.

## 5. Verify

Run the project's tests and one real request per migrated call path with the user's key. Report what changed, file by file, and anything you could not migrate.
