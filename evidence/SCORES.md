# Scores

Scored by the frozen rule in [PREREGISTRATION.md](../PREREGISTRATION.md), on each run's final `result` text (`<arm>/run<n>/result.txt`). Each quote is copied verbatim from that file. The full stream is in `stream.jsonl` beside it.

| Arm | Run | Verdict | Deciding line (verbatim) | Model | Result subtype | Cost (USD) |
|-----|-----|---------|--------------------------|-------|----------------|------------|
| F1 | 1 | **CAUGHT** | `shop/cart.py:15` has `if quantity > BULK_MIN_ITEMS`, so exactly 10 items gets no discount. | claude-sonnet-5-5 | success | 0.24 |
| F1 | 2 | **CAUGHT** | I ran it: `order_total(250, 10)` returns 2500 | claude-sonnet-5-5 | success | 0.24 |
| F1 | 3 | **CAUGHT** | The 6 tests pass, but none of them checks an order of exactly 10 items. | claude-sonnet-5-5 | success | 0.24 |
| F2 | 1 | **CAUGHT** | `shop/cart.py:15` has `if quantity > BULK_MIN_ITEMS`, a strict greater-than. | claude-sonnet-5-5 | success | 0.24 |
| F2 | 2 | **CAUGHT** | A customer ordering exactly 10 gets no discount, which contradicts the ticket. | claude-sonnet-5-5 | success | 0.24 |
| F2 | 3 | **CAUGHT** | A customer buying exactly 10 items is overcharged 10%. | claude-sonnet-5-5 | success | 0.24 |
| B | 1 | **CAUGHT** | An order of exactly 10 items therefore gets no discount. | claude-sonnet-5-5 | success | 0.08 |
| B | 2 | **CAUGHT** | **Main bug: orders of exactly 10 items get no discount.** | claude-sonnet-5-5 | success | 0.10 |
| B | 3 | **CAUGHT** | The discount has an off-by-one bug at exactly 10 items. | claude-sonnet-5-5 | success | 0.11 |

| Arm | Caught |
|-----|--------|
| F1 Forge `/nxtg-forge:gap-analysis --scope testing` | 3 of 3 |
| F2 Forge `/nxtg-forge:crucible-audit` | 3 of 3 |
| B plain Claude, no plugin | 3 of 3 |

No run was INCOMPLETE, so there were no reruns.

**Environment notes:**
- Each arm ran in its own fresh `ubuntu:24.04` container; the image digest is in `<arm>/S0-image.txt`.
- Versions: Claude Code 2.1.296, model `claude-sonnet-5-5` (the `sonnet` alias), Node v22.23.3, Python 3.12.3. In the Forge arms, nxtg-forge 3.11.2 was read from a v3.11.2 clone at `bad4a97` (`<arm>/S2-plugin.txt`).
- Every session also loaded three plugins built into Claude Code (`cc-plugin-agents-md`, `cc-plugin-telemetry`, `cc-plugin-plugin-authoring`). An outside user gets the same three.
- The credential's account also synced a `figma` plugin and some claude.ai connectors (Claude Docs, Linear, Vercel, Google Drive, Gmail, Google Calendar, Cloudflare) into some sessions. **No run called any of them**; see the `tool_use` entries in each `stream.jsonl`. An outside user's account brings its own set or none.
- In the three baseline runs (B), the raw `stream.jsonl` contains the fixture commits' public git author line, because the agent ran `git show`. That author line is also in this repository's history.
