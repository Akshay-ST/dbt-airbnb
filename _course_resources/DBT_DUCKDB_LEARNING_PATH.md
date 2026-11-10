# dbt + DuckDB Learning Path

## Purpose and scope

This plan rebuilds the learning path from the public course notes in [`_course_resources/course-resources.md`](./_course_resources/course-resources.md), using the model flow in the course diagram and the project files already in this repository.

- Use the local Airbnb CSV data and DuckDB as the warehouse.
- Skip Snowflake account setup, credentials, warehouses, roles, grants, and Snowflake-only administration.
- Skip the Preset dashboard and dashboard setup for now.
- Learn dbt concepts in the existing Airbnb project, then add Airflow DAGs as a separate orchestration track.

## Current starting point

- dbt connects to the local DuckDB file `airbnb.duckdb`.
- The CSV files are loaded as `raw.raw_listings`, `raw.raw_hosts`, and `raw.raw_reviews`.
- dbt has queried all three sources successfully.
- The existing model SQL and project hooks still include Snowflake-specific syntax/configuration. Before running the complete project on DuckDB, we will adapt those parts while preserving the original learning intent.

## Pipeline we will learn

```text
raw hosts ──┬──> scd_raw_hosts
            └──> src_hosts ──> dim_hosts_cleansed ──┐
                                                    ├──> dim_listings_w_hosts
raw listings ┬──> scd_raw_listings                 │
             └──> src_listings -> dim_listings_cleansed ─┘
                                       ├──> dim_listings_minimum_nights test
                                       └──> consistent_created_at test

raw reviews ──> src_reviews ──> fct_reviews ──> mart_fullmoon_reviews
                                      ▲                    ▲
                                      │                    │
                                      └── tests       seed_full_moon_dates

full_moon_no_sleep.sql is an analysis that queries the mart.
```

Tests check the models; they are not transformation steps. The dashboard node shown in the course diagram is intentionally left out of this plan.

## Learning steps

For each step, choose a restart point during review: **Start here**, **Review**, or **Comfortable**.

### 1. Re-orient to the project and dbt workflow

**Course notes:** Introduction and Environment Setup; dbt Project Setup.

**Objective:** Be able to explain the project structure and distinguish dbt models, sources, seeds, tests, snapshots, macros, and analyses.

**Practice:** Inspect `airbnb/dbt_project.yml`, `airbnb/models/`, `airbnb/tests/`, `airbnb/snapshots/`, and `airbnb/seeds/`. Run `dbt debug`, `dbt ls`, and `dbt show` against the local target.

**Ready to continue when:** You can describe where dbt reads project files from and how to select the DuckDB target.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 2. Sources and staging models

**Course notes:** Models — SRC Listings, SRC Reviews, and the SRC Hosts exercise; Sources and Seeds.

**Objective:** Learn how raw tables are declared as sources and how staging models rename columns and provide a consistent starting layer.

**Practice:** Trace `source('airbnb', ...)` from `airbnb/models/sources.yml` into `src_listings`, `src_hosts`, and `src_reviews`. Query a source and its staging model, and compare their columns.

**DuckDB focus:** Keep the raw CSV-derived tables in the `raw` schema. Use dbt source freshness only after confirming the date column and its timestamp type behave as expected locally.

**Ready to continue when:** You can explain the difference between a source table and a dbt model, and why downstream models use `ref()`.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 3. Cleansing dimensions and joining models

**Course notes:** DIM Listings, DIM Hosts, and DIM Listings with Hosts.

**Objective:** Practice CTEs, `ref()`, type conversion, null handling, `CASE`, joins, and model materializations.

**Practice:** Follow `dim_listings_cleansed`, `dim_hosts_cleansed`, and `dim_listings_w_hosts`. Translate Snowflake-only expressions to DuckDB-compatible SQL as encountered, and compare view, table, and ephemeral behavior.

**Ready to continue when:** You can trace a listing from a raw source through its cleansed dimension and explain the host join.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 4. Seeds and the full-moon mart

**Course notes:** Sources and Seeds; `mart_fullmoon_reviews`.

**Objective:** Learn how a small local CSV seed becomes a dbt relation and how a mart combines facts with reference data.

