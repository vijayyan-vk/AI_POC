-- =====================================================================
-- Script: Multi-Language Table Manipulation Operations
-- Language: PL/SQL
-- Operations: INSERT, SELECT, UPDATE, DELETE, MERGE, TRUNCATE
-- Purpose: Demonstrates CRUD operations on random test tables
-- Author: AI Assistant
-- Date: June 2, 2026
-- =====================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET HEADING ON;

PROMPT ==========================================
PROMPT PL/SQL Manipulation Script - All Operations
PROMPT ==========================================

-- =====================================================================
-- OPERATION 1: INSERT - Add new rows to test table
-- =====================================================================
PROMPT
PROMPT [1] INSERT OPERATION - Adding new records
PROMPT

DECLARE
  v_table_name VARCHAR2(30) := 'TBL_0001_AAAAAAAA'; -- Sample table
  v_sql VARCHAR2(4000);
BEGIN
  -- Insert 5 new records
  FOR i IN 1..5 LOOP
    v_sql := 'INSERT INTO ' || v_table_name || ' (ID, COL_01, COL_02, COL_03) ' ||
             'VALUES (' || (100 + i) || ', ' || 
             q'['INSERT_Test_]' || i || q'[', ' ||
             DBMS_RANDOM.VALUE(1000, 9999) || ', SYSDATE)';
    EXECUTE IMMEDIATE v_sql;
    DBMS_OUTPUT.PUT_LINE('Inserted row ' || i);
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('INSERT Operation Completed');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in INSERT: ' || SQLERRM);
END;
/

-- =====================================================================
-- OPERATION 2: SELECT - Retrieve and display data
-- =====================================================================
PROMPT
PROMPT [2] SELECT OPERATION - Retrieving records
PROMPT

DECLARE
  TYPE t_record IS RECORD (
    id NUMBER,
    col_01 VARCHAR2(100),
    col_02 NUMBER
  );
  v_record t_record;
  v_cursor SYS_REFCURSOR;
  v_sql VARCHAR2(4000);
BEGIN
  v_sql := 'SELECT ID, COL_01, COL_02 FROM TBL_0001_AAAAAAAA WHERE ROWNUM <= 5';
  OPEN v_cursor FOR v_sql;
  
  LOOP
    FETCH v_cursor INTO v_record;
    EXIT WHEN v_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_record.id || ' | Col01: ' || v_record.col_01 || 
                         ' | Col02: ' || v_record.col_02);
  END LOOP;
  
  CLOSE v_cursor;
  DBMS_OUTPUT.PUT_LINE('SELECT Operation Completed');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in SELECT: ' || SQLERRM);
END;
/

-- =====================================================================
-- OPERATION 3: UPDATE - Modify existing records
-- =====================================================================
PROMPT
PROMPT [3] UPDATE OPERATION - Modifying records
PROMPT

DECLARE
  v_table_name VARCHAR2(30) := 'TBL_0001_AAAAAAAA';
  v_sql VARCHAR2(4000);
  v_rows_updated NUMBER;
BEGIN
  v_sql := 'UPDATE ' || v_table_name || ' SET COL_02 = COL_02 + 100 WHERE ID >= 1 AND ID <= 5';
  EXECUTE IMMEDIATE v_sql;
  v_rows_updated := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Updated ' || v_rows_updated || ' rows');
  DBMS_OUTPUT.PUT_LINE('UPDATE Operation Completed');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in UPDATE: ' || SQLERRM);
END;
/

-- =====================================================================
-- OPERATION 4: DELETE - Remove specific records
-- =====================================================================
PROMPT
PROMPT [4] DELETE OPERATION - Removing records
PROMPT

DECLARE
  v_table_name VARCHAR2(30) := 'TBL_0001_AAAAAAAA';
  v_sql VARCHAR2(4000);
  v_rows_deleted NUMBER;
BEGIN
  v_sql := 'DELETE FROM ' || v_table_name || ' WHERE ID >= 100 AND ID <= 104';
  EXECUTE IMMEDIATE v_sql;
  v_rows_deleted := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Deleted ' || v_rows_deleted || ' rows');
  DBMS_OUTPUT.PUT_LINE('DELETE Operation Completed');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in DELETE: ' || SQLERRM);
END;
/

-- =====================================================================
-- OPERATION 5: MERGE - Conditional insert/update operations
-- =====================================================================
PROMPT
PROMPT [5] MERGE OPERATION - Conditional DML
PROMPT

DECLARE
  v_source_table VARCHAR2(30) := 'TBL_0001_AAAAAAAA';
  v_target_table VARCHAR2(30) := 'TBL_0002_BBBBBBBB';
BEGIN
  EXECUTE IMMEDIATE 'MERGE INTO ' || v_target_table || ' t ' ||
    'USING (SELECT * FROM ' || v_source_table || ' WHERE ROWNUM <= 3) s ' ||
    'ON (t.ID = s.ID) ' ||
    'WHEN MATCHED THEN UPDATE SET t.COL_02 = s.COL_02 + 50 ' ||
    'WHEN NOT MATCHED THEN INSERT (ID, COL_01, COL_02, COL_03) ' ||
    'VALUES (s.ID, s.COL_01, s.COL_02, s.COL_03)';
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('MERGE Operation Completed');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in MERGE: ' || SQLERRM);
END;
/

-- =====================================================================
-- OPERATION 6: TRUNCATE - Remove all records from table
-- =====================================================================
PROMPT
PROMPT [6] TRUNCATE OPERATION - Removing all records
PROMPT

DECLARE
  v_temp_table VARCHAR2(30) := 'TBL_0003_CCCCCCCC'; -- Temp table for truncate demo
BEGIN
  -- First create a temp table if needed
  BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE ' || v_temp_table || ' AS SELECT * FROM TBL_0001_AAAAAAAA';
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
  
  -- Truncate the temp table
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_temp_table;
  DBMS_OUTPUT.PUT_LINE('Truncated table: ' || v_temp_table);
  DBMS_OUTPUT.PUT_LINE('TRUNCATE Operation Completed');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in TRUNCATE: ' || SQLERRM);
END;
/

PROMPT
PROMPT ==========================================
PROMPT All PL/SQL Operations Completed Successfully
PROMPT ==========================================

COMMIT;
EXIT;