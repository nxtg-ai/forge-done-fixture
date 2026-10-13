import unittest

from shop.cart import order_total


class OrderTotalTest(unittest.TestCase):
    def test_total_is_price_times_quantity(self):
        self.assertEqual(order_total(250, 4), 1000)

    def test_empty_order_is_zero(self):
        self.assertEqual(order_total(250, 0), 0)

    def test_negative_quantity_is_rejected(self):
        with self.assertRaises(ValueError):
            order_total(250, -1)

    def test_negative_price_is_rejected(self):
        with self.assertRaises(ValueError):
            order_total(-1, 2)


class BulkDiscountTest(unittest.TestCase):
    def test_bulk_order_gets_ten_percent_off(self):
        self.assertEqual(order_total(250, 12), 2700)

    def test_small_order_pays_full_price(self):
        self.assertEqual(order_total(250, 3), 750)


if __name__ == "__main__":
    unittest.main()
