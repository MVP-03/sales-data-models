{{
  config(materialized='ephemeral')
}}

/*
  Scores each lead 0-100 against ICP criteria.
  Weights are pulled from the icp_criteria seed table.
*/

with leads as (
    select * from {{ ref('stg_leads') }}
),

criteria as (
    select * from {{ ref('icp_criteria') }}
),

industry_weight as (
    select weight from criteria where criterion = 'industry'
),

scored as (
    select
        l.lead_id,
        l.email,
        l.company,
        l.domain,
        l.industry,
        l.employee_count,
        l.country,
        l.has_api,
        l.annual_revenue_usd,

        -- Industry score (25%)
        case
            when l.industry in ('SaaS', 'Software', 'Technology', 'Fintech') then 25
            when l.industry in ('E-commerce', 'Retail', 'Media')             then 15
            else 5
        end as industry_score,

        -- Employee count score (20%)
        case
            when l.employee_count between 50  and 500  then 20
            when l.employee_count between 500 and 2000 then 15
            when l.employee_count between 10  and 49   then 10
            else 3
        end as employee_score,

        -- Country score (15%)
        case
            when l.country in ('united states', 'canada', 'united kingdom') then 15
            when l.country in ('australia', 'germany', 'france')            then 10
            else 5
        end as country_score,

        -- Has API score (20%)
        case when l.has_api then 20 else 0 end as api_score,

        -- Revenue score (20%)
        case
            when l.annual_revenue_usd >= 10000000  then 20
            when l.annual_revenue_usd >= 1000000   then 15
            when l.annual_revenue_usd >= 100000    then 8
            else 2
        end as revenue_score

    from leads l
),

final as (
    select
        *,
        (industry_score + employee_score + country_score + api_score + revenue_score) as icp_score,
        case
            when (industry_score + employee_score + country_score + api_score + revenue_score) >= 80 then 'Strong Fit'
            when (industry_score + employee_score + country_score + api_score + revenue_score) >= 60 then 'Good Fit'
            when (industry_score + employee_score + country_score + api_score + revenue_score) >= 40 then 'Weak Fit'
            else 'Poor Fit'
        end as fit_label
    from scored
)

select * from final
