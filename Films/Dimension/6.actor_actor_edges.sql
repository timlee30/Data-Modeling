WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY actorid, filmid) AS row_num
    FROM actor_films
),
filtered AS (
    SELECT * FROM deduped WHERE row_num = 1
),
  aggregated AS (
    SELECT
        f1.actorid AS actor1,
        f2.actorid AS actor2,
        COUNT(DISTINCT f1.filmid) AS num_films
    FROM filtered f1
    JOIN filtered f2 
        ON f1.filmid = f2.filmid
        AND f1.actorid > f2.actorid  -- Prevent duplicate pairs
    GROUP BY f1.actorid, f2.actorid
)
INSERT INTO edges_films (
    subject_identifier,
    subject_type,
    object_identifier,
    object_type,
    edge_type,
    properties
)
select 
 	actor1 AS subject_identifier,
    'actor'::vertex_type_film_data AS subject_type,
    actor2 AS object_identifier,
    'actor'::vertex_type_film_data AS object_type,
    'coacted_with'::edge_type_film_data AS edge_type,
    json_build_object('num_films', num_films) AS properties
FROM aggregated;




select *
from edges_films
where edge_type='acted_in'