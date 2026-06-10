# GA4 Ecommerce Analytics Pipeline with dbt & BigQuery

## Project Overview

This project demonstrates the development of an end-to-end analytics pipeline for an ecommerce website using Google Analytics 4 event data.

The goal was to transform raw GA4 event-level data into business-ready data marts that support executive reporting, funnel analysis, retention tracking, customer segmentation, product analytics, and revenue performance monitoring.

The solution was built using:

* Google BigQuery
* dbt
* SQL
* Data Quality Testing

---

## Business Objectives

The project answers the following business questions:

* How many users and sessions does the website generate?
* Which acquisition channels drive the highest revenue?
* What is the conversion rate across the purchase funnel?
* How well are users retained over time?
* Which products generate the most revenue?
* What is the customer lifetime value (LTV)?
* How can users be segmented based on purchase behavior?

---

## Source Data

Dataset:

Google Analytics 4 Public Ecommerce Dataset

Period:

November 2020 – January 2021

Raw source:

bigquery-public-data.ga4_obfuscated_sample_ecommerce

---

## Data Modeling Architecture

### Staging Layer

#### stg_ga4__events

Event-level dataset enriched with:

* Session identifiers
* Traffic attribution
* Device information
* Geographic dimensions
* Ecommerce metrics
* Data quality flags

Key transformations:

* Event classification
* Channel grouping
* Internal traffic detection
* GDPR data flagging
* Purchase validation

---

#### stg_ga4__sessions

Session-level aggregation.

Metrics:

* Sessions
* Revenue
* Transactions
* Engagement
* Funnel progression
* Conversion flags

---

#### stg_ga4__purchases

Transaction-level purchase dataset.

Key features:

* Transaction deduplication
* Item-level analysis
* Product hierarchy extraction
* Revenue validation

---

## Analytics Marts

### mart_executive_kpi

Executive summary metrics:

* Users
* Sessions
* Revenue
* Purchases
* Conversion Rate
* Average Order Value
* ARPU

---

### mart_channel_performance

Marketing channel performance analysis.

Metrics:

* Sessions
* Users
* Revenue
* Transactions
* Conversion Rate
* Revenue per Session
* ARPU
* AOV

Dimensions:

* Channel Group

---

### mart_funnel

Session-based ecommerce funnel.

Stages:

* View Item
* Add to Cart
* Checkout
* Payment
* Purchase

Metrics:

* Funnel counts
* Step conversion rates

---

### mart_retention

Monthly cohort retention analysis.

Metrics:

* Cohort Size
* Active Users
* Retention Rate

Dimensions:

* Cohort Month
* Month Number

---

### mart_product_performance

Product-level sales analytics.

Metrics:

* Revenue
* Units Sold
* Transactions
* Average Price

Dimensions:

* Product
* Brand
* Category

---

### mart_user_ltv

Customer lifetime value model.

Metrics:

* Lifetime Revenue
* Sessions
* Transactions
* Purchase Sessions
* Average Order Value
* Lifetime Days

---

### mart_customer_segments

Customer segmentation based on revenue contribution.

Segments:

* VIP
* High Value
* Paying
* Non-Paying

---

## Data Quality Framework

Implemented data quality controls:

* Unique session validation
* Purchase deduplication
* Revenue integrity checks
* Funnel consistency validation
* Retention boundary testing
* LTV validation

Examples:

* Purchase events without transaction_id identified and excluded
* Duplicate purchase events removed using transaction-level deduplication
* Revenue metrics validated against source events

---

## Key Findings

### Revenue

Total revenue:

330,348

### Channel Performance

Top revenue channel:

Direct

Revenue:

236,579

### Funnel

Largest drop-off occurs between product view and purchase stages.

### Retention

Month 1 retention:

36.1%

Month 2 retention:

29.9%

### Device Performance

Desktop and mobile generated similar conversion rates (~1.4%).

---

## Technologies

* SQL
* dbt
* BigQuery
* Git
* Tableau (planned dashboard layer)

---

## Future Improvements

* Incremental dbt models
* CI/CD pipeline with GitHub Actions
* Advanced attribution models
* Customer RFM segmentation
* Marketing ROI analysis
* Interactive Tableau dashboards

---

Developed as a portfolio project focused on modern analytics engineering and product analytics practices.
