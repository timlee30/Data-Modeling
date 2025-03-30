---base query

WITH last_season AS (
    SELECT * FROM actors
    WHERE current_year = 2009
), 
this_season AS (
    SELECT * FROM actor_films
    WHERE year = 2010
)
-- ✅ INSERT into `actors`

INSERT INTO actors (
            actor, actorid, filmid, films, quality_class, is_active, current_year
        ) 

SELECT
    COALESCE(ls.actor, ts.actor) AS actor,
    COALESCE(ls.actorid, ts.actorid) AS actorid,
    COALESCE(ls.filmid, ts.filmid) AS filmid, 
    COALESCE(ls.films, ARRAY[]::film_info[]) 
        || CASE WHEN ts.filmid IS NOT NULL THEN
            ARRAY[ROW(
                ts.film,
                ts.votes,
                ts.rating,
                ts.filmid
            )::film_info]
            ELSE ARRAY[]::film_info[] END AS films,
    CASE
        WHEN ts.filmid IS NOT NULL THEN
            (CASE 
                WHEN AVG(ts.rating) OVER(PARTITION BY ts.actor) > 8 THEN 'star'
                WHEN AVG(ts.rating) OVER(PARTITION BY ts.actor) > 7 THEN 'good'
                WHEN AVG(ts.rating) OVER(PARTITION BY ts.actor) > 6 THEN 'average'
                ELSE 'bad' 
            END)::quality_class
        ELSE ls.quality_class
    END AS quality_class,
    CASE 
        WHEN ts.filmid IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS is_active,
    2010 AS current_year
FROM last_season ls
FULL OUTER JOIN this_season ts
ON ls.actorid = ts.actorid 
AND ls.filmid = ts.filmid; 





select min(year),max(year)
from actor_films


--loop 

-- DO $$ 
-- DECLARE 
--     year_start INTEGER := 1970; 
--     year_end INTEGER := 2021; 
-- BEGIN 
--     WHILE year_start <= year_end LOOP 

--         RAISE NOTICE 'Processing year: %', year_start;
        
--         WITH last_season AS (
--             SELECT * FROM actors
--             WHERE current_year = year_start - 1
--         ), 
--         this_season AS (
--             SELECT * FROM actor_films
--             WHERE year = year_start
--         )
--         -- ✅ Insert into `actors`
--         INSERT INTO actors (
--             actor, actorid, filmid, films, quality_class, is_active, current_year
--         ) 
--         SELECT
--             COALESCE(ls.actor, ts.actor) AS actor,
--             COALESCE(ls.actorid, ts.actorid) AS actorid,
--             COALESCE(ts.filmid, ts.filmid) AS filmid,  -- ✅ Ensuring unique film per actor per year
--             COALESCE(ls.films, ARRAY[]::film_info[]) 
--                 || CASE WHEN ts.filmid IS NOT NULL THEN
--                     ARRAY[ROW(
--                         ts.film,
--                         ts.votes,
--                         ts.rating,
--                         ts.filmid
--                     )::film_info]
--                     ELSE ARRAY[]::film_info[] END AS films,
--             CASE
--                 WHEN ts.filmid IS NOT NULL THEN
--                     (CASE 
--                         WHEN AVG(ts.rating) OVER(PARTITION BY ts.actor) > 8 THEN 'star'
--                         WHEN AVG(ts.rating) OVER(PARTITION BY ts.actor) > 7 THEN 'good'
--                         WHEN AVG(ts.rating) OVER(PARTITION BY ts.actor) > 6 THEN 'average'
--                         ELSE 'bad' 
--                     END)::quality_class
--                 ELSE ls.quality_class
--             END AS quality_class,
--             CASE 
--                 WHEN ts.filmid IS NOT NULL THEN TRUE
--                 ELSE FALSE
--             END AS is_active,
--             year_start AS current_year
--         FROM last_season ls
--         FULL OUTER JOIN this_season ts
--         ON ls.actorid = ts.actorid 
--         AND ls.filmid = ts.filmid
--         ON CONFLICT (actorid, filmid, current_year) DO NOTHING;  -- ✅ Prevents duplicate inserts

--         -- ✅ Move to next year
--         year_start := year_start + 1;

--     END LOOP;
-- END $$;



