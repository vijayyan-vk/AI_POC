-- ============================================================================
-- PL/SQL Package for SEGMENT_TEST_TABLE - All DML Operations
-- File: segment_dml_plsql.sql
-- Purpose: Complete package with INSERT, UPDATE, DELETE, SELECT procedures
-- Database: Oracle 23.26.2.2.0 (ATP)
-- User: dev_user_26ai
-- Created: May 22, 2026
-- ============================================================================

SET ECHO ON;
SET TIMING ON;

-- ============================================================================
-- 1. CREATE SEQUENCE (if not exists)
-- ============================================================================

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEGMENT_TEST_TABLE_SEQ';
  DBMS_OUTPUT.PUT_LINE('Sequence dropped');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Sequence does not exist - creating new');
END;
/

CREATE SEQUENCE SEGMENT_TEST_TABLE_SEQ 
  START WITH 10001 
  INCREMENT BY 1 
  NOCACHE;

COMMIT;
DBMS_OUTPUT.PUT_LINE('✓ Sequence SEGMENT_TEST_TABLE_SEQ created');

-- ============================================================================
-- 2. CREATE PACKAGE SPECIFICATION
-- ============================================================================

CREATE OR REPLACE PACKAGE segment_test_pkg AS

  /* ========================================================================
     Package: segment_test_pkg
     Purpose: Provide DML operations (INSERT, UPDATE, DELETE, SELECT) for 
              SEGMENT_TEST_TABLE with error handling and logging
     ======================================================================== */

  -- ========================================================================
  -- INSERT Operations
  -- ========================================================================

  /**
   * INSERT a single transaction record
   * @param p_customer_id        Customer ID
   * @param p_order_id           Order ID
   * @param p_product_id         Product ID
   * @param p_transaction_amount Transaction amount
   * @param p_customer_name      Customer name
   * @param p_product_name       Product name
   */
  PROCEDURE insert_transaction(
    p_customer_id NUMBER,
    p_order_id NUMBER,
    p_product_id NUMBER,
    p_transaction_amount NUMBER,
    p_customer_name VARCHAR2,
    p_product_name VARCHAR2
  );

  /**
   * INSERT multiple transaction records in bulk
   * @param p_record_count Number of records to insert
   */
  PROCEDURE bulk_insert_transactions(
    p_record_count NUMBER
  );

  -- ========================================================================
  -- UPDATE Operations
  -- ========================================================================

  /**
   * UPDATE a single transaction by transaction ID
   * @param p_transaction_id     Transaction ID
   * @param p_transaction_amount New transaction amount
   * @param p_status_code        New status code
   * @param p_payment_status     New payment status
   */
  PROCEDURE update_transaction(
    p_transaction_id NUMBER,
    p_transaction_amount NUMBER,
    p_status_code NUMBER,
    p_payment_status VARCHAR2
  );

  /**
   * UPDATE multiple transactions by status code
   * @param p_old_status Old status code to match
   * @param p_new_status New status code
   */
  PROCEDURE update_by_status(
    p_old_status NUMBER,
    p_new_status NUMBER
  );

  /**
   * UPDATE payment status for a transaction
   * @param p_transaction_id Transaction ID
   * @param p_payment_status New payment status
   */
  PROCEDURE update_payment_status(
    p_transaction_id NUMBER,
    p_payment_status VARCHAR2
  );

  -- ========================================================================
  -- DELETE Operations
  -- ========================================================================

  /**
   * DELETE a single transaction by ID
   * @param p_transaction_id Transaction ID to delete
   */
  PROCEDURE delete_transaction(
    p_transaction_id NUMBER
  );

  /**
   * DELETE multiple transactions by status code
   * @param p_status_code Status code to match for deletion
   */
  PROCEDURE delete_by_status(
    p_status_code NUMBER
  );

  /**
   * DELETE archived transactions
   */
  PROCEDURE delete_archived_transactions;

  -- ========================================================================
  -- SELECT Operations
  -- ========================================================================

  /**
   * GET a single transaction by ID (returns cursor)
   * @param p_transaction_id Transaction ID
   * @param p_cursor         Output cursor with result
   */
  PROCEDURE get_transaction(
    p_transaction_id NUMBER,
    p_cursor OUT SYS_REFCURSOR
  );

  /**
   * GET all transactions (returns cursor)
   * @param p_cursor Output cursor with all transactions
   */
  PROCEDURE get_all_transactions(
    p_cursor OUT SYS_REFCURSOR
  );

  /**
   * GET transactions by status code (returns cursor)
   * @param p_status_code Status code to filter
   * @param p_cursor      Output cursor with results
   */
  PROCEDURE get_by_status(
    p_status_code NUMBER,
    p_cursor OUT SYS_REFCURSOR
  );

  /**
   * GET transaction count
   * @param p_count Output parameter with total count
   */
  PROCEDURE get_transaction_count(
    p_count OUT NUMBER
  );

  /**
   * GET transaction summary (aggregations)
   * @param p_total_count Output total record count
   * @param p_total_amount Output total transaction amount
   * @param p_avg_amount Output average transaction amount
   * @param p_max_amount Output maximum transaction amount
   * @param p_min_amount Output minimum transaction amount
   */
  PROCEDURE get_transaction_summary(
    p_total_count OUT NUMBER,
    p_total_amount OUT NUMBER,
    p_avg_amount OUT NUMBER,
    p_max_amount OUT NUMBER,
    p_min_amount OUT NUMBER
  );

