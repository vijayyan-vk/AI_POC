# SEGMENT_TEST_TABLE - Multi-Technology DML Operations

**Created:** May 22, 2026  
**Database:** Oracle 23.26.2.2.0 (ATP - Always Free Tier)  
**User:** dev_user_26ai  
**Table:** SEGMENT_TEST_TABLE (10,000 rows)

---

## Overview

This project demonstrates **all DML operations** (INSERT, UPDATE, DELETE, SELECT) across **5 different technologies**, ensuring comprehensive multi-language database integration patterns.

---

## Technologies Implemented

### 1. **PL/SQL (Oracle Native)**
- **File:** Compiled in Database (segment_test_pkg)
- **Operations:** All DML (INSERT, UPDATE, DELETE, SELECT)
- **Type:** Package with procedures
- **Status:** ✅ Compiled & Ready

**Package Name:** `segment_test_pkg`

**Procedures Available:**
```sql
-- INSERT
EXEC segment_test_pkg.insert_transaction(
    p_customer_id => 101,
    p_order_id => 1001,
    p_product_id => 501,
    p_transaction_amount => 1500.50,
    p_customer_name => 'John Doe',
    p_product_name => 'Premium Product'
);

-- BULK INSERT
EXEC segment_test_pkg.bulk_insert_transactions(100);

-- UPDATE
EXEC segment_test_pkg.update_transaction(
    p_transaction_id => 10001,
    p_transaction_amount => 2000.75,
    p_status_code => 2,
    p_payment_status => 'COMPLETED'
);

-- UPDATE BY STATUS
EXEC segment_test_pkg.update_by_status(1, 2);

-- DELETE
EXEC segment_test_pkg.delete_transaction(10001);

-- SELECT (via cursor)
DECLARE
    v_cursor SYS_REFCURSOR;
BEGIN
    segment_test_pkg.get_transaction(10001, v_cursor);
END;
```

---

### 2. **Python 3.x**
- **File:** `segment_dml_python.py`
- **Operations:** INSERT, UPDATE (bulk operations)
- **Library:** cx_Oracle
- **Status:** ✅ Ready to Execute

**Installation:**
```bash
pip install cx_Oracle python-dotenv
```

**Usage:**
```bash
python segment_dml_python.py
```

**Features:**
- Single transaction insert
- Bulk insert (50+ records)
- Update transaction by ID
- Update by status code
- Error handling & rollback

---

### 3. **JavaScript/Node.js**
- **File:** `segment_dml_javascript.js`
- **Operations:** DELETE (primary), SELECT (supporting)
- **Library:** oracledb
- **Status:** ✅ Ready to Execute

**Installation:**
```bash
npm install oracledb dotenv
```

**Usage:**
```bash
node segment_dml_javascript.js
```

**Features:**
- Delete single transaction
- Delete by status code
- Delete by date range
- Delete archived transactions
- Bulk delete (multiple records)

---

### 4. **Shell Script (Bash)**
- **File:** `segment_dml_shell.sh`
- **Operations:** SELECT, UPDATE
- **Tool:** SQLPlus
- **Status:** ✅ Ready to Execute

**Installation:**
```bash
chmod +x segment_dml_shell.sh
```

**Usage:**
```bash
# SELECT operations
./segment_dml_shell.sh select_all
./segment_dml_shell.sh select_by_id 10001
./segment_dml_shell.sh select_by_status 1
./segment_dml_shell.sh select_summary

# UPDATE operations
./segment_dml_shell.sh update 10001 2500.00 2 "PAID"
./segment_dml_shell.sh update_status 1 2
./segment_dml_shell.sh update_payment 10001 "COMPLETED"
```

**Features:**
- Select all transactions (with limit)
- Select by ID
- Select by status code
- Transaction summary
- Update single transaction
- Update by status
- Update payment status

---

### 5. **Go Language**
- **File:** `segment_dml_go.go`
- **Operations:** All DML (INSERT, UPDATE, DELETE, SELECT)
- **Library:** database/sql with godror driver
- **Status:** ✅ Ready to Compile & Execute

**Installation:**
```bash
go get github.com/godror/godror
```

**Build:**
```bash
go build -o segment_dml_go segment_dml_go.go
```

