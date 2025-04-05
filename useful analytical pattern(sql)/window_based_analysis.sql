WITH events_augmented AS (
    -- Enrich events with device info and standardized referrer categories
    SELECT
        COALESCE(d.os_type, 'unknown') AS os_type,
        COALESCE(d.device_type, 'unknown') AS device_type,
        COALESCE(d.browser_type, 'unknown') AS browser_type,
        url,
        user_id,
        CASE
            WHEN referrer LIKE '%linkedin%' THEN 'Linkedin'
            WHEN referrer LIKE '%t.co%' THEN 'Twitter'
            WHEN referrer LIKE '%google%' THEN 'Google'
            WHEN referrer LIKE '%lnkd%' THEN 'Linkedin'
            WHEN referrer LIKE '%eczachly%' OR referrer LIKE '%zachwilson%' THEN 'On Site'
            ELSE referrer
        END AS referrer,
        DATE(event_time) AS event_date
    FROM events e
    JOIN devices d ON e.device_id = d.device_id
),

aggregated AS (
    -- Count daily events per (referrer, url) combination
    SELECT
        url,
        referrer,
        event_date,
        COUNT(*) AS daily_event_count
    FROM events_augmented
    GROUP BY url, referrer, event_date
),

windowed AS (
    SELECT
        referrer,
        url,
        event_date,
        daily_event_count,

        -- Total for current month (same for all rows in the month)
        SUM(daily_event_count) OVER (
            PARTITION BY referrer, url, DATE_TRUNC('month', event_date)
            ORDER BY event_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS monthly_cumulative_sum,

        -- 🔁 Rolling cumulative sum (grows row-by-row over time)
        -- Equivalent to: ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        SUM(daily_event_count) OVER (
            PARTITION BY referrer, url
            ORDER BY event_date
        ) AS rolling_cumulative_sum,

        -- 📌 Static total for all time (same value on every row)
        -- Includes ALL rows in the partition — regardless of current row
        SUM(daily_event_count) OVER (
            PARTITION BY referrer, url
            ORDER BY event_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS total_cumulative_sum,

        -- 7-day rolling window: current day and past 6 days
        SUM(daily_event_count) OVER (
            PARTITION BY referrer, url
            ORDER BY event_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS weekly_rolling_count,

        -- 7-day window: the 7 days before the current 7-day range
        SUM(daily_event_count) OVER (
            PARTITION BY referrer, url
            ORDER BY event_date
            ROWS BETWEEN 13 PRECEDING AND 6 PRECEDING
        ) AS previous_weekly_rolling_count

    FROM aggregated
    ORDER BY referrer, url, event_date
)

-- Final output: include only rows with meaningful volume
SELECT
    referrer,
    url,
    event_date,
    daily_event_count,
    weekly_rolling_count,
    previous_weekly_rolling_count,

    -- How much of the monthly traffic came on this day
    CAST(daily_event_count AS REAL) / monthly_cumulative_sum AS pct_of_month,

    -- How much of all-time traffic came on this day
    CAST(daily_event_count AS REAL) / total_cumulative_sum AS pct_of_total

FROM windowed
WHERE total_cumulative_sum > 500
  AND referrer IS NOT NULL;
