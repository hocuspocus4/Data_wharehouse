WITH combined AS (
    -- Subscription revenue: monthly equivalent cost per plan type
    SELECT
        TO_CHAR(DATE_TRUNC('month', s.beginning_date), 'Month YYYY') AS month,
        DATE_TRUNC('month', s.beginning_date)                        AS sort_date,
        st.sub_type                                                  AS subscription_type,
        ROUND(
            SUM(
                CASE
                    WHEN st.sub_type = 'monthly'   THEN st.cost
                    WHEN st.sub_type = 'quarterly' THEN st.cost / 3
                    WHEN st.sub_type = 'yearly'    THEN st.cost / 12
                END
            )::NUMERIC, 2
        )                                                             AS total_revenue
    FROM subscriptions s
    JOIN subscription_types st ON s.sub_type = st.sub_type
    GROUP BY DATE_TRUNC('month', s.beginning_date), st.sub_type, st.cost

    UNION ALL

    -- Pay-as-you-go: actual payments from users with no active subscription
    SELECT
        TO_CHAR(DATE_TRUNC('month', p.payment_date), 'Month YYYY')   AS month,
        DATE_TRUNC('month', p.payment_date)                           AS sort_date,
        'pay-as-you-go'                                               AS subscription_type,
        ROUND(SUM(p.amount)::NUMERIC, 2)                              AS total_revenue
    FROM payments p
    JOIN rides r ON p.ride_id = r.ride_id
    WHERE NOT EXISTS (
        SELECT 1 FROM subscriptions s
        WHERE s.user_id        = r.user_id
          AND s.beginning_date <= r.start_time::DATE
          AND (s.end_date IS NULL OR s.end_date >= r.start_time::DATE)
    )
    GROUP BY DATE_TRUNC('month', p.payment_date)
)
SELECT month, subscription_type, total_revenue
FROM combined
ORDER BY sort_date, subscription_type;
