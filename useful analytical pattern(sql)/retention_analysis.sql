SELECT
       date - first_active_date AS days_since_first_active,
       CAST(COUNT(CASE
           WHEN daily_active_state
                    IN ('Retained', 'Resurrected', 'New') THEN 1 END) AS REAL)/COUNT(1) as pct_active,
       COUNT(1) AS users_on_day 
	   FROM users_growth_accounting
GROUP BY date - first_active_date
order by date - first_active_date

-- 📅 Day 4 since first_active:

-- These users all signed up 4 days ago

-- You’re now checking in on them on their Day 4

-- 👥 There are 45 users from that cohort who have a row in the users_growth_accounting table on their Day 4

-- 🔥 Of those, only ~9% were active on that Day 4 — meaning:

-- Their daily_active_state was 'New', 'Retained', or 'Resurrected'

-- 🧊 The rest (91%) were likely 'Stale' or 'Churned' — i.e., they didn’t return or haven’t come back yet