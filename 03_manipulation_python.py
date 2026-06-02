#!/usr/bin/env python3
# =====================================================================
# Script: Multi-Language Table Manipulation Operations
# Language: Python
# Operations: INSERT, SELECT, UPDATE, DELETE, MERGE, TRUNCATE
# Purpose: Demonstrates CRUD operations on random test tables
# Author: AI Assistant
# Date: June 2, 2026
# =====================================================================

import cx_Oracle
import random
import datetime
from typing import List, Tuple

class TableManipulator:
    def __init__(self, username: str, password: str, dsn: str):
        """Initialize database connection"""
        try:
            self.connection = cx_Oracle.connect(user=username, password=password, dsn=dsn)
            self.cursor = self.connection.cursor()
            print("✓ Database connection established")
        except cx_Oracle.Error as e:
            print(f"✗ Connection error: {e}")
            raise

    def close_connection(self):
        """Close database connection"""
        self.cursor.close()
        self.connection.close()
        print("✓ Database connection closed")

    # =====================================================================
    # OPERATION 1: INSERT - Add new rows to test table
    # =====================================================================
    def insert_operation(self, table_name: str = 'TBL_0001_AAAAAAAA', num_rows: int = 5):
        """Insert new records into table"""
        print("\n[1] INSERT OPERATION - Adding new records")
        print("-" * 50)
        try:
            for i in range(1, num_rows + 1):
                id_val = 200 + i
                col_01 = f"INSERT_Test_{i}"
                col_02 = random.uniform(1000, 9999)
                col_03 = datetime.date.today()
                
                sql = f"""INSERT INTO {table_name} (ID, COL_01, COL_02, COL_03) 
                         VALUES (:1, :2, :3, :4)"""
                
                self.cursor.execute(sql, (id_val, col_01, col_02, col_03))
                print(f"Inserted row {i}: ID={id_val}, COL_01={col_01}, COL_02={col_02}")
            
            self.connection.commit()
            print(f"✓ INSERT Operation Completed - {num_rows} rows inserted")
        except cx_Oracle.Error as e:
            print(f"✗ Error in INSERT: {e}")
            self.connection.rollback()

    # =====================================================================
    # OPERATION 2: SELECT - Retrieve and display data
    # =====================================================================
    def select_operation(self, table_name: str = 'TBL_0001_AAAAAAAA', limit: int = 5):
        """Retrieve and display data from table"""
        print("\n[2] SELECT OPERATION - Retrieving records")
        print("-" * 50)
        try:
            sql = f"SELECT ID, COL_01, COL_02 FROM {table_name} WHERE ROWNUM <= :1"
            self.cursor.execute(sql, (limit,))
            
            rows = self.cursor.fetchall()
            if rows:
                for row in rows:
                    print(f"ID: {row[0]:>4} | COL_01: {str(row[1]):>30} | COL_02: {row[2]:>10}")
                print(f"✓ SELECT Operation Completed - {len(rows)} rows retrieved")
            else:
                print("✓ SELECT Operation Completed - No rows found")
        except cx_Oracle.Error as e:
            print(f"✗ Error in SELECT: {e}")

    # =====================================================================
    # OPERATION 3: UPDATE - Modify existing records
    # =====================================================================
    def update_operation(self, table_name: str = 'TBL_0001_AAAAAAAA', 
                        id_start: int = 1, id_end: int = 5, increment: int = 100):
        """Update existing records in table"""
        print("\n[3] UPDATE OPERATION - Modifying records")
        print("-" * 50)
        try:
            sql = f"""UPDATE {table_name} 
                     SET COL_02 = COL_02 + :1 
                     WHERE ID >= :2 AND ID <= :3"""
            
            self.cursor.execute(sql, (increment, id_start, id_end))
            rows_updated = self.cursor.rowcount
            self.connection.commit()
            print(f"Updated {rows_updated} rows: Incremented COL_02 by {increment}")
            print(f"✓ UPDATE Operation Completed")
        except cx_Oracle.Error as e:
            print(f"✗ Error in UPDATE: {e}")
            self.connection.rollback()

    # =====================================================================
    # OPERATION 4: DELETE - Remove specific records
    # =====================================================================
    def delete_operation(self, table_name: str = 'TBL_0001_AAAAAAAA', 
                        id_start: int = 200, id_end: int = 204):
        """Delete specific records from table"""
        print("\n[4] DELETE OPERATION - Removing records")
        print("-" * 50)
        try:
            sql = f """DELETE FROM {table_name} 
                     WHERE ID >= :1 AND ID <= :2"""
            
            self.cursor.execute(sql, (id_start, id_end))
            rows_deleted = self.cursor.rowcount
            self.connection.commit()
            print(f"Deleted {rows_deleted} rows with ID between {id_start} and {id_end}")
            print(f"✓ DELETE Operation Completed")
        except cx_Oracle.Error as e:
            print(f"✗ Error in DELETE: {e}")
            self.connection.rollback()

    # =====================================================================
    # OPERATION 5: MERGE - Conditional insert/update operations
    # =====================================================================
    def merge_operation(self, source_table: str = 'TBL_0001_AAAAAAAA', 
                       target_table: str = 'TBL_0002_BBBBBBBB'):
        """Perform MERGE operation (conditional insert/update)"""
        print("\n[5] MERGE OPERATION - Conditional DML")
        print("-" * 50)
        try:
            sql = f"""MERGE INTO {target_table} t
                     USING (SELECT * FROM {source_table} WHERE ROWNUM <= 3) s
                     ON (t.ID = s.ID)
                     WHEN MATCHED THEN 
                         UPDATE SET t.COL_02 = s.COL_02 + 50
                     WHEN NOT MATCHED THEN 
                         INSERT (ID, COL_01, COL_02, COL_03) 
                         VALUES (s.ID, s.COL_01, s.COL_02, s.COL_03)"""
            
            self.cursor.execute(sql)
            self.connection.commit()
            print(f"MERGE: Updated/Inserted records from {source_table} to {target_table}")
            print(f"✓ MERGE Operation Completed")
        except cx_Oracle.Error as e:
            print(f"✗ Error in MERGE: {e}")
            self.connection.rollback()

    # =====================================================================
    # OPERATION 6: TRUNCATE - Remove all records from table
    # =====================================================================
    def truncate_operation(self, table_name: str = 'TBL_0003_CCCCCCCC'):
        """Truncate table (remove all records)"""
        print("\n[6] TRUNCATE OPERATION - Removing all records")
        print("-" * 50)
        try:
            # First verify table exists
            verify_sql = f"SELECT COUNT(*) FROM {table_name}"
            self.cursor.execute(verify_sql)
            count_before = self.cursor.fetchone()[0]
            
            # Truncate the table
            sql = f"TRUNCATE TABLE {table_name}"
            self.cursor.execute(sql)
            print(f"Truncated table: {table_name} ({count_before} rows removed)")
            print(f"✓ TRUNCATE Operation Completed")
        except cx_Oracle.Error as e:
            print(f"✗ Error in TRUNCATE: {e}")

    def run_all_operations(self):
        """Execute all CRUD operations"""
        print("\n" + "="*50)
        print("Python Table Manipulation - All Operations")
        print("="*50)
        
        try:
            self.insert_operation('TBL_0001_AAAAAAAA', 5)
            self.select_operation('TBL_0001_AAAAAAAA', 5)
            self.update_operation('TBL_0001_AAAAAAAA', 1, 5, 100)
            self.delete_operation('TBL_0001_AAAAAAAA', 200, 204)
            self.merge_operation('TBL_0001_AAAAAAAA', 'TBL_0002_BBBBBBBB')
            self.truncate_operation('TBL_0003_CCCCCCCC')
        except Exception as e:
            print(f"✗ Error during operations: {e}")

        print("\n" + "="*50)
        print("All Python Operations Completed Successfully")
        print("="*50)


# =====================================================================
# Main Execution
# =====================================================================
if __name__ == "__main__":
    # Database connection parameters
    DB_USER = "dev_user_26ai"
    DB_PASSWORD = "your_password_here"
    DB_DSN = "gcf91c40155de9b_vkatp26ai_low"  # Oracle Cloud connection string
    
    try:
        # Create manipulator instance
        manipulator = TableManipulator(DB_USER, DB_PASSWORD, DB_DSN)
        
        # Run all operations
        manipulator.run_all_operations()
        
        # Close connection
        manipulator.close_connection()
        
    except Exception as e:
        print(f"✗ Fatal error: {e}")