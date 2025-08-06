{{
  config(materialized='table')
}}

with metrics as (
    select * from {{ ref('int_campaign_metrics') }}
),

final as (
    select
        campaign_name,
        sequence_step,
        variant,
        send_year,
        send_quarter,
        total_sent,
        total_opened,
        total_replied,
        total_positive_replies,
        total_meetings,
        open_rate,
        reply_rate,
        booking_rate,
        positive_reply_rate,
        is_winning_variant,
        current_timestamp as modeled_at
    from metrics
)

select * from final
