## Table: subscriptions
- customer_id (INT): Unique customer identifier
- start_date (DATE): Subscription start date
- end_date (DATE): Subscription end date (NULL if active)
- status (VARCHAR): Current subscription status ('active', 'churned', etc.)
- plan_name (VARCHAR): Name of subscription plan
- current_mrr (NUMERIC): Monthly Recurring Revenue
- billing_cycle (VARCHAR): Subscription cycle ('monthly', 'annual')
- upgraded_plan (BOOLEAN): TRUE if the customer ever upgraded plan
- customer_tenure_days (INT): Total subscription tenure in days

## Table: subscription_status_history
- customer_id (INT): Unique customer identifier
- status_date (DATE): Date of status change or event
- status (VARCHAR): Subscription status at that date
- churn_reason (VARCHAR): Reason for churn ('voluntary', 'payment_failed', etc.)
- event_type (VARCHAR): Event type ('payment_failed', 'support_ticket')
- event_id (INT): Unique identifier for the event

## Table: feature_usage
- customer_id (INT): Unique customer identifier
- usage_date (DATE): Date of feature usage
- usage_level (VARCHAR): Usage intensity ('low', 'medium', 'high')