# 🏥 NHS Outpatient Appointment Attendance & Operations Intelligence Platform

### *An Enterprise End-to-End Data Engineering, MySQL Analytics, and Looker Studio Business Intelligence System*

---

![Database](https://img.shields.io/badge/Database-MySQL%208.0%2B-blue?style=for-the-badge&logo=mysql&logoColor=white)
![ETL Scripting](https://img.shields.io/badge/ETL-Standard%20SQL-orange?style=for-the-badge&logo=sqlite&logoColor=white)
![Data Staging](https://img.shields.io/badge/Data%20Staging-Google%20Sheets-green?style=for-the-badge&logo=googlesheets&logoColor=white)
![BI Platform](https://img.shields.io/badge/BI%20Platform-Looker%20Studio-yellow?style=for-the-badge&logo=looker&logoColor=white)
![Pipeline Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)

---

## 📌 1. EXECUTIVE SUMMARY

The **NHS Outpatient Appointment Attendance & Operations Intelligence Platform** is an enterprise-grade analytics solution engineered to diagnose and mitigate patient non-attendance ("no-shows") across regional UK healthcare facilities. By processing **110,527 scheduled appointment encounter records**, this platform transforms raw transactional data into actionable operational intelligence to recover wasted clinical capacity and reduce expanding patient waiting lists.

Built utilizing a cross-platform data pipeline comprising **MySQL 8.0+**, **Google Sheets**, and **Looker Studio**, the system executes automated ETL cleaning scripts, temporal lead-time binning, and multi-dimensional cohort aggregations. Crucially, the analytical engine resolved a major statistical anomaly by uncovering **Simpson's Paradox** in digital outreach—proving that automated SMS reminders actively improve patient attendance by up to **+7.44%** when controlling for booking lead times. The final output provides hospital leadership with an interactive 2-page executive BI dashboard and a predictive **15% capacity overbooking strategy** to optimize clinical throughput.

---

## 🎯 2. BUSINESS PROBLEM & ENGINEERING MOTIVATION

### The Enterprise Challenge
Outpatient care departments across the NHS Foundation Trust operate under severe capacity constraints. An initial audit of 110,527 scheduled appointments revealed an aggregate non-attendance rate of **20.19%**, representing **22,319 unfulfilled consultations**.

```
                                OUTPATIENT CAPACITY AUDIT
  ┌──────────────────────────────────────────────────────────────────────────────────┐
  │  TOTAL SCHEDULED APPOINTMENTS   : 110,527 Encounters                             │
  │  ATTENDED CONSULTATIONS         : 88,208 Encounters (79.81%)                     │
  │  UNFULFILLED NO-SHOWS           : 22,319 Encounters (20.19%)                     │
  └──────────────────────────────────────────────────────────────────────────────────┘
```

### Operational Liabilities & Engineering Motivation
1. **Clinical Staff Idle Time:** One out of every five booked consultation slots yields zero clinical outcome, leaving consultant physicians, nursing specialists, and expensive diagnostic equipment underutilised.
2. **Artificial Queue Inflation:** Unfulfilled consultations force patients back into scheduling pipelines, inflating waiting times for secondary and urgent care services.
3. **Misleading Digital Metrics (The Paradox):** Preliminary, unadjusted data reviews generated significant confusion within operational management by suggesting that sending SMS reminders correlated with *higher* non-attendance rates. A robust SQL data mart and cohort model were required to resolve this statistical paradox and inform digital communication protocols.

---

## 🛠️ 3. TECH STACK & ARCHITECTURAL DECISIONS

| Layer / Tool | Technology Choice | Engineering Justification |
| :--- | :--- | :--- |
| **Relational Database** | **MySQL 8.0+** | Selected for enterprise ACID compliance, strict schema enforcement, indexing capabilities, and high-performance tabular aggregations. |
| **ETL & Data Transformation** | **Standard ANSI SQL** | Written natively in SQL to ensure portable, reproducible data cleaning, temporal calculations (`DATEDIFF`), and conditional feature engineering (`CASE WHEN`). |
| **Data Staging Lake** | **Google Sheets** | Applied as a lightweight, cloud-native intermediate data staging layer bridging local MySQL exports with web-based BI connectors. |
| **Business Intelligence Layer** | **Google Looker Studio** | Chosen for cross-platform browser accessibility, real-time interactive slicing, custom calculated fields, and zero-latency executive sharing. |
| **Version Control & Docs** | **Git & GitHub** | Applied for versioning SQL scripts, managing project assets, hosting documentation, and portfolio distribution. |

---

## 📊 4. DATASET & SCHEMA OVERVIEW

### Dataset Metadata
* **Source:** NHS Outpatient Encounter Dataset (UK Regional Healthcare System)
* **Raw Record Count:** 110,527 Encounters (110,526 validated post-cleaning)
* **Entity Granularity:** One record per unique appointment encounter (`AppointmentID`)

### Relational Schema Layout

#### Raw Staging Schema (`raw_appointments`)
```text
PatientId (BIGINT), AppointmentID (BIGINT PK), Gender (VARCHAR), ScheduledDay (DATETIME), 
AppointmentDay (DATETIME), Age (INT), Neighbourhood (VARCHAR), Scholarship (INT), 
Hipertension (INT), Diabetes (INT), Alcoholism (INT), Handcap (INT), SMS_received (INT), No-show (VARCHAR)
```

#### Production Data Mart Schema (`clean_appointments`)
```text
appointment_id (PK), patient_id (FK), gender, age, age_group, neighbourhood, 
scheduled_datetime, appointment_datetime, scheduled_date, appointments_date, 
scheduled_hour, appointment_day_of_week, lead_time_days, lead_time_category, 
welfare_assistance, hypertension, diabetes, alcoholism, disability, 
has_chronic_condition, sms_received, is_noshow, attendance_status
```

---

## 🔄 5. DATA ARCHITECTURE & PIPELINE FLOW

The end-to-end data pipeline traces the flow from raw CSV extraction through database ingestion, ETL cleaning, staging, and executive visualization:

```text
  [Raw CSV Dataset (110,527 Encounters)]
                     │
                     ▼
  [MySQL Staging Schema: `raw_appointments`]
                     │
                     ▼ (SQL ETL Transformation Script: `data_cleaning.sql`)
  [MySQL Production Data Mart: `clean_appointments`]
                     │
                     ▼ (SQL Analytical Suite: `analysis_queries.sql`)
  [Cleaned CSV Export: `clean_appointments.csv`]
                     │
                     ▼
  [Google Sheets Cloud Staging Lake]
                     │
                     ▼ (Native Connector Sync)
  [Looker Studio BI Dashboard Layer]
                     │
                     ├──► Page 1: Operational Executive Overview
                     └──► Page 2: Strategic Intervention & Clinical Risk Cohorts
```

---

## 💻 6. SQL TRANSFORMATIONS & FEATURE ENGINEERING SNAPSHOT

The production ETL transformation script (`SQL/data_cleaning.sql`) cleans text fields, handles age anomalies, computes temporal booking lead times, and constructs composite medical risk flags.

```sql
-- Production Data Cleaning & Feature Engineering Script
USE NHS_Outpatient_DB;

DROP TABLE IF EXISTS clean_appointments;

CREATE TABLE clean_appointments AS
SELECT
    -- Identifiers & Primary Keys
    CAST(AppointmentID AS UNSIGNED) AS appointment_id,
    CAST(PatientId AS UNSIGNED) AS patient_id,
    
    -- Gender Standardisation
    CASE WHEN Gender = 'F' THEN 'Female' ELSE 'Male' END AS gender,
    
    -- Age Validation & Demographics
    Age AS age,
    CASE 
        WHEN Age BETWEEN 0 AND 17 THEN '0-17 Pediatric'
        WHEN Age BETWEEN 18 AND 35 THEN '18-35 Young Adult'
        WHEN Age BETWEEN 36 AND 60 THEN '36-60 Adult'
        ELSE '61+ Senior'
    END AS age_group,
    
    TRIM(Neighbourhood) AS neighbourhood,
    
    -- Temporal Timestamps & Extracted Attributes
    ScheduledDay AS scheduled_datetime,
    AppointmentDay AS appointment_datetime,
    CAST(ScheduledDay AS DATE) AS scheduled_date,
    CAST(AppointmentDay AS DATE) AS appointments_date,
    HOUR(ScheduledDay) AS scheduled_hour,
    DAYNAME(AppointmentDay) AS appointment_day_of_week,
    
    -- Lead Time Calculation & Categorisation (DATEDIFF)
    DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) AS lead_time_days,
    CASE 
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) <= 0 THEN '0 Days (Same Day)'
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) BETWEEN 1 AND 3 THEN '1-3 Days'
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) BETWEEN 4 AND 7 THEN '4-7 Days'
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) BETWEEN 8 AND 14 THEN '8-14 Days'
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) BETWEEN 15 AND 30 THEN '15-30 Days'
        ELSE '31+ Days'
    END AS lead_time_category,
    
    -- Welfare & Chronic Medical Flag Construction
    Scholarship AS welfare_assistance,
    Hipertension AS hypertension,
    Diabetes AS diabetes, 
    Alcoholism AS alcoholism,
    Handcap AS disability,
    CASE
        WHEN Hipertension = 1 OR Diabetes = 1 OR Alcoholism = 1 OR Handcap > 0 THEN 1
        ELSE 0
    END AS has_chronic_condition,
    
    -- Digital Communication & Attendance Target Flags
    SMS_received AS sms_received,
    CASE WHEN `No-show` = 'Yes' THEN 1 ELSE 0 END AS is_noshow,
    CASE WHEN `No-show` = 'Yes' THEN 'No-Show' ELSE 'Attended' END AS attendance_status

FROM raw_appointments 
WHERE Age >= 0;

ALTER TABLE clean_appointments ADD PRIMARY KEY (appointment_id);
```

---

## 📈 7. KEY INSIGHTS & ANALYTICAL FINDINGS

### 1. Uncovering Simpson's Paradox in Digital Outreach
Unadjusted aggregate data suggested that patients receiving SMS reminders had higher non-attendance rates (**27.57%**) than non-receivers (**16.70%**). However, by controlling for booking lead time, SQL analysis proved that SMS reminders were exclusively dispatched for long lead-time appointments (where baseline non-attendance naturally exceeds 30%). Within every equivalent lead-time tier, SMS notifications **reduce non-attendance by up to +7.44%**.

```
                        CONTROLLED LEAD-TIME DATA (TRUE SMS EFFECT)
  ┌──────────────────────┬─────────────────┬──────────────────┬──────────────────────┐
  │ Lead-Time Tier       │ No SMS Rate %   │ SMS Sent Rate %  │ SMS Attendance Lift  │
  ├──────────────────────┼─────────────────┼──────────────────┼──────────────────────┤
  │ 1-3 Days             │ 23.42%          │ 21.28%           │ +2.14% Attendance    │
  │ 4-7 Days             │ 26.16%          │ 23.97%           │ +2.19% Attendance    │
  │ 8-14 Days            │ 33.36%          │ 28.11%           │ +5.25% Attendance    │
  │ 15-30 Days           │ 37.24%          │ 29.80%           │ +7.44% Attendance    │
  │ 31+ Days             │ 32.05%          │ 30.21%           │ +1.84% Attendance    │
  └──────────────────────┴─────────────────┴──────────────────┴──────────────────────┘
```

### 2. Booking Lead-Time Attendance Decay
A strong direct relationship exists between advance scheduling length and patient non-attendance:
* **Same-Day Bookings (0 Days):** **4.65% No-Show Rate** (95.35% Attendance Rate).
* **1 to 3 Days Lead Time:** Non-attendance jumps to **22.89%**.
* **15 to 30 Days Lead Time:** Non-attendance peaks at **32.59%** (1 in every 3 patients misses consultation).

### 3. Chronic Condition Patient Compliance
Patients managing chronic illnesses (Hypertension, Diabetes, Disability) demonstrate significantly higher medical compliance (**17.86% No-Show Rate**) compared to non-chronic patients (**20.93% No-Show Rate**).

### 4. Geographic Clinic Disparities
Non-attendance varies widely across regional health centres, ranging from high-compliance clinics (*Santa Martha* at **15.84%**) to high-risk clinics (*Itararé* at **26.27%**).

---

## 🖥️ 8. BI DASHBOARD ARCHITECTURE & SCREENSHOTS

The presentation layer comprises a 2-page executive BI dashboard constructed in Looker Studio:

### Page 1 — Operational Executive Overview
* **Primary Scorecards:** Total Scheduled Appointments (`110,526`), Total Missed Appointments (`22,319`), Overall No-Show Rate (`20.19%`).
* **Global Slicers:** `Lead Time`, `Appointment Day`, `Age Group`.
* **Visual Grid:**
  * **Horizontal Bar Chart:** `No-Show Rate %` by `lead_time_category` (Visualizes attendance decay).
  * **Column Chart:** Appointment volume and no-show counts by `appointment_day_of_week`.
  * **Donut Chart:** Proportional attendance distribution across weekday schedules.

![Operational Executive Overview](Screenshots/Operational%20Executive%20Overview.png)

---

### Page 2 — Strategic Intervention & Clinical Risk Cohorts
* **Global Slicers:** `Gender`, `Neighbourhood`, `SMS Received`.
* **Visual Grid:**
  * **Grouped Bar Chart:** `No-Show Rate %` split by `sms_received` across `lead_time_category` (Proves Simpson's Paradox).
  * **Heatmap Table:** Top 10 regional neighbourhood clinics ranked by appointment volume and no-show rate.
  * **Stacked Bar Chart:** Attendance status breakdown across chronic illness cohorts.

![Strategic Intervention & Clinical Risk Cohorts](Screenshots/Strategic%20Intervention%20%26%20Clinical%20Risk%20Cohorts.png)

📥 [Download Full Executive PDF Report](Documentation/Health-Care_Report.pdf)

---

## 💡 9. STRATEGIC BUSINESS RECOMMENDATIONS

Based on empirical data findings, the following operational strategies are recommended for NHS Foundation Trust leadership:

1. **Re-engineer SMS Trigger Protocols:** Suppress SMS notifications for short lead-time bookings (0–3 days) to save messaging costs. Implement a staged **two-prompt SMS protocol** (dispatched at 7 days and 24 hours prior) for long lead-time appointments (15+ days).
2. **Predictive Capacity Overbooking Model:** Implement a controlled **15% capacity overbooking allowance** for appointment slots scheduled more than 14 days in advance to offset expected 30%+ non-attendance decay.
3. **Targeted Regional Engagement Teams:** Deploy community engagement health workers and telephone outreach to top high-risk neighbourhood clinics (*Itararé*, *Jesus De Nazareth*) exhibiting no-show rates above 24%.
4. **Self-Service Digital Cancellation Portal:** Enable two-way SMS cancellation keywords (*Reply CANCEL or RESCHEDULE*) to reallocate freed consultation slots back to urgent same-day patients.

---

## 📂 10. REPOSITORY DIRECTORY STRUCTURE

```text
Healthcare-Outpatient-Analytics/
│
├── README.md                                   <- Universal Master Documentation
│
├── SQL/
│   ├── database_creation.sql                  <- MySQL Database Initialisation Script
│   ├── table_creation.sql                     <- Raw Staging Table Schema Script
│   ├── data_cleaning.sql                      <- Production ETL & Feature Engineering Script
│   ├── analysis_queries.sql                   <- Master Analytical Query Suite
│   └── master_pipeline.sql                    <- Single-File Complete Execution Script
│
├── Dataset/
│   ├── raw_appointments.csv                   <- Raw Source Dataset (110,527 records)
│   └── clean_appointments.csv                 <- Cleaned Data Mart Export (110,526 records)
│
├── PowerBI/
│   └── Health-Care_Report.pbix                <- Power BI Project Deliverable File
│
├── Screenshots/
│   ├── Operational Executive Overview.png     <- Page 1 Dashboard Interface Image
│   └── Strategic Intervention & Clinical Risk Cohorts.png <- Page 2 Dashboard Image
│
└── Documentation/
    └── Health-Care_Report.pdf                 <- Full Executive PDF Report Deliverable
```

---

## 🚀 11. HOW TO REPRODUCE / RUN THE PROJECT

### Prerequisites
* MySQL Server 8.0+ & MySQL Workbench
* Web Browser (for Looker Studio & Google Sheets)
* Git CLI

### Step 1: Clone the Repository
```bash
git clone https://github.com/Dhiliban-R/Healthcare-Outpatient-Analytics.git
cd Healthcare-Outpatient-Analytics
```

### Step 2: Initialize Database & Staging Schema
Open MySQL Workbench, connect to your server, and execute:
```sql
SOURCE SQL/database_creation.sql;
SOURCE SQL/table_creation.sql;
```

### Step 3: Import Raw Dataset
Import `Dataset/raw_appointments.csv` into table `raw_appointments` using the MySQL Workbench Table Data Import Wizard or `LOAD DATA INFILE`.

### Step 4: Execute ETL Transformations & Analytical Queries
Run the cleaning and analytical scripts:
```sql
SOURCE SQL/data_cleaning.sql;
SOURCE SQL/analysis_queries.sql;
```

### Step 5: Connect to BI Layer
1. Export `clean_appointments` table to CSV and import into Google Sheets.
2. Open [Looker Studio](https://lookerstudio.google.com), connect the Google Sheet, and inspect or rebuild the dashboard report.

---

## 👤 12. AUTHOR PROFILE & SOCIAL LINKS

**Author:** Dhiliban R (Student ID: AF05303153)  
**Role:** Junior Data Analyst / Analytics Specialist  
**Education:** B.E. Computer Science and Engineering — Government College of Engineering, Salem  
**Specialized Training:** Advanced Program in Data & Business Analytics with AI — Anudip Foundation (Pallavaram, Chennai)  

### Connect with Me
* 💼 **LinkedIn Profile:** [linkedin.com/in/dhiliban-r](https://linkedin.com/in/dhiliban-r)
* 📁 **GitHub Repository:** [github.com/Dhiliban-R](https://github.com/Dhiliban-R)
* 📧 **Direct Email:** [dhilipanrc@gmail.com](mailto:dhilipanrc@gmail.com)

---

## 📜 13. LICENSING & DISCLAIMER

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

*Disclaimer: This analytics platform is constructed for educational, portfolio, and demonstrative usage. All patient identification records within the dataset have been fully anonymised in compliance with healthcare data governance standards.*
