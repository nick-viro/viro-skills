---
name: viro-pick-model
description: Choose the right Viro API model or router for a task, using the live catalog of prices, context windows and energy standards. Use when the user asks which Viro model to use, wants the cheapest or cleanest option, or is deciding between viro/clean, viro/optimized and viro/frontier.
---

# Pick a Viro model

Get the live catalog first. Prices and models change, so never answer from memory:

- With the `viro-docs` MCP server: `list_models` (pass `energy: "clean"` for renewable-only models).
- Otherwise: `GET https://api.viro.app/v1/models`, or https://console.viro.app/models.

## Start with a router

Most users should pick a router. It chooses a real model per request and bills at that model's rate:

| Router | Picks | Use when |
| - | - | - |
| `viro/clean` | the best model on renewable-verified infrastructure; errors rather than falling back | clean energy is the point (default) |
| `viro/optimized` | the cheapest model that still clears the task, across the whole catalog | cost matters most |
| `viro/frontier` | the strongest model available, cost and energy secondary | quality matters most |

The model that actually ran comes back in the `x-viro-resolved-model` response header (and on the Usage page).

## When to name a model instead

Pin a concrete model when the user needs reproducible output, a specific context window, image input, embeddings or image generation, or a model their evals were run on. Then weigh, from the live list:

1. **Energy standard**: "100% Clean Energy" (`viro/*`) runs on renewable-verified infrastructure; "Energy Matched" (frontier `openai/*`, `anthropic/*`, `google/*`, `xai/*`) has its electricity matched with renewables.
2. **Context window** against the longest prompt the user sends.
3. **Price** per million input and output tokens, and whether the model is cached (repeated prefixes are discounted automatically where supported).
4. **Capabilities**: tool calling and structured output for agents; vision for images.

For coding agents, prefer a router or a model with strong tool calling; say which you'd pick and why in one or two sentences, with its price and energy standard.
