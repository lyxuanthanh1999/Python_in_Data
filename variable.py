from faker.generator import random
from datetime import datetime
create_table_commands = (
        """
       CREATE TABLE brand (
        brand_id SERIAL PRIMARY KEY,
        brand_name VARCHAR(100) NOT NULL UNIQUE,
        country VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )

    """,
    """
        CREATE TABLE category (
            category_id SERIAL PRIMARY KEY,
            category_name VARCHAR(100) NOT NULL UNIQUE,
            parent_category_id INT,
            level SMALLINT NOT NULL CHECK (level IN(1,2)),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_parent_category_id
                FOREIGN KEY (parent_category_id)
                REFERENCES category (category_id)
                ON DELETE SET NULL
        )
    """,
    """
        CREATE TABLE seller (
            seller_id SERIAL PRIMARY KEY,
            seller_name VARCHAR(150),
            join_date DATE,
            seller_type VARCHAR(50),
            rating DECIMAL(2,1),
            country VARCHAR(50),
            CONSTRAINT ck_seller_type CHECK(seller_type IN ('Official', 'Marketplace')),
            CONSTRAINT ck_rating CHECK (rating >= 0 AND rating <= 5)
        )
    """,
    """
        CREATE TABLE customer (	
            customer_id SERIAL PRIMARY KEY,
            customer_name VARCHAR(150) NOT NULL,
            email VARCHAR(150) UNIQUE NOT NULL,
            phone VARCHAR(20) UNIQUE,
            gender VARCHAR(10),
            address VARCHAR(255),
            city VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT ck_gender CHECK(gender IN ('Male', 'Female'))
        )
    """,
    """
        CREATE TABLE product (
            product_id SERIAL PRIMARY KEY,

            sku VARCHAR(64) UNIQUE NOT NULL,
            product_name VARCHAR(200) NOT NULL,
            category_id INT NOT NULL,
            brand_id INT NOT NULL,
            seller_id INT NOT NULL,
            price DECIMAL(12,2) NOT NULL,
            stock_qty INT NOT NULL DEFAULT 0,
            rating DECIMAL(2,1) DEFAULT 5.0,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
            created_by VARCHAR(150) NOT NULL,
            updated_at TIMESTAMP,
            updated_by VARCHAR(150),
            is_deleted BOOLEAN DEFAULT FALSE NOT NULL,
            deleted_at TIMESTAMP,
            deleted_by VARCHAR(150),
        
            CONSTRAINT fk_category_id
                FOREIGN KEY (category_id)
                REFERENCES category (category_id)
                ON DELETE RESTRICT,
            CONSTRAINT fk_brand_id
                FOREIGN KEY (brand_id)
                REFERENCES brand (brand_id)
                ON DELETE RESTRICT,
            CONSTRAINT fk_seller_id
                FOREIGN KEY (seller_id)
                REFERENCES seller (seller_id)
                ON DELETE RESTRICT,
            CONSTRAINT ck_price CHECK (price > 0),
            CONSTRAINT ck_rating CHECK ( rating >= 0 AND rating <= 5 ),
            CONSTRAINT ck_stock_qty CHECK ( stock_qty >= 0 )
        )
    """,
    """
        CREATE TABLE orders(
            order_id SERIAL PRIMARY KEY,
            customer_id INT NOT NULL,
            order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            status VARCHAR(20) NOT NULL,
            total_amount DECIMAL(12,2) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

            CONSTRAINT ck_total_amount CHECK(total_amount >= 0),
            CONSTRAINT ck_created_at CHECK(created_at >= order_date),
            CONSTRAINT ck_status CHECK(status IN ('PLACED','PAID','SHIPPED','DELIVERED','CANCELLED','RETURNED')),
            CONSTRAINT fk_customer_id
                FOREIGN KEY (customer_id)
                REFERENCES customer (customer_id)
			ON DELETE RESTRICT
        )
    """,
    """
        CREATE TABLE order_item(
            order_item_id BIGSERIAL PRIMARY KEY,
            order_id INT NOT NULL,
            product_id INT NOT NULL,
            order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
            quantity INT NOT NULL,
            unit_price DECIMAL(12,2) NOT NULL,
            subtotal DECIMAL(12,2) NOT NULL,
	        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	
            CONSTRAINT fk_order_id
                FOREIGN KEY (order_id)
                REFERENCES orders (order_id)
                ON DELETE RESTRICT,
	        CONSTRAINT fk_product_id
		        FOREIGN KEY (product_id)
		        REFERENCES product(product_id)
		        ON DELETE RESTRICT,

	        CONSTRAINT ck_quantity CHECK (quantity > 0),
            CONSTRAINT ck_unit_price CHECK (unit_price > 0),
	        CONSTRAINT ck_subtotal CHECK (subtotal = quantity * unit_price),
	        CONSTRAINT ck_created_at CHECK (created_at >= order_date)
    )
    """,
    """
        CREATE TABLE promotion(
            promotion_id SERIAL PRIMARY KEY,
            promotion_name VARCHAR(100) NOT NULL,
            promotion_type VARCHAR(50) NOT NULL,
            discount_type VARCHAR(20) NOT NULL,
            discount_value NUMERIC(10,2) NOT NULL,
            start_date DATE,
            end_date DATE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

            CONSTRAINT ck_discount_type CHECK (discount_type IN ('percentage','fixed_amount')),
            CONSTRAINT ck_discount_value CHECK (discount_value > 0 AND (discount_type = 'fixed_amount' OR discount_value <= 100)),
            CONSTRAINT ck_start_date CHECK (start_date >= DATE(created_at)),
            CONSTRAINT ck_end_date CHECK (end_date >= start_date)
	
        )
    """,
    """
        CREATE TABLE promotion_product(
            promo_product_id SERIAL PRIMARY KEY,
            promotion_id INT NOT NULL,
            product_id INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

            CONSTRAINT uq_promotion_id_product_id UNIQUE(promotion_id, product_id),
	        CONSTRAINT fk_promotion_id
                FOREIGN KEY(promotion_id)
                REFERENCES promotion(promotion_id)
                ON DELETE RESTRICT,
	        CONSTRAINT fk_product_id
	            FOREIGN KEY(product_id)
	            REFERENCES product(product_id)
	            ON DELETE RESTRICT
        )
    """,
    )


