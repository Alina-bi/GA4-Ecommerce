# GA4 Ecommerce Analytics Platform

End-to-end analytics engineering project built on Google Analytics 4 public e-commerce data:
BigQuery → dbt → Tableau → GitHub Actions

Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce (Nov 2020 – Jan 2021, ~4.3M events)
Status: Production-style analytics pipeline with testing, data quality monitoring, source freshness validation and documented business marts.

## Project Overview

The goal of the project was to transform raw GA4 event data into trusted analytical datasets and reporting-ready business marts while applying modern analytics engineering practices:

* layered dbt architecture
* automated testing
* source freshness monitoring
* revenue reconciliation
* data quality monitoring
* business metric standardization

---

## Business Objectives

The project addresses common ecommerce analytics use cases:

* Marketing channel performance
* Executive KPI reporting
* Ecommerce funnel analysis
* Customer retention analysis
* Customer lifetime value analysis
* Product performance analysis
* Data quality monitoring
* Revenue reconciliation

---

## Tech Stack

* SQL
* dbt
* Google BigQuery
* Google Analytics 4 Sample Ecommerce Dataset
* Tableau Public
* GitHub
* GitHub Actions (CI/CD)

---

### Coverage Metrics

| Metric                    | Value   |
| ------------------------- | ------- |
| Raw events                | ~4.3M   |
| Sessions                  | ~408K   |
| Users                     | ~243K   |
| Purchase events           | 4,786   |
| Unique orders             | 4,466   |
| Revenue reconciled        | 308,830 |
| Revenue discrepancy fixed | 560     |
| Data marts                | 6       |
| Automated tests           | 20+     |

---

## Data Architecture

### Data Pipeline

```mermaid
graph LR
    %% Напрямок зліва направо (Left to Right) для кращої читабельності
    
    subgraph Source [Джерело даних]
        Raw[GA4 Raw Events]
    end

    subgraph Staging [Staging Шар]
        Stg[stg_ga4__events]
    end

    subgraph Intermediate [Проміжний шар / Логіка]
        Int1[int_sessions]
        Int2[int_funnel_steps]
        Int3[int_user_metrics]
    end

    subgraph Marts [Вітрини даних / Data Marts]
        M1[mart_executive_kpi]
        M2[mart_daily_performance]
        M3[mart_funnel]
        M4[mart_product_performance]
        M5[mart_retention]
        M6[mart_user_ltv]
        M7[mart_data_quality]
    end

    subgraph BI [Візуалізація]
        Tableau[(Tableau Dashboards)]
    end

    %% Зв'язки між шарами (без "каші" з ліній)
    Raw --> Stg
    Stg --> Int1 & Int2 & Int3
    
    Int1 & Int2 & Int3 --> M1
    Int1 & Int2 & Int3 --> M2
    Int1 & Int2 & Int3 --> M3
    Int1 & Int2 & Int3 --> M4
    Int1 & Int2 & Int3 --> M5
    Int1 & Int2 & Int3 --> M6
    Int1 & Int2 & Int3 --> M7

    M1 & M2 & M3 & M4 & M5 & M6 & M7 --> Tableau

    %% Стилізація для сучасного вигляду
    style Raw fill:#ECEFF1,stroke:#37474F,stroke-width:2px,color:#333
    style Stg fill:#E1F5FE,stroke:#0288D1,stroke-width:1px,color:#333
    style Int1 fill:#E8F5E9,stroke:#388E3C,stroke-width:1px,color:#333
    style Int2 fill:#E8F5E9,stroke:#388E3C,stroke-width:1px,color:#333
    style Int3 fill:#E8F5E9,stroke:#388E3C,stroke-width:1px,color:#333
    style Tableau fill:#E0F2F1,stroke:#004D40,stroke-width:2px,color:#333
    
    classDef marts fill:#FFF3E0,stroke:#F57C00,stroke-width:1px,color:#333;
    class M1,M2,M3,M4,M5,M6,M7 marts;
```

### Staging Layer

Purpose: standardize raw GA4 export data and expose business-friendly fields.

Models:

* stg_ga4__events

Key transformations:

* event parameter extraction
* traffic attribution parsing
* ecommerce extraction
* device enrichment
* geography enrichment
* channel grouping
* data quality flags

Examples:

* missing transaction detection
* GDPR deleted traffic detection
* internal referral detection

---

### Intermediate Layer

Purpose: separate business logic from reporting logic.

Models:

* int_sessions
* int_user_metrics
* int_purchase_events_deduped

Responsibilities:

* session reconstruction
* user aggregation
* purchase deduplication

---

### Business Marts

The marts layer contains business-ready metrics designed for reporting and decision making.

#### mart_daily_performance

Marketing performance mart.

Dimensions:
* channel
* source
* medium
* country
* city
* device
* browser

Metrics:
* sessions
* users
* transactions
* revenue
* conversion rate
* AOV
  
