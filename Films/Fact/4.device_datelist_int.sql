-- CREATE TABLE device_datelist_int (
--     user_id NUMERIC(20,0),  -- 🔹 Supports large numbers while allowing numerical operations
--     browser_type TEXT,  -- 🔹 Users can have multiple browsers
--     datelist_int BIT(32),  -- 🔹 Stores compressed 32-day activity in bit format
--     last_updated DATE,  -- 🔹 Track last update
--     PRIMARY KEY (user_id, browser_type)
-- );



WITH starter AS (
    -- Check if user was active on each valid date
    SELECT 
        uc.user_id,
        uc.browser_type,
        uc.device_activity_datelist @> ARRAY [DATE(d.valid_date)] AS is_active,
        EXTRACT(DAY FROM DATE('2023-01-31') - d.valid_date) AS days_since
    FROM user_devices_cumulated uc
    CROSS JOIN (
        -- Generate a series of dates for January (since our dataset is in January)
        SELECT generate_series('2023-01-01', '2023-01-31', INTERVAL '1 day') AS valid_date
    ) d
),
bits AS (
    -- Convert active dates into a bitwise representation
    SELECT 
        user_id,
        browser_type,
        SUM(CASE 
                WHEN is_active THEN POW(2, 32 - days_since) 
                ELSE 0 
            END)::BIGINT::BIT(32) AS datelist_int
    FROM starter
    GROUP BY user_id, browser_type
)

-- ✅ Insert into `user_device_datelist_int`
INSERT INTO device_datelist_int (user_id, browser_type, datelist_int, last_updated)
SELECT 
    user_id,
    browser_type,
    datelist_int,
    '2023-01-31' AS last_updated
FROM bits
-- ON CONFLICT (user_id, browser_type) 
-- DO UPDATE 
-- SET datelist_int = EXCLUDED.datelist_int, 
--     last_updated = EXCLUDED.last_updated;

