# Slowly Changing Dimensions with Snowflake

[![Architecture Diagram](images/scd-architecture.drawio.png)]
> This repository demonstrates an implementation of slowly changing dimensions (SCD) techniques using Snowflake, including architecture, SQL scripts, and a deployment environment (Docker + Snowflake SQL + orchestration).

---

## Table of Contents

- [Overview](#overview)  
- [Architecture](#architecture)  
- [Repository Structure](#repository-structure)  
- [Prerequisites](#prerequisites)  
- [Setup and Usage](#setup-and-usage)  
  - [Snowflake account & credentials](#snowflake-account--credentials)  
  - [Docker / Local environment](#docker--local-environment)  
  - [Run scripts / pipelines](#run-scripts--pipelines)  
- [SCD Patterns Supported](#scd-patterns-supported)  
- [Testing / Verification](#testing--verification)  
- [Future Enhancements](#future-enhancements)  
- [Credits / References](#credits--references)  

---

## Overview

In data warehousing, **Slowly Changing Dimensions (SCD)** are dimension tables in which attribute values change slowly over time. This repository demonstrates how to implement SCD techniques in **Snowflake**, managing history, versioning, and updates in an analytical system.

You’ll find sample SQL scripts, architectural design, and a Docker-based orchestration environment to experiment with.

---

## Architecture

The architecture diagram below illustrates how data flows from staging sources into a Snowflake data warehouse layer, how dimension tables are updated (including historical versions), and how queries can access current and historical states via fact joins.

[![SCD Architecture](images/scd-architecture.drawio.png)](images/scd-architecture.drawio.png)

*Image file: `images/scd-architecture.drawio.png`*

---

## Repository Structure

Here’s a breakdown of key folders and files:
├── images/
│ └── scd-architecture.drawio.png ← architecture diagram
├── SQL/
│ ├── staging.sql ← staging tables scripts
│ ├── dimension_type1.sql ← SCD Type 1 scripts
│ ├── dimension_type2.sql ← SCD Type 2 scripts
│ └── fact_loading.sql ← fact table script
├── docker_exp/
│ ├── Dockerfile ← container setup
│ └── docker-compose.yml ← orchestrates services
├── faker.ipynb ← notebook to generate mock data
├── presentation.ipynb ← slide / walkthrough notebook
└── README.md ← (this file)

---

## Prerequisites

Before running the solution, you’ll need:

- A **Snowflake account** (or access to an existing one)  
- Permissions to create databases, schemas, and run SQL  
- **Docker** & **docker-compose** installed, if using the containerized environment  
- Python (for any data generation or orchestration, e.g. via the Jupyter notebooks)  

---

## Setup and Usage

Below is a recommended flow to get started.

### Snowflake account & credentials

1. Create or have a Snowflake user with enough access (e.g. `SYSADMIN`, or a custom role with create/usage rights).  
2. Note the following Snowflake connection parameters:
   - Account name / URL  
   - Username / password / key  
   - Warehouse name  
   - Database & schema names  

You may want to store these in environment variables or a `.env` file when running via Docker.

### Docker / Local environment

If using the `docker_exp/` setup:

1. Create a `.env` file in `docker_exp/` (or set in your host) containing your Snowflake credentials and connection parameters.  
2. Run:
   ```bash
   docker-compose up
The containers will spin up (if there are services such as orchestration scripts, runners, or utilities) and connect to Snowflake to execute the SQL scripts as defined.

Alternatively, you can run SQL scripts manually via Snowflake UI or your preferred SQL client.

Run scripts / pipelines

Execute the staging scripts to create staging schemas and tables.

Use the dimension scripts (Type 1 / Type 2) to load / update dimension tables.

For Type 1: updates overwrite existing values

For Type 2: new rows inserted, with start / end timestamps, versioning

Load fact tables, joining with dimension keys (current or historical) as needed

You can re-run the dimension scripts with changed data to simulate changes and see how history is tracked

SCD Patterns Supported

This project illustrates (or supports) the following SCD patterns:

Type 1 (Overwrite): changes simply overwrite existing records

Type 2 (Versioned / History): creates new records with validity periods, preserving history

You can extend this to Type 3, Type 4, or hybrid strategies depending on use case.

Testing / Verification

To verify correct behavior:

Use the faker.ipynb notebook to generate sample dimension changes and load them

Query the dimension tables before and after changes to ensure:

For Type 1: only the current version remains

For Type 2: previous versions have correct end_date / is_current flags

Join with fact table queries that target both “current” and “historical” dimensions

Validate counts, version numbers, and temporal integrity

