# 📘 Fact Data Modeling - Lab Guide

## 📌 Overview
This guide provides a detailed breakdown of the lab files used in **Week 2: Fact Data Modeling**. Each SQL script is designed to transform, aggregate, and optimize data for analytical processing. The key focus areas include **tracking user activity, summarizing device metrics, and generating efficient fact tables**.

## 🛠 Lab Files and Descriptions

### 1️⃣ `analyze_datelist.sql`
**Purpose:**
- Converts user activity dates into a compact **bitwise integer representation (`datelist_int`)**.
- Uses **bitwise operations** to efficiently store last **32 days** of activity.

**Key Logic:**
- Generates a **series of dates** for the last 32 days.
- Uses the **BIT_COUNT** function to extract weekly/monthly active users.

**Referenced In:**
- `generate_datelist.sql`
- `user_datelist_int`

---
### 2️⃣ `array_metrics_analysis.sql`
**Purpose:**
- Aggregates daily **site hit metrics** into an **array format** for efficient storage and querying.
- Uses **cumulative array-based storage** for storing daily metrics.

**Key Logic:**
- Extracts daily user hits from `events`.
- Updates `array_metrics` table with new daily counts.
- Uses `ARRAY_FILL` to populate missing values.

**Referenced In:**
- `generate_monthly_array_metrics.sql`

---
### 3️⃣ `generate_datelist.sql`
**Purpose:**
- Generates the `datelist_int` column from `device_activity_datelist`.
- Uses **bitwise operations** to efficiently store user activity history.

**Key Logic:**
- Extracts active days from the array field.
- Uses `POW(2, 32 - days_since)` to encode activity.
- Inserts transformed data into `user_datelist_int`.

**Referenced In:**
- `user_datelist_int`

---
### 4️⃣ `generate_monthly_array_metrics.sql`
**Purpose:**
- Populates the `monthly_user_site_hits` table with **daily user activity metrics**.

**Key Logic:**
- Extracts **user event logs** and **aggregates daily hit counts**.
- Uses `ARRAY_AGG()` to maintain **cumulative daily site hit metrics**.
- Appends new data instead of overwriting existing records.

**Referenced In:**
- `array_metrics_analysis.sql`

---
### 5️⃣ `quick_sum_device_hits.sql`
**Purpose:**
- Performs **quick aggregations** of device-based user activity.
- Extracts **total site hits per day** from the dataset.

**Key Logic:**
- Uses **SUM(hit_array[i])** to retrieve daily hit counts.
- Aggregates across `monthly_user_site_hits`.
- Provides an optimized query for fast device activity analysis.

**Referenced In:**
- `generate_monthly_array_metrics.sql`

---
### 6️⃣ `user_cumulated_populate.sql`
**Purpose:**
- **Tracks daily user activity** over time.
- Maintains a **cumulative record** of active days per user.

**Key Logic:**
- Extracts users **from events logs**.
- Updates `users_cumulated` **by appending active dates**.
- Uses `ARRAY_APPEND()` to store new activity records efficiently.

**Referenced In:**
- `analyze_datelist.sql`
- `generate_datelist.sql`



---
## 📝 Key Takeaways
✅ **Compact Data Representation:** Uses **bitwise encoding** for user activity tracking.  
✅ **Optimized Aggregation:** Stores daily site hits as **arrays** to reduce table scans.  
✅ **Incremental Data Updates:** Ensures data is **appended, not overwritten**, for accurate historical analysis.  
✅ **Performance Optimization:** Leverages **indexed bitwise operations** for quick filtering of active users.



