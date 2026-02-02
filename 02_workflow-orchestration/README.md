## Assignment

So far in the course, we processed data for the year 2019 and 2020. Your task is to extend the existing flows to include data for the year 2021.

**Method**:

1. In current folder do `docker compose up -d` to fire up Kestra at `http://localhost:8080`.
2. Create a new flow there -- copy-paste from `09_gcp_taxi_scheduled.yaml`.
3. Input variables into KV Store (`GCP_BUCKET_NAME`, `GCP_CREDS`, `GCP_DATASET`, `GCP_PROJECT_ID`, `GCP_LOCATION`).
4. Go to Flows > `09_gcp_taxi_scheduled` > Triggers, select backfill execution for `green_schedule` from Jan 1, 2019 to Jul 2, 2021. Same for `yellow_schedule` (I didn't process data for 2019 and 2020, otherwise can select Jan 1, 2021 as first date to backfill).

## Quiz Questions

### Question 1
Within the execution for `Yellow` Taxi data for the year `2020` and month `12`: what is the uncompressed file size (i.e. the output file `yellow_tripdata_2020-12.csv` of the `extract` task)?

**Method**:

1. In Kestra go to Flows > `09_gcp_taxi_scheduled` > Executions
2. Find Execution with labels `file:yellow_tripdata_2020-12.csv` `taxi:yellow`
3. Go to Metrics, find `upload_to_gcs` `file.size`

**Answer**: 134.5 MiB

### Question 2
What is the rendered value of the variable `file` when the inputs `taxi` is set to `green`, `year` is set to `2020`, and `month` is set to `04` during execution?

**Method**:

The file value is `"{{inputs.taxi}}_tripdata_{{trigger.date | date('yyyy-MM')}}.csv"`. As `render` substitutes variables with their values, the answer is `green_tripdata_2020-04.csv`.

**Answer**: `green_tripdata_2020-04.csv`

### Question 3
How many rows are there for the `Yellow` Taxi data for all CSV files in the year 2020?

**Method**:

I used this query in BigQuery:

```sql
SELECT
  COUNT(1)
FROM
  `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_tripdata`
WHERE
  tpep_pickup_datetime >= '2020-01-01' AND tpep_pickup_datetime < '2021-01-01';
```

And got 24648663.

**Answer**: 24,648,499

### Question 4
How many rows are there for the `Green` Taxi data for all CSV files in the year 2020?

**Method**:

```sql
SELECT
  COUNT(1)
FROM
  `project-7620f717-1e5e-458a-80e.demo_dataset.green_tripdata`
WHERE
  lpep_pickup_datetime >= '2020-01-01' AND lpep_pickup_datetime < '2021-01-01';
```

Got 1734039.

**Answer**: 1,734,051

### Question 5
How many rows are there for the `Yellow` Taxi data for the March 2021 CSV file

**Method**:

```sql
SELECT COUNT(1)
FROM `project-7620f717-1e5e-458a-80e.demo_dataset.yellow_tripdata_2021_03`;
```

**Answer**: 1,925,152

### Question 6
How would you configure the timezone to New York in a Schedule trigger?

**Method**:

Check documentation on Schedule trigger config, it says `timezone` property uses the [List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). Look up "New York" there.

**Answer**: Add a `timezone` property set to `America/New_York` in the `Schedule` trigger configuration
