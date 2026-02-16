{{ config(materialized='table') }}

-- Deduplicate enriched trip data
-- Only 2.7M of 115M rows are in duplicate groups, so we isolate those
-- and dedup only them — avoids sorting/hashing all 115M rows

with group_counts as (
    select vendor_id, pickup_datetime, pickup_location_id, service_type
    from {{ ref('int_trips_enriched') }}
    group by vendor_id, pickup_datetime, pickup_location_id, service_type
    having count(*) > 1
),

-- Non-duplicates: the vast majority, passed through untouched
clean_rows as (
    select e.*
    from {{ ref('int_trips_enriched') }} e
    anti join group_counts g
        on e.vendor_id = g.vendor_id
        and e.pickup_datetime = g.pickup_datetime
        and e.pickup_location_id = g.pickup_location_id
        and e.service_type = g.service_type
),

-- Duplicates: only ~2.7M groups, dedup with row_number
duped_rows as (
    select e.*
    from {{ ref('int_trips_enriched') }} e
    semi join group_counts g
        on e.vendor_id = g.vendor_id
        and e.pickup_datetime = g.pickup_datetime
        and e.pickup_location_id = g.pickup_location_id
        and e.service_type = g.service_type
    qualify row_number() over(
        partition by e.vendor_id, e.pickup_datetime, e.pickup_location_id, e.service_type
        order by e.dropoff_datetime
    ) = 1
)

select * from clean_rows
union all
select * from duped_rows
