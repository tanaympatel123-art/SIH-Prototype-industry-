-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 01_create_database.sql
-- Target DBMS: MySQL 8.x / MariaDB (XAMPP / phpMyAdmin Compatible)
-- ==============================================================================

-- 1. Create Database with utf8mb4 encoding for full Unicode & emoji support
CREATE DATABASE IF NOT EXISTS sih26044_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2. Switch to the newly created database context
USE sih26044_db;
