-- =============================================================================
-- Script: data_cleaning.sql
-- Description: MySQL Data Cleaning, Normalisation, & Feature Engineering ETL Script
-- Author: Lead Data Analyst
-- Engine: MySQL 8.0+
-- =============================================================================

USE NHS_Outpatient_DB;

DROP TABLE IF EXISTS clean_appointments;

CREATE TABLE clean_appointments AS
SELECT
    -- Primary Keys & Identifiers
    CAST(AppointmentID AS UNSIGNED) AS appointment_id,
    CAST(PatientId AS UNSIGNED) AS patient_id,
    
    -- Gender Normalisation
    CASE
        WHEN Gender = 'F' THEN 'Female'
        WHEN Gender = 'M' THEN 'Male'
        ELSE 'Others'
    END AS gender,
    
    -- Demographics & Age Cohort Categorisation
    Age AS age,
    CASE 
        WHEN Age BETWEEN 0 AND 17 THEN '0-17 Pediatric'
        WHEN Age BETWEEN 18 AND 35 THEN '18-35 Young Adult'
        WHEN Age BETWEEN 36 AND 60 THEN '36-60 Adult'
        ELSE '61+ Senior'
    END AS age_group,
    
    -- Location & Neighbourhood String Trimming
    TRIM(Neighbourhood) AS neighbourhood,
    
    -- Temporal Timestamps & Dates
    ScheduledDay AS scheduled_datetime,
    AppointmentDay AS appointment_datetime,
    CAST(ScheduledDay AS DATE) AS scheduled_date,
    CAST(AppointmentDay AS DATE) AS appointments_date,
    HOUR(ScheduledDay) AS scheduled_hour,
    DAYNAME(AppointmentDay) AS appointment_day_of_week,
    
    -- Lead Time Calculation & Granular Categorisation
    DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) AS lead_time_days,
    CASE 
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) <= 0 THEN '0 Days (Same Day)'
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) BETWEEN 1 AND 3 THEN '1-3 Days'
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) BETWEEN 4 AND 7 THEN '4-7 Days'
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) BETWEEN 8 AND 14 THEN '8-14 Days'
        WHEN DATEDIFF(CAST(AppointmentDay AS DATE), CAST(ScheduledDay AS DATE)) BETWEEN 15 AND 30 THEN '15-30 Days'
        ELSE '31+ Days'
    END AS lead_time_category,
    
    -- Welfare & Chronic Medical Flags
    Scholarship AS welfare_assistance,
    Hipertension AS hypertension,
    Diabetes AS diabetes, 
    Alcoholism AS alcoholism,
    Handcap AS disability,
    CASE
        WHEN Hipertension = 1 OR Diabetes = 1 OR Alcoholism = 1 OR Handcap > 0 THEN 1
        ELSE 0
    END AS has_chronic_condition,
    
    -- Digital Communication & Attendance Metrics
    SMS_received AS sms_received,
    CASE WHEN `No-show` = 'Yes' THEN 1 ELSE 0 END AS is_noshow,
    CASE WHEN `No-show` = 'Yes' THEN 'No-Show' ELSE 'Attended' END AS attendance_status

FROM raw_appointments 
WHERE Age >= 0;

-- Set Primary Key constraint on clean_appointments
ALTER TABLE clean_appointments ADD PRIMARY KEY (appointment_id);
