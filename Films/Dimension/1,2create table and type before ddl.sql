select *
from actor_films


 CREATE TYPE quality_class AS
     ENUM ('bad', 'average', 'good', 'star');


CREATE TYPE film_info AS (
    film TEXT,
    votes REAL,
    rating REAL,
    filmid TEXT
);





CREATE TABLE actors (
    actor TEXT,  
    actorid TEXT,  
    filmid TEXT,  -- ✅ Now added to uniquely identify films per actor
    films film_info[],  
    quality_class quality_class,  
    is_active BOOLEAN,  
    current_year INTEGER,  
    PRIMARY KEY (actorid, filmid, current_year)  
);

SELECT * FROM actor_films
where filmid is null





