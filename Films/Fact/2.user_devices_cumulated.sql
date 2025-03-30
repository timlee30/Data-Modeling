select  *
from users
limit 10





WITH starter AS (
    SELECT uc.dates_active @> ARRAY [DATE(d.valid_date)]   AS is_active,
           EXTRACT(
               DAY FROM DATE('2023-03-31') - d.valid_date) AS days_since,
           uc.user_id
    FROM users_cumulated uc
             CROSS JOIN
         (SELECT generate_series('2023-02-28', '2023-03-31', INTERVAL '1 day') AS valid_date) as d
    WHERE date = DATE('2023-03-31')
),
     bits AS (
         SELECT user_id,
                SUM(CASE
                        WHEN is_active THEN POW(2, 32 - days_since)
                        ELSE 0 END)::bigint::bit(32) AS datelist_int,
                DATE('2023-03-31') as date
         FROM starter
         GROUP BY user_id
     )

     INSERT INTO user_datelist_int
     SELECT * FROM bits


select *
from devices d
limit 10 
select *
from events e
limit 10

----------------------------------------------------

WITH user_activity AS (
    SELECT
        e.user_id,
        d.browser_type,
        DATE(e.event_time) AS activity_date
    FROM events e
    JOIN devices d ON e.device_id = d.device_id  
    WHERE e.user_id IS NOT NULL
),
aggregated_activity AS (
    SELECT 
        user_id,
        browser_type,
        ARRAY_AGG(DISTINCT activity_date ORDER BY activity_date) AS active_dates
    FROM user_activity
    GROUP BY user_id, browser_type
)

-- This is a SELECT to validate, later we INSERT
SELECT * FROM aggregated_activity
limit 10;

--------------------------------------------------------

CREATE TABLE user_devices_cumulated (
    user_id BIGINT,
    browser_type TEXT,
    device_activity_datelist DATE[],  -- Array of active dates for each browser type
    last_updated DATE,
    PRIMARY KEY (user_id, browser_type)  -- Composite Primary Key
);
ALTER TABLE user_devices_cumulated ALTER COLUMN user_id TYPE NUMERIC(20,0);
--------------------------------------------------

WITH user_activity AS (
    SELECT
        e.user_id,
        d.browser_type,
        DATE(e.event_time) AS activity_date
    FROM events e
    JOIN devices d ON e.device_id = d.device_id  
    WHERE e.user_id IS NOT NULL
),
aggregated_activity AS (
    SELECT 
        user_id,
        browser_type,
        ARRAY_AGG(DISTINCT activity_date ORDER BY activity_date) AS active_dates
    FROM user_activity
    GROUP BY user_id, browser_type
)
-- Insert into user_devices_cumulated
-- INSERT INTO user_devices_cumulated (user_id, browser_type, device_activity_datelist, last_updated)
SELECT 
    user_id,
    browser_type,
    active_dates as device_activity_datelist,
    CURRENT_DATE
FROM aggregated_activity

-------------------------------
select *
from user_devices_cumulated