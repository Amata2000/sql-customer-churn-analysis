-- ============================================================
-- File: schema.sql
-- Project: Customer Retention & Churn Analysis
-- Purpose: Define tables required for SQL churn and retention analysis
-- Notes: This schema supports all 4 core SQL files
-- ============================================================

-- ============================================================
-- Table: subscriptions
-- Description: Customer subscription records
-- ============================================================
CREATE TABLE subscriptions (
    customer_id INT PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE,                       -- NULL if active
    status VARCHAR(20) NOT NULL,         -- 'active', 'churned', etc.
    plan_name VARCHAR(50),
    current_mrr NUMERIC(10,2),          -- Monthly Recurring Revenue
    billing_cycle VARCHAR(10),           -- 'monthly', 'annual'
    upgraded_plan BOOLEAN DEFAULT FALSE, -- TRUE if customer ever upgraded plan
    customer_tenure_days INT             -- Current or total tenure in days
);

-- ============================================================
-- Table: subscription_status_history
-- Description: Tracks historical subscription status and events
-- ============================================================
CREATE TABLE subscription_status_history (
    customer_id INT,
    status_date DATE NOT NULL,
    status VARCHAR(20),                  -- 'active', 'churned'
    churn_reason VARCHAR(50),            -- e.g., 'voluntary', 'payment_failed'
    event_type VARCHAR(50),              -- e.g., 'payment_failed', 'support_ticket'
    event_id INT                         -- Unique identifier per event
);

-- ============================================================
-- Table: feature_usage
-- Description: Tracks customer product engagement levels
-- ============================================================
CREATE TABLE feature_usage (
    customer_id INT,
    usage_date DATE,
    usage_level VARCHAR(20)              -- 'high', 'medium', 'low'
);