**Usage:**
```bash
# Demo (all operations)
./segment_dml_go -op demo

# Insert
./segment_dml_go -op insert -cust 101 -order 1001 -prod 501 -amount 1500.50

# Bulk Insert
./segment_dml_go -op bulk

# Update
./segment_dml_go -op update -id 10001 -amount 2000.75 -status 2

# Delete
./segment_dml_go -op delete -id 10001

# Select
./segment_dml_go -op select -id 10001

# All Records
./segment_dml_go -op all
```

**Features:**
- All DML operations in single binary
- Command-line flag-based operation selection
- Bulk operations support
- Error handling and rollback
- Connection pooling

---

## Environment Variables

All scripts use the following environment variables (with defaults):

```bash
export DB_USER="dev_user_26ai"
export DB_PASSWORD="your_password"
export DB_HOST="adb.us-phoenix-1.oraclecloud.com"
export DB_PORT="1522"
export DB_SERVICE="gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com"
export TNS_ADMIN="$HOME/wallet"  # For Oracle Wallet (if needed)
```

**Or create `.env` file:**
```
DB_USER=dev_user_26ai
DB_PASSWORD=your_password
DB_HOST=adb.us-phoenix-1.oraclecloud.com
DB_PORT=1522
DB_SERVICE=gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com
```

---

## SEGMENT_TEST_TABLE Structure

```
Column Name               | Data Type      | Nullable
--------------------------|----------------|----------
TRANSACTION_ID           | NUMBER         | N (PK)
CUSTOMER_ID              | NUMBER         | Y
ORDER_ID                 | NUMBER         | Y
PRODUCT_ID               | NUMBER         | Y
SUPPLIER_ID              | NUMBER         | Y
TRANSACTION_DATE         | DATE           | Y
CREATION_DATE            | DATE           | Y
UPDATE_DATE              | DATE           | Y
TRANSACTION_AMOUNT       | NUMBER         | Y
TAX_AMOUNT               | NUMBER         | Y
DISCOUNT_AMOUNT          | NUMBER         | Y
SHIPPING_COST            | NUMBER         | Y
TOTAL_AMOUNT             | NUMBER         | Y
STATUS_CODE              | NUMBER         | Y
PAYMENT_METHOD_ID        | NUMBER         | Y
SHIPPING_METHOD_ID       | NUMBER         | Y
WAREHOUSE_ID             | NUMBER         | Y
PRODUCT_NAME             | VARCHAR2       | Y
CUSTOMER_NAME            | VARCHAR2       | Y
CITY                     | VARCHAR2       | Y
STATE                    | VARCHAR2       | Y
COUNTRY                  | VARCHAR2       | Y
POSTAL_CODE              | VARCHAR2       | Y
EMAIL                    | VARCHAR2       | Y
PHONE                    | VARCHAR2       | Y
TRANSACTION_DESC         | VARCHAR2       | Y
NOTES                    | VARCHAR2       | Y
REFERENCE_NUMBER         | VARCHAR2       | Y
INVOICE_NUMBER           | VARCHAR2       | Y
PO_NUMBER                | VARCHAR2       | Y
TRACKING_NUMBER          | VARCHAR2       | Y
QUANTITY                 | NUMBER         | Y
UNIT_PRICE               | NUMBER         | Y
COMMISSION_AMOUNT        | NUMBER         | Y
PROFIT_MARGIN            | NUMBER         | Y
CURRENCY_CODE            | CHAR           | Y
PAYMENT_STATUS           | VARCHAR2       | Y
FULFILLMENT_STATUS       | VARCHAR2       | Y
RETURN_STATUS            | VARCHAR2       | Y
SOURCE_SYSTEM            | VARCHAR2       | Y
DATA_SOURCE              | VARCHAR2       | Y
BATCH_ID                 | NUMBER         | Y
PROCESS_ID               | NUMBER         | Y
ERROR_CODE               | VARCHAR2       | Y
ERROR_MESSAGE            | VARCHAR2       | Y
RETRY_COUNT              | NUMBER         | Y
IS_PROCESSED             | CHAR           | Y
IS_ARCHIVED              | CHAR           | Y
```

**Total Rows:** 10,000  
**Sequence:** SEGMENT_TEST_TABLE_SEQ (starts at 10001)

---

## Quick Start Guide

### Step 1: Set Up Environment
```bash
# Create .env file with your credentials
cat > .env << EOF
DB_USER=dev_user_26ai
DB_PASSWORD=your_password
DB_HOST=adb.us-phoenix-1.oraclecloud.com
DB_PORT=1522
DB_SERVICE=gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com
EOF
```

