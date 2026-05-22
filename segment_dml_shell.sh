#!/bin/bash

###############################################################################
# Shell Script for SEGMENT_TEST_TABLE - SELECT and UPDATE Operations
# Technology: Bash Shell with SQLPlus
# Purpose: Perform SELECT and UPDATE operations on SEGMENT_TEST_TABLE
# Usage: ./segment_dml_shell.sh [operation] [params]
###############################################################################

set -e

# Configuration
DB_USER="${DB_USER:-dev_user_26ai}"
DB_PASSWORD="${DB_PASSWORD:-your_password}"
DB_HOST="${DB_HOST:-adb.us-phoenix-1.oraclecloud.com}"
DB_PORT="${DB_PORT:-1522}"
DB_SERVICE="${DB_SERVICE:-gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com}"
TNS_ADMIN="${TNS_ADMIN:-$HOME/wallet}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

log_error() {
    echo -e "${RED}✗ $1${NC}"
}

log_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

###############################################################################
# SELECT Operations
###############################################################################

# SELECT all transactions
select_all_transactions() {
    log_info "Retrieving all transactions..."
    
    sqlplus -S -L "${DB_USER}/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}" <<EOF
SET PAGESIZE 100
SET LINESIZE 200
SET COLSEP '|'
SET ECHO OFF
COLUMN TRANSACTION_ID FORMAT 999999
COLUMN CUSTOMER_ID FORMAT 99999
COLUMN TRANSACTION_AMOUNT FORMAT 99999.99
COLUMN STATUS_CODE FORMAT 99

SELECT 
    TRANSACTION_ID, 
    CUSTOMER_ID, 
    ORDER_ID, 
    PRODUCT_ID, 
    TRANSACTION_AMOUNT,
    STATUS_CODE,
    PAYMENT_STATUS,
    CREATION_DATE
FROM SEGMENT_TEST_TABLE 
ORDER BY TRANSACTION_ID DESC
FETCH FIRST 20 ROWS ONLY;

EXIT;
EOF
    
    log_success "Transaction retrieval completed"
}

# SELECT by transaction ID
select_transaction_by_id() {
    local transaction_id=$1
    
    if [ -z "$transaction_id" ]; then
        log_error "Transaction ID is required"
        return 1
    fi
    
    log_info "Retrieving transaction ID: $transaction_id..."
    
    sqlplus -S -L "${DB_USER}/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}" <<EOF
SET PAGESIZE 50
SET LINESIZE 200
SET ECHO OFF

SELECT * FROM SEGMENT_TEST_TABLE WHERE TRANSACTION_ID = $transaction_id;

EXIT;
EOF
    
    if [ $? -eq 0 ]; then
        log_success "Transaction retrieved: $transaction_id"
    else
        log_error "Failed to retrieve transaction: $transaction_id"
        return 1
    fi
}

# SELECT by status code
select_by_status() {
    local status_code=$1
    
    if [ -z "$status_code" ]; then
        log_error "Status code is required"
        return 1
    fi
    
    log_info "Retrieving transactions with status: $status_code..."
    
    sqlplus -S -L "${DB_USER}/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}" <<EOF
SET PAGESIZE 100
SET LINESIZE 200
SET ECHO OFF
COLUMN COUNT(*) FORMAT 99999

SELECT COUNT(*) as TOTAL_COUNT FROM SEGMENT_TEST_TABLE WHERE STATUS_CODE = $status_code;

SELECT 
    TRANSACTION_ID, 
    CUSTOMER_NAME, 
    TRANSACTION_AMOUNT,
    STATUS_CODE,
    CREATION_DATE
FROM SEGMENT_TEST_TABLE 
WHERE STATUS_CODE = $status_code
ORDER BY TRANSACTION_ID DESC
FETCH FIRST 20 ROWS ONLY;

EXIT;
EOF
    
    log_success "Status query completed"
}

# SELECT with aggregation
select_transaction_summary() {
    log_info "Retrieving transaction summary..."
    
    sqlplus -S -L "${DB_USER}/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}" <<EOF
SET PAGESIZE 50
SET LINESIZE 200
SET ECHO OFF
COLUMN COUNT FORMAT 99999
COLUMN AVG_AMOUNT FORMAT 99999.99
COLUMN MAX_AMOUNT FORMAT 99999.99
COLUMN MIN_AMOUNT FORMAT 99999.99

SELECT 
    COUNT(*) as TOTAL_TRANSACTIONS,
    AVG(TRANSACTION_AMOUNT) as AVG_AMOUNT,
    MAX(TRANSACTION_AMOUNT) as MAX_AMOUNT,
    MIN(TRANSACTION_AMOUNT) as MIN_AMOUNT,
    SUM(TRANSACTION_AMOUNT) as TOTAL_AMOUNT
FROM SEGMENT_TEST_TABLE;

EXIT;
EOF
    
    log_success "Summary retrieved"
}