#### mart_funnel

Normalized ecommerce funnel.

Steps:
* View Item
* Add To Cart
* Begin Checkout
* Purchase

Metrics:
* item_to_cart_rate
* cart_to_checkout_rate
* checkout_to_purchase_rate

#### mart_product_performance

Product performance analysis:

Metrics:
* product revenue
* units sold
* transaction count
* average item price

#### mart_retention

Customer retention metrics:

Metrics:
* cohort size
* active users
* retention rate

#### mart_user_ltv

Thin BI-facing layer built on top of int_user_metrics.

Purpose:
* expose user-level metrics for Tableau
* provide stable reporting interface
* avoid duplication of business logic

Metrics:
* total revenue
* total sessions
* active days
* purchase count
* average order value
* first-touch acquisition dimensions

#### mart_data_quality

Centralized data quality monitoring

Checks:
* missing transaction IDs
* duplicate transaction IDs
* revenue validation
* session anomalies
* data freshness checks

---

### Data Quality Deep Dive

One of the main goals of the project was ensuring metric consistency across all reporting layers.

During validation a revenue discrepancy was discovered.

#### Initial Finding

Revenue from session-level reporting did not match revenue from order-level reporting.

select round(sum(revenue),2)
from fct_orders

Result: 308,270

select round(sum(session_revenue),2)
from int_sessions

Result: 308,830

Difference: 560

#### Hypothesis 1

Duplicate purchase events.

Validation:
Purchase events: 4,786
Unique transactions: 4,451
Duplicates: 335

Deduplication implemented using:

row_number() over (
  partition by transaction_id
  order by event_timestamp
)

Partially reduced the discrepancy.

#### Hypothesis 2

Missing transaction IDs.

Validation:

906 purchase events

These events were excluded from financial reporting.

Discrepancy remained.

Hypothesis rejected.

#### Hypothesis 3

Session aggregation issue.

Validation:

No duplicated session_id values detected.

Hypothesis rejected.

#### Hypothesis 4

Transaction ID collisions.

Validation revealed that transaction_id was not globally unique.

Multiple users shared identical transaction IDs.

Example:

select
 transaction_id,
 count(distinct user_pseudo_id)
from int_purchase_events_deduped
group by 1
having count(distinct user_pseudo_id) > 1

Root cause confirmed.

#### Solution

A synthetic business key was introduced:

concat(
 user_pseudo_id,
 '-',
 transaction_id
) as order_key

All financial models were migrated to use:
order_key

instead of:
transaction_id

#### Result

Revenue reconciliation:

Session Revenue: 308,830
Order Revenue:   308,830
Difference:      0

Revenue fully reconciled.

### Data Quality Improvements

Additional improvements implemented:

#### Channel Attribution Fix

Investigation revealed that:

<Other>

traffic was incorrectly classified as:

Direct

because NULL source values and obfuscated GA4 values were treated identically.

Channel grouping logic was redesigned using raw source and medium values.

Result:
* Direct traffic corrected
* Obfuscated traffic isolated
* Channel reporting became more accurate

#### Testing

Automated dbt tests include:
* unique keys
* not null validation
* relationships tests
* funnel validation
* retention validation
* revenue validation
* LTV validation

All marts are validated through dbt test runs.

### Source Freshness Monitoring

The project includes dbt source freshness monitoring.

freshness:

  warn_after:
    count: 24
    period: hour

  error_after:
    count: 48
    period: hour

Purpose:

monitor source latency
detect stale data
simulate production-grade monitoring

Note:

The public GA4 sample dataset is static, therefore freshness checks are included to demonstrate implementation rather than operational alerting.

### CI/CD

CI/CD is implemented using GitHub Actions.

Every push and pull request automatically runs:
* dbt parse
* dbt build
* source freshness checks

This ensures that new changes do not break model dependencies or data quality validations.

<img width="162" height="208" alt="image" src="https://github.com/user-attachments/assets/45017e79-afbe-4349-8f02-8f4b26025127" />


### Documentation

dbt documentation includes:
* model descriptions
* column descriptions
* lineage graph
* business definitions
* test coverage

<img width="1602" height="696" alt="image" src="https://github.com/user-attachments/assets/477ce34a-2160-41eb-a49b-44d8381e4208" />

The lineage graph visualizes how raw GA4 events are transformed into reporting-ready analytical datasets.

### Key Skills Demonstrated
* Analytics Engineering
* SQL Development
* Data Modeling
* dbt
* BigQuery
* Data Quality Monitoring
* Revenue Reconciliation
* Funnel Analytics
* Cohort Analysis
* Customer Lifetime Value Analysis
* Marketing Attribution
* CI/CD
* Source Freshness Monitoring

### Repository Structure
models/
├── staging/
├── intermediate/
├── marts/
├── tests/
.github/
└── workflows/
