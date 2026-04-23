{% docs __overview__ %}
# Airbnb pipeline

Hey, welcome to our Airbnb pipeline documentation!

Here is the schema of our input data:
![input schema](assets/input_schema.png)

# _____________________________________ 

# Airbnb Pipeline Documentation

Welcome to the Airbnb data warehouse! This dbt project transforms raw Airbnb listing, host, and review data into clean, business-ready analytics tables.

## 📊 Project Overview

This data warehouse follows a **layered medallion architecture** that progressively transforms raw data into business-ready insights:

```
Raw Data Layer → Source Layer → Dimension/Fact Layer → Mart Layer
    (ephemeral)                                        (business views)
```

### Input Data Schema

Here is the schema of our raw input data:
![input schema](assets/input_schema.png)

---

## 🏗️ Project Structure

### **Layer 1: Raw Data Sources**
Located in: `airbnb` schema (raw tables)

Raw data ingested from external systems:
- **`raw_listings`** - Airbnb property listings with pricing, amenities, and metadata
- **`raw_hosts`** - Host information including superhost status and metadata
- **`raw_reviews`** - Guest reviews with sentiment and timestamps

### **Layer 2: Source Models** (`src/` folder)
**Materialization:** Ephemeral (not stored in database)

These lightweight models clean and standardize raw data:
- **`src_listings`** - Selects and renames columns from raw listings
- **`src_hosts`** - Cleanses host data 
- **`src_reviews`** - Prepares review data for downstream use

**Purpose:** Provide a single source of truth for raw data transformation logic.

### **Layer 3: Dimension & Fact Tables** (`dim/` and `fct/` folders)

#### Dimensions (`dim/` folder)
**Materialization:** Table (persisted in database)

Business-ready dimension tables:
- **`dim_listings_cleansed`** - Clean listings table with standardized data types, cleaned prices, and business rules applied
- **`dim_hosts_cleansed`** - Enriched host dimension with default values for missing names
- **`dim_listings_w_hosts`** - Conformed dimension joining listings with host information for easy analysis

**Key Validations:**
- Unique & non-null listing IDs
- Valid room types (Entire home/apt, Private room, Shared room, Hotel room)
- Positive minimum nights values
- Referential integrity between listings and hosts

#### Facts (`fct/` folder)
**Materialization:** Incremental (only new/updated records processed)

Transactional fact tables:
- **`fct_reviews`** - Fact table containing all reviews with generated surrogate keys
  - Includes: reviewer name, sentiment, listing reference, review text
  - Incremental updates: only processes reviews added since the last run
  - Quality checks: reviewer name must be present, valid sentiment values

### **Layer 4: Mart Tables** (`mart/` folder)
**Materialization:** Table (business-ready aggregations)

Final curated datasets for analytics:
- **`mart_fullmoon_reviews`** - Analysis table joining reviews with full moon dates to enable impact analysis of lunar cycles on review sentiment

---

## 📈 Data Lineage Diagrams

### High-Level Data Flow

```
                    Raw Data Sources
                    ┌─────────────────┐
                    │ raw_listings    │
                    │ raw_hosts       │
                    │ raw_reviews     │
                    └────┬────┬───┬───┘
                         │    │   │
              ┌──────────────────────────────┐
              │   Source Layer (ephemeral)   │
              ├──────────────────────────────┤
              │ src_listings │ src_hosts    │ src_reviews
              └──────┬──────┬──┴──┬────────┘
                     │      │     │
        ┌────────────────────────────────────────┐
        │  Dimension & Fact Layer (persisted)    │
        ├────────────────────────────────────────┤
        │ dim_listings_cleansed                  │
        │ dim_hosts_cleansed  │  fct_reviews     │
        └─────────────┬──────────────┬────────────┘
                      │              │
                      ▼              ▼
        ┌──────────────────────────────────────┐
        │    Joined Dimensions & Marts         │
        ├──────────────────────────────────────┤
        │ dim_listings_w_hosts                 │
        │ mart_fullmoon_reviews                │
        └──────────────────────────────────────┘
```

### Detailed Model Dependencies

**Listings Flow:**
```
raw_listings → src_listings → dim_listings_cleansed → dim_listings_w_hosts
                                                    ↘ mart_fullmoon_reviews
```

**Hosts Flow:**
```
raw_hosts → src_hosts → dim_hosts_cleansed → dim_listings_w_hosts
```

**Reviews Flow:**
```
raw_reviews → src_reviews → fct_reviews → mart_fullmoon_reviews
```

---

## 🔧 Key Transformations

| Layer | Model | Input | Transformations | Output |
|-------|-------|-------|-----------------|--------|
| Source | `src_listings` | `raw_listings` | Column selection, rename to business terms | 9 columns |
| Dimension | `dim_listings_cleansed` | `src_listings` | Handle nulls, convert price, fix minimum nights | Cleaned listings |
| Dimension | `dim_hosts_cleansed` | `src_hosts` | Handle missing names, standardize fields | Cleaned hosts |
| Dimension | `dim_listings_w_hosts` | `dim_listings_cleansed`, `dim_hosts_cleansed` | LEFT JOIN hosts to listings | Denormalized view |
| Fact | `fct_reviews` | `src_reviews` | Generate surrogate keys, incremental load | Fact table |
| Mart | `mart_fullmoon_reviews` | `fct_reviews`, `seed_full_moon_dates` | Enrich with lunar cycle data | Analysis-ready table |

---

## ✅ Data Quality & Testing

The project includes comprehensive data quality checks:

**Dimension Tests:**
- Uniqueness: `listing_id`, `host_id` must be unique
- Not Null: Critical fields must be populated
- Referential Integrity: `listing_id` references must exist
- Accepted Values: `room_type` must be valid categories
- Custom Tests: Positive values, minimum row counts

**Fact Tests:**
- Not Null: Core review fields required
- Valid Sentiments: Review sentiment in {positive, neutral, negative}
- Referential Integrity: Reviews link to valid listings

See the [dbt tests documentation](/run_results.json) for full test results.

---

## 🔄 Materialization Strategy

| Layer | Materialization | Reason |
|-------|-----------------|--------|
| Source | Ephemeral | Logic-only layer, not queried directly |
| Dimension | Table | Frequently queried for analysis |
| Fact | Incremental | Large table, only new records added daily |
| Mart | Table | Business views, optimized for reporting |

---

## 📝 Running the Pipeline

```bash
# Run all models
dbt run

# Run with specific selector
dbt run --selector dim_and_fct

# Build and test
dbt build

# Generate documentation
dbt docs generate
```

---

## 📚 Additional Resources

- **Data Model Specification:** See [schema.yml](path/to/schema.yml) for complete column definitions
- **Source Mapping:** See [sources.yml](path/to/sources.yml) for raw data source details
- **Tests:** See the `tests/` folder for custom data quality checks

{% enddocs %}