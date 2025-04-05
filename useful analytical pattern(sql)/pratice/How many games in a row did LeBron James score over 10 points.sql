-- WITH game_results AS (
--     SELECT
--         g.game_id,
--         g.season,
--         g.game_date_est as date,
--         gd.team_id,
--         CASE
--             WHEN gd.team_id = g.home_team_id AND g.pts_home > g.pts_away THEN 1
--             WHEN gd.team_id = g.visitor_team_id AND g.pts_away > g.pts_home THEN 1
--             ELSE 0
--         END AS is_win
--     FROM game_details gd
--     JOIN games g ON g.game_id = gd.game_id
-- ),
-- team_games AS (
--     SELECT
--         *,
--         ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY date) AS rn
--     FROM game_results
-- ),
-- rolling_90 AS (
--     SELECT
--         team_id,
--         date,
--         SUM(is_win) OVER (
--             PARTITION BY team_id
--             ORDER BY rn
--             ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
--         ) AS wins_in_90
--     FROM team_games
-- )
-- SELECT Abbreviation, MAX(wins_in_90) AS max_90_game_wins
-- FROM rolling_90
-- join teams t on rolling_90.team_id=t.team_id
-- GROUP BY Abbreviation
-- ORDER BY max_90_game_wins DESC
-- LIMIT 5;

-- select *
-- from teams
-- limit 5

--- How many games in a row did LeBron James score over 10 points?
WITH lebron_games AS (
    SELECT
        gd.game_id,
        g.game_date_est AS date,
        gd.pts,
        CASE WHEN gd.pts > 10 THEN 1 ELSE 0 END AS scored_10_plus
    FROM game_details gd
    JOIN games g ON gd.game_id = g.game_id
    WHERE gd.player_name = 'LeBron James'
),
streak_groups AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY date) -
           SUM(scored_10_plus) OVER (ORDER BY date ROWS UNBOUNDED PRECEDING) AS streak_group
    FROM lebron_games
),
filtered AS (
    SELECT * FROM streak_groups WHERE scored_10_plus = 1
),
group_counts AS (
    SELECT streak_group, COUNT(*) AS streak_length
    FROM filtered
    GROUP BY streak_group
)
SELECT MAX(streak_length) AS longest_streak
FROM group_counts;
