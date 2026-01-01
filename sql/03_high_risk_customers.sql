-- ============================================================
-- File: 03_high_risk_customers.sql
-- Project: Customer Retention & Churn Analysis
-- Focus: SaaS / Subscription Business
--
-- Description:
-- Identifies active customers with a high likelihood of churn
-- based on behavioral and operational risk signals.
--
-- Risk Signals Considered:
-- - Inactivity / recency
-- - Payment failures
-- - Support ticket volume
-- - Low product usage
--
-- Output:
-- Ranked list of high-risk customers for retention actions.
--
-- Assumptions:
-- - subscriptions.status indicates current subscription state
-- - subscription_status_history stores behavioral events
-- - feature_usage tracks product engagement levels
-- ============================================================

WITH customer_activity AS (
    -- Aggregate recent customer activity and risk indicators
    SELECT
        s.customer_id,
        s.plan_name,
        s.current_mrr,
        s.start_date,
        MAX(ssh.status_date) AS last_activity_date,

        COUNT(DISTINCT CASE
            WHEN ssh.event_type = 'support_ticket'
             AND ssh.status_date >= CURRENT_DATE - INTERVAL '30 days'
            THEN ssh.event_id
        END) AS support_tickets_30d,

        COUNT(DISTINCT CASE
            WHEN ssh.event_type = 'payment_failed'
             AND ssh.status_date >= CURRENT_DATE - INTERVAL '30 days'
            THEN ssh.event_id
        END) AS payment_failures_30d,

        COUNT(DISTINCT CASE
            WHEN fu.usage_level = 'low'
             AND fu.usage_date >= CURRENT_DATE - INTERVAL '14 days'
            THEN fu.usage_date
        END) AS low_usage_days_14d

    FROM subscriptions s
    LEFT JOIN subscription_status_history ssh
        ON s.customer_id = ssh.customer_id
    LEFT JOIN feature_usage fu
        ON s.customer_id = fu.customer_id
    WHERE s.status = 'active'
    GROUP BY
        s.customer_id,
        s.plan_name,
        s.current_mrr,
        s.start_date
),

risk_scoring AS (
    -- Compute composite churn risk score
    SELECT
        customer_id,
        plan_name,
        current_mrr,
        support_tickets_30d,
        payment_failures_30d,
        low_usage_days_14d,
        last_activity_date,

        (
            CASE
                WHEN CURRENT_DATE - last_activity_date > 30 THEN 10
                WHEN CURRENT_DATE - last_activity_date > 14 THEN 5
                ELSE 0
            END
            + support_tickets_30d * 3
            + payment_failures_30d * 5
            + low_usage_days_14d * 2
        ) AS risk_score,

        CASE
            WHEN CURRENT_DATE - last_activity_date > 30 THEN 'Inactive >30 days'
            WHEN payment_failures_30d >= 2 THEN 'Repeated payment failures'
            WHEN support_tickets_30d >= 3 THEN 'High support volume'
            WHEN low_usage_days_14d >= 7 THEN 'Low product usage'
            ELSE 'Multiple minor risk signals'
        END AS primary_risk_reason
    FROM customer_activity
)

SELECT
    customer_id,
    plan_name,
    current_mrr,
    risk_score,
    primary_risk_reason,
    ROW_NUMBER() OVER (
        ORDER BY risk_score DESC, current_mrr DESC
    ) AS risk_rank
FROM risk_scoring
WHERE risk_score >= 8
ORDER BY risk_rank
LIMIT 50;