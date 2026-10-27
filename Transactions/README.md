# Transactions REST API (IBM App Connect Enterprise)

A complete REST API service for banking transactions built for **IBM App Connect Enterprise (ACE)** using **ESQL** and backed by **PostgreSQL** for persistence.

---

## 📌 Overview

This project implements the complete lifecycle for financial transactions associated with bank accounts:
- **Create**: Add a new transaction (with account ID, amount, type, etc.)
- **Retrieve**: Fetch details of a specific transaction by its ID
- **Update**: Modify transaction details (status, description, amount, etc.)
- **Delete**: Remove a transaction record
- **List**: Query transactions with optional filtering by `accountId` and `status`

### Key Highlights
- **PostgreSQL Persistence**: Employs native ACE ESQL database queries (`INSERT`, `SELECT`, `UPDATE`, `DELETE`) referencing datasource `MY_PG_DSN`.
- **Account Association**: Requires and validates `accountId` on all created transactions.
- **Contract-First Design**: OpenAPI 3.0 specification (`openapi.json`) synchronized with the ACE REST API descriptor (`restapi.descriptor`).
- **Resilient ESQL Coding**: Uses `FIELDVALUE(...)`, strict type-checking, case-tolerant property extraction, `(JSON.Array)` typing, and dual-casing fallbacks for ODBC column names.

---

## 📁 Project Structure

```
transactions/
├── .project                                  # Eclipse & ACE Toolkit project definition
├── .settings/
│   └── org.eclipse.core.resources.prefs      # Resource encoding preferences (UTF-8)
├── restapi.descriptor                        # ACE REST API operation mappings
├── openapi.json                              # OpenAPI 3.0 API definition
├── schema.sql                                # PostgreSQL DDL and seed data script
├── skills.md                                 # Technical and integration knowledge notes
├── README.md                                 # Project documentation and test guide
│
├── gen/
│   └── Transactions.msgflow                  # Generated REST API main message flow
│
├── createTransaction.subflow                 # Subflow: POST /v1/transactions
├── createTransaction_Compute.esql            # ESQL: Insert into PostgreSQL
│
├── getTransaction.subflow                    # Subflow: GET /v1/transactions/{transactionId}
├── getTransaction_Compute.esql               # ESQL: Single row query
│
├── updateTransaction.subflow                 # Subflow: PUT /v1/transactions/{transactionId}
├── updateTransaction_Compute.esql            # ESQL: Database UPDATE
│
├── deleteTransaction.subflow                 # Subflow: DELETE /v1/transactions/{transactionId}
├── deleteTransaction_Compute.esql            # ESQL: Database DELETE
│
├── listTransactions.subflow                  # Subflow: GET /v1/transactions
└── listTransactions_Compute.esql             # ESQL: Multi-row query & JSON array builder
```

---

## 🗄️ Database Setup (PostgreSQL)

Execute `schema.sql` against your PostgreSQL database:

```bash
psql -h localhost -U postgres -d banking_db -f schema.sql
```

### Table Definition (`public.transactions`)
| Column | Type | Constraints | Description |
|---|---|---|---|
| `transaction_id` | `VARCHAR(64)` | `PRIMARY KEY` | Unique transaction ID (e.g., `TXN-1001` or generated `TXN-YYMMDDHHMM`) |
| `account_id` | `VARCHAR(64)` | `NOT NULL` | Associated bank account identifier |
| `amount` | `NUMERIC(15, 2)` | `NOT NULL` | Monetary value |
| `currency` | `VARCHAR(3)` | `NOT NULL DEFAULT 'USD'` | Currency ISO code |
| `transaction_type` | `VARCHAR(20)` | `CHECK IN ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'PAYMENT')` | Type of transaction |
| `status` | `VARCHAR(20)` | `CHECK IN ('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED')` | Lifecycle status |
| `description` | `VARCHAR(255)` | | Optional description / narration |
| `created_date` | `TIMESTAMP` | `NOT NULL DEFAULT CURRENT_TIMESTAMP` | Creation timestamp |
| `updated_date` | `TIMESTAMP` | `NOT NULL DEFAULT CURRENT_TIMESTAMP` | Last updated timestamp |

