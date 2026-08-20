-- =============================================================================
-- Script: analysis_queries.sql
-- Description: Core SQL Analytics Suite for NHS Outpatient Attendance
-- Author: Lead Data Analyst
-- Engine: MySQL 8.0+
-- =============================================================================

USE NHS_Outpatient_DB;

-- -----------------------------------------------------------------------------
-- QUERY 1: EXECUTIVE BASELINE SCORECARD METRICS
-- -----------------------------------------------------------------------------
SELECT 
    COUNT(appointment_id) AS total_scheduled_appointments,
    SUM(is_noshow) AS total_missed_appointments,
    COUNT(appointment_id) - SUM(is_noshow) AS total_attended_appointments,
    ROUND(SUM(is_noshow) * 100.0 / COUNT(appointment_id), 2) AS overall_noshow_rate_pct
FROM clean_appointments;


-- -----------------------------------------------------------------------------
-- QUERY 2: LEAD TIME BREAKDOWN & ATTENDANCE DECAY RATE
-- -----------------------------------------------------------------------------
SELECT 
    lead_time_category,
    COUNT(appointment_id) AS total_appointments,
    SUM(is_noshow) AS total_noshows,
    ROUND(SUM(is_noshow) * 100.0 / NULLIF(COUNT(appointment_id), 0), 2) AS noshow_rate_pct
FROM clean_appointments
GROUP BY lead_time_category
ORDER BY 
    CASE lead_time_category
        WHEN '0 Days (Same Day)' THEN 1
        WHEN '1-3 Days' THEN 2
        WHEN '4-7 Days' THEN 3
        WHEN '8-14 Days' THEN 4
        WHEN '15-30 Days' THEN 5
        ELSE 6
    END;


-- -----------------------------------------------------------------------------
-- QUERY 3: DAY OF WEEK ATTENDANCE VOLUME & NO-SHOW TRENDS
-- -----------------------------------------------------------------------------
SELECT 
    appointment_day_of_week,
    COUNT(appointment_id) AS total_appointments,
    SUM(is_noshow) AS total_noshows,
    ROUND(SUM(is_noshow) * 100.0 / NULLIF(COUNT(appointment_id), 0), 2) AS noshow_rate_pct
FROM clean_appointments
GROUP BY appointment_day_of_week
ORDER BY total_appointments DESC;


-- -----------------------------------------------------------------------------
-- QUERY 4: UNCOVERING SIMPSON'S PARADOX (SMS REMINDERS × LEAD TIME)
-- -----------------------------------------------------------------------------
SELECT 
    lead_time_category,
    CASE WHEN sms_received = 1 THEN 'SMS Received' ELSE 'No SMS' END AS sms_status,
    COUNT(appointment_id) AS total_appointments,
    SUM(is_noshow) AS total_noshows,
    ROUND(SUM(is_noshow) * 100.0 / NULLIF(COUNT(appointment_id), 0), 2) AS noshow_rate_pct
FROM clean_appointments
GROUP BY lead_time_category, sms_received
ORDER BY 
    CASE lead_time_category
        WHEN '0 Days (Same Day)' THEN 1
        WHEN '1-3 Days' THEN 2
        WHEN '4-7 Days' THEN 3
        WHEN '8-14 Days' THEN 4
        WHEN '15-30 Days' THEN 5
        ELSE 6
    END,
    sms_received DESC;


-- -----------------------------------------------------------------------------
-- QUERY 5: TOP 10 HIGH-VOLUME NEIGHBOURHOODS VS NO-SHOW RATE
-- -----------------------------------------------------------------------------
SELECT 
    neighbourhood,
    COUNT(appointment_id) AS total_appointments,
    SUM(is_noshow) AS total_noshows,
    ROUND(SUM(is_noshow) * 100.0 / NULLIF(COUNT(appointment_id), 0), 2) AS noshow_rate_pct
FROM clean_appointments
GROUP BY neighbourhood
ORDER BY total_appointments DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- QUERY 6: CHRONIC CONDITION PROFILE VS COMPLIANCE RATE
-- -----------------------------------------------------------------------------
SELECT 
    CASE WHEN has_chronic_condition = 1 THEN 'Has Chronic Illness' ELSE 'No Chronic Illness' END AS chronic_profile,
    COUNT(appointment_id) AS total_appointments,
    SUM(is_noshow) AS total_noshows,
    ROUND(SUM(is_noshow) * 100.0 / NULLIF(COUNT(appointment_id), 0), 2) AS noshow_rate_pct
FROM clean_appointments
GROUP BY has_chronic_condition;
