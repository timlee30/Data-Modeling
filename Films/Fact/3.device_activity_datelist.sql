WITH starter AS (
    -- Check if user was active on each valid date
    SELECT 
        uc.user_id,
        uc.browser_type,
        uc.device_activity_datelist @> ARRAY [DATE(d.valid_date)] AS is_active,
        EXTRACT(DAY FROM DATE('2023-01-31') - d.valid_date) AS days_since
    FROM user_devices_cumulated uc
    CROSS JOIN (
        -- Generate a series of dates for the last 32 days (January Only)
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

-- ✅ Insert into `device_activity_datelist`
-- INSERT INTO device_activity_datelist (user_id, browser_type, datelist_int, last_updated)
SELECT 
    user_id,
    browser_type,
    datelist_int,
    '2023-01-31' as last_updated,
    
    -- ✅ Align output format with lab reference
    BIT_COUNT(datelist_int) > 0 AS monthly_active,
    BIT_COUNT(datelist_int) AS l32,
    BIT_COUNT(datelist_int & CAST('11111110000000000000000000000000' AS BIT(32))) > 0 AS weekly_active,
    BIT_COUNT(datelist_int & CAST('11111110000000000000000000000000' AS BIT(32))) AS l7,
    BIT_COUNT(datelist_int & CAST('00000001111111000000000000000000' AS BIT(32))) > 0 AS weekly_active_previous_week

FROM bits;


