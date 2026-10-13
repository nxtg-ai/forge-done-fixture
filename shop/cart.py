"""Order totals for a small online shop. Prices are integer cents."""

# DONE-1: orders of 10 or more items get 10% off the subtotal.
BULK_MIN_ITEMS = 10
BULK_DISCOUNT_PERCENT = 10


def order_total(unit_price_cents: int, quantity: int) -> int:
    """Return the total in cents for `quantity` items at `unit_price_cents` each."""
    if quantity < 0:
        raise ValueError("quantity must not be negative")
    if unit_price_cents < 0:
        raise ValueError("unit price must not be negative")
    subtotal = unit_price_cents * quantity
    if quantity >= BULK_MIN_ITEMS:
        subtotal -= subtotal * BULK_DISCOUNT_PERCENT // 100
    return subtotal