###############################################################################
# UPDATE Operations
###############################################################################

# UPDATE single transaction
update_transaction() {
    local transaction_id=$1
    local transaction_amount=$2
    local status_code=$3
    local payment_status=$4
    
    if [ -z "$transaction_id" ] || [ -z "$transaction_amount" ]; then
        log_error "Transaction ID and Amount are required"
        return 1
    fi
    
    log_info "Updating transaction ID: $transaction_id..."
    
    sqlplus -S -L "${DB_USER}/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}" <<EOF
SET ECHO OFF

UPDATE SEGMENT_TEST_TABLE SET
    TRANSACTION_AMOUNT = $transaction_amount,
    STATUS_CODE = NVL($status_code, STATUS_CODE),
    PAYMENT_STATUS = NVL('$payment_status', PAYMENT_STATUS),
    UPDATE_DATE = SYSDATE
WHERE TRANSACTION_ID = $transaction_id;

COMMIT;

SELECT COUNT(*) as ROWS_UPDATED FROM SEGMENT_TEST_TABLE WHERE TRANSACTION_ID = $transaction_id;

EXIT;
EOF
    
    if [ $? -eq 0 ]; then
        log_success "Transaction updated: ID=$transaction_id, Amount=$transaction_amount"
    else
        log_error "Failed to update transaction: $transaction_id"
        return 1
    fi
}

# UPDATE by status code
update_by_status() {
    local old_status=$1
    local new_status=$2
    
    if [ -z "$old_status" ] || [ -z "$new_status" ]; then
        log_error "Old status and new status are required"
        return 1
    fi
    
    log_info "Updating status from $old_status to $new_status..."
    
    sqlplus -S -L "${DB_USER}/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}" <<EOF
SET ECHO OFF

UPDATE SEGMENT_TEST_TABLE SET
    STATUS_CODE = $new_status,
    UPDATE_DATE = SYSDATE
WHERE STATUS_CODE = $old_status;

COMMIT;

SELECT COUNT(*) as ROWS_UPDATED FROM SEGMENT_TEST_TABLE WHERE STATUS_CODE = $new_status AND STATUS_CODE = $new_status;

EXIT;
EOF
    
    if [ $? -eq 0 ]; then
        log_success "Status updated: From=$old_status To=$new_status"
    else
        log_error "Failed to update status"
        return 1
    fi
}

# UPDATE payment status
update_payment_status() {
    local transaction_id=$1
    local payment_status=$2
    
    if [ -z "$transaction_id" ] || [ -z "$payment_status" ]; then
        log_error "Transaction ID and payment status are required"
        return 1
    fi
    
    log_info "Updating payment status for transaction ID: $transaction_id..."
    
    sqlplus -S -L "${DB_USER}/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}" <<EOF
SET ECHO OFF

UPDATE SEGMENT_TEST_TABLE SET
    PAYMENT_STATUS = '$payment_status',
    UPDATE_DATE = SYSDATE
WHERE TRANSACTION_ID = $transaction_id;

COMMIT;

SELECT PAYMENT_STATUS FROM SEGMENT_TEST_TABLE WHERE TRANSACTION_ID = $transaction_id;

EXIT;
EOF
    
    if [ $? -eq 0 ]; then
        log_success "Payment status updated: ID=$transaction_id, Status=$payment_status"
    else
        log_error "Failed to update payment status"
        return 1
    fi
}

###############################################################################
# Main Menu
###############################################################################

show_usage() {
    cat << EOF
Usage: $0 [command] [options]

SELECT Operations:
    select_all                          - Select all transactions (limit 20)
    select_by_id <transaction_id>       - Select specific transaction
    select_by_status <status_code>      - Select by status code
    select_summary                      - Show transaction summary

UPDATE Operations:
    update <id> <amount> [status] [payment]  - Update single transaction
    update_status <old_status> <new_status>  - Update by status code
    update_payment <id> <payment_status>     - Update payment status

Examples:
    $0 select_all
    $0 select_by_id 10001
    $0 select_by_status 1
    $0 update 10001 2500.00 2 "PAID"
    $0 update_status 1 2
    $0 update_payment 10001 "COMPLETED"

EOF
}

###############################################################################
# Script Entry Point
###############################################################################

if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

case "$1" in
    select_all)
        select_all_transactions
        ;;
    select_by_id)
        select_transaction_by_id "$2"
        ;;
    select_by_status)
        select_by_status "$2"
        ;;
    select_summary)
        select_transaction_summary
        ;;
    update)
        update_transaction "$2" "$3" "$4" "$5"
        ;;
    update_status)
        update_by_status "$2" "$3"
        ;;
    update_payment)
        update_payment_status "$2" "$3"
        ;;
    -h|--help)
        show_usage
        ;;
    *)
        log_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac

exit 0
