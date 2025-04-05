-- SELECT
--     gd.player_name,
--     gd.team_id,
--     g.season,
--     SUM(gd.pts) AS total_points,

--     COUNT(DISTINCT g.game_id) FILTER (
--         WHERE
--             (gd.team_id = g.home_team_id AND g.pts_home > g.pts_away)
--             OR
--             (gd.team_id = g.visitor_team_id AND g.pts_away > g.pts_home)
--     ) AS games_won,

--     CASE
--         WHEN GROUPING(gd.player_name) = 0 AND GROUPING(gd.team_id) = 0 THEN 'player_team'
--         WHEN GROUPING(gd.player_name) = 0 AND GROUPING(g.season) = 0 THEN 'player_season'
--         WHEN GROUPING(gd.team_id) = 0 THEN 'team_only'
--         ELSE 'other'
--     END AS aggregation_level

-- FROM game_details gd
-- JOIN games g ON g.game_id = gd.game_id

-- GROUP BY GROUPING SETS (
--     (gd.player_name, gd.team_id),
--     (gd.player_name, g.season),
--     (gd.team_id)
-- )
-- ORDER BY aggregation_level, total_points DESC NULLS LAST;


----------------------------------------




-- SELECT *
-- FROM (
--     SELECT
--     gd.player_name,
--     gd.team_id,
--     g.season,
--     SUM(gd.pts) AS total_points,

--     COUNT(DISTINCT g.game_id) FILTER (
--         WHERE
--             (gd.team_id = g.home_team_id AND g.pts_home > g.pts_away)
--             OR
--             (gd.team_id = g.visitor_team_id AND g.pts_away > g.pts_home)
--     ) AS games_won,

--     CASE
--         WHEN GROUPING(gd.player_name) = 0 AND GROUPING(gd.team_id) = 0 THEN 'player_team'
--         WHEN GROUPING(gd.player_name) = 0 AND GROUPING(g.season) = 0 THEN 'player_season'
--         WHEN GROUPING(gd.team_id) = 0 THEN 'team_only'
--         ELSE 'other'
--     END AS aggregation_level

-- FROM game_details gd
-- JOIN games g ON g.game_id = gd.game_id

-- GROUP BY GROUPING SETS (
--     (gd.player_name, gd.team_id),
--     (gd.player_name, g.season),
--     (gd.team_id)
-- )

-- ) sub
-- WHERE aggregation_level = 'player_team'
-- and total_points is not null
-- ORDER BY total_points DESC
-- LIMIT 1;

-- 1. Who scored the most points playing for one team?
-- "Giannis Antetokounmpo" is the most

---------------------------------------------------------

-- SELECT *
-- FROM (
--    SELECT
--     gd.player_name,
--     gd.team_id,
--     g.season,
--     SUM(gd.pts) AS total_points,

--     COUNT(DISTINCT g.game_id) FILTER (
--         WHERE
--             (gd.team_id = g.home_team_id AND g.pts_home > g.pts_away)
--             OR
--             (gd.team_id = g.visitor_team_id AND g.pts_away > g.pts_home)
--     ) AS games_won,

--     CASE
--         WHEN GROUPING(gd.player_name) = 0 AND GROUPING(gd.team_id) = 0 THEN 'player_team'
--         WHEN GROUPING(gd.player_name) = 0 AND GROUPING(g.season) = 0 THEN 'player_season'
--         WHEN GROUPING(gd.team_id) = 0 THEN 'team_only'
--         ELSE 'other'
--     END AS aggregation_level

-- FROM game_details gd
-- JOIN games g ON g.game_id = gd.game_id

-- GROUP BY GROUPING SETS (
--     (gd.player_name, gd.team_id),
--     (gd.player_name, g.season),
--     (gd.team_id)
-- )

-- ) sub
-- WHERE aggregation_level = 'player_season'
-- and total_points is not null
-- ORDER BY total_points DESC
-- LIMIT 1;


-- 2. Who scored the most points in a single season?


-- "James Harden" 3247



-----------------------------------

-- Team with most total wins
SELECT *
FROM (
    SELECT
    gd.player_name,
    gd.team_id,
    g.season,
    SUM(gd.pts) AS total_points,

    COUNT(DISTINCT g.game_id) FILTER (
        WHERE
            (gd.team_id = g.home_team_id AND g.pts_home > g.pts_away)
            OR
            (gd.team_id = g.visitor_team_id AND g.pts_away > g.pts_home)
    ) AS games_won,

    CASE
        WHEN GROUPING(gd.player_name) = 0 AND GROUPING(gd.team_id) = 0 THEN 'player_team'
        WHEN GROUPING(gd.player_name) = 0 AND GROUPING(g.season) = 0 THEN 'player_season'
        WHEN GROUPING(gd.team_id) = 0 THEN 'team_only'
        ELSE 'other'
    END AS aggregation_level

FROM game_details gd
JOIN games g ON g.game_id = gd.game_id

GROUP BY GROUPING SETS (
    (gd.player_name, gd.team_id),
    (gd.player_name, g.season),
    (gd.team_id)
)

) sub
WHERE aggregation_level = 'team_only'
ORDER BY games_won DESC
LIMIT 1;



