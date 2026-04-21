Decoding E-commerce Dynamics: A Deep Dive into Target’s Brazilian Operations

<img width="1431" height="763" alt="Image" src="https://github.com/user-attachments/assets/e821b4d3-6793-477a-a966-e242f391a385" />


Context:

Target is a globally renowned brand and a prominent retailer in the United States. Target makes itself a preferred shopping destination by offering outstanding value, inspiration, innovation and an exceptional guest experience that no other retailer can deliver.

This particular business case focuses on the operations of Target in Brazil and provides insightful information about 100,000 orders placed between 2016 and 2018. The dataset offers a comprehensive view of various dimensions including the order status, price, payment and freight performance, customer location, product attributes, and customer reviews.

By analyzing this extensive dataset, it becomes possible to gain valuable insights into Target's operations in Brazil. The information can shed light on various aspects of the business, such as order processing, pricing strategies, payment and shipping efficiency, customer demographics, product characteristics, and customer satisfaction levels.

Dataset:
[The data is available in 8 csv files:]

customers.csv
sellers.csv
order_items.csv
geolocation.csv
payments.csv
reviews.csv
orders.csv
products.csv

The column description for these csv files is given below.

The customers.csv contain following features:

Features

Description

customer_id

ID of the consumer who made the purchase

customer_unique_id

Unique ID of the consumer

customer_zip_code_prefix

Zip Code of consumer’s location

customer_city

Name of the City from where order is made

customer_state

State Code from where order is made (Eg. são paulo - SP)

The sellers.csv contains following features:

Features

Description

seller_id

Unique ID of the seller registered

seller_zip_code_prefix

Zip Code of the seller’s location

seller_city

Name of the City of the seller

seller_state

State Code (Eg. são paulo - SP)

The order_items.csv contain following features:

Features

Description

order_id

A Unique ID of order made by the consumers

order_item_id

A Unique ID given to each item ordered in the order

product_id

A Unique ID given to each product available on the site

seller_id

Unique ID of the seller registered in Target

shipping_limit_date

The date before which the ordered product must be shipped

price

Actual price of the products ordered

freight_value

Price rate at which a product is delivered from one point to another

The geolocations.csv contain following features:

Features

Description

geolocation_zip_code_prefix

First 5 digits of Zip Code

geolocation_lat

Latitude

geolocation_lng

Longitude

geolocation_city

City

geolocation_state

State

The payments.csv contain following features:

Features

Description

order_id

A Unique ID of order made by the consumers

payment_sequential

Sequences of the payments made in case of EMI

payment_type

Mode of payment used (Eg. Credit Card)

payment_installments

Number of installments in case of EMI purchase

payment_value

Total amount paid for the purchase order

The orders.csv contain following features:

Features

Description

order_id

A Unique ID of order made by the consumers

customer_id

ID of the consumer who made the purchase

order_status

Status of the order made i.e. delivered, shipped, etc.

order_purchase_timestamp

Timestamp of the purchase

order_delivered_carrier_date

Delivery date at which carrier made the delivery

order_delivered_customer_date

Date at which customer got the product

order_estimated_delivery_date

Estimated delivery date of the products

The reviews.csv contain following features:

Features

Description

review_id

ID of the review given on the product ordered by the order id

order_id

A Unique ID of order made by the consumers

review_score

Review score given by the customer for each order on a scale of 1-5

review_comment_title

Title of the review

review_comment_message

Review comments posted by the consumer for each order

review_creation_date

Timestamp of the review when it is created

review_answer_timestamp

Timestamp of the review answered

The products.csv contain following features:

Features

Description

product_id

A Unique identifier for the proposed project.

product_category_name

Name of the product category

product_name_lenght

Length of the string which specifies the name given to the products ordered

product_description_lenght

Length of the description written for each product ordered on the site

product_photos_qty

Number of photos of each product ordered available on the shopping portal

product_weight_g

Weight of the products ordered in grams

product_length_cm

Length of the products ordered in centimeters

product_height_cm

Height of the products ordered in centimeters

product_width_cm

Width of the product ordered in centimeters

<img width="1318" height="834" alt="Image" src="https://github.com/user-attachments/assets/cda3ea69-6237-4c1d-9813-74e8f26f55bb" />
