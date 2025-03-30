## 🏀 NBA Dataset - Data Modeling and Graph Representation 🏀

### 📌 Overview
This project models NBA data using both traditional dimensional modeling (star schema) and graph-based modeling (vertices and edges). The dataset includes teams, players, games, and their relationships, optimized for analytical queries and graph-based exploration. 📊

### 🛠️ Data Model
The dataset consists of the following key components:

#### 1. Players Table (`players.sql`)
Stores individual player details and their performance across seasons. 👤
   - **Primary Key:** (`player_name`, `current_season`)
   - **Key Columns:**
     - `player_name`: Player's name
     - `height`, `college`, `country`: Background information
     - `draft_year`, `draft_round`, `draft_number`: Draft details
     - `seasons`: Array of performance stats per season
     - `scoring_class`: Categorization based on performance (star, good, average, bad)
     - `years_since_last_active`: Tracks how long a player has been inactive
     - `is_active`: Boolean indicating if the player is currently active
     - `current_season`: The year associated with the latest data entry

#### 2. Teams Table (`teams.sql`)
Stores team-level metadata. 🏆
   - **Primary Key:** `team_id`
   - **Key Columns:**
     - `abbreviation`, `nickname`, `city`, `arena`, `year_founded`: Team details

#### 3. Games Table (`games.sql`)
Stores game-specific details including participating teams and outcomes. 🏀
   - **Primary Key:** `game_id`
   - **Key Columns:**
     - `season`, `game_date`, `home_team_id`, `away_team_id`, `home_score`, `away_score`

#### 4. Game Details Table (`game_details.sql`)
Stores detailed statistics of players in each game. 📊
   - **Primary Key:** (`player_id`, `game_id`)
   - **Key Columns:**
     - `start_position`, `pts`, `team_id`, `team_abbreviation`: Player performance per game

#### 5. Slowly Changing Dimensions (SCD) - Players History (`players_scd_table.sql`)
Implements a Type 2 Slowly Changing Dimension (SCD) to track player performance over time. 🔄
   - **Primary Key:** (`player_name`, `start_season`)
   - **Key Columns:**
     - `scoring_class`, `is_active`, `start_season`, `end_season`

#### 6. Graph Model - Vertices (`graph_ddls.sql`)
Defines the vertex structure for graph-based data exploration. 🔗
   - **Vertex Types:** player, team, game
   - **Table:** `vertices`
     - `identifier`: Unique ID (e.g., player name, team ID, game ID)
     - `type`: Enum representing the vertex type
     - `properties`: JSON storing additional metadata

#### 7. Graph Model - Edges (`graph_ddls.sql`)
Defines relationships between players, teams, and games. 🔄
   - **Edge Types:** plays_against, shares_team, plays_in, plays_on
   - **Table:** `edges`
     - `subject_identifier`, `object_identifier`: Defines relationships between entities
     - `edge_type`: Type of relationship
     - `properties`: JSON storing relationship metadata

#### 8. Player-Game Edges (`player_game_edges.sql`)
Creates edges between players and games they participated in. 🎮
   - **Edge Type:** plays_in
   - **Table:** `player_game_edges`
     - `player_id` → `game_id`
     - **Properties:** `start_position`, `pts`, `team_id`

#### 9. Player-Player Edges (`player_player_edges.sql`)
Creates edges between players who played in the same game. 🤝
   - **Edge Type:** shares_team
   - **Table:** `player_player_edges`
     - `player_id_1` → `player_id_2`
     - **Properties:** `game_id`, `team_id`

#### 10. Pipeline Query - Player SCD Update (`pipeline_player_scd_query.sql`)
Processes the player SCD table by incorporating new season data. ⏳
   - Updates player records annually
   - Assigns `scoring_class` based on the latest stats
   - Manages `years_since_last_active` tracking

#### 11. Analytical Queries (`analytical_queries.sql`)
Prepares analytical insights leveraging both relational and graph-based structures. 📊
   - **Sample Queries:**
     - Retrieve top-scoring players
     - Find most active teams
     - Explore player career trajectories
     - Graph-based shortest paths between players

---

### 🛠️ Usage
1. **DDL Setup:** Execute the schema definitions for relational tables and graph structures. 🏗️
2. **Data Ingestion:** Load data into tables using the defined structures. 💽
3. **Graph Model Execution:** Populate vertices and edges from the dataset. 🔗
4. **SCD Processing:** Update `players_scd_table` incrementally. 🔄
5. **Analytics:** Run analytical queries for insights. 📊

### 🎯 Key Takeaways
- Combines traditional star schema and graph models for flexible analysis.
- Uses `players_scd_table` for tracking historical changes.
- Graph model allows for advanced queries like shortest path and centrality. 🚀

This structure provides a comprehensive way to analyze NBA data from multiple perspectives. 📈

---

## References
This project was inspired and learned from the materials in the [Data Engineer Handbook Bootcamp](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/bootcamp/materials).

