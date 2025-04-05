WITH last_year AS (
    SELECT
        player_name,
        is_active AS was_active,
        current_season AS season
    FROM players_scd_table
),
this_year AS (
    SELECT
        player_name,
        is_active AS is_active,
        current_season AS season
    FROM players_scd_table
),
transitions AS (
    SELECT
        COALESCE(this_year.player_name, last_year.player_name) AS player_name,
        last_year.season AS last_season,
        this_year.season AS current_season,
        last_year.was_active,
        this_year.is_active,
        CASE
            WHEN last_year.was_active IS NULL AND this_year.is_active = true THEN 'New'
            WHEN last_year.was_active = true AND this_year.is_active = true THEN 'Continued Playing'
            WHEN last_year.was_active = true AND this_year.is_active = false THEN 'Retired'
            WHEN last_year.was_active = false AND this_year.is_active = true THEN 'Returned from Retirement'
            WHEN last_year.was_active = false AND this_year.is_active = false THEN 'Stayed Retired'
            ELSE 'Unknown'
        END AS state_transition
    FROM this_year
    FULL OUTER JOIN last_year
        ON this_year.player_name = last_year.player_name
       AND this_year.season = last_year.season + 1
)

SELECT *
FROM transitions
ORDER BY player_name, current_season;


