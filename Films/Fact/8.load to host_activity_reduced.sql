INSERT INTO host_activity_reduced (host, month, hit_array, unique_visitors_array)
-- ✅ Step 1: Aggregate daily host activity
WITH daily_aggregate AS (
    SELECT 
        host,
        DATE(event_time) AS date,
        COUNT(1) AS num_hits,  -- Total hits for this host on this date
        COUNT(DISTINCT user_id) AS unique_visitors  -- Unique visitors per host on this date
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-07')  -- Change this dynamically for incremental load
    GROUP BY host, DATE(event_time)
),

-- ✅ Step 2: Retrieve existing data for the host from `host_activity_reduced`
yesterday_array AS (
    SELECT *
    FROM host_activity_reduced 
    WHERE month = DATE('2023-01-01')  -- Same month_start logic as in user array metrics
)

-- ✅ Step 3: Insert new data into `host_activity_reduced`
SELECT 
    -- Keep host identifier
    COALESCE(da.host, ya.host) AS host,

    -- Determine the month start date (always the first of the month)
    COALESCE(ya.month, DATE_TRUNC('month', da.date)) AS month,

    -- Update hit_array with new daily hit counts
    CASE 
        WHEN ya.hit_array IS NOT NULL THEN 
            ya.hit_array || ARRAY[COALESCE(da.num_hits, 0)]
        WHEN ya.hit_array IS NULL THEN
            ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)]) 
                || ARRAY[COALESCE(da.num_hits, 0)]
    END AS hit_array,

    -- Update unique_visitors_array with new daily unique visitor counts
    CASE 
        WHEN ya.unique_visitors_array IS NOT NULL THEN 
            ya.unique_visitors_array || ARRAY[COALESCE(da.unique_visitors, 0)]
        WHEN ya.unique_visitors_array IS NULL THEN
            ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)]) 
                || ARRAY[COALESCE(da.unique_visitors, 0)]
    END AS unique_visitors_array

FROM daily_aggregate da
FULL OUTER JOIN yesterday_array ya 
ON da.host = ya.host

-- ✅ Handle conflicts: If a row for this host + month_start exists, update it instead
ON CONFLICT (host, month)
DO 
    UPDATE SET 
        hit_array = EXCLUDED.hit_array,
        unique_visitors_array = EXCLUDED.unique_visitors_array;





select * 
from host_activity_reduced

-- delete 
-- from host_activity_reduced
