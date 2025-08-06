{{
  config(materialized='view')
}}

with source as (
    select * from {{ source('crm', 'raw_leads') }}
),

cleaned as (
    select
        id                                          as lead_id,
        lower(trim(email))                          as email,
        trim(first_name)                            as first_name,
        trim(last_name)                             as last_name,
        lower(trim(company))                        as company,
        lower(trim(domain))                         as domain,
        trim(title)                                 as job_title,
        trim(industry)                              as industry,
        employee_count::integer                     as employee_count,
        annual_revenue_usd::bigint                  as annual_revenue_usd,
        lower(trim(country))                        as country,
        has_api::boolean                            as has_api,
        cast(created_at as timestamp)               as created_at,
        cast(updated_at as timestamp)               as updated_at

    from source
    where email is not null
      and email like '%@%'
      and id is not null
)

select * from cleaned
