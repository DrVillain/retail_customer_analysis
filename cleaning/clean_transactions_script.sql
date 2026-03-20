-- ============================================
-- STEP 1: Create product category lookup table
-- ============================================

-- Lookup table to map product names to their corresponding categories
-- used to fill in NULL product_category values in the transactions table
CREATE TABLE dbo.product_category_lookup_t (
    product_name VARCHAR(100),
    product_category VARCHAR(100)
);

INSERT INTO dbo.product_category_lookup_t VALUES
('Air Fryer', 'Small Kitchen Appliances'),
('Amazon Echo', 'Smart Home Devices'),
('Amazon Fire HD', 'Tablets'),
('Area Rug', 'Home Decor'),
('Asus ROG', 'Desktop Computers'),
('Asus ZenBook', 'Laptops'),
('Audio-Technica Turntable', 'Audio Equipment'),
('Baking Sheet', 'Cookware'),
('Bed Frame', 'Furniture'),
('Blender', 'Small Kitchen Appliances'),
('Bookshelf', 'Furniture'),
('Bose Headphones', 'Audio Equipment'),
('Cast Iron Skillet', 'Cookware'),
('Coffee Maker', 'Small Kitchen Appliances'),
('Comforter Set', 'Bedding'),
('Cookware Set', 'Cookware'),
('Curtains', 'Home Decor'),
('Dell Inspiron Desktop', 'Desktop Computers'),
('Dell XPS 15', 'Laptops'),
('Dining Table', 'Furniture'),
('Dishwasher', 'Kitchen Appliances'),
('Dutch Oven', 'Cookware'),
('Duvet Cover', 'Bedding'),
('Electric Range', 'Kitchen Appliances'),
('External Hard Drive', 'Computer Accessories'),
('Food Processor', 'Small Kitchen Appliances'),
('Google Nest', 'Smart Home Devices'),
('Google Pixel 6', 'Smartphones'),
('HP Pavilion', 'Desktop Computers'),
('HP Spectre', 'Laptops'),
('iMac', 'Desktop Computers'),
('iPad Pro', 'Tablets'),
('iPhone 13', 'Smartphones'),
('JBL Bluetooth Speaker', 'Audio Equipment'),
('Knife Set', 'Cookware'),
('Lenovo IdeaCentre', 'Desktop Computers'),
('Lenovo Tab', 'Tablets'),
('Lenovo ThinkPad', 'Laptops'),
('LG OLED TV', 'TVs'),
('Logitech Mouse', 'Computer Accessories'),
('MacBook Pro', 'Laptops'),
('Mattress Topper', 'Bedding'),
('Mechanical Keyboard', 'Computer Accessories'),
('Microsoft Surface', 'Tablets'),
('Microwave Oven', 'Kitchen Appliances'),
('Nintendo Switch', 'Gaming Consoles'),
('Oculus Quest', 'Gaming Consoles'),
('Office Desk', 'Furniture'),
('OnePlus 10', 'Smartphones'),
('Philips Hue Lights', 'Smart Home Devices'),
('Pillows', 'Bedding'),
('PlayStation 5', 'Gaming Consoles'),
('Range Hood', 'Kitchen Appliances'),
('Refrigerator', 'Kitchen Appliances'),
('Ring Doorbell', 'Smart Home Devices'),
('Samsung Galaxy S22', 'Smartphones'),
('Samsung Galaxy Tab', 'Tablets'),
('Samsung QLED TV', 'TVs'),
('Sheets', 'Bedding'),
('Smart Thermostat', 'Smart Home Devices'),
('Sofa', 'Furniture'),
('Sonos Speaker', 'Audio Equipment'),
('Sony Bravia', 'TVs'),
('Sony Soundbar', 'Audio Equipment'),
('Steam Deck', 'Gaming Consoles'),
('Table Lamp', 'Home Decor'),
('TCL Roku TV', 'TVs'),
('Throw Pillows', 'Home Decor'),
('Toaster', 'Small Kitchen Appliances'),
('USB-C Hub', 'Computer Accessories'),
('Vizio SmartCast TV', 'TVs'),
('Wall Art', 'Home Decor'),
('Webcam', 'Computer Accessories'),
('Xbox Series X', 'Gaming Consoles'),
('Xiaomi Mi 12', 'Smartphones');

-- ============================================
-- STEP 2: Clean transactions table
-- ============================================

WITH cleaned_transactions AS 
(
	SELECT
		--pk is left as is
		transaction_id,

		--fk is left as is
		customer_id,

		-- removing whitespaces from product_name
		TRIM(T.product_name) AS product_name,

		-- filling in NULL product_category values using the lookup table
		COALESCE(T.product_category, L.product_category) AS product_category,

		-- casting quantity to an integer, quantity should be a whole number
		TRY_CAST(quantity AS INT) AS quantity,

		-- casting price to a decimal with 2 decimal places
		TRY_CAST(price AS DECIMAL (10, 2)) AS price,

		-- casting transaction_date to date
		TRY_CAST(transaction_date AS DATE) AS transaction_date,

		-- removing whitespaces from store_location
		TRIM(store_location) AS store_location,

		-- removing whitespaces from payment_method
		TRIM(payment_method) AS payment_method,

		-- substituting the NULLs in discount_applied with 0
		COALESCE(discount_applied, 0) AS discount_applied

	FROM dbo.transactions AS T

	-- joining to the lookup table to fill in NULL product_category values
	LEFT JOIN dbo.product_category_lookup_t AS L
		ON TRIM(T.product_name) = L.product_name

	-- filtering out for NULLs in the quantity and price columns since they are incomplete/voided transactions
	WHERE quantity IS NOT NULL AND price IS NOT NULL

)

SELECT *
INTO dbo.cleaned_transactions
FROM cleaned_transactions
