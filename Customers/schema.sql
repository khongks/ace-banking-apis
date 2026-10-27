-- =============================================================================
-- PostgreSQL Database Schema for Customers REST API
-- Project: Customers
-- IBM App Connect Enterprise (ACE) / ESQL Integration
--
-- To execute an external .sql file directly from the command line using psql, use the -f (or --file) flag:
-- psql -h hostname -U username -d dbname -f
-- =============================================================================

-- 1. Create table public.transactions
CREATE TABLE IF NOT EXISTS public.customers (
    customer_id      VARCHAR(64)    NOT NULL,
    first_name       VARCHAR(32)    NOT NULL,
    last_name        VARCHAR(32)    NOT NULL,
    email            VARCHAR(48)    NOT NULL,
    phone            VARCHAR(16)    NOT NULL,
    date_of_birth    VARCHAR(16)    NOT NULL,
    status           VARCHAR(20)    NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

-- 2. Indexes for query optimization
CREATE INDEX IF NOT EXISTS idx_customers_status 
    ON public.customers(status);

-- 3. Optional sample test records
INSERT INTO public.customers (customer_id, first_name, last_name, email, phone, date_of_birth, status) VALUES 
('CUS-000000000001', 'John', 'Smith', 'john.smith@example.com', '+61411222333', '1980-05-12', 'ACTIVE'),
('CUS-000000000002', 'Sarah', 'Johnson', 'sarah.j@example.com', '+61422333444', '1985-09-23', 'ACTIVE'),
('CUS-000000000003', 'Michael', 'Brown', 'mbrown@example.com', '+61433444555', '1975-01-15', 'ACTIVE'),
('CUS-000000000004', 'Emily', 'Davis', 'emily.d@example.com', '+61444555666', '1992-11-04', 'ACTIVE'),
('CUS-000000000005', 'David', 'Wilson', 'dwilson@example.com', '+61455667788', '1988-06-30', 'INACTIVE'),
('CUS-000000000006', 'Jessica', 'Taylor', 'jtaylor@example.com', '+61466778899', '1995-03-21', 'ACTIVE'),
('CUS-000000000007', 'James', 'Anderson', 'janderson@example.com', '+61477889900', '1979-12-11', 'ACTIVE'),
('CUS-000000000008', 'Laura', 'Thomas', 'lthomas@example.com', '+61488990011', '1990-08-19', 'ACTIVE'),
('CUS-000000000009', 'Robert', 'Jackson', 'rjackson@example.com', '+61499001122', '1983-04-05', 'INACTIVE'),
('CUS-000000000010', 'Linda', 'White', 'lwhite@example.com', '+61400112233', '1997-10-14', 'ACTIVE');

-- =============================================================================
-- IBM App Connect Enterprise ODBC Setup Guide for PostgreSQL
-- =============================================================================
--
-- 1. odbc.ini configuration (e.g. /var/mqsi/odbc/odbc.ini or $ODBCINI):
--
--    [ODBC Data Sources]
--    MY_PG_DSN=PostgreSQL Wire Protocol
--
--    [MY_PG_DSN]
--    Driver=/opt/ibm/ace-13.0.9.0/server/ODBC/drivers/lib/UKsqls95.so  (or DataDirect / psqlODBC driver)
--    Description=IBM App Connect Enterprise PostgreSQL Wire Protocol
--    Database=banking_db
--    HostName=localhost
--    PortNumber=5432
--    LogonID=postgres
--    Password=secret
--
-- 2. Configure credentials in ACE Integration Node / Server using mqsisetdbparms:
--
--    mqsisetdbparms <IntegrationNodeName> -n odbc::MY_PG_DSN -u <dbuser> -p <dbpassword>
--
--    For independent integration server:
--    mqsisetdbparms --work-dir <work-dir> -n odbc::MY_PG_DSN -u <dbuser> -p <dbpassword>
--
-- 3. Verify connection:
--
--    mqsicvp <IntegrationNodeName> -n MY_PG_DSN
--
-- =============================================================================
