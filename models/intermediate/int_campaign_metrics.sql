{{
  config(materialized='ephemeral')
}}

with campaigns as (
    select * from {{ ref('stg_campaigns') }}
),

aggregated as (
    select
        campaign_name,
        sequence_step,
        variant,
        send_year,
        send_quarter,

        sum(sent)             as total_sent,
        sum(opened)           as total_opened,
        sum(replied)          as total_replied,
        sum(positive_replies) as total_positive_replies,
        sum(meetings_booked)  as total_meetings,

        round(sum(opened)::numeric / nullif(sum(sent), 0), 4)             as open_rate,
        round(sum(replied)::numeric / nullif(sum(sent), 0), 4)            as reply_rate,
        round(sum(meetings_booked)::numeric / nullif(sum(sent), 0), 4)    as booking_rate,
        round(sum(positive_replies)::numeric / nullif(sum(replied), 0), 4) as positive_reply_rate

    from campaigns
    group by 1, 2, 3, 4, 5
),

with_winner_flag as (
    select
        *,
        booking_rate = max(booking_rate) over (
            partition by campaign_name, sequence_step, send_year, send_quarter
        ) as is_winning_variant

    from aggregated
)

select * from with_winner_flag
