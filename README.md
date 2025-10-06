
# Slowly Changing Dimensions (SCD) with Snowflake

![SCD Architecture](slowly-changing-dimensions-with-snowflake/images/scd-archiecture.drawio.png)

This project demonstrates how to **design and implement Slowly Changing Dimensions (SCD)** in **Snowflake** — from data ingestion and transformation to dimension versioning and fact table integration.  

It shows **SCD Type 1** and **Type 2** techniques through SQL scripts, uses **Snowflake** as the data warehouse, and provides a **Docker-based setup** for orchestration and testing.  
It also includes Jupyter notebooks for data generation and project explanation.

---

## 🧭 Table of Contents
- [1. Introduction](#1-introduction)
- [2. Project Objectives](#2-project-objectives)
- [3. What are Slowly Changing Dimensions (SCD)?](#3-what-are-slowly-changing-dimensions-scd)
- [4. Project Architecture](#4-project-architecture)
- [5. Repository Structure](#5-repository-structure)
- [6. Data Flow Explanation](#6-data-flow-explanation)
- [7. Setting up the Environment](#7-setting-up-the-environment)
  - [Snowflake Setup](#snowflake-setup)
  - [Docker Setup](#docker-setup)
- [8. Running the Project](#8-running-the-project)
- [9. Detailed Explanation of SCD Scripts](#9-detailed-explanation-of-scd-scripts)
  - [SCD Type 1](#scd-type-1)
  - [SCD Type 2](#scd-type-2)
- [10. Testing and Validation](#10-testing-and-validation)
- [11. Future Enhancements](#11-future-enhancements)
- [12. Conclusion](#12-conclusion)
- [13. License](#13-license)

---

## 1. Introduction

In real-world analytics, customer, product, and employee data change over time — names are updated, locations change, or customers switch segments.  
To track these changes without losing historical accuracy, **Slowly Changing Dimensions (SCD)** are used in data warehouses.

This project implements those concepts practically in **Snowflake**, a modern cloud-based data warehouse.  
It’s designed as an educational and hands-on project to show **how to detect, manage, and store dimension changes** using SQL and automation tools.

---

## 2. Project Objectives

The goals of this project are:

- To demonstrate how **Slowly Changing Dimensions** are implemented in Snowflake.
- To show how **data versioning** works in dimension tables.
- To use **SQL scripting** for detecting and processing changes.
- To simulate **real data changes** using generated datasets.
- To design an **end-to-end data architecture** for an analytical system.

---

## 3. What are Slowly Changing Dimensions (SCD)?

**SCDs** are dimensions in a data warehouse that change slowly over time, rather than frequently.  

For example, a *customer’s city* or *email address* might change occasionally. We must decide whether to overwrite the old data or preserve both versions.  

There are different types of SCDs:

| Type | Description | Example |
|------|--------------|----------|
| **Type 1** | Overwrites old data with new data | Customer email updated; no history kept. |
| **Type 2** | Creates a new record to keep history | Customer address changes; old row closed, new row added. |
| **Type 3** | Keeps limited history in extra columns | Store current and previous values in same row. |

This project implements **Type 1** and **Type 2**, the most widely used in analytics.

---

## 4. Project Architecture

![SCD Architecture](images/scd-architecture.drawio.png)

The architecture follows a **modern data pipeline** flow:

1. **Data Generation**  
   Using the `faker.ipynb` notebook, random customer or product data is generated.

2. **Data Staging**  
   The data is loaded into **staging tables** inside Snowflake (temporary or transient storage).

3. **Dimension Table Creation**  
   SQL scripts (`dimension_type1.sql` and `dimension_type2.sql`) create dimension tables (e.g., `DIM_CUSTOMER`) and define logic for handling inserts/updates.

4. **Change Detection Logic**  
   The scripts compare staging data to existing dimension data to identify:
   - New records (to insert)
   - Modified records (to update or version)
   - Unchanged records (to ignore)

5. **Fact Table Loading**  
   Facts (like sales or transactions) are loaded and joined to dimension keys, ensuring referential integrity to either current or historical dimension versions.

6. **Historical Querying**  
   Analysts can query historical states (using SCD Type 2) or only current state (Type 1) depending on business needs.

---

## 5. Repository Structure

```bash
.
├── images/
│   └── scd-architecture.drawio.png        # Architecture diagram
├── SQL/
│   ├── staging.sql                        # Create staging area and load mock data
│   ├── dimension_type1.sql                # SCD Type 1 logic (overwrite)
│   ├── dimension_type2.sql                # SCD Type 2 logic (history)
│   └── fact_loading.sql                   # Load fact tables
├── docker_exp/
│   ├── Dockerfile                         # Environment setup for Snowflake integration
│   └── docker-compose.yml                 # Container orchestration
├── faker.ipynb                            # Generates mock data using Faker library
├── presentation.ipynb                     # Explains project and results visually
└── README.md                              # Documentation
````

---

## 6. Data Flow Explanation

1. **Source Data → Staging Layer:**
   Raw data generated or received from APIs/files is inserted into staging tables.

2. **Staging → Dimension Layer:**
   SQL logic compares staging vs. existing dimension to detect changes.

3. **Dimension → Fact Layer:**
   Fact tables (like sales) reference dimension keys to ensure temporal accuracy.

---

## 7. Setting up the Environment

### Snowflake Setup

1. Create a database and schemas:

   ```sql
   CREATE DATABASE DATA_DESIGN;
   CREATE SCHEMA STAGING;
   CREATE SCHEMA DIM;
   CREATE SCHEMA FACT;
   ```
2. Upload SQL scripts in your Snowflake worksheet or run via SnowSQL CLI.
3. Ensure your role has `CREATE` and `INSERT` privileges.
4. Define a warehouse and connect it to your session.

### Docker Setup

1. Navigate to the Docker directory:

   ```bash
   cd docker_exp
   ```
2. Start the container:

   ```bash
   docker-compose up --build
   ```

## 8. Running the Project

1. Run the **`faker.ipynb`** notebook to create fake customer data.
2. Use **`SQL/staging.sql`** to load data into Snowflake staging tables.
3. Run **`SQL/dimension_type1.sql`** or **`SQL/dimension_type2.sql`**:

   * Type 1: Overwrites data directly.
   * Type 2: Creates new versions for changed records.
4. Load fact data with **`SQL/fact_loading.sql`**.
5. Query your dimension tables to observe how data changes over time.

---

## 9. Detailed Explanation of SCD Scripts

### SCD Type 1

**Goal:** Overwrite old values with new ones (no history).

Example logic:

```sql
MERGE INTO DIM_CUSTOMER AS target
USING STG_CUSTOMER AS source
ON target.CUSTOMER_ID = source.CUSTOMER_ID
WHEN MATCHED THEN
  UPDATE SET target.FIRST_NAME = source.FIRST_NAME,
             target.LAST_NAME = source.LAST_NAME,
             target.EMAIL = source.EMAIL
WHEN NOT MATCHED THEN
  INSERT (CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL)
  VALUES (source.CUSTOMER_ID, source.FIRST_NAME, source.LAST_NAME, source.EMAIL);
```

### SCD Type 2

**Goal:** Preserve historical versions by creating a new record when changes occur.

Example logic:

```sql
MERGE INTO DIM_CUSTOMER AS target
USING STG_CUSTOMER AS source
ON target.CUSTOMER_ID = source.CUSTOMER_ID
AND target.IS_CURRENT = TRUE
WHEN MATCHED AND (
  target.FIRST_NAME <> source.FIRST_NAME OR
  target.LAST_NAME <> source.LAST_NAME OR
  target.EMAIL <> source.EMAIL
) THEN
  UPDATE SET target.IS_CURRENT = FALSE,
             target.END_TIME = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN
  INSERT (CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, START_TIME, END_TIME, IS_CURRENT)
  VALUES (source.CUSTOMER_ID, source.FIRST_NAME, source.LAST_NAME, source.EMAIL,
          CURRENT_TIMESTAMP(), NULL, TRUE);
```

This ensures:

* Old record is closed (`IS_CURRENT = FALSE`)
* New record starts fresh (`IS_CURRENT = TRUE`)

---

## 10. Testing and Validation

1. Generate initial dataset and load it.
2. Modify a few records (e.g., change customer city or email).
3. Re-run SCD scripts:

   * Type 1: Overwritten immediately.
   * Type 2: Old record closed, new record added.
4. Query the dimension:

   ```sql
   SELECT * FROM DIM_CUSTOMER ORDER BY CUSTOMER_ID, START_TIME;
   ```
5. Verify that:

   * Historical rows exist with correct `END_TIME`.
   * `IS_CURRENT` flag marks the latest record.
   * Fact tables point to correct dimension keys.

---

## 11. Future Enhancements

* Add **Type 3** (limited history) support.
* Use **Snowflake Streams & Tasks** for automated change detection.
* Integrate with **Airflow** or **dbt** for orchestration.
* Add **CI/CD** pipeline for automatic schema migration.
* Implement soft deletes and late-arriving record handling.

---

## 12. Conclusion

This project provides a **complete, working example** of how Slowly Changing Dimensions are implemented in Snowflake.
It combines SQL logic, architecture design, and practical testing workflows to help data engineers and analysts understand how to manage evolving data over time.

By mastering these techniques, you can:

* Maintain historical accuracy in your analytics.
* Ensure consistent dimension key management.
* Build scalable, reliable data pipelines for any enterprise data warehouse.

---

