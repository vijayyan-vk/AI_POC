#!/bin/bash

# =====================================================================
# Script: Multi-Language Table Manipulation Operations
# Language: Shell (Bash)
# Operations: INSERT, SELECT, UPDATE, DELETE, MERGE, TRUNCATE
# Purpose: Demonstrates CRUD operations on random test tables
# Author: AI Assistant
# Date: June 2, 2026
# =====================================================================

set -e  # Exit on error

# =====================================================================
# Configuration
# =====================================================================
DB_USER="dev_user_26ai"
DB_PASSWORD="your_password_here"
DB_SID="gcf91c40155de9b_vkatp26ai_low"
TABLE_NAME="TBL_0001_AAAAAAAA"
SOURCE_TABLE="TBL_0001_AAAAAAAA"
TARGET_TABLE="TBL_0002_BBBBBBBB"
TEMP_TABLE="TBL_0003_CCCCCCCC"

# Oracle SQL*Plus connection string
CONNECT_STRING="${DB_USER}/${DB_PASSWORD}@${DB_SID}"

# =====================================================================
# Helper Functions
# =====================================================================

# Execute SQL query
execute_sql() {
    local sql="$1"
    sqlplus -s "${CONNECT_STRING}" <<EOF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
${sql}
EXIT;
EOF
}

# Execute SQL with output
execute_sql_with_output() {
    local sql="$1"
    sqlplus "${CONNECT_STRING}" <<EOF
SET ECHO OFF
${sql}
EXIT;
EOF
}

# Print section header
print_header() {
    echo ""
    echo "=================================="
    echo "$1"
    echo "=================================="
}

# =====================================================================
# OPERATION 1: INSERT - Add new rows to test table
# =====================================================================
insert_operation() {
    print_header "[1] INSERT OPERATION - Adding new records"
    
    for i in {1..5}; do
        local id=$((200 + i))
        local col_01="INSERT_Test_${i}"
        local col_02=$(awk -v seed="$RANDOM" 'BEGIN {srand(seed); printf "%.2f", rand() * 8000 + 1000}')
        local col_03=$(date +"%d-%b-%y")
        
        local sql="INSERT INTO ${TABLE_NAME} (ID, COL_01, COL_02, COL_03) VALUES (${id}, '${col_01}', ${col_02}, TO_DATE('${col_03}', 'DD-MON-YY'));"
        
        execute_sql "SET ECHO ON
        ${sql}
        COMMIT;"
        
        echo "✓ Inserted row $i: ID=$id, COL_01=$col_01, COL_02=$col_02"
    done
    
    echo "✓ INSERT Operation Completed - 5 rows inserted"
}

# =====================================================================
# OPERATION 2: SELECT - Retrieve and display data
# =====================================================================
select_operation() {
    print_header "[2] SELECT OPERATION - Retrieving records"
    
    local sql="SELECT ID, COL_01, COL_02 FROM ${TABLE_NAME} WHERE ROWNUM <= 5;"
    
    echo "SELECT ID, COL_01, COL_02 FROM ${TABLE_NAME} WHERE ROWNUM <= 5;" | sqlplus "${CONNECT_STRING}" | grep -v "^$" | head -20
    
    echo "✓ SELECT Operation Completed"
}

# =====================================================================
# OPERATION 3: UPDATE - Modify existing records
# =====================================================================
update_operation() {
    print_header "[3] UPDATE OPERATION - Modifying records"
    
    local sql="UPDATE ${TABLE_NAME} SET COL_02 = COL_02 + 100 WHERE ID >= 1 AND ID <= 5;
    COMMIT;
    SELECT COUNT(*) as rows_updated FROM ${TABLE_NAME} WHERE ID >= 1 AND ID <= 5;"
    
    execute_sql_with_output "${sql}"
    
    echo "✓ UPDATE Operation Completed"
}

# =====================================================================
# OPERATION 4: DELETE - Remove specific records
# =====================================================================
delete_operation() {
    print_header "[4] DELETE OPERATION - Removing records"
    
    local sql="DELETE FROM ${TABLE_NAME} WHERE ID >= 200 AND ID <= 204;
    COMMIT;
    SELECT 'Deleted rows successfully' FROM DUAL;"
    
    execute_sql_with_output "${sql}"
    
    echo "✓ DELETE Operation Completed"
}

# =====================================================================
# OPERATION 5: MERGE - Conditional insert/update operations
# =====================================================================
merge_operation() {
    print_header "[5] MERGE OPERATION - Conditional DML"
    
    local merge_sql="MERGE INTO ${TARGET_TABLE} t
    USING (SELECT * FROM ${SOURCE_TABLE} WHERE ROWNUM <= 3) s
    ON (t.ID = s.ID)
    WHEN MATCHED THEN 
        UPDATE SET t.COL_02 = s.COL_02 + 50
    WHEN NOT MATCHED THEN 
        INSERT (ID, COL_01, COL_02, COL_03) 
        VALUES (s.ID, s.COL_01, s.COL_02, s.COL_03);
    COMMIT;
    SELECT 'MERGE completed' FROM DUAL;"
    
    execute_sql_with_output "${merge_sql}"
    
    echo "✓ MERGE Operation Completed"
}

# =====================================================================
# OPERATION 6: TRUNCATE - Remove all records from table
# =====================================================================
truncate_operation() {
    print_header "[6] TRUNCATE OPERATION - Removing all records"
    
    local sql="TRUNCATE TABLE ${TEMP_TABLE};
    SELECT 'Table truncated successfully' FROM DUAL;"
    
    execute_sql_with_output "${sql}"
    
    echo "✓ TRUNCATE Operation Completed"
}

# =====================================================================
# Main Execution
# =====================================================================
main() {
    echo ""
    echo "==============================================="
    echo "Shell Script Table Manipulation - All Operations"
    echo "==============================================="
    
    # Verify database connection
    if ! echo "SELECT 1 FROM DUAL;" | sqlplus -s "${CONNECT_STRING}" > /dev/null 2>&1; then
        echo "✗ Failed to connect to database"
        echo "  Connection string: ${CONNECT_STRING}"
        exit 1
    fi
    
    echo "✓ Database connection established"
    
    # Execute all operations
    insert_operation
    select_operation
    update_operation
    delete_operation
    merge_operation
    truncate_operation
    
    echo ""
    echo "==============================================="
    echo "All Shell Operations Completed Successfully"
    echo "==============================================="
}

# Run main function
main "$@"