### Step 2: Test PL/SQL Package
```bash
# Connect to Oracle and run:
sqlplus dev_user_26ai/password@database

-- Insert test record
EXEC segment_test_pkg.insert_transaction(101, 1001, 501, 1500.50, 'John', 'Product');

-- Verify
SELECT COUNT(*) FROM SEGMENT_TEST_TABLE;
```

### Step 3: Run Python Script
```bash
python segment_dml_python.py
```

### Step 4: Run JavaScript Script
```bash
node segment_dml_javascript.js
```

### Step 5: Run Shell Script
```bash
chmod +x segment_dml_shell.sh
./segment_dml_shell.sh select_all
```

### Step 6: Build & Run Go Program
```bash
go build -o segment_dml_go segment_dml_go.go
./segment_dml_go -op demo
```

---

## Key Features Across All Technologies

| Feature | PL/SQL | Python | JavaScript | Shell | Go |
|---------|--------|--------|------------|-------|-----|
| INSERT  | ✅     | ✅     | ❌         | ❌    | ✅   |
| UPDATE  | ✅     | ✅     | ❌         | ✅    | ✅   |
| DELETE  | ✅     | ❌     | ✅         | ❌    | ✅   |
| SELECT  | ✅     | ✅     | ✅         | ✅    | ✅   |
| Bulk Ops| ✅     | ✅     | ✅         | ❌    | ✅   |
| Error Handling | ✅ | ✅ | ✅ | ✅ | ✅ |
| Transaction Support | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Connection Strings

**Oracle SQL Developer (Direct):**
```
dev_user_26ai / password @ adb.us-phoenix-1.oraclecloud.com:1522:gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com
```

**Easy Connect (23c+):**
```
dev_user_26ai/password@adb.us-phoenix-1.oraclecloud.com:1522/gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com
```

**TNS Name Entry:**
```
VKATP26AI_LOW = (description=(retry_count=20)(retry_delay=3)
(address=(protocol=tcps)(port=1522)
(host=adb.us-phoenix-1.oraclecloud.com))
(connect_data=(service_name=gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com))
(security=(ssl_server_dn_match=yes)))
```

---

## Troubleshooting

### Python Connection Issues
```bash
# Ensure cx_Oracle is installed
python -c "import cx_Oracle; print(cx_Oracle.__version__)"

# Check environment variables
echo $DB_USER
echo $DB_HOST
```

### Node.js Connection Issues
```bash
# Ensure oracledb is installed
npm list oracledb

# Check Node version
node --version
```

### Shell Script Issues
```bash
# Make executable
chmod +x segment_dml_shell.sh

# Check SQLPlus installation
which sqlplus
sqlplus -version
```

### Go Build Issues
```bash
# Install godror
go get github.com/godror/godror

# Build with verbose output
go build -v -o segment_dml_go segment_dml_go.go
```

---

## Best Practices

1. **Error Handling:** All scripts include comprehensive error handling and rollback mechanisms
2. **Parameterized Queries:** All SQL queries use parameterized statements to prevent SQL injection
3. **Connection Pooling:** Applications establish and reuse connections efficiently
4. **Logging:** All operations log success/failure with relevant details
5. **Transaction Management:** All DML operations are wrapped in transactions with proper commit/rollback

---

## Files in This Project

```
├── segment_dml_plsql.sql         (PL/SQL Package - compiled in DB)
├── segment_dml_python.py         (Python: INSERT, UPDATE)
├── segment_dml_javascript.js     (JavaScript: DELETE)
├── segment_dml_shell.sh          (Shell: SELECT, UPDATE)
├── segment_dml_go.go             (Go: All DML)
├── README.md                     (This file)
└── .env.example                  (Environment template)
```

---

## Support & Documentation

For detailed information on each technology, refer to:
- **PL/SQL:** Oracle 23c PL/SQL User's Guide
- **Python:** cx_Oracle documentation
- **JavaScript:** oracledb documentation
- **Shell:** Oracle SQLPlus User's Guide
- **Go:** godror documentation

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-22 | Initial multi-technology implementation |

---

**Last Updated:** May 22, 2026  
**Project Status:** ✅ Production Ready  
**Compatibility:** Oracle 23c+, Go 1.19+, Python 3.7+, Node.js 14+