**Practice:** Inspect `seed_full_moon_dates.csv`, build the seed, trace its `ref()` into `mart_fullmoon_reviews`, and explain the date join.

**Ready to continue when:** You can describe when a seed is useful and how it differs from a source table.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 5. Fact tables and incremental models

**Course notes:** Incremental Models; Incremental Models Compatible with Orchestrators.

**Objective:** Understand incremental materialization, `is_incremental()`, `this`, unique keys, schema-change behavior, and full refreshes.

**Practice:** Trace `fct_reviews`; compare an initial build with a later incremental build and a full refresh. Use DuckDB-compatible settings and a safe local dataset for any insert/update exercise.

**Ready to continue when:** You can explain which rows an incremental run selects and when a full refresh is needed.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 6. Snapshots and slowly changing dimensions

**Course notes:** Snapshots for Listings; assignment for Hosts.

**Objective:** Learn how snapshots preserve changes in source records over time, including the unique key and timestamp strategy.

**Practice:** Trace `scd_raw_listings` and `scd_raw_hosts`. Review how snapshot metadata represents earlier and current versions. Run a controlled change locally and observe the result.

**Ready to continue when:** You can explain what a snapshot records and how it differs from a normal model rebuild.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 7. Data tests, unit tests, and contracts

**Course notes:** Generic Tests; singular tests; Unit Tests; Contracts; Custom Generic Tests; test severity and stored failures.

**Objective:** Use tests to express data quality rules and catch regressions in model logic.

**Practice:** Review built-in tests in `airbnb/models/schema.yml`, singular tests in `airbnb/tests/`, generic tests in `airbnb/tests/generic/`, and the unit test for the full-moon mart.

**Ready to continue when:** You can explain what makes a data test fail and when to choose a built-in, singular, generic, or unit test.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 8. Jinja, macros, packages, and variables

**Course notes:** Jinja, Macros and Packages; Setting Test Parameters; Variables.

**Objective:** Understand how dbt renders reusable SQL and how packages add macros and tests.

**Practice:** Read `airbnb/macros/`, inspect `airbnb/packages.yml`, and try a small Jinja expression, macro call, and project variable. Learn when `dbt deps` is needed after package changes.

**Ready to continue when:** You can identify which parts of a model are SQL and which are rendered by dbt/Jinja.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 9. Documentation, analyses, and debugging

**Course notes:** Documentation; Analyses; Debugging Tests and Testing with dbt-expectations.

**Objective:** Use dbt docs and compiled SQL to understand lineage, describe models, and diagnose failures.

**Practice:** Review `airbnb/models/docs.md`, `airbnb/models/overview.md`, and `airbnb/analyses/full_moon_no_sleep.sql`. Inspect compiled SQL when a test or model behaves unexpectedly. Dashboard and Preset material is out of scope for now.

**Ready to continue when:** You can follow a model's lineage and use compiled SQL or logs to investigate an error.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 10. Hooks and warehouse-specific behavior

**Course notes:** Hooks and Grants.

**Objective:** Learn what hooks do while separating portable dbt concepts from Snowflake administration.

**Practice:** Review the audit-table hooks in `airbnb/dbt_project.yml`. Keep only behavior that is meaningful and supported in local DuckDB; skip role/grant exercises. Do not treat Snowflake setup or grants as prerequisites for this project.

**Ready to continue when:** You can explain when a hook runs and why grants are a warehouse permission concern rather than a local DuckDB learning requirement.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

### 11. Airflow DAGs to orchestrate the dbt project

**Course notes:** The course has an orchestration section using Dagster. Airflow is an additional learning track requested for this project.

**Objective:** Learn Python DAG structure, task dependencies, schedules, retries, logs, and how an Airflow task runs dbt against DuckDB.

**Practice:** First write a small DAG with independent Python tasks. Then add tasks to prepare/verify local inputs, run `dbt build`, and inspect the run result. Keep Airflow in a separate environment from the dbt project environment.

**Reference:** [Apache Airflow tutorials](https://airflow.apache.org/docs/apache-airflow/stable/tutorial/).

**Ready to continue when:** You can explain the task graph and see Airflow report the dbt task's success or failure.

**Restart choice:** [ ] Start here  [ ] Review  [ ] Comfortable

## My restart point

Write the first step to restart from after reviewing this plan:

> 

Notes or questions:

> 
