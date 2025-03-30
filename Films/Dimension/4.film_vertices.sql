-- insert films to vertices_film

WITH films_deduped AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY filmid ORDER BY year DESC) AS row_num
    FROM actor_films
)
INSERT INTO vertices_film (identifier, type, properties)
SELECT 
    filmid AS identifier,
    'films'::vertex_type_film_data AS type,
    json_build_object(
        'title', film,
        'release_year', year,
        'votes', votes,
        'rating', rating
    ) AS properties
FROM films_deduped
WHERE row_num = 1;  -- ✅ Keeps only one row per filmid

--insert actors to  vertices_film
select *
from vertices_film 
