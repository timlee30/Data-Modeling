select *
from events

CREATE TABLE hosts_cumulated (
    host TEXT PRIMARY KEY,         -- 🔹 Unique domain name
    host_activity_datelist DATE[], -- 🔹 Stores all active dates for the host
    last_updated DATE              -- 🔹 Tracks last update
);


WITH host_activity AS (
    SELECT
        host,
        DATE(event_time) AS activity_date
    FROM events
    WHERE host IS NOT NULL
)
,
aggregated_activity AS (
    SELECT 
        host,
        ARRAY_AGG(DISTINCT activity_date ORDER BY activity_date) AS active_dates
    FROM host_activity
    GROUP BY host
)
-- Insert into user_devices_cumulated
INSERT INTO hosts_cumulated (host, host_activity_datelist, last_updated)
SELECT 
    host,
    active_dates as host_activity_datelist,
    '2023-01-31' as last_updated
FROM aggregated_activity



select * from hosts_cumulated