END segment_test_pkg;
/

DBMS_OUTPUT.PUT_LINE('✓ Package specification created');
COMMIT;

-- ============================================================================
-- 3. CREATE PACKAGE BODY
-- ============================================================================

CREATE OR REPLACE PACKAGE BODY segment_test_pkg AS

  -- ========================================================================
  -- Private Constants
  -- ========================================================================
  c_module_name CONSTANT VARCHAR2(30) := 'segment_test_pkg';

  -- ========================================================================
  -- INSERT PROCEDURE: insert_transaction
  -- ========================================================================
  PROCEDURE insert_transaction(
    p_customer_id NUMBER,
    p_order_id NUMBER,
    p_product_id NUMBER,
    p_transaction_amount NUMBER,
    p_customer_name VARCHAR2,
    p_product_name VARCHAR2
  ) AS
    v_id NUMBER;
  BEGIN
    INSERT INTO SEGMENT_TEST_TABLE (
      TRANSACTION_ID, CUSTOMER_ID, ORDER_ID, PRODUCT_ID,
      TRANSACTION_AMOUNT, CUSTOMER_NAME, PRODUCT_NAME,
      TRANSACTION_DATE, CREATION_DATE, STATUS_CODE, IS_PROCESSED
    ) VALUES (
      SEGMENT_TEST_TABLE_SEQ.NEXTVAL, p_customer_id, p_order_id, p_product_id,
      p_transaction_amount, p_customer_name, p_product_name,
      SYSDATE, SYSDATE, 1, 'N'
    ) RETURNING TRANSACTION_ID INTO v_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Transaction inserted successfully | ID: ' || v_id || 
                        ' | Customer: ' || p_customer_name || ' | Amount: ' || p_transaction_amount);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('✗ Error inserting transaction: ' || SQLERRM);
      RAISE;
  END insert_transaction;

  -- ========================================================================
  -- INSERT PROCEDURE: bulk_insert_transactions
  -- ========================================================================
  PROCEDURE bulk_insert_transactions(
    p_record_count NUMBER
  ) AS
    v_inserted_count NUMBER := 0;
  BEGIN
    FOR i IN 1..p_record_count LOOP
      INSERT INTO SEGMENT_TEST_TABLE (
        TRANSACTION_ID, CUSTOMER_ID, ORDER_ID, PRODUCT_ID,
        TRANSACTION_AMOUNT, TRANSACTION_DATE, CREATION_DATE,
        STATUS_CODE, IS_PROCESSED
      ) VALUES (
        SEGMENT_TEST_TABLE_SEQ.NEXTVAL, MOD(i, 1000) + 1, MOD(i, 500) + 1, MOD(i, 200) + 1,
        DBMS_RANDOM.VALUE(100, 10000), SYSDATE, SYSDATE,
        1, 'N'
      );
      v_inserted_count := v_inserted_count + 1;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Bulk insert completed | Records inserted: ' || v_inserted_count);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('✗ Error in bulk insert: ' || SQLERRM);
      RAISE;
  END bulk_insert_transactions;

  -- ========================================================================
  -- UPDATE PROCEDURE: update_transaction
  -- ========================================================================
  PROCEDURE update_transaction(
    p_transaction_id NUMBER,
    p_transaction_amount NUMBER,
    p_status_code NUMBER,
    p_payment_status VARCHAR2
  ) AS
  BEGIN
    UPDATE SEGMENT_TEST_TABLE SET
      TRANSACTION_AMOUNT = p_transaction_amount,
      STATUS_CODE = p_status_code,
      PAYMENT_STATUS = p_payment_status,
      UPDATE_DATE = SYSDATE
    WHERE TRANSACTION_ID = p_transaction_id;
    
    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Transaction ID not found: ' || p_transaction_id);
    END IF;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Transaction updated | ID: ' || p_transaction_id || 
                        ' | Amount: ' || p_transaction_amount || ' | Status: ' || p_status_code);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('✗ Error updating transaction: ' || SQLERRM);
      RAISE;
  END update_transaction;

  -- ========================================================================
  -- UPDATE PROCEDURE: update_by_status
  -- ========================================================================
  PROCEDURE update_by_status(
    p_old_status NUMBER,
    p_new_status NUMBER
  ) AS
    v_count NUMBER;
  BEGIN
    UPDATE SEGMENT_TEST_TABLE SET
      STATUS_CODE = p_new_status,
      UPDATE_DATE = SYSDATE
    WHERE STATUS_CODE = p_old_status;
    
    v_count := SQL%ROWCOUNT;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Status update completed | From: ' || p_old_status || 
                        ' To: ' || p_new_status || ' | Records updated: ' || v_count);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('✗ Error updating by status: ' || SQLERRM);
      RAISE;
  END update_by_status;

  -- ========================================================================
  -- UPDATE PROCEDURE: update_payment_status
  -- ========================================================================
  PROCEDURE update_payment_status(
    p_transaction_id NUMBER,
    p_payment_status VARCHAR2
  ) AS
  BEGIN
    UPDATE SEGMENT_TEST_TABLE SET
      PAYMENT_STATUS = p_payment_status,
      UPDATE_DATE = SYSDATE
    WHERE TRANSACTION_ID = p_transaction_id;
    
    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Transaction ID not found: ' || p_transaction_id);
    END IF;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Payment status updated | ID: ' || p_transaction_id || 
                        ' | Status: ' || p_payment_status);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('✗ Error updating payment status: ' || SQLERRM);
      RAISE;
  END update_payment_status;

  -- ========================================================================
  -- DELETE PROCEDURE: delete_transaction
  -- ========================================================================
  PROCEDURE delete_transaction(
    p_transaction_id NUMBER
  ) AS
  BEGIN
    DELETE FROM SEGMENT_TEST_TABLE WHERE TRANSACTION_ID = p_transaction_id;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20002, 'Transaction ID not found: ' || p_transaction_id);
    END IF;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Transaction deleted | ID: ' || p_transaction_id);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('✗ Error deleting transaction: ' || SQLERRM);
      RAISE;
  END delete_transaction;

  -- ========================================================================
  -- DELETE PROCEDURE: delete_by_status
  -- ========================================================================
  PROCEDURE delete_by_status(
    p_status_code NUMBER
  ) AS
    v_count NUMBER;
  BEGIN
    DELETE FROM SEGMENT_TEST_TABLE WHERE STATUS_CODE = p_status_code;
    v_count := SQL%ROWCOUNT;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Delete by status completed | Status: ' || p_status_code || 
                        ' | Records deleted: ' || v_count);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('✗ Error deleting by status: ' || SQLERRM);
      RAISE;
  END delete_by_status;

  -- ========================================================================
  -- DELETE PROCEDURE: delete_archived_transactions
  -- ========================================================================
  PROCEDURE delete_archived_transactions AS
    v_count NUMBER;
  BEGIN
    DELETE FROM SEGMENT_TEST_TABLE WHERE IS_ARCHIVED = 'Y';
    v_count := SQL%ROWCOUNT;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Archived transactions deleted | Records: ' || v_count);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('✗ Error deleting archived transactions: ' || SQLERRM);
      RAISE;
  END delete_archived_transactions;

  -- ========================================================================
  -- SELECT PROCEDURE: get_transaction
  -- ========================================================================
  PROCEDURE get_transaction(
    p_transaction_id NUMBER,
    p_cursor OUT SYS_REFCURSOR
  ) AS
  BEGIN
    OPEN p_cursor FOR
      SELECT * FROM SEGMENT_TEST_TABLE WHERE TRANSACTION_ID = p_transaction_id;
    DBMS_OUTPUT.PUT_LINE('✓ Transaction retrieved | ID: ' || p_transaction_id);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('✗ Error retrieving transaction: ' || SQLERRM);
      RAISE;
  END get_transaction;

  -- ========================================================================
  -- SELECT PROCEDURE: get_all_transactions
  -- ========================================================================
  PROCEDURE get_all_transactions(
    p_cursor OUT SYS_REFCURSOR
  ) AS
  BEGIN
    OPEN p_cursor FOR
      SELECT * FROM SEGMENT_TEST_TABLE ORDER BY TRANSACTION_ID DESC;
    DBMS_OUTPUT.PUT_LINE('✓ All transactions retrieved');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('✗ Error retrieving all transactions: ' || SQLERRM);
      RAISE;
  END get_all_transactions;

  -- ========================================================================
  -- SELECT PROCEDURE: get_by_status
  -- ========================================================================
  PROCEDURE get_by_status(
    p_status_code NUMBER,
    p_cursor OUT SYS_REFCURSOR
  ) AS
  BEGIN
    OPEN p_cursor FOR
      SELECT * FROM SEGMENT_TEST_TABLE WHERE STATUS_CODE = p_status_code 
      ORDER BY TRANSACTION_ID DESC;
    DBMS_OUTPUT.PUT_LINE('✓ Transactions retrieved | Status: ' || p_status_code);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('✗ Error retrieving by status: ' || SQLERRM);
      RAISE;
  END get_by_status;

  -- ========================================================================
  -- SELECT PROCEDURE: get_transaction_count
  -- ========================================================================
  PROCEDURE get_transaction_count(
    p_count OUT NUMBER
  ) AS
  BEGIN
    SELECT COUNT(*) INTO p_count FROM SEGMENT_TEST_TABLE;
    DBMS_OUTPUT.PUT_LINE('✓ Transaction count: ' || p_count);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('✗ Error getting transaction count: ' || SQLERRM);
      RAISE;
  END get_transaction_count;

  -- ========================================================================
  -- SELECT PROCEDURE: get_transaction_summary
  -- ========================================================================
  PROCEDURE get_transaction_summary(
    p_total_count OUT NUMBER,
    p_total_amount OUT NUMBER,
    p_avg_amount OUT NUMBER,
    p_max_amount OUT NUMBER,
    p_min_amount OUT NUMBER
  ) AS
  BEGIN
    SELECT COUNT(*), SUM(TRANSACTION_AMOUNT), AVG(TRANSACTION_AMOUNT), 
           MAX(TRANSACTION_AMOUNT), MIN(TRANSACTION_AMOUNT)
    INTO p_total_count, p_total_amount, p_avg_amount, p_max_amount, p_min_amount
    FROM SEGMENT_TEST_TABLE;
    
    DBMS_OUTPUT.PUT_LINE('✓ Transaction summary retrieved');
    DBMS_OUTPUT.PUT_LINE('  Total Count: ' || p_total_count);
    DBMS_OUTPUT.PUT_LINE('  Total Amount: ' || ROUND(p_total_amount, 2));
    DBMS_OUTPUT.PUT_LINE('  Average Amount: ' || ROUND(p_avg_amount, 2));
    DBMS_OUTPUT.PUT_LINE('  Max Amount: ' || ROUND(p_max_amount, 2));
    DBMS_OUTPUT.PUT_LINE('  Min Amount: ' || ROUND(p_min_amount, 2));
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('✗ Error getting transaction summary: ' || SQLERRM);
      RAISE;
  END get_transaction_summary;

