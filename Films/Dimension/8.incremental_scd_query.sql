-- CREATE TYPE scd_type_actors AS (
--     quality_class quality_class,  
--     is_active BOOLEAN,
--     start_year INTEGER,  
--     end_year INTEGER 
-- );


-- CREATE TABLE IF NOT EXISTS actors_history_scd (
--     actor TEXT,
--     actorid TEXT,
--     quality_class quality_class,  
--     is_active BOOLEAN,
--     start_year INTEGER,  
--     end_year INTEGER,
--     current_year INTEGER,
--     PRIMARY KEY (actorid, start_year)
-- );


WITH last_year_scd AS (
    SELECT * FROM actors_history_scd
    WHERE current_year = 1969
),
historical_scd AS (
    SELECT
        actor,
        actorid,
        quality_class,
        is_active,
        start_year,
        end_year
    FROM actors_history_scd
    WHERE current_year = 1969
    AND end_year < 1969
),
this_year_data AS (
    SELECT * FROM actors
    WHERE current_year = 1970
),
unchanged_records AS (
    SELECT
        ty.actor,
        ty.actorid,
        ty.quality_class,
        ty.is_active,
        ly.start_year,
        ty.current_year AS end_year
    FROM this_year_data ty
    JOIN last_year_scd ly
    ON ly.actorid = ty.actorid
    WHERE ty.quality_class = ly.quality_class
    AND ty.is_active = ly.is_active
),
changed_records AS (
    SELECT
        ty.actor,
        ty.actorid,
        UNNEST(ARRAY[
            ROW(
                ly.quality_class,
                ly.is_active,
                ly.start_year,
                ly.end_year
            )::scd_type_actors,
            ROW(
                ty.quality_class,
                ty.is_active,
                ty.current_year,
                ty.current_year
            )::scd_type_actors
        ]) AS records
    FROM this_year_data ty
    LEFT JOIN last_year_scd ly
    ON ly.actorid = ty.actorid
    WHERE (ty.quality_class <> ly.quality_class
        OR ty.is_active <> ly.is_active)
),
unnested_changed_records AS (
    SELECT actor,
           actorid,
           (records::scd_type_actors).quality_class,
           (records::scd_type_actors).is_active,
           (records::scd_type_actors).start_year,
           (records::scd_type_actors).end_year
    FROM changed_records
),
new_records AS (
    SELECT
        ty.actor,
        ty.actorid,
        ty.quality_class,
        ty.is_active,
        ty.current_year AS start_year,
        ty.current_year AS end_year
    FROM this_year_data ty
    LEFT JOIN last_year_scd ly
    ON ty.actorid = ly.actorid
    WHERE ly.actorid IS NULL
)
--INSERT INTO actors_history_scd
SELECT distinct *, 1970 AS current_year FROM (
    SELECT * FROM historical_scd
    UNION ALL
    SELECT * FROM unchanged_records
    UNION ALL
    SELECT * FROM unnested_changed_records
    UNION ALL
    SELECT * FROM new_records
) a;


-- select * from actors_history_scd
