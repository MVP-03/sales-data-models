<div align="center">

# sales-data-models

**dbt models for GTM analytics — leads, ICP scoring, and campaign performance.**

![dbt](https://img.shields.io/badge/dbt-1.7-FF694B?style=flat-square&logo=dbt&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Postgres-336791?style=flat-square&logo=postgresql&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

</div>

---

## What it does

A dbt project that transforms raw CRM and outreach exports into clean, analysis-ready tables for GTM reporting. Models are layered: staging cleans raw sources, intermediate applies scoring logic, marts produce the final tables your BI tool or RevOps team queries.

---

## Model Layers

```
sources (raw_leads, raw_campaigns)
    |
    v
staging/          -- views, typed and cleaned
    stg_leads     -- deduped lead records with typed columns
    stg_campaigns -- per-step campaign performance rows
    |
    v
intermediate/     -- ephemeral, business logic only
    int_lead_scores       -- ICP scoring (0-100) + fit label
    int_campaign_metrics  -- aggregated rates + variant winner flag
    |
    v
marts/            -- tables, queried by BI / exports
    fct_pipeline            -- all leads with ICP tier for outreach prioritisation
    fct_campaign_performance -- campaign metrics with winner flagging
```

---

## ICP Scoring Logic

| Signal | Weight | Notes |
|---|---|---|
| Industry | 25% | SaaS/Tech/Fintech score highest |
| Has API | 20% | Signals technical buyer |
| Annual revenue | 20% | Revenue proxy for budget |
| Employee count | 20% | 50-500 headcount is sweet spot |
| Country | 15% | US/CA/UK score highest |

Scores 80+ = Strong Fit → Tier 1. Adjustable via `seeds/icp_criteria.csv`.

---

## Quickstart

```bash
git clone https://github.com/MVP-03/sales-data-models.git
cd sales-data-models

pip install dbt-postgres

cp profiles.yml.example ~/.dbt/profiles.yml
# Edit with your DB credentials

dbt deps
dbt seed
dbt run
dbt test
```

---

## Project Structure

```
sales-data-models/
├── dbt_project.yml
├── profiles.yml.example
├── models/
│   ├── staging/
│   │   ├── stg_leads.sql
│   │   ├── stg_campaigns.sql
│   │   └── schema.yml             # source definitions + column tests
│   ├── intermediate/
│   │   ├── int_lead_scores.sql
│   │   └── int_campaign_metrics.sql
│   └── marts/
│       ├── fct_pipeline.sql
│       └── fct_campaign_performance.sql
├── seeds/
│   └── icp_criteria.csv           # ICP weights, editable without code changes
├── macros/
│   └── positive_value.sql         # Custom test macro
└── README.md
```

---

## License

MIT
