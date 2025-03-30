CREATE TYPE vertex_type_film_data
    AS ENUM('films', 'actor');


CREATE TABLE vertices_film (
    identifier TEXT,
    type vertex_type_film_data,
    properties JSON,
    PRIMARY KEY (identifier, type)
);


CREATE TYPE edge_type_film_data AS ENUM('acted_in');


CREATE TABLE edges_films (
    subject_identifier TEXT,
    subject_type vertex_type_film_data,
    object_identifier TEXT,
    object_type vertex_type_film_data,
    edge_type edge_type_film_data,
    properties JSON,
    PRIMARY KEY (subject_identifier,
                subject_type,
                object_identifier,
                object_type,
                edge_type)
)