# =============================================================================
# INSERT QUERY
# =============================================================================

query_brand = """
    INSERT INTO brand (brand_name,country,created_at)
    VALUES(%s, %s, %s)
    ON CONFLICT (brand_name) DO NOTHING
    RETURNING brand_id;
"""
query_category = """
    INSERT INTO category (category_name, level, parent_category_id,created_at)
    VALUES(%s, %s, %s, %s)
    ON CONFLICT (category_name) DO NOTHING
"""

query_seller = """
    INSERT INTO seller (seller_name,join_date,seller_type,rating,country)
    VALUES(%s, %s, %s,%s,%s)
    RETURNING seller_id;
"""

query_customer ="""
    INSERT INTO customer (customer_name, email, phone, gender, address, city, created_at)
    VALUES (%s,%s,%s,%s,%s,%s,%s);
"""
#  ON CONFLICT (email, phone) DO NOTHING;
query_product = """
    INSERT INTO product (
        sku, product_name, category_id, brand_id, seller_id,
        price, stock_qty, rating, is_active, created_at, created_by,
        updated_at, updated_by, is_deleted, deleted_at, deleted_by
    )
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
"""

query_promotion = """
    INSERT INTO promotion (
        promotion_name, promotion_type, discount_type, discount_value,
        start_date, end_date, created_at
    )
    VALUES (%s, %s, %s, %s, %s, %s, %s);
"""

query_promotion_product = """
    INSERT INTO promotion_product (promotion_id, product_id, created_at)
    VALUES (%s, %s, %s)
    ON CONFLICT (promotion_id, product_id) DO NOTHING;
"""

