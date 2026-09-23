# E-Commerce Customer Behaviour & Revenue Analytics

An end-to-end analytics project that explores how customers buy, how often they come back, and where revenue comes from. It uses **Python** for cleaning and analysis, **SQL (MySQL)** for advanced querying, and **Power BI** for the final dashboard.

## Project Objectives

- Understand customer purchasing behaviour and sales trends
- Measure customer retention and repeat purchase behaviour
- Segment customers using RFM (Recency, Frequency, Monetary) analysis
- Analyse revenue by month, product category and region
- Present the insights in an interactive Power BI dashboard

## Tech Stack

| Area | Tools |
|------|-------|
| Data cleaning, EDA, feature engineering | Python (pandas, matplotlib / seaborn), Jupyter Notebook |
| Querying and analysis | MySQL (JOINs, CTEs, window functions) |
| Dashboarding | Power BI (KPI cards, DAX measures, drill-through) |
| Version control | Git & GitHub |

## Dataset

The data follows a 5-table e-commerce schema:

| Table | Description |
|-------|-------------|
| `Customers` | Customer IDs and location (state) |
| `Orders` | Order IDs, customers, order dates and status |
| `OrderItems` | Products, prices and shipping per order |
| `Payments` | Payment type and payment value per order |
| `Products` | Product category and attributes (e.g. weight) |

> **Note:** The dataset is **synthetically generated**. It was built with real repeat customers, realistic price-to-payment relationships, and deliberate data-quality issues (duplicate rows, inconsistent casing, missing values) so that cleaning and retention analysis could be practised properly.

## Project Workflow

1. **Data understanding** – inspected structure, data types, missing values and duplicates
2. **Data cleaning** – removed duplicate customer rows and handled missing values in state, approval date, product category and product weight
3. **Merging** – joined all 5 tables into a single master table (`data/processed/master_cleaned.csv`)
4. **Feature engineering** – order totals, customer revenue, order counts, average order value, days between orders
5. **Retention analysis** – repeat customer rate and time between orders
6. **RFM segmentation** – scored customers 1–5 on R, F and M and grouped them into named segments
7. **Revenue trends** – monthly trend, category performance and regional performance
8. **SQL analysis** – the same business questions answered in MySQL using JOINs, CTEs and window functions
9. **Power BI dashboard** – *(in progress)*

## Key Findings

- **Repeat customer rate:** about **65%** of customers placed more than one order
- **Time between orders:** repeat customers order again after about **185 days** on average (median about **150 days**)
- **RFM segments:** customers fall into six groups: Champions, Loyal Customers, Needs Attention, Lost, New/Promising and At Risk
- **Revenue trends:** *(add your top categories, top regions and peak months here)*

## Repository Structure

```
├── data/
│   └── processed/
│       └── master_cleaned.csv
├── notebooks/
│   └── 01_data_understanding.ipynb
├── sql/
│   ├── 02_joins.sql
│   ├── 03_ctes.sql
│   └── 04_window_functions.sql
├── dashboard/                       # Power BI file (coming soon)
├── .gitignore
└── README.md
```

## SQL Highlights

- **JOINs:** inner, left and multi-table joins combined with aggregation
- **CTEs:** average order value, repeat rate, first/last order dates and an RFM base query
- **Window functions:** `ROW_NUMBER`, `RANK` / `DENSE_RANK`, `NTILE` for RFM scoring, `LAG` for retention gap analysis, and a running total of cumulative revenue

## How to Run

1. Clone the repository
   ```bash
   git clone https://github.com/Chaitali2508/E-Commerce-Customer-Behaviour-Revenue-Analytics.git
   cd E-Commerce-Customer-Behaviour-Revenue-Analytics
   ```
2. Install the required libraries
   ```bash
   pip install pandas numpy matplotlib seaborn jupyter
   ```
3. Open the notebooks in the `notebooks/` folder and run them in order
4. Run the `.sql` files in the `sql/` folder in MySQL against the 5 tables

## Skills Demonstrated

Data cleaning · Exploratory data analysis · Feature engineering · Customer retention analysis · RFM segmentation · Advanced SQL (CTEs, window functions) · Data visualisation · Dashboarding with Power BI

## Author

**Chaitali** – [GitHub](https://github.com/Chaitali2508)