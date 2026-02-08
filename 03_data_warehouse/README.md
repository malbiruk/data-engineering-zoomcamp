## BigQuery Setup

Creating external table:
```sql
CREATE OR REPLACE EXTERNAL TABLE `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records_external`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://dezoomcamp_hw3_2026_project-7620f717-1e5e-458a-80e/yellow_tripdata_2024-0*.parquet']
);
```

Creating materialized table:
```sql
CREATE OR REPLACE TABLE `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records`
AS
SELECT * FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records_external`;
```

## Quiz Questions

### Question 1. Counting records
What is count of records for the 2024 Yellow Taxi Data?

**Method**:

```sql
SELECT COUNT(*) FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records`;
```

**Answer**:  20,332,093

### Question 2. Data read estimation
Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.

What is the **estimated amount** of data that will be read when this query is executed on the External Table and the Table?

**Method**:
```sql
-- External table
SELECT DISTINCT PULocationID FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records_external`;

-- Materialized table
SELECT DISTINCT PULocationID FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records`;
```

**Answer**: 0 MB for the External Table and 155.12 MB for the Materialized Table

### Question 3. Understanding columnar storage
Write a query to retrieve the PULocationID from the table (not the external table) in BigQuery. Now write a query to retrieve the PULocationID and DOLocationID on the same table.

Why are the estimated number of Bytes different?

**Method**:
```sql
SELECT PULocationID FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records`;
SELECT PULocationID, DOLocationID FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records`;
```

**Answer**: BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires
reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.

### Question 4. Counting zero fare trips
How many records have a fare_amount of 0?

**Method**:
```sql
SELECT COUNT(*)
FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records`
WHERE fare_amount = 0;
```

**Answer**: 8333

### Question 5. Partitioning and clustering
What is the best strategy to make an optimized table in Big Query if your query will always filter based on tpep_dropoff_datetime and order the results by VendorID (Create a new table with this strategy)

**Method**:
```sql
CREATE OR REPLACE TABLE `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records_pt_cl`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records`;
```

**Answer**: Partition by tpep_dropoff_datetime and Cluster on VendorID

### Question 6. Partition benefits
Write a query to retrieve the distinct VendorIDs between tpep_dropoff_datetime
2024-03-01 and 2024-03-15 (inclusive)


Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. What are these values?

**Method**:
```sql
-- Not partitioned
SELECT DISTINCT VendorID FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records`
WHERE tpep_dropoff_datetime >= '2024-03-01' AND tpep_dropoff_datetime < '2024-03-16';
-- Partitioned
SELECT DISTINCT VendorID FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records_pt_cl`
WHERE tpep_dropoff_datetime >= '2024-03-01' AND tpep_dropoff_datetime < '2024-03-16';
```

**Answer**: 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table

### Question 7. External table storage
Where is the data stored in the External Table you created?

**Answer**: GCP Bucket

### Question 8. Clustering best practices
It is best practice in Big Query to always cluster your data:

**Answer**: False

### Question 9. Understanding table scans
No Points: Write a `SELECT count(*)` query FROM the materialized table you created. How many bytes does it estimate will be read? Why?

**Method**:
```sql
SELECT COUNT(*) FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_taxi_trip_records`;
```

**Answer**: 0 bytes. Amount of rows is saved as metadata on table creation/update and BigQuery doesn't perform any actual queries under the hood to retrieve the amount of rows.
