-- ==========================================
-- Customers
-- ==========================================
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(5) NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state CHAR(2) NOT NULL
);

-- ==========================================
-- sellers
-- ==========================================
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(5) NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state CHAR(2) NOT NULL
);

-- ==========================================
-- products
-- ==========================================
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100) NOT NULL,
    product_name_lenght SMALLINT NOT NULL,
    product_description_lenght SMALLINT NOT NULL,
    product_photos_qty INTEGER NOT NULL,
    product_weight_g INTEGER NOT NULL,
    product_length_cm DECIMAL(10,2) NOT NULL,
    product_height_cm DECIMAL(10,2) NOT NULL,
    product_width_cm DECIMAL(10,2) NOT NULL
);

-- ==========================================
-- product_category_translation
-- ==========================================
CREATE TABLE product_category_translation(
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100) NOT NULL
);

-- ==========================================
-- orders
-- ==========================================
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp TIMESTAMP NOT NULL,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP NOT NULL
);

-- ==========================================
-- order_items
-- ==========================================
CREATE TABLE order_items(
    order_id VARCHAR(50) NOT NULL,
    order_item_id INTEGER NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date TIMESTAMP NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    freight_value NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);

-- ==========================================
-- order_payments
-- ==========================================
CREATE TABLE order_payments(
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INTEGER NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    payment_installments INTEGER NOT NULL,
    payment_value NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (order_id, payment_sequential)
);
-- ==========================================
-- order_reviews
-- ==========================================
CREATE TABLE order_reviews(
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    review_score SMALLINT NOT NULL,
    review_comment_title VARCHAR(100),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP NOT NULL,
    review_answer_timestamp TIMESTAMP
);
-- ==========================================
-- geolocation
-- ==========================================
CREATE TABLE geolocation(
    geolocation_id BIGSERIAL PRIMARY KEY,
    geolocation_zip_code_prefix VARCHAR(5) NOT NULL,
    geolocation_lat NUMERIC(10,6) NOT NULL,
    geolocation_lng NUMERIC(10,6) NOT NULL,
    geolocation_city VARCHAR(100) NOT NULL,
    geolocation_state CHAR(2) NOT NULL
);