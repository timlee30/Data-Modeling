-- 📊 Create a summary dashboard that aggregates hits across different combinations of device info
CREATE TABLE device_hits_dashboard AS

WITH events_augmented AS (
    -- 🧠 Step 1: Join events with device metadata and clean nulls
    SELECT
        COALESCE(d.os_type, 'unknown') AS os_type,
        COALESCE(d.device_type, 'unknown') AS device_type,
        COALESCE(d.browser_type, 'unknown') AS browser_type,
        url,
        user_id
    FROM events e
    JOIN devices d ON e.device_id = d.device_id
)

-- 🟦 Step 2: Group by multiple dimensions using GROUPING SETS
SELECT
    -- Label which level of aggregation this row belongs to
    CASE
        WHEN GROUPING(os_type) = 0 AND GROUPING(device_type) = 0 AND GROUPING(browser_type) = 0
            THEN 'os_type__device_type__browser'  -- Fully detailed group
        WHEN GROUPING(browser_type) = 0 THEN 'browser_type'         -- Only browser_type grouped
        WHEN GROUPING(device_type) = 0 THEN 'device_type'           -- Only device_type grouped
        WHEN GROUPING(os_type) = 0 THEN 'os_type'                   -- Only os_type grouped
    END AS aggregation_level,

    -- Fill missing dimension values with '(overall)' for readability
    COALESCE(os_type, '(overall)') AS os_type,
    COALESCE(device_type, '(overall)') AS device_type,
    COALESCE(browser_type, '(overall)') AS browser_type,

    -- Count the number of events/hits in each group
    COUNT(1) AS number_of_hits

FROM events_augmented

-- 🧩 Define multiple grouping combinations
GROUP BY GROUPING SETS (
    (browser_type, device_type, os_type),  -- Full detail
    (browser_type),                        -- Browser only
    (os_type),                             -- OS only
    (device_type)                          -- Device only
)

-- 🔽 Sort by highest number of hits
ORDER BY COUNT(1) DESC;