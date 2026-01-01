-- ============================================================
-- File: 01_churn_rate.sql
-- Project: Customer Retention & Churn Analysis
-- Focus: SaaS / Subscription Business
--
-- Description:
-- Calculates monthly churn rate over the last 12 months.
-- Churn Rate = (Churned Customers in Month / Active Customers at Start of Month) * 100
--
-- Assumptions:
-- - subscription_status_history tracks all status changes
-- - status = 'active' indicates an active subscription
-- - status = 'churned' indicates cancellation
-- ============================================================

WITH calendar_months AS (
    -- Generate monthly periods for the last 12 months
    SELECT 
        DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month' * n AS month_start
    FROM generate_series(0, 11) AS n
),

starting_customers AS (
    -- Customers active at the start of each month
    SELECT
        cm.month_start,
        COUNT(DISTINCT s.customer_id) AS starting_customers
    FROM calendar_months cm
    JOIN subscriptions s
        ON s.start_date < cm.month_start
       AND (s.end_date IS NULL OR s.end_date >= cm.month_start)
    GROUP BY cm.month_start
),

churned_customers AS (
    -- Customers who churned within each month
    SELECT
        DATE_TRUNC('month', ssh.status_date) AS month_start,
        COUNT(DISTINCT ssh.customer_id) AS churned_customers
    FROM subscription_status_history ssh
    WHERE ssh.status = 'churned'
      AND ssh.status_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', ssh.status_date)
)

SELECT
    cm.month_start AS month,
    sc.starting_customers,
    COALESCE(cc.churned_customers, 0) AS churned_customers,
    ROUND(
        COALESCE(cc.churned_customers, 0) * 100.0 
        / NULLIF(sc.starting_customers, 0),
        2
    ) AS churn_rate_percent,
    ROUND(
        100.0 - (
            COALESCE(cc.churned_customers, 0) * 100.0 
            / NULLIF(sc.starting_customers, 0)
        ),
        2
    ) AS retention_rate_percent
FROM calendar_months cm
LEFT JOIN starting_customers sc
    ON cm.month_start = sc.month_start
LEFT JOIN churned_customers cc
    ON cm.month_start = cc.month_start
ORDER BY cm.month_start;