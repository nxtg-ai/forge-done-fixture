"""Order totals for a small online shop. Prices are integer cents."""


def order_total(unit_price_cents: int, quantity: int) -> int:
    """Return the total in cents for `quantity` items at `unit_price_cents` each."""
    if quantity < 0:
        raise ValueError("quantity must not be negative")
    if unit_price_cents < 0:
        raise ValueError("unit price must not be negative")
    return unit_price_cents * quantity
