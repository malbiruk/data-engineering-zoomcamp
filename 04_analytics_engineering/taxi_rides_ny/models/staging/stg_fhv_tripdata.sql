select
    -- identifiers
    dispatching_base_num,
    cast(pulocationid as int) as pickup_location_id,
    cast(dolocationid as int) as dropoff_location_id,

    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    cast(sr_flag as int) as sr_flag,
    affiliated_base_number

from {{ source('raw', 'fhv_tripdata') }}
where dispatching_base_num is not null
