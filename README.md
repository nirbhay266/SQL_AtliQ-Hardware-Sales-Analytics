# 📊 AtliQ Hardware Sales Analysis (SQL Project)

## 📌 Project Overview
AtliQ Hardware is a leading electronics company operating across multiple regions and platforms.  
This project focuses on analyzing **sales and operational data** to uncover actionable insights and support **strategic decision-making**.

The analysis includes:
- Gross & Net Sales reports
- Pre-invoice and post-invoice discount impacts
- Top-performing markets, customers, and products
- Seasonal and trend-based insights
- Performance optimization in SQL queries

---

## 🎯 Problem Statement
AtliQ Hardware required an in-depth analysis of its sales data to:
- Identify patterns, trends, and improvement areas across regions, channels, and product categories.
- Make **data-driven business decisions** to stay competitive.

---

## 🎯 Key Objectives
- Understand customer and market trends.
- Analyze product performance across divisions.
- Evaluate the impact of discounts on sales.
- Identify seasonal patterns in sales.
- Provide actionable recommendations to improve profitability.

---

## 🛠 Tools & Technologies
- **SQL** → Data extraction & transformation.
- **Power BI** → Data visualization & dashboarding.
- **Excel** → Data cleaning & preparation.

---

## 🔄 Data Analysis Workflow
1. **Data Collection** – Aggregated sales data from fact & dimension tables.  
2. **Data Cleaning** – Ensured consistency and accuracy using Excel.  
3. **Exploratory Data Analysis (EDA)** – Identified KPIs, trends, and outliers using SQL.  
4. **Visualization** – Created dashboards in Power BI.  
5. **Insights Generation** – Derived actionable conclusions.  
6. **Recommendations** – Proposed growth strategies.

---

## 📂 SQL Modules Implemented
### 1. Sales Reports
- **Monthly & Yearly Gross Sales** for Croma India.
- **Market Badge Logic** – Gold if sold quantity > 5M, else Silver.

### 2. Discount Impact Analysis
- Pre-invoice & Post-invoice discount adjustments.
- Net Sales calculation using created SQL views.

### 3. Performance Optimization
- Removed `get_fiscal_year()` in joins by using `dim_date`.
- Added `fiscal_year` column in `fact_sales_monthly` for faster queries.

### 4. Top N Analysis
- Top N markets by net sales (Stored Procedure).
- Top N customers by net sales (Stored Procedure).
- Top N products per division by quantity sold.

### 5. Window Functions
- Net sales % contribution per customer.
- Sales distribution per region.
- Ranking top products per division.

---

## 📊 Key Insights
- **Customer & Market Insights** → Top markets & customers identified.
- **Product Performance** → Notebooks & accessories were top performers; unique product count +36%.
- **Sales Trends** → Retailer channels contributed 73% of gross sales in FY2021.
- **Discount Impact** → Flipkart, Viveks, Ezone, Croma, and Amazon had highest discounts.
- **Seasonality** → Q1 2020 (Sept–Nov) recorded highest sold quantity.

---

## 💡 Recommendations
✅ Expand product offerings in high-performing markets.  
✅ Optimize discount strategies for profitability.  
✅ Invest in retailer channels to maintain sales growth.  
✅ Align marketing with seasonal peaks.

---

## 📈 Impact
- Provided AtliQ Hardware with **data-driven insights** to improve sales and customer satisfaction.
- Demonstrated **data storytelling** and the alignment of analytics with business goals.

---

## 📂 Project Structure
```plaintext
SQL_Project/
│
├── queries/                  # SQL scripts for all modules
├── views/                    # Created views for modular queries
├── procedures/               # Stored procedures for reusable logic
├── PowerBI_Dashboard.pbix    # Interactive dashboard
└── README.md                 # Project documentation
```

---

## 🖼 Sample Dashboard
*(Add screenshots here)*

---

## 📬 Contact
**Nirbhay Kumar**  
📧 Email: your-email@example.com  
🔗 [LinkedIn](https://www.linkedin.com/in/nirbhay-kumar-32b947262/)  
🐦 [Twitter](https://x.com/nirbhaykkr6)  