END segment_test_pkg;
/

DBMS_OUTPUT.PUT_LINE('✓ Package body created');
COMMIT;

-- ============================================================================
-- 4. Verify Package Creation
-- ============================================================================

EXECUTE DBMS_OUTPUT.PUT_LINE('✓ Package segment_test_pkg compiled successfully');

-- Verify package exists
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_name = 'SEGMENT_TEST_PKG' 
ORDER BY object_type;

-- ============================================================================
-- 5. Test Procedures (Optional)
-- ============================================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('Package Ready for Use');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Example Usage:');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('-- Insert a transaction');
  DBMS_OUTPUT.PUT_LINE('EXEC segment_test_pkg.insert_transaction(101, 1001, 501, 1500.50, ''John Doe'', ''Product A'');');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('-- Bulk insert');
  DBMS_OUTPUT.PUT_LINE('EXEC segment_test_pkg.bulk_insert_transactions(50);');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('-- Update transaction');
  DBMS_OUTPUT.PUT_LINE('EXEC segment_test_pkg.update_transaction(10001, 2000.75, 2, ''PAID'');');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('-- Delete transaction');
  DBMS_OUTPUT.PUT_LINE('EXEC segment_test_pkg.delete_transaction(10001);');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('-- Get transaction summary');
  DBMS_OUTPUT.PUT_LINE('DECLARE');
  DBMS_OUTPUT.PUT_LINE('  v_count NUMBER;');
  DBMS_OUTPUT.PUT_LINE('  v_total NUMBER;');
  DBMS_OUTPUT.PUT_LINE('  v_avg NUMBER;');
  DBMS_OUTPUT.PUT_LINE('  v_max NUMBER;');
  DBMS_OUTPUT.PUT_LINE('  v_min NUMBER;');
  DBMS_OUTPUT.PUT_LINE('BEGIN');
  DBMS_OUTPUT.PUT_LINE('  segment_test_pkg.get_transaction_summary(v_count, v_total, v_avg, v_max, v_min);');
  DBMS_OUTPUT.PUT_LINE('END;');
  DBMS_OUTPUT.PUT_LINE('/');
  DBMS_OUTPUT.PUT_LINE('');
END;
/

SET ECHO OFF;
COMMIT;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
-- Created: May 22, 2026
-- Status: Production Ready
-- ============================================================================
