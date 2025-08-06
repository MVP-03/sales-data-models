{{
  config(materialized='view')
}}

with source as (
    select * from {{ source('outreach', 'raw_campaigns') }}
),

cleaned as (
    select
        id                                          as campaign_id,
        trim(campaign_name)                         as campaign_name,
        sequence_step::integer                      as sequence_step,
        trim(variant)                               as variant,
        sent::integer                               as sent,
        opened::integer                             as opened,
        replied::integer                            as replied,
        coalesce(positive_replies::integer, 0)      as positive_replies,
        coalesce(meetings_booked::integer, 0)       as meetings_booked,
        cast(send_date as date)                     as send_date,
        extract(year from cast(send_date as date))  as send_year,
        extract(quarter from cast(send_date as date)) as send_quarter

    from source
    where sent > 0
      and campaign_name is not null
)

select * from cleaned
