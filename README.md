README

## Project Overview
- Analyze customer retention and churn for a SaaS/subscription business.
- Calculate key metrics: churn rate, cohort retention, high-risk customers, and revenue at risk.
- Provide actionable insights to support retention strategies and revenue protection.

## Business Focus
- SaaS / subscription-based services.
- Reduce churn and increase customer lifetime value.
- Monitor revenue at risk and identify high-risk customers.

## Key Metrics
- Churn Rate: Percentage of customers lost in a given period.
- Cohort Retention: Percentage of customers retained over time by signup cohort.
- High-Risk Customers: Active customers likely to churn based on behavior and payment history.
- Revenue at Risk: Total MRR exposed to churn from high-risk customers.

## SQL Files
- 01_churn_rate.sql – Calculates monthly churn and retention rates.
- 02_cohort_retention.sql – Builds monthly cohort retention matrix.
- 03_high_risk_customers.sql – Identifies and ranks customers at high risk of churn.
- 04_revenue_at_risk.sql – Calculates MRR exposed to high-risk customers.

## Assumptions
- subscriptions table tracks current and historical subscription details.
- subscription_status_history records all customer status changes and events.
- feature_usage tracks product engagement (low/medium/high).
- Active subscriptions have status = 'active'.

## Instructions
- Load the schema using schema.sql.
- (Optional) Load sample data from the data/ folder.
- Run SQL files in the following order for analysis:
  1. Churn rate
  2. Cohort retention
  3. High-risk customers
  4. Revenue at risk