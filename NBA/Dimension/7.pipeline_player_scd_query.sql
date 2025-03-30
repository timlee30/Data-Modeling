WITH last_season AS (
    SELECT * FROM players
    WHERE current_season = 2021
), 
this_season AS (
    SELECT * FROM player_seasons
    WHERE season = 2022
)
INSERT INTO players (
    player_name, height, college, country, draft_year, draft_round, draft_number, 
    seasons, scoring_class, years_since_last_active, is_active, current_season
) 
SELECT
    COALESCE(ls.player_name, ts.player_name) AS player_name,
    COALESCE(ls.height, ts.height) AS height,
    COALESCE(ls.college, ts.college) AS college,
    COALESCE(ls.country, ts.country) AS country,
    COALESCE(ls.draft_year, ts.draft_year) AS draft_year,
    COALESCE(ls.draft_round, ts.draft_round) AS draft_round,
    COALESCE(ls.draft_number, ts.draft_number) AS draft_number,
    COALESCE(ls.seasons, ARRAY[]::season_stats[]) 
        || CASE WHEN ts.season IS NOT NULL THEN
            ARRAY[ROW(ts.season, ts.pts, ts.ast, ts.reb, ts.weight)::season_stats]
            ELSE ARRAY[]::season_stats[] END AS seasons,
    CASE
        WHEN ts.season IS NOT NULL THEN
            (CASE 
                WHEN ts.pts > 20 THEN 'star'
                WHEN ts.pts > 15 THEN 'good'
                WHEN ts.pts > 10 THEN 'average'
                ELSE 'bad' 
            END)::scoring_class



        ELSE ls.scoring_class
    END AS scoring_class,
    -- ✅ Now including `years_since_last_active` as INTEGER
    CASE 
        WHEN ts.season IS NOT NULL THEN 0  -- Reset to 0 if active
        ELSE COALESCE(ls.years_since_last_active, 0) + 1  -- Increase if inactive
    END AS years_since_last_active,
    -- ✅ Ensure `is_active` remains BOOLEAN
    CASE 
        WHEN ts.season IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS is_active,
    2022 AS current_season
FROM last_season ls
FULL OUTER JOIN this_season ts
ON ls.player_name = ts.player_name;



-- select min(season)  from player_seasons

--  recursive 














