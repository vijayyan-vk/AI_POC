-- =====================================================================
-- Script: Create 100 Random Tables with Random Columns and Sample Data
-- Purpose: Generate test tables for multi-language manipulation scripts
-- Author: AI Assistant
-- Date: June 2, 2026
-- =====================================================================

SET ECHO ON;
SET FEEDBACK ON;

-- =====================================================================
-- TABLE CREATION SCRIPT - Generates 100 random tables
-- =====================================================================

BEGIN
  FOR i IN 1..100 LOOP
    DECLARE
      v_table_name VARCHAR2(30);
      v_col_count PLS_INTEGER;
      v_col_def VARCHAR2(4000);
      v_sql VARCHAR2(4000);
      v_data_types SYS.DBMS_SQL.VARCHAR2_TABLE;
      v_col_names SYS.DBMS_SQL.VARCHAR2_TABLE;
    BEGIN
      -- Generate random table name
      v_table_name := 'TBL_' || TO_CHAR(i, '0000') || '_' || 
                      SUBSTR(DBMS_RANDOM.STRING('u', 8), 1, 8);
      
      -- Generate 5-15 random columns
      v_col_count := TRUNC(DBMS_RANDOM.VALUE(5, 16));
      v_col_def := 'ID NUMBER PRIMARY KEY, ';
      
      -- Define data types array
      v_data_types(1) := 'VARCHAR2(50)';
      v_data_types(2) := 'NUMBER(10,2)';
      v_data_types(3) := 'DATE';
      v_data_types(4) := 'VARCHAR2(100)';
      v_data_types(5) := 'NUMBER(5,0)';
      v_data_types(6) := 'CLOB';
      v_data_types(7) := 'TIMESTAMP';
      v_data_types(8) := 'CHAR(10)';
      
      -- Build column definitions
      FOR col_idx IN 1..v_col_count LOOP
        v_col_names(col_idx) := 'COL_' || TO_CHAR(col_idx, '00');
        v_col_def := v_col_def || v_col_names(col_idx) || ' ' || 
                     v_data_types(MOD(col_idx, 8) + 1) || ', ';
      END LOOP;
      
      -- Remove trailing comma and space
      v_col_def := RTRIM(v_col_def, ', ');
      
      -- Create table
      v_sql := 'CREATE TABLE ' || v_table_name || ' (' || v_col_def || ')';
      EXECUTE IMMEDIATE v_sql;
      
      -- Insert 10 random rows
      FOR row_idx IN 1..10 LOOP
        v_sql := 'INSERT INTO ' || v_table_name || ' (ID';
        FOR col_idx IN 1..v_col_count LOOP
          v_sql := v_sql || ', ' || v_col_names(col_idx);
        END LOOP;
        v_sql := v_sql || ') VALUES (' || row_idx;
        
        FOR col_idx IN 1..v_col_count LOOP
          CASE MOD(col_idx, 8) + 1
            WHEN 1 THEN v_sql := v_sql || ', ' || q'['Test_Data_]' || row_idx || '_' || col_idx || q'[']';
            WHEN 2 THEN v_sql := v_sql || ', ' || DBMS_RANDOM.VALUE(1, 1000);
            WHEN 3 THEN v_sql := v_sql || ', TRUNC(SYSDATE + ' || DBMS_RANDOM.VALUE(1, 365) || ')';
            WHEN 4 THEN v_sql := v_sql || ', ' || q'['Description_]' || row_idx || '_' || col_idx || q'[']';
            WHEN 5 THEN v_sql := v_sql || ', ' || TRUNC(DBMS_RANDOM.VALUE(0, 100));
            WHEN 6 THEN v_sql := v_sql || ', ' || q'['Clob_Data_]' || row_idx || '_' || col_idx || q'[']';
            WHEN 7 THEN v_sql := v_sql || ', SYSTIMESTAMP';
            WHEN 8 THEN v_sql := v_sql || ', ' || q'['CHAR_]' || SUBSTR(TO_CHAR(i), 1, 4) || q'[']';
          END CASE;
        END LOOP;
        v_sql := v_sql || ')';
        EXECUTE IMMEDIATE v_sql;
      END LOOP;
      
      -- Commit every 10 tables
      IF MOD(i, 10) = 0 THEN
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Created and populated ' || i || ' tables');
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating table ' || i || ': ' || SQLERRM);
    END;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Successfully created 100 random tables with data');
END;
/

-- Verify table creation
SELECT COUNT(*) AS total_tables FROM user_tables;
SELECT table_name, num_rows FROM user_tables WHERE table_name LIKE 'TBL_%' ROWNUM <= 10;

COMMIT;
EXIT;