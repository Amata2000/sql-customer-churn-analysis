-- ============================================================
-- File: 02_cohort_retention.sql
-- Project: Customer Retention & Churn Analysis
-- Focus: SaaS / Subscription Business
--
-- Description:
-- Builds a monthly cohort retention matrix showing how many
-- customers from each signup cohort remain active over time.
--
-- Key Metrics:
-- - Cohort size
-- - Months since cohort start
-- - Retained customers
-- - Retention rate (%)
--
-- Assumptions:
-- - subscriptions.start_date represents first subscription start
-- - subscription_status_history tracks monthly activity
-- - status = 'active' indicates an active subscription
-- ============================================================

WITH customer_cohorts AS (
    -- Assign each customer to a cohort based on first subscription month
    SELECT
        s.customer_id,
        DATE_TRUNC('month', MIN(s.start_date)) AS cohort_month
    FROM subscriptions s
    GROUP BY s.customer_id
),

monthly_activity AS (
    -- Capture months in which customers were active
    SELECT DISTINCT
        ssh.customer_id,
        DATE_TRUNC('month', ssh.status_date) AS activity_month
    FROM subscription_status_history ssh
    WHERE ssh.status = 'active'
),

cohort_activity AS (
    -- Map customer activity back to their cohort
    SELECT
        cc.cohort_month,
        ma.activity_month,
        cc.customer_id
    FROM customer_cohorts cc
    JOIN monthly_activity ma
        ON cc.customer_id = ma.customer_id
       AND ma.activity_month >= cc.cohort_month
),

cohort_sizes AS (
    -- Total customers in each cohort
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
)

SELECT
    ca.cohort_month,
    cs.cohort_size,
    EXTRACT(
        MONTH FROM AGE(ca.activity_month, ca.cohort_month)
    ) AS months_since_cohort,
    COUNT(DISTINCT ca.customer_id) AS retained_customers,
    ROUND(
        COUNT(DISTINCT ca.customer_id) * 100.0 
        / cs.cohort_size,
        2
    ) AS retention_rate_percent
FROM cohort_activity ca
JOIN cohort_sizes cs
    ON ca.cohort_month = cs.cohort_month
WHERE ca.cohort_month >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months'
GROUP BY
    ca.cohort_month,
    cs.cohort_size,
    months_since_cohort
ORDER BY
    ca.cohort_month,
    months_since_cohort;