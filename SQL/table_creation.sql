-- =============================================================================
-- Script: table_creation.sql
-- Description: Define raw schema for appointment encounter records
-- Author: Lead Data Analyst
-- Engine: MySQL 8.0+
-- =============================================================================

USE NHS_Outpatient_DB;

DROP TABLE IF EXISTS raw_appointments;

CREATE TABLE raw_appointments (
    PatientId BIGINT NOT NULL,
    AppointmentID BIGINT NOT NULL PRIMARY KEY,
    Gender VARCHAR(10) NOT NULL,
    ScheduledDay DATETIME NOT NULL,
    AppointmentDay DATETIME NOT NULL,
    Age INT NOT NULL,
    Neighbourhood VARCHAR(255) NOT NULL,
    Scholarship INT NOT NULL,
    Hipertension INT NOT NULL,
    Diabetes INT NOT NULL,
    Alcoholism INT NOT NULL,
    Handcap INT NOT NULL,
    SMS_received INT NOT NULL,
    `No-show` VARCHAR(10) NOT NULL
);