### ACE ODBC Runtime Configuration

1. In `/var/mqsi/odbc/odbc.ini` (or `$ODBCINI`):
```ini
[ODBC Data Sources]
MY_PG_DSN=PostgreSQL Wire Protocol

[MY_PG_DSN]
Driver=/opt/ibm/ace-12.0.12.0/server/ODBC/drivers/lib/UKsqls95.so
Description=IBM App Connect Enterprise PostgreSQL Wire Protocol
Database=banking_db
HostName=localhost
PortNumber=5432
LogonID=postgres
Password=secret
```

2. Register credentials with the ACE Integration Node:
```bash
mqsisetdbparms <IntegrationNodeName> -n odbc::MY_PG_DSN -u postgres -p secret
mqsicvp <IntegrationNodeName> -n MY_PG_DSN
```

---

## 🚀 API Endpoints & Testing

Base path: `/v1/transactions`

### 1. Create Transaction
- **Method**: `POST`
- **Path**: `/v1/transactions/`
- **Request Body**:
```json
{
  "accountId": "ACC-10001",
  "amount": 250.75,
  "currency": "USD",
  "transactionType": "DEPOSIT",
  "status": "COMPLETED",
  "description": "Salary deposit"
}
```
- **Curl**:
```bash
curl -X POST http://localhost:7800/v1/transactions/ \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "ACC-10001",
    "amount": 250.75,
    "currency": "USD",
    "transactionType": "DEPOSIT",
    "status": "COMPLETED",
    "description": "Salary deposit"
  }'
```
- **Response**: `201 Created`

---

### 2. Retrieve Transaction by ID
- **Method**: `GET`
- **Path**: `/v1/transactions/{transactionId}`
- **Curl**:
```bash
curl -X GET http://localhost:7800/v1/transactions/TXN-1001
```
- **Response**: `200 OK`
```json
{
  "transactionId": "TXN-1001",
  "accountId": "ACC-10001",
  "amount": 500.00,
  "currency": "USD",
  "transactionType": "DEPOSIT",
  "status": "COMPLETED",
  "description": "Initial opening deposit",
  "createdDate": "2026-10-12 10:00:00",
  "updatedDate": "2026-10-12 10:00:00"
}
```

---

### 3. Update Transaction by ID
- **Method**: `PUT`
- **Path**: `/v1/transactions/{transactionId}`
- **Request Body**:
```json
{
  "status": "CANCELLED",
  "description": "Customer requested cancellation"
}
```
- **Curl**:
```bash
curl -X PUT http://localhost:7800/v1/transactions/TXN-1001 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "CANCELLED",
    "description": "Customer requested cancellation"
  }'
```
- **Response**: `200 OK`

---

### 4. Delete Transaction by ID
- **Method**: `DELETE`
- **Path**: `/v1/transactions/{transactionId}`
- **Curl**:
```bash
curl -X DELETE http://localhost:7800/v1/transactions/TXN-1001
```
- **Response**: `204 No Content` (Empty body)

---

### 5. List All Transactions (with Filters)
- **Method**: `GET`
- **Path**: `/v1/transactions/`
- **Query Parameters**:
  - `accountId` (optional): e.g. `?accountId=ACC-1001`
  - `status` (optional): e.g. `?status=COMPLETED`
- **Curl**:
```bash
# List all transactions
curl -X GET http://localhost:7800/v1/transactions/
# Filter by account ID
curl -X GET "http://localhost:7800/v1/transactions?accountId=ACC-1001"

# Filter by account ID and status
curl -X GET "http://localhost:7800/v1/transactions?accountId=ACC-1001&status=COMPLETED"
```
- **Response**: `200 OK` (Array of transactions)
