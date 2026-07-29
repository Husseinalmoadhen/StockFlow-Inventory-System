# 📦 StockFlow Inventory Management System

A professional PostgreSQL database project that simulates a real-world inventory management system. This project demonstrates relational database design, SQL development, views, stored functions, triggers, indexing, and query optimization.

---

# Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Database Schema](#database-schema)
- [ER Diagram](#er-diagram)
- [Database Objects](#database-objects)
  - [Tables](#tables)
  - [Views](#views)
  - [Functions](#functions)
  - [Triggers](#triggers)
  - [Indexes](#indexes)
- [Example Queries](#example-queries)
- [How to Run](#how-to-run)
- [Project Structure](#project-structure)
- [Future Improvements](#future-improvements)
- [Author](#author)
- [License](#license)

---

# Overview

The **StockFlow Inventory Management System** is a PostgreSQL database project designed to manage products, suppliers, warehouses, inventory, customers, orders, and payments.

The project demonstrates:

- Relational database design
- Database normalization
- Primary and foreign keys
- Constraints
- Views
- Stored Functions
- Triggers
- Indexes
- Query optimization

This project was developed as part of my software development portfolio to demonstrate practical PostgreSQL and SQL skills for backend development.

---

# Features

- Product Management
- Category Management
- Supplier Management
- Warehouse Management
- Inventory Tracking
- Customer Management
- Order Processing
- Payment Processing
- Inventory Reports
- Low Stock Monitoring
- Automatic Inventory Updates
- Stored Functions
- Query Optimization with Indexes

---

# Database Schema

The database contains **9 relational tables**.

| Table | Description |
|--------|-------------|
| categories | Stores product categories |
| suppliers | Stores supplier information |
| products | Stores product details |
| warehouses | Stores warehouse locations |
| inventory | Tracks inventory quantities |
| customers | Stores customer information |
| orders | Stores customer orders |
| order_items | Stores products within each order |
| payments | Stores payment records |

---

# ER Diagram

![ER Diagram](screenshots/erd.png)

---

# Database Objects

## Tables

- categories
- suppliers
- products
- warehouses
- inventory
- customers
- orders
- order_items
- payments

---

## Views

- product_details_view
- inventory_report_view
- order_details_view
- low_stock_view

---

## Functions

### calculate_inventory_value()

Calculates the total inventory value across all warehouses.

```sql
SELECT calculate_inventory_value();
```

---

## Triggers

Automatically updates inventory quantities whenever new order items are inserted, helping maintain inventory consistency.

---

## Indexes

Indexes have been created to improve query performance on frequently searched columns and foreign key relationships.

Indexed tables include:

- products
- inventory
- orders
- order_items
- payments

---

# Example Queries

## View Products

```sql
SELECT * FROM products;
```

## Inventory Report

```sql
SELECT * FROM inventory_report_view;
```

## Order Details

```sql
SELECT * FROM order_details_view;
```

## Low Stock Report

```sql
SELECT * FROM low_stock_view;
```

## Calculate Inventory Value

```sql
SELECT calculate_inventory_value();
```

---

# Screenshots

## Inventory Report

![Inventory Report](screenshots/inventory_report.png)

---

## Order Details

![Order Details](screenshots/order_details.png)

---

## Low Stock Report

![Low Stock Report](screenshots/low_stock_view.png)

---

## Inventory Value Function

![Inventory Value](screenshots/inventory_value.png)

---

## Database Tables

![Tables](screenshots/tables.png)

---

## Database Views

![Views](screenshots/views.png)

---

## Indexes

![Indexes](screenshots/indexes.png)

---

# How to Run

### 1. Install PostgreSQL

Install PostgreSQL and pgAdmin.

### 2. Create a Database

```sql
CREATE DATABASE stockflow_db;
```

### 3. Connect to the Database

Open pgAdmin and connect to **stockflow_db**.

### 4. Execute the SQL Script

Run:

```
stockflow_database.sql
```

This will automatically create:

- Tables
- Relationships
- Constraints
- Views
- Stored Functions
- Triggers
- Indexes
- Sample Data

### 5. Run Example Queries

Execute the example queries above to explore the database.

---

# Project Structure

```text
StockFlow-Inventory-System/
│
├── README.md
├── LICENSE
├── stockflow_database.sql
│
└── screenshots/
    ├── erd.png
    ├── tables.png
    ├── views.png
    ├── indexes.png
    ├── inventory_report.png
    ├── low_stock_view.png
    ├── order_details.png
    └── inventory_value.png
```

---

# Future Improvements

Potential future enhancements include:

- REST API integration
- User authentication
- Role-based access control
- Purchase order management
- Sales analytics
- Supplier analytics
- Barcode integration
- Docker deployment
- Cloud database deployment
- Web dashboard

---

# Author

**Hussein Almoadhen**

Applied Computing Student

Aspiring Backend Software Developer

GitHub:
https://github.com/husseinalmoadhen

LinkedIn:
https://www.linkedin.com/in/hussein-almoadhen/

---

# License

This project is licensed under the **MIT License**.

See the **LICENSE** file for more information.
