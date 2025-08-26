# Diving Deep into Sales Data with SQL 📈

This repository contains a collection of advanced SQL queries designed to perform a comprehensive analysis of sales data. The queries move from basic temporal aggregations to complex performance comparisons and customer segmentation, demonstrating a full spectrum of analytical techniques.

The primary goal of this project is to extract actionable insights from a sales data warehouse, focusing on sales trends, product performance, and customer behavior.

# 📋 Table of Contents
About The Project

Analysis Highlights

Temporal & Cumulative Analysis

Advanced Performance Analysis

Segmentation & Contribution

Comprehensive Reporting

Key SQL Techniques Used

Database Schema



# <a id="about-the-project"></a>About The Project
This project provides a detailed, query-based approach to understanding business performance through sales data. By analyzing sales over time, comparing product performance year-over-year, and segmenting customers into meaningful groups, these queries can help answer critical business questions such as:

What are our long-term sales trends?

Which products are our consistent top performers?

Which product categories contribute most to our revenue?

Who are our most valuable customers?

How can we tailor our marketing efforts to different customer segments?

# 📊 <a id="analysis-highlights"></a>Analysis Highlights
## Temporal & Cumulative Analysis
This section focuses on understanding performance over time.

Sales Over Time: Aggregates total sales by day, month, and year to identify trends and seasonality.

Cumulative Sales: Uses window functions (SUM() OVER (...)) to calculate a running total of sales, providing a clear view of growth momentum.

## Advanced Performance Analysis
These queries dive deeper into the drivers of performance.

Year-over-Year Product Performance: Compares a product's sales in a given year to its sales in the previous year using the LAG() window function.

Performance vs. Average: Calculates the average sales for each product across all years and compares annual performance against this benchmark to identify standout periods.

## Segmentation & Contribution
Segmentation is key to a targeted business strategy.

Category Contribution: Determines which product categories contribute most to overall sales and calculates their percentage of the total revenue.

Product Cost Segmentation: Groups products into cost ranges (< $100, $100-$500, etc.) to analyze inventory and pricing strategy.

Customer Segmentation: Classifies customers into VIP, Regular, and New segments based on their purchasing history (lifespan) and total spending.

## Comprehensive Reporting
The final queries use Common Table Expressions (CTEs) to build detailed, easy-to-read summary reports.

Customer Report: Creates a 360-degree view of each customer, calculating key metrics like recency, lifespan, average order value (AOV), and average monthly spend.

Product Report: Consolidates product performance metrics, including total orders, unique customers, recency, and average monthly revenue.

## 🛠️ <a id="key-sql-techniques-used"></a>Key SQL Techniques Used
Common Table Expressions (CTEs): To create modular, readable, and reusable sub-queries.

Window Functions: SUM(), AVG(), and LAG() for cumulative calculations and period-over-period comparisons.

Aggregate Functions: SUM(), COUNT(), AVG(), MIN(), MAX().

Joins: LEFT JOIN to combine data from fact and dimension tables.

Date/Time Functions: DATE_FORMAT(), YEAR(), MONTH(), PERIOD_DIFF(), TIMESTAMPDIFF().

Conditional Logic: CASE statements for custom segmentation and grouping.

## 🗂️ <a id="database-schema"></a>Database Schema
The queries are written for a star schema data warehouse with the following tables:

gold_fact_sales: A fact table containing transactional data like order_date, sales_amount, quantity, customer_key, and product_key.

gold_dim_products: A dimension table with product attributes like product_name, category, subcategory, and cost.

gold_dim_customers: A dimension table with customer attributes like customer_name, birthdate, and contact information.

