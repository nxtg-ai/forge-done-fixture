# forge-done-fixture

> **This repository is deliberately seeded.** It contains a change that is marked done, whose tests pass, and which still carries a defect that no test exercises. It exists so that anyone can check whether [Forge](https://github.com/nxtg-ai/forge-plugin), a governance plugin for Claude Code, catches that defect, and compare it with a plain Claude review.

**Results: pending.** The runs are pre-registered in [PREREGISTRATION.md](PREREGISTRATION.md), committed before the first run. The results and raw outputs will be added in `evidence/`, as found.

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

See [PREREGISTRATION.md](PREREGISTRATION.md) for the exact arms, prompts and scoring rule, and [REPRODUCE.md](REPRODUCE.md) for the commands (added with the evidence).

## License

MIT
