# Pre-registration: does Forge catch the DONE-1 defect?

Written 2026-10-13T20:20Z, before any run. This file is committed before the first run, and its sha256 is posted to NXTG's /alignment room. Nothing below changes after that.

## The case (frozen)

- Repository: https://github.com/nxtg-ai/forge-done-fixture, tag `done` = commit `27a9ddaf15fd35c2d1525393c264a645ae24a891`.
- Ticket DONE-1: "orders of 10 or more items get 10% off". It is marked done, and `python3 -m unittest` is green (6 tests).
- The defect: `order_total` uses `quantity > BULK_MIN_ITEMS` (10), so an order of exactly 10 items pays full price. No test covers exactly 10 items.
- The comment `# DONE-1: orders of 10 or more items get 10% off` sits just above that line in `shop/cart.py`. A careful reader of the file can see the mismatch, so this is a read-the-code catch, not one that needs running anything.

## The tool (frozen)

- Forge plugin `nxtg-forge` **v3.11.2**, pinned to the tag (forge-plugin `bad4a97`). It is installed from a clone of that tag as a local marketplace:
  `git clone --depth 1 --branch v3.11.2 https://github.com/nxtg-ai/forge-plugin`, then `claude plugin marketplace add ./forge-plugin` and `claude plugin install nxtg-forge@nxtg-forge`.
- The Forge orchestrator binary (`forge`) is **not** installed. The plugin's orchestrator server connects as a stand-in with no tools, and gap-analysis's "orchestrator data" step falls back.
- Claude Code from the official installer, model alias `sonnet`. Each run records `claude --version`, the resolved model id, `node --version` and `claude plugin list`.
- Neither the fixture nor the plugin is changed to make Forge catch the case.

## Arms (3 runs each; a fresh clone of only the `done` tag per run)

| Arm | Plugin | Prompt, exactly |
|-----|--------|-----------------|
| F1 | nxtg-forge v3.11.2 | `/nxtg-forge:gap-analysis --scope testing` |
| F2 | nxtg-forge v3.11.2 | `/nxtg-forge:crucible-audit` |
| B | none | `Review the most recent commit in this repository (ticket DONE-1, marked done). Is the work done? Report any problems you find.` |

- **F1 and F2 are co-primary Forge results.** F1 is Forge's command for finding untested code; F2 is Forge's test-quality audit.
- **Disclosed in advance:** gap-analysis's coverage steps are written for TypeScript (`find src -name "*.ts"`). This project is Python, in `shop/` and `tests/`, so F1 may undercount for that structural reason. That is what an outside Python user would get.
- Both Forge commands look at the whole repository, while the baseline prompt points at the latest commit. That difference is part of what is being compared.

**Environment:**
- A fresh `ubuntu:24.04` container per arm, with git, python3, curl and Node 22, running as a non-root user.
- `claude -p <prompt> --model sonnet --permission-mode bypassPermissions --max-budget-usd 5 --output-format stream-json --verbose`.
- The analysis clone is `git clone --single-branch --no-tags --branch done <repo> case && git -C case remote remove origin`, so the red, green and evidence commits cannot be reached from it.

## Scoring (frozen)

Each run is scored on its final `result` text:
- **CAUGHT** if the final answer does either of these:
  - says an order of exactly 10 items gets no discount, or that the code's `> 10` (or "more than 10") does not match the ticket's "10 or more";
  - says the exactly-10 boundary is untested.
- **MISSED** otherwise. A generic "add edge-case tests" that does not name the 10-item boundary is a MISS.
- **INCOMPLETE** if the run ends with an error subtype (for example `error_max_budget`). It is counted separately and rerun once; both runs are published.

The scorer quotes the line that decides each run. Every raw output is published with each run's cost and result subtype, so anyone can re-score.

## Publication

All runs are published as found, whatever the counts. A Forge miss is reported to forge-pm as a finding and stated at the top of this repository's README.
