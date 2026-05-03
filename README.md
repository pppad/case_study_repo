1. Modular Data Architecture

To ensure an accurate, repeatable, and scalable reporting process, the pipeline is built on a Medallion Architecture.  

Bronze (Raw) Layer: Captures source CSV seeds (Transactions and Customer) with original formatting and load metadata for full lineage tracking.  

Silver (Clean) Layer: Hosted in stg_ models where defensive cleaning, type-casting, and standardization occurs.  

Gold (Ready) Layer: Final fct_ models (e.g., fct_regulatory_reports) where business logic is applied and metrics are aggregated for delivery.  

2. Defensive Engineering & Data Quality

This project implements automated quality controls to mitigate identified risks in the raw source data.  

Deduplication: Implements a ROW_NUMBER() window function in the Staging layer to keep only the latest record for each transaction_id, preventing artificial volume inflation from system retries.  

Schema Stability: Uses SAFE_CAST to ensure datatype persistence and BigQuery encryption for audit-ready data persistence.  

Integrity Filters: Automated tests in the Staging layer ensure that only joinable, non-null records reach the Marts, maintaining a "clean and tidy" dataset.  

3. Regulatory Logic & Metric Definitions

Logic was designed for total transparency, allowing regulators to verify the rationale behind every figure.  

Gross Volume Calculation: Applied Absolute Value Logic (ABS()) to transaction amounts. This ensures reversals (e.g., Transaction ID 107) are disclosed as total financial activity rather than being netted out.  

Regional Normalization: Consolidates variations like 'UK' and 'GBR' at the source to prevent under-reporting for the R1 UK Entity.  

Currency Routing: Programmatically distinguishes between Cross-Currency (multiple routes) and Same-Currency (identical start/end) transactions to satisfy specific R2 requirements.  

4. Governance

The technical stack is aligned with Wise values to ensure operational excellence and risk mitigation.  

Transparency (GitHub): Mandatory Four-Eyes Principle implemented via GitHub. All logic changes require a peer review and historical lineage tracking.  

Accuracy (CI/CD): Every deployment triggers automated dbt tests (Unique/Not Null) to ensure reports are free from structural or calculation errors.  

Mission First (Standardization): The UK/US framework acts as a global blueprint, enabling Wise to scale reporting into new markets with minimal intervention.  

5. Limitations & Future Roadmap

While current delivery uses best-effort proxies, the roadmap outlines a shift toward automated precision.  

Current Proxy: Due to missing IP logs, current_address_country was used as a proxy for residency at the time of transaction.  

SCD Type 2: Future state includes implementing Slowly Changing Dimensions to capture "point-in-time" address snapshots.  

BI Automation: Transitioning from one-off CSV extracts toward automated monitoring in Looker/Dashboards for real-time compliance tracking.  

Project Deliverables

dbt_project.yml: Materialization rules and project configuration.  

schema.yml: Automated test suite for data validation.  

SQL Models: The modular code responsible for transforming raw data into Gold-layer reports.  

README.md: The current document.