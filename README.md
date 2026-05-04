# README — Regulatory Reporting Pipeline (R1 / R2)

## Objective

This project demonstrates an illustrative regulatory reporting framework for calculating the following metrics:

* **R1:** UK Entity Cross-Currency Volume
* **R2a:** US Entity Cross-Currency Volume
* **R2b:** US Entity Same-Currency Volume

The solution was designed to demonstrate:

* scalable regulatory reporting,
* auditability,
* controlled data transformations,
* governance-aware implementation,
* and repeatable analytics engineering practices.

Reporting period:
`01/04/2022 - 01/08/2023`

Illustrative output figures:

* **R1:** £3,718
* **R2a:** £365
* **R2b:** £0

---

# Pipeline Execution

## 1. Initialise the Environment

Ensure `dbt-bigquery` (or equivalent adapter) is installed.

Configure `profiles.yml` to point to the appropriate BigQuery project and dataset.

---

## 2. Load Source Data

Run:

```bash
dbt seed
```

This loads:

* `Transactions.csv`
* `Customer.csv`

into the Bronze (Raw) layer.

---

## 3. Build the Transformation Layers

Run:

```bash
dbt run
```

This materialises the Medallion Architecture:

| Layer            | Purpose                                          |
| ---------------- | ------------------------------------------------ |
| Bronze (Raw)     | Source ingestion and lineage preservation        |
| Silver (Staging) | Cleaning, standardisation, deduplication         |
| Gold (Marts)     | Regulatory business logic and aggregated outputs |

---

## 4. Execute Data Quality Controls

Run:

```bash
dbt test
```

The current automated suite validates:

* uniqueness constraints,
* null handling,
* and core structural integrity checks.

---

# Architecture Overview

The pipeline follows a modular Medallion Architecture to support:

* scalability,
* auditability,
* controlled transformations,
* and reusable reporting logic.

## Bronze (Raw)

Stores source CSV extracts in their original format for traceability and lineage preservation.

## Silver (Staging)

Implements:

* defensive type casting,
* standardisation,
* deduplication logic,
* and data quality filtering.

## Gold (Marts)

Contains final regulatory reporting logic and aggregated reporting outputs.

---

# Data Quality & Engineering Controls

The implementation includes foundational governance and data quality controls to reduce reporting risk.

## Deduplication Logic

Duplicate transaction IDs are resolved using `ROW_NUMBER()` logic, retaining the latest available transaction as an interim assumption due to absence of event-versioning metadata.

## Defensive Type Handling

`SAFE_CAST()` and `COALESCE()` are used to improve pipeline stability and reduce schema-related failures.

## Entity Normalisation

Country values such as `UK` and `GBR` are normalised to reduce under-reporting risk.

## Controlled Reporting Outputs

The Gold layer acts as the controlled reporting layer used for downstream regulatory consumption.

## Auditability

GitHub version control and dbt lineage support traceability and reproducibility of reporting logic.

---

# Regulatory Logic

## Cross-Currency Logic

Transactions where:
`source_currency != destination_currency`

Example:
`GBP --> USD`

## Same-Currency Logic

Transactions where:
`source_currency = destination_currency`

Example:
`GBP --> GBP`

## Gross vs Net Treatment

Both Gross and Net reporting logic were produced because the regulatory requirement did not explicitly specify the intended methodology.

Gross logic applies:

```sql
ABS(amount)
```

to represent total financial activity including reversals/refunds.

Final methodology remains subject to Compliance / Regulatory Reporting sign-off.

---

# Governance & Controls

The framework was designed to support:

* repeatable reporting,
* controlled delivery,
* audit evidence retention,
* and scalable governance processes.

Key governance concepts demonstrated:

* Assumption Register
* Data Issue Log
* Four-Eyes Principle
* Controlled reporting outputs
* Escalation triggers
* Compliance sign-off gates

---

# Current Limitations

The following limitations were identified during implementation:

* Historical customer address snapshots were unavailable.
* IP / transaction-origin evidence was unavailable.
* Duplicate transaction handling lacked event-versioning metadata.
* Currency-route formatting relies on consistent upstream structure.
* Gross vs Net methodology remains pending clarification.

All assumptions and limitations should be formally reviewed before production implementation or external submission.

Refer to:
`Assumptions Register.docx`

---

# Future Enhancements

Potential future improvements include:

* SCD Type 2 implementation for historical address tracking
* Additional automated reconciliation controls
* Threshold-based anomaly detection
* Accepted-values and regex validation tests
* Continuous auditing / exception monitoring
* Dashboard integration (e.g. Looker)
* Automated escalation workflows

Note:
The current dbt test suite demonstrates core integrity controls required for the illustrative workflow. Additional automated controls would be incrementally introduced as the framework matures.

---

# Project Deliverables

| File                        | Description                                     |
| --------------------------- | ----------------------------------------------- |
| `dbt_project.yml`           | Project configuration and materialisation rules |
| `schema.yml`                | Automated dbt tests and model documentation     |
| `stg_* models`              | Staging-layer cleaning and standardisation      |
| `fct_* models`              | Final reporting and aggregation logic           |
| `Assumptions Register.docx` | Governance assumptions and known limitations    |
| `README.txt`                | Project overview and execution guide            |

---

# Disclaimer

This implementation is intended to demonstrate an illustrative regulatory reporting framework and governance-aware analytics workflow.

It is not intended to represent a finalised regulatory submission without formal Compliance, Finance, and Regulatory Reporting approval.
