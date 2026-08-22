-- ==========================================
-- orders → customers
-- ==========================================
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- ==========================================
-- order_items → orders
-- ==========================================
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- ==========================================
-- order_items → products
-- ==========================================
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- ==========================================
-- order_items → sellers
-- ==========================================
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_seller
FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id);

-- ==========================================
-- order_payments → orders
-- ==========================================
ALTER TABLE order_payments
ADD CONSTRAINT fk_order_payments_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- ==========================================
-- order_reviews → orders
-- ==========================================
ALTER TABLE order_reviews
ADD CONSTRAINT fk_order_reviews_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);