{{
  config(materialized='table')
}}

with leads as (
    select * from {{ ref('int_lead_scores') }}
),

pipeline as (
    select
        lead_id,
        email,
        company,
        domain,
        industry,
        employee_count,
        country,
        icp_score,
        fit_label,

        -- Tier assignment for outreach prioritisation
        case
            when icp_score >= 80 then 1
            when icp_score >= 60 then 2
            when icp_score >= 40 then 3
            else 4
        end as icp_tier,

        current_timestamp as modeled_at

    from leads
)

select * from pipeline
