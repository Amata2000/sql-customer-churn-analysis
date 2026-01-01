-- ============================================================
-- File: 04_revenue_at_risk.sql
-- Project: Customer Retention & Churn Analysis
-- Focus: SaaS / Subscription Business
--
-- Description:
-- Quantifies Monthly Recurring Revenue (MRR) exposed to churn
-- by aggregating revenue from high-risk active customers.
--
-- Key Outputs:
-- - Revenue at risk by risk segment
-- - Percentage of total active MRR at risk
--
-- Assumptions:
-- - current_mrr represents active monthly recurring revenue
-- - High-risk customers are identified in 03_high_risk_customers
-- - subscriptions.status = 'active' indicates paying customers
-- ============================================================

WITH high_risk_customers AS (
    -- Recompute risk scores to keep file self-contained
    SELECT
        rs.customer_id,
        rs.risk_score,
        rs.primary_risk_reason
    FROM (
        SELECT
            s.customer_id,
            (
                CASE
                    WHEN CURRENT_DATE - MAX(ssh.status_date) > 30 THEN 10
                    WHEN CURRENT_DATE - MAX(ssh.status_date) > 14 THEN 5
                    ELSE 0
                END
                + COUNT(DISTINCT CASE
                    WHEN ssh.event_type = 'support_ticket'
                     AND ssh.status_date >= CURRENT_DATE - INTERVAL '30 days'
                    THEN ssh.event_id
                END) * 3
                + COUNT(DISTINCT CASE
                    WHEN ssh.event_type = 'payment_failed'
                     AND ssh.status_date >= CURRENT_DATE - INTERVAL '30 days'
                    THEN ssh.event_id
                END) * 5
            ) AS risk_score,
            CASE
                WHEN CURRENT_DATE - MAX(ssh.status_date) > 30 THEN 'Inactive >30 days'
                WHEN COUNT(DISTINCT CASE
                    WHEN ssh.event_type = 'payment_failed'
                     AND ssh.status_date >= CURRENT_DATE - INTERVAL '30 days'
                    THEN ssh.event_id
                END) >= 2 THEN 'Repeated payment failures'
                WHEN COUNT(DISTINCT CASE
                    WHEN ssh.event_type = 'support_ticket'
                     AND ssh.status_date >= CURRENT_DATE - INTERVAL '30 days'
                    THEN ssh.event_id
                END) >= 3 THEN 'High support volume'
                ELSE 'Multiple risk indicators'
            END AS primary_risk_reason
        FROM subscriptions s
        LEFT JOIN subscription_status_history ssh
            ON s.customer_id = ssh.customer_id
        WHERE s.status = 'active'
        GROUP BY s.customer_id
    ) rs
    WHERE rs.risk_score >= 8
),

total_active_mrr AS (
    -- Total MRR from all active customers
    SELECT
        SUM(current_mrr) AS total_mrr
    FROM subscriptions
    WHERE status = 'active'
)

SELECT
    CASE
        WHEN hrc.risk_score >= 15 THEN 'Critical'
        WHEN hrc.risk_score >= 10 THEN 'High'
        ELSE 'Medium'
    END AS risk_segment,
    COUNT(DISTINCT s.customer_id) AS at_risk_customers,
    SUM(s.current_mrr) AS mrr_at_risk,
    ROUND(
        SUM(s.current_mrr) * 100.0
        / NULLIF(tam.total_mrr, 0),
        2
    ) AS percent_of_total_mrr,
    STRING_AGG(
        DISTINCT hrc.primary_risk_reason,
        ', '
    ) AS common_risk_reasons
FROM high_risk_customers hrc
JOIN subscriptions s
    ON hrc.customer_id = s.customer_id
CROSS JOIN total_active_mrr tam
GROUP BY risk_segment, tam.total_mrr
ORDER BY
    CASE risk_segment
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
    END;