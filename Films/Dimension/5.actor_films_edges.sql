WITH acted_in_edges AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY actorid, filmid ORDER BY year DESC) AS row_num
    FROM actor_films
)
INSERT INTO edges_films (subject_identifier, subject_type, object_identifier, object_type, edge_type, properties)
SELECT 
    actorid AS subject_identifier,
    'actor'::vertex_type_film_data AS subject_type,
    filmid AS object_identifier,
    'films'::vertex_type_film_data AS object_type,
    'acted_in'::edge_type_film_data AS edge_type,
    json_build_object('year', year) AS properties
	
FROM acted_in_edges
WHERE row_num = 1;



select *
from edges_films
where edge_type='acted_in'

where 