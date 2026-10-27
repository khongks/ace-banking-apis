# Skills & Architectural Patterns - Transactions REST API

## Integration Technologies
- IBM App Connect Enterprise (ACE) / IBM Integration Bus style REST API implementation
- ESQL compute module development for PostgreSQL database integration
- Message flow and subflow-based service orchestration
- REST API descriptor configuration mapped to generated message flows (`gen/Transactions.msgflow`)

## API Design & Specifications
- OpenAPI 3.0 contract-first REST API definition (`openapi.json`)
- CRUD and List operations for banking transactions:
  - `createTransaction` (POST `/v1/transactions/`)
  - `getTransaction` (GET `/v1/transactions/{transactionId}`)
  - `updateTransaction` (PUT `/v1/transactions/{transactionId}`)
  - `deleteTransaction` (DELETE `/v1/transactions/{transactionId}`)
  - `listTransactions` (GET `/v1/transactions/` with `accountId` and `status` query filters)
- Full request/response JSON schema definitions
- Standard HTTP status code modeling:
  - `200 OK`: Successful retrieval, update, or list query
  - `201 Created`: Successful creation of transaction
  - `204 No Content`: Successful deletion with empty body
  - `400 Bad Request`: Validation failure or missing payload
  - `404 Not Found`: Transaction resource does not exist
  - `409 Conflict`: Duplicate transaction ID collision

## Database & Persistence (PostgreSQL)
- Native ACE ESQL relational database access without using `PASSTHRU`:
  - `THE(SELECT * FROM Database.{DBSchema}.{DBTable} AS T WHERE ...)` for single row retrieval
  - Multi-row `SELECT` into `ROW` arrays (`transaction.Transaction[]`) for list operations
  - Parameterized `INSERT INTO Database.{DBSchema}.{DBTable} (...) VALUES (...)`
  - Parameterized `UPDATE Database.{DBSchema}.{DBTable} AS T SET ... WHERE ...`
  - Parameterized `DELETE FROM Database.{DBSchema}.{DBTable} AS T WHERE ...`
- ODBC datasource resolution via `Database.{DBSchema}.{DBTable}` using `MY_PG_DSN`
- Handling column case-sensitivity between PostgreSQL ODBC drivers and ACE ESQL (`COALESCE(txRow.transaction_id, txRow.TRANSACTION_ID)`)
- Relational schema modeling with constraints (`PRIMARY KEY`, `NOT NULL`, `CHECK`) and indexes

## Data Transformation and Validation
- JSON payload parsing with `FIELDVALUE(...)` scalar extraction
- Mandatory field validations (`accountId`, `amount`, `transactionType`)
- Enumeration validation for `transactionType` (`DEPOSIT`, `WITHDRAWAL`, `TRANSFER`, `PAYMENT`)
- Enumeration validation for `status` (`PENDING`, `COMPLETED`, `FAILED`, `CANCELLED`)
- Dynamic ID generation using `UUIDASCHAR` when `transactionId` is omitted
- Partial/complete field merging on update operations

## Integration Runtime Patterns
- Preserving HTTP transport context downstream via `CopyMessageHeaders()`
- Manipulation of `InputRoot`, `OutputRoot`, and `OutputLocalEnvironment.Destination.HTTP.ReplyStatusCode`
- Typed array creation with `CREATE FIELD OutputRoot.JSON.Data IDENTITY (JSON.Array)Data;`
- Reference-based navigation using `WHILE LASTMOVE(refTx) DO ... MOVE refTx NEXTSIBLING NAME 'Transaction';`
- Completely blank payload propagation on `204 No Content` via `SET OutputRoot.JSON = NULL;`
