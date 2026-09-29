# NHS Outpatient Appointment Attendance & Operations Intelligence Platform

## Industry
**Healthcare – Hospital Operations & Outpatient Care Analytics**

## Project Overview

The **NHS Outpatient Appointment Attendance & Operations Intelligence Platform** is an enterprise data analytics and business intelligence solution engineered to evaluate patient non-attendance ("no-shows") across hospital outpatient departments.

The project utilizes **MySQL and SQL** for database creation, table schema design, data cleansing, feature engineering, and cohort analysis, alongside **Looker Studio / Power BI** for multi-page interactive executive dashboards.

By analyzing over 110,000 patient encounters, the platform identifies scheduling bottlenecks, evaluates digital reminder effectiveness (uncovering Simpson's Paradox), isolates demographic risk cohorts, and delivers actionable operational interventions to reduce waiting times and optimize clinical capacity.

### Business Areas Covered
- Appointment volume and attendance tracking
- Booking lead-time decay analysis
- Digital communications (SMS reminder) effectiveness
- Chronic condition patient compliance profiling
- Geographic & neighborhood clinic demand analysis
- Demographic (Age/Gender) risk segmentation

---

## Project Objectives

- Build a structured relational database model for outpatient encounter records.
- Standardise patient demographic, scheduling, and clinical condition variables.
- Evaluate the impact of booking lead times on appointment non-attendance rates.
- Resolve Simpson's Paradox regarding SMS reminder effectiveness across lead-time tiers.
- Measure patient compliance among chronic illness cohorts (Hypertension, Diabetes, Alcoholism).
- Identify high-volume neighborhood clinics with elevated non-attendance rates.
- Construct a 2-page interactive BI dashboard for clinical leadership.
- Formulate strategic operational recommendations for NHS Foundation Trust leadership.

---

## Tools & Technologies

| Tool / Technology | Purpose |
|---|---|
| **MySQL 8.0+** | Database creation, data warehousing, and tabular storage |
| **SQL** | Data cleaning, feature engineering, CTEs, and aggregation analytics |
| **Looker Studio / Power BI** | Multi-page interactive executive dashboard development |
| **Google Sheets / Excel** | Intermediate data staging layer |
| **GitHub** | Version control, documentation, and portfolio publishing |

---

## Dataset Description

The project utilizes an enterprise **NHS Outpatient Encounter Dataset** containing 110,527 scheduled appointment records.

### Key Dataset Columns

```text
AppointmentID, PatientId, Gender, ScheduledDay, AppointmentDay,
Age, Neighbourhood, Scholarship, Hipertension, Diabetes, 
Alcoholism, Handcap, SMS_received, No-show
```

### Processed Analytical Schema (`clean_appointments`)

```text
appointment_id, patient_id, gender, age, age_group, neighbourhood,
scheduled_datetime, appointment_datetime, scheduled_date, appointments_date,
scheduled_hour, appointment_day_of_week, lead_time_days, lead_time_category,
welfare_assistance, hypertension, diabetes, alcoholism, disability,
has_chronic_condition, sms_received, is_noshow, attendance_status
```

---

## Database Design

The database structure centres on the `clean_appointments` analytical table derived from raw staging data.

```text
  [raw_appointments (Staging Table)]
                 │
                 ▼ (Data Cleaning & Feature Engineering ETL)
  [clean_appointments (Primary Analytical Data Mart)]
                 │
                 ├──► Key Metrics (Total Appointments, No-Show Rate)
                 ├──► Dimension Grids (Lead Time, Day of Week, Neighbourhood)
                 └──► Clinical Profiles (Chronic Conditions, Age Groups)
```

---

## SQL Analysis

SQL scripts were used to build the database, clean raw text fields, calculate lead times, handle division safeguards, and perform executive cohort analysis.

### Database & Schema Creation

```sql
CREATE DATABASE IF NOT EXISTS NHS_Outpatient_DB;
USE NHS_Outpatient_DB;
```

### Data Validation & Cleaning Snapshot

```sql
-- Normalising lead times and binary attendance flags
CREATE TABLE clean_appointments AS
SELECT
    CAST(AppointmentID AS UNSIGNED) AS appointment_id,
    CAST(PatientId AS UNSIGNED) AS patient_id,
    CASE WHEN Gender = 'F' THEN 'Female' ELSE 'Male' END AS gender,
    Age AS age,
    CASE 
        WHEN Age BETWEEN 0 AND 17 THEN '0-17 Pediatric'
        WHEN Age BETWEEN 18 AND 35 THEN '18-35 Young Adult'
        WHEN Age BETWEEN 36 AND 60 THEN '36-60 Adult'
        ELSE '61+ Senior'
    END AS age_group,
    DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) AS lead_time_days,
    CASE WHEN `No-show` = 'Yes' THEN 1 ELSE 0 END AS is_noshow
FROM raw_appointments
WHERE Age >= 0;
```

---

## BI Dashboard Architecture

The executive presentation layer is structured into two dedicated report pages:

### Page 1 — Operational Executive Overview
- **Scorecards:** Total Scheduled Appointments (`110,526`), Total Missed Appointments (`22,319`), Overall No-Show Rate (`20.19%`).
- **Global Slicers:** `Lead Time`, `Appointment Day`, `Age Group`.
- **Lead Time Breakdown (Bar Chart):** Demonstrates non-attendance decay from 4.66% (Same Day) to 33.00% (31+ Days).
- **Day of Week Breakdown (Column Chart):** Highlights volume distribution across weekdays.
- **Attendance Distribution (Donut Chart):** Proportional attendance across weekday consultations.

### Page 2 — Strategic Intervention & Clinical Risk Cohorts
- **Global Slicers:** `Gender`, `Neighbourhood`, `SMS Received`.
- **Uncovering Simpson's Paradox (Grouped Bar Chart):** Proves that SMS notifications reduce non-attendance when controlling for lead-time tiers.
- **Top 10 High-Volume Neighbourhoods (Heatmap Table):** Ranks clinic locations by volume and no-show rate.
- **Chronic Condition Profile (Stacked Bar Chart):** Compares compliance across chronic illness cohorts.

---

## Key KPIs

| KPI | Business Purpose | Value |
|---|---|---|
| **Total Scheduled Appointments** | Measures total outpatient encounter volume | **110,526** |
| **Total Missed Appointments** | Measures total non-attendance encounters | **22,319** |
| **Overall No-Show Rate %** | Baseline percentage of unfulfilled consultations | **20.19%** |
| **Same-Day No-Show Rate %** | Non-attendance for immediate bookings | **4.66%** |
| **Long Lead-Time No-Show Rate %**| Non-attendance for 31+ day advance bookings | **33.00%** |
| **Chronic Condition Compliance** | Attendance rate among chronic illness cohorts | **82.14%** |

---

## Key Insights

1. **Simpson's Paradox Discovered:** Aggregate data suggested SMS reminders increased no-shows (27.57% vs 16.70%). Controlled analysis proved SMS messages were only sent for long lead times (which have a higher baseline decay). Within equal lead time windows, SMS reminders consistently improve attendance.
2. **Lead-Time Attendance Decay:** Non-attendance escalates sharply with scheduling lead time, climbing from **4.66%** for same-day bookings to **33.00%** for appointments booked 31+ days in advance.
3. **Chronic Condition Compliance:** Patients with chronic medical conditions (Hypertension, Diabetes) exhibit lower non-attendance rates (**17.86%**) compared to non-chronic patients (**20.93%**).
4. **Geographic Concentration:** Non-attendance rates vary across clinics, with specific neighborhoods (e.g., *Santos Dumont* at 28.92%) demonstrating significant operational friction compared to the Trust baseline.

---

## Project Workflow

```text
Raw Dataset (110,527 Records)
     ↓
Data Inspection & Schema Audit
     ↓
MySQL Database Creation
     ↓
SQL Data Cleaning & Feature Engineering
     ↓
SQL Analytics & Cohort Queries
     ↓
Data Staging & Integration
     ↓
Looker Studio / Power BI Dashboard Build
     ↓
Executive Presentation & Insight Generation
     ↓
Operational Recommendations
```

---

## Repository Structure

```text
Healthcare-Outpatient-Analytics/
│
├── README.md
│
├── SQL/
│   ├── database_creation.sql
│   ├── table_creation.sql
│   ├── data_cleaning.sql
│   └── analysis_queries.sql
│
├── Dataset/
│   ├── raw_appointments.csv
│   └── clean_appointments.csv
│
├── PowerBI/
│   └── Health-Care_Report.pbix
│
├── Screenshots/
│   ├── Operational Executive Overview.png
│   └── Strategic Intervention & Clinical Risk Cohorts.png
│
└── Documentation/
    └── Health-Care_Report.pdf
```

---

## Dashboard Screenshots & Deliverables

### 1. Page 1 — Operational Executive Overview
![Operational Executive Overview](Screenshots/Operational%20Executive%20Overview.png)

### 2. Page 2 — Strategic Intervention & Clinical Risk Cohorts
![Strategic Intervention & Clinical Risk Cohorts](Screenshots/Strategic%20Intervention%20%26%20Clinical%20Risk%20Cohorts.png)

### Executive PDF Report
📥 [Download Full Executive PDF Report](Documentation/Health-Care_Report.pdf)

---

## How to Run the Project

### 1. Clone the Repository
```bash
git clone https://github.com/Dhiliban-R/Healthcare-Outpatient-Analytics.git
cd Healthcare-Outpatient-Analytics
```

### 2. Create MySQL Database & Tables
Open **MySQL Workbench** or terminal shell and execute:
```sql
SOURCE SQL/database_creation.sql;
SOURCE SQL/table_creation.sql;
```

### 3. Clean & Transform Data
Execute the ETL script to generate the `clean_appointments` table:
```sql
SOURCE SQL/data_cleaning.sql;
```

### 4. Run Analytical Queries
Execute the cohort queries:
```sql
SOURCE SQL/analysis_queries.sql;
```

### 5. View Dashboard
Open the interactive report file or view `Documentation/Health-Care_Report.pdf`.

---

## Recommendations & Strategic Interventions

- **Re-engineer SMS Dispatch Rules:** Eliminate SMS messages for short lead-time bookings (0–3 days) and deploy staged multi-prompt SMS triggers at 14, 7, and 2 days prior to long lead-time appointments.
- **Dynamic Overbooking Model:** Introduce a **15% capacity overbooking allowance** for appointments scheduled more than 14 days in advance to offset expected non-attendance decay.
- **Targeted Clinic Resources:** Deploy localized patient engagement teams to top high-risk neighborhood clinics showing no-show rates above 25%.

---

## Author & Acknowledgements

**Author:** Dhiliban R (AF05303153)  
**Role:** Junior Data Analyst  
**Education:** B.E. Computer Science and Engineering, Government College of Engineering, Salem  
**Professional Upskilling:** Advanced Program in Data & Business Analytics with AI – Anudip Foundation (Pallavaram, Chennai)  

### Connect & Follow
- 💼 **LinkedIn:** [linkedin.com/in/dhiliban-r](https://linkedin.com/in/dhiliban-r)
- 📁 **GitHub Repository:** [github.com/dhiliban-r](https://github.com/dhiliban-r)
- 📧 **Email:** [dhilipanr01@gmail.com](mailto:dhilipanr01@gmail.com)

---

## License

This project is created for **educational, portfolio, and data analytics demonstration purposes**.
