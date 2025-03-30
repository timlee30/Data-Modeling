## 🎬 Film Dataset - Data Modeling and Graph Representation 🎥

### 📌 Overview
This project models film industry data using both traditional dimensional modeling (star schema) and graph-based modeling (vertices and edges). The dataset includes actors, films, and their relationships, optimized for analytical queries and graph-based exploration. 📊

### 🌆 Data Model
The dataset consists of the following key components:

#### 1. Actors Table (`actors.sql`)
Stores individual actor details and their film history. 👨‍🎥
   - **Primary Key:** (`actorid`, `current_year`)
   - **Key Columns:**
     - `actor`: Actor's name
     - `actorid`: Unique identifier for each actor
     - `films`: Array of structured film data (`film_info[]`)
     - `quality_class`: Categorization based on recent film ratings (star, good, average, bad)
     - `is_active`: Boolean indicating if the actor is currently active
     - `current_year`: The year associated with the latest data entry

#### 2. Films Table (`films.sql`)
Stores metadata about films. 🎬
   - **Primary Key:** `filmid`
   - **Key Columns:**
     - `title`: Name of the film
     - `year`: Release year
     - `votes`: Number of user votes
     - `rating`: IMDb rating

#### 3. Slowly Changing Dimensions (SCD) - Actor History (`actors_scd_table.sql`)
Implements a Type 2 Slowly Changing Dimension (SCD) to track actor performance over time. 🔄
   - **Primary Key:** (`actorid`, `start_year`)
   - **Key Columns:**
     - `quality_class`, `is_active`, `start_year`, `end_year`

#### 4. Graph Model - Vertices (`graph_ddls.sql`)
Defines the vertex structure for graph-based data exploration. 🔗
   - **Vertex Types:** actor, film
   - **Table:** `vertices_film`
     - `identifier`: Unique ID (e.g., `actorid`, `filmid`)
     - `type`: Enum representing the vertex type
     - `properties`: JSON storing additional metadata

#### 5. Graph Model - Edges (`graph_ddls.sql`)
Defines relationships between actors and films. 🔄
   - **Edge Types:** `acted_in`
   - **Table:** `edges_films`
     - `subject_identifier`, `object_identifier`: Defines relationships between entities
     - `edge_type`: Type of relationship
     - `properties`: JSON storing relationship metadata

#### 6. Actor-Film Edges (`actor_film_edges.sql`)
Creates edges between actors and the films they appeared in. 🎥
   - **Edge Type:** `acted_in`
   - **Table:** `edges_films`
     - `actorid` ➔ `filmid`
     - **Properties:** `year`

#### 7. Actor-Actor Edges (`actor_actor_edges.sql`)
Creates edges between actors who co-starred in the same film. 👨‍🎥👩‍🎥
   - **Edge Type:** `co_acted`
   - **Table:** `actor_actor_edges`
     - `actorid_1` ➔ `actorid_2`
     - **Properties:** `filmid`, `year`

#### 8. Pipeline Query - Actor SCD Update (`pipeline_actor_scd_query.sql`)
Processes the actor SCD table by incorporating new yearly data. ⏳
   - Updates actor records annually
   - Assigns `quality_class` based on the latest film ratings
   - Manages `is_active` status

#### 9. Analytical Queries (`analytical_queries.sql`)
Prepares analytical insights leveraging both relational and graph-based structures. 📊
   - **Sample Queries:**
     - Retrieve top-rated films of an actor
     - Find actors who frequently co-star together
     - Explore actor career trajectories
     - Graph-based shortest paths between actors

---

### 🛠️ Usage
1. **DDL Setup:** Execute the schema definitions for relational tables and graph structures. 🛠️
2. **Data Ingestion:** Load data into tables using the defined structures. 💽
3. **Graph Model Execution:** Populate vertices and edges from the dataset. 🔗
4. **SCD Processing:** Update `actors_scd_table` incrementally. 🔄
5. **Analytics:** Run analytical queries for insights. 📊

### 🌈 Key Takeaways
- Combines traditional star schema and graph models for flexible analysis.
- Uses `actors_scd_table` for tracking historical changes.
- Graph model allows for advanced queries like shortest path and centrality. 🚀

This structure provides a comprehensive way to analyze film industry data from multiple perspectives. 🎥📊

---

## References
This project was inspired and learned from the materials in the [Data Engineer Handbook Bootcamp](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/bootcamp/materials).

