# forge-done-fixture

> **This repository is deliberately seeded.** It contains a change that is marked done, whose tests pass, and which still carries a defect that no test exercises. It exists so that anyone can check whether [Forge](https://github.com/nxtg-ai/forge-plugin), a governance plugin for Claude Code, catches that defect, and compare it with a plain Claude review.

## Result

The runs were pre-registered in [PREREGISTRATION.md](PREREGISTRATION.md), committed (`fe73148`) before the first run. Every run used `claude-sonnet-5-5` on Claude Code 2.1.296, Forge plugin v3.11.2, three fresh runs per arm, on 2026-10-13.

| Arm | What ran | Caught the defect |
|-----|----------|-------------------|
| F1 Forge | `/nxtg-forge:gap-analysis --scope testing` | **3 of 3** |
| F2 Forge | `/nxtg-forge:crucible-audit` | **3 of 3** |
| B plain Claude, no plugin | "Review the most recent commit in this repository (ticket DONE-1, marked done). Is the work done? Report any problems you find." | **3 of 3** |

- **Forge caught the change marked done but never tested in all 6 Forge runs.** Each run named the `> 10` check against the ticket's "10 or more" and showed that `order_total(250, 10)` returns 2500.
- **A plain Claude review caught it too, in all 3 runs.** On this case Forge does not do better than plain Claude: the defect can be read straight from the code, with the ticket comment one line above it.
- What Forge added here is structure: a severity-ranked gap table (F1) and an 8-pattern test-quality verdict, FAIL (F2), plus a governance health score.
- This fixture shows that Forge catches the case. It does not show that Forge catches something plain Claude misses.

Every quote, cost and model id is in [evidence/SCORES.md](evidence/SCORES.md). The raw streams are under `evidence/<arm>/run<n>/`. To run it yourself, see [REPRODUCE.md](REPRODUCE.md).

## The case

A small Python project, `shop`, computes order totals in integer cents.

| Tag | What it is | `python3 -m unittest` |
|-----|------------|-----------------------|
| `done` | Ticket DONE-1, "orders of 10 or more items get 10% off", implemented and marked **done** in the commit message and `TICKETS.md`. | green (6 tests) |
| `red` | One new test: an order of exactly 10 items must get the discount. | **fails** (1 of 8) |
| `green` | The fix: the discount starts at 10 items, not 11. | green (8 tests) |

**The defect at `done`:** `order_total` checks `quantity > BULK_MIN_ITEMS` (10), so an order of exactly 10 items pays full price: 2500 cents instead of 2250. The done-change's tests try 12 items and 3 items, never 10.

The ticket comment sits just above the faulty line, so a careful reader of `shop/cart.py` can see the mismatch. This is a read-the-code catch, not a hard one.

## See the red and the green

```bash
git clone https://github.com/nxtg-ai/forge-done-fixture && cd forge-done-fixture
git checkout done  && python3 -m unittest      # OK: 6 tests pass, defect present
git checkout red   && python3 -m unittest      # FAILED: test_exactly_ten_items_gets_the_discount
git checkout green && python3 -m unittest      # OK: 8 tests pass
```

## Reproduce the Forge and baseline runs

See [PREREGISTRATION.md](PREREGISTRATION.md) for the exact arms, prompts and scoring rule, and [REPRODUCE.md](REPRODUCE.md) for the commands, from a fresh container with no NXTG state. The harness that produced `evidence/` is [evidence/run-arm.sh](evidence/run-arm.sh).

## License

MIT
