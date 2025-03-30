WITH actor_pairs AS (
    SELECT 
        e1.subject_identifier AS actor_1, 
        e2.subject_identifier AS actor_2, 
        COUNT(e1.object_identifier) AS films_together
    FROM edges_films e1
    JOIN edges_films e2
    ON e1.object_identifier = e2.object_identifier  -- Same film
    AND e1.subject_identifier < e2.subject_identifier  -- Avoid duplicates (A-B vs B-A)
    WHERE e1.edge_type = 'acted_in' AND e2.edge_type = 'acted_in'
    GROUP BY 1, 2
)
SELECT * , af1.actor, af2.actor
FROM actor_pairs ap
join actor_films af1 on ap.actor_1= af1.actorid
join actor_films af2 on ap.actor_2= af2.actorid
ORDER BY films_together DESC
LIMIT 10;