query_order = """
    INSERT INTO orders (customer_id, order_date, status, total_amount, created_at)
    VALUES (%s, %s, %s, %s, %s)
    RETURNING order_id;
"""
query_order_item = """
    INSERT INTO order_item (order_id, product_id, order_date, quantity, unit_price, subtotal, created_at)
    VALUES (%s, %s, %s, %s, %s, %s, %s);
"""

query_insert_order = """
    INSERT INTO orders (customer_id, order_date, status, total_amount, created_at)
    VALUES %s
    RETURNING order_id;
"""

query_insert_order_item = """
    INSERT INTO order_item (order_id, product_id, order_date, quantity, unit_price, subtotal, created_at)
    VALUES %s;
"""



# =============================================================================
# QUERY
# =============================================================================

query_select_brand_id = """SELECT brand_id FROM brand;"""
query_select_main_category_id_name = """SELECT category_name,category_id FROM category WHERE level = 1;"""
query_select_sub_category_id = """SELECT category_id FROM category WHERE level = 2;"""
query_select_seller_id = """SELECT seller_id FROM seller;"""
query_select_product_id="SELECT product_id FROM product;"
query_select_promotion_id = "SELECT promotion_id FROM promotion;"
query_select_promotion_product_id = "SELECT promo_product_id FROM promotion_product;"
query_select_customer_id = """SELECT customer_id FROM customer;"""
query_select_product_price = """SELECT product_id, price FROM product;"""

query_truncate_all = """
    TRUNCATE TABLE 
        order_item,
        orders,
        promotion_product,
        promotion,
        product,
        customer,
        seller,
        category,
        brand
    RESTART IDENTITY CASCADE;
"""
query_truncate_order = """
    TRUNCATE TABLE 
        order_item,
        orders;
"""

# =============================================================================
# Variable
# =============================================================================

startDate = datetime(2024,1,1)
endDate = datetime(2024,12,31)

categories_tree = {
        'Điện tử & Công nghệ': [
            "Điện thoại thông minh", "Laptop & Máy tính", "Tai nghe không dây", "Đồng hồ thông minh"
        ],
        'Thời trang & Phụ kiện': [
            "Áo sơ mi nam", "Quần jean nữ", "Giày thể thao", "Túi xách thời trang"
        ],
        'Nhà cửa & Đời sống': [
            "Bàn ghế phòng khách", "Nồi chiên không dầu", "Chăn ga gối nệm", "Đèn trang trí"
        ],
        'Sắc đẹp & Sức khỏe': [
            "Kem chống nắng", "Son môi cao cấp", "Nước hoa chính hãng", "Sữa rửa mặt"
        ],
        'Sách & Văn phòng phẩm': [
            "Sách Kỹ năng sống", "Sách Kinh tế", "Sách Lập trình CNTT", "Bút viết & Vở ghi"
        ]
    }

promotion_names = [
        "Mega Sale", "Flash Sale Giờ Vàng", "Siêu Sale Lương Về", "Black Friday",
        "Chào Hè Rực Rỡ", "Tết Rộn Ràng", "Back to School", "Cuối Tuần Giảm Sốc",
        "Tri Ân Khách Hàng", "Mid-Year Sale", "Đại Tiệc Mua Sắm", "Sinh Nhật Rộn Ràng"
    ]

promotion_types = ['product', 'category', 'seller', 'flash_sale']
discount_types = ['percentage', 'fixed_amount']
genders = ['Male','Female']

VN_PREFIXES = [
    '090', '091', '092', '093', '094', '096', '097', '098',
    '086', '088', '089', '081', '082', '083', '085',
    '070', '076', '077', '078', '079',
    '032', '033', '035', '036', '037', '038', '039'
]
unique_suffixes = random.sample(range(1000000, 10000000), 30000)

ORDER_STATUSES = ['DELIVERED', 'SHIPPED', 'PAID', 'PLACED', 'CANCELLED', 'RETURNED']
STATUS_WEIGHTS  = [0.60,        0.20,     0.10,   0.05,     0.03,        0.02]
order_statuses  = ORDER_STATUSES   # alias cho insert_value_pandas.py

order_startDate = datetime(2025, 1, 1)
order_endDate   = datetime(2025, 5, 31, 23, 59, 59)