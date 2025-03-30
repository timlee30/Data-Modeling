## 📚 Overview
This project focuses on the aggregation and analysis of user and host activity data. Through a series of tasks, we process raw event data to derive meaningful insights, culminating in the creation of a reduced fact table for efficient querying.

## 🛠️ Tasks and Implementations

### 1. Building `device_activity_datelist`
- **Objective:** Create a table to log the dates each device was active.
- **Implementation:** Developed a SQL query to populate `device_activity_datelist` by referencing `analyze_datelist.sql` from the lab.

### 2. Utilizing `user_devices_cumulated.sql`
- **Objective:** Determine if the query from `user_devices_cumulated.sql` is used to build `device_activity_datelist`.
- **Implementation:** Confirmed that the aggregation logic aligns with the structures defined in `user_devices_cumulated.sql`.

### 3. Aggregation and Presentation
- **Objective:** Ensure the aggregated data is presented in alignment with lab standards.
- **Implementation:** Modified the query to match the expected output format, considering that the dataset contains only January data.

### 4. Generating `datelist_int`
- **Objective:** Convert the `device_activity_datelist` column into a `datelist_int` column.
- **Implementation:** Referenced `generate_datelist.sql` to create a query that transforms `device_activity_datelist` into `datelist_int`, ensuring compatibility with the dataset's structure.

### 5. Creating `device_datelist_int` Table
- **Objective:** Design a table to store the integer representation of device activity dates.
- **Implementation:** Developed a Data Definition Language (DDL) script to create the `device_datelist_int` table, referencing the structure of `user_datelist_int`. Adjusted data types as necessary based on previous experiences.

### 6. Analyzing `datelist_int`
- **Objective:** Interpret the `datelist_int` to determine user activity metrics.
- **Implementation:** Utilized bitwise operations to calculate metrics such as monthly active days and weekly active days, ensuring alignment with the analysis methods outlined in `analyze_datelist.sql`.

### 7. Creating `host_activity_reduced` Table
- **Objective:** Design a reduced fact table to store monthly aggregated host activity data.
- **Implementation:** Developed a DDL script to create the `host_activity_reduced` table, which includes columns for month, host, hit array (total hits per day), and unique visitors array (distinct user counts per day).

### 8. Incremental Loading of `host_activity_reduced`
- **Objective:** Implement an incremental query to load data into `host_activity_reduced` on a day-by-day basis.
- **Implementation:** Referenced `array_metrics_analysis.sql` to create a query that updates `host_activity_reduced` incrementally, ensuring that new daily data is appended without overwriting existing records.

## 📈 Key Outcomes
- **Data Structuring:** Successfully transformed raw event data into structured tables that facilitate efficient querying and analysis.
- **Incremental Data Loading:** Implemented mechanisms to update aggregated data tables incrementally, preserving historical data while incorporating new information.
- **Activity Analysis:** Developed queries to analyze user and host activity patterns, providing insights into engagement metrics over specified timeframes.

