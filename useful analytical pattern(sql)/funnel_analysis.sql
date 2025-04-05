-- 🟩 Step 1: Remove exact duplicate events (same url, host, user, timestamp)
WITH deduped_events AS (
    SELECT
        url,
        host,
        user_id,
        event_time
    FROM events
    GROUP BY 1, 2, 3, 4
),

-- 🟦 Step 2: Keep only events with user_id and add event_date (for same-day filtering)
clean_events AS (
    SELECT
        *,
        DATE(event_time) AS event_date
    FROM deduped_events
    WHERE user_id IS NOT NULL
    ORDER BY user_id, event_time
),

-- 🧠 Step 3: Check if each event was followed (later on the same day) by a conversion to `/api/v1/user`
converted AS (
    SELECT
        ce1.user_id,
        ce1.event_time,
        ce1.url AS visited_url,

        -- 1 if this session led to a conversion, 0 otherwise
        COUNT(DISTINCT CASE
            WHEN ce2.url = '/api/v1/user' THEN ce2.url
        END) AS is_converted
    FROM clean_events ce1
    JOIN clean_events ce2
        ON ce2.user_id = ce1.user_id
        AND ce2.event_date = ce1.event_date
        AND ce2.event_time > ce1.event_time  -- conversion must happen after visit
    GROUP BY 1, 2, 3
)

-- 📊 Step 4: Aggregate by visited URL to calculate conversion rate
SELECT
    visited_url,
    COUNT(*) AS total_visits,
    CAST(SUM(is_converted) AS REAL) / COUNT(*) AS conversion_rate
FROM converted
GROUP BY visited_url
-- HAVING
--     -- Only keep URLs with conversions and enough volume
--     CAST(SUM(is_converted) AS REAL) / COUNT(*) > 0
--     AND COUNT(*) > 100;
