-- DROP TABLE IF EXISTS users_growth_accounting;

-- CREATE TABLE users_growth_accounting (
--     user_id TEXT PRIMARY KEY,
--     first_active_date DATE NOT NULL,
--     last_active_date DATE NOT NULL,
--     daily_active_state TEXT NOT NULL,
--     weekly_active_state TEXT NOT NULL,
--     date_list DATE[] NOT NULL,
--     date DATE NOT NULL
-- );




-- 🟩 Insert or update user activity snapshot for the current day (2023-01-14)
INSERT INTO users_growth_accounting (
    user_id,
    first_active_date,
    last_active_date,
    daily_active_state,
    weekly_active_state,
    date_list,
    date
)

-- 🟨 Grab the previous day's user state (snapshot from Jan 13)
WITH yesterday AS (
    SELECT * FROM users_growth_accounting
    WHERE date = DATE('2023-01-13')
),

-- 🟦 Aggregate today's user activity from the events table
today AS (
    SELECT
        CAST(user_id AS TEXT) AS user_id, -- ensure consistent type
        DATE_TRUNC('day', event_time::timestamp) AS today_date, -- normalize event date
        COUNT(1) -- count of events per user (not used later, but could be)
    FROM events
    WHERE DATE_TRUNC('day', event_time::timestamp) = DATE('2023-01-14') -- today's activity
        AND user_id IS NOT NULL
    GROUP BY user_id, DATE_TRUNC('day', event_time::timestamp)
)

-- 🧠 Merge yesterday's snapshot with today's activity
SELECT
    COALESCE(t.user_id, y.user_id) AS user_id, -- support full outer join: either new or returning user

    -- First time the user was seen
    COALESCE(y.first_active_date, t.today_date) AS first_active_date,

    -- Last time the user was seen (today if active)
    COALESCE(t.today_date, y.last_active_date) AS last_active_date,

    -- Classify daily user state
    CASE
        WHEN y.user_id IS NULL THEN 'New' -- new user
        WHEN y.last_active_date = t.today_date - INTERVAL '1 day' THEN 'Retained' -- active yesterday & today
        WHEN y.last_active_date < t.today_date - INTERVAL '1 day' THEN 'Resurrected' -- came back after gap
        WHEN t.today_date IS NULL AND y.last_active_date = y.date THEN 'Churned' -- was active yesterday, inactive today
        ELSE 'Stale' -- none of the above
    END AS daily_active_state,

    -- Classify weekly user state
    CASE
        WHEN y.user_id IS NULL THEN 'New'
        WHEN y.last_active_date < t.today_date - INTERVAL '7 day' THEN 'Resurrected'
        WHEN t.today_date IS NULL AND y.last_active_date = y.date - INTERVAL '7 day' THEN 'Churned'
        WHEN COALESCE(t.today_date, y.last_active_date) + INTERVAL '7 day' >= y.date THEN 'Retained'
        ELSE 'Stale'
    END AS weekly_active_state,

    -- Accumulate all active dates into date_list
    COALESCE(y.date_list, ARRAY[]::DATE[]) ||
        CASE WHEN t.user_id IS NOT NULL THEN ARRAY[t.today_date] ELSE ARRAY[]::DATE[] END AS date_list,

    -- Record the date for this snapshot row
    COALESCE(t.today_date, y.date + INTERVAL '1 day') AS date

FROM today t
FULL OUTER JOIN yesterday y ON t.user_id = y.user_id

-- 🟧 If the user already exists, update their record; otherwise insert a new row
ON CONFLICT (user_id)
DO UPDATE SET
    first_active_date = LEAST(EXCLUDED.first_active_date, users_growth_accounting.first_active_date), -- preserve earliest date
    last_active_date = GREATEST(EXCLUDED.last_active_date, users_growth_accounting.last_active_date), -- update to latest
    daily_active_state = EXCLUDED.daily_active_state, -- overwrite with today's classification
    weekly_active_state = EXCLUDED.weekly_active_state, -- same for weekly state
    date_list = users_growth_accounting.date_list || EXCLUDED.date, -- append today’s date
    date = EXCLUDED.date; -- update snapshot date

