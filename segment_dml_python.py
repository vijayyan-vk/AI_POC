#!/usr/bin/env python3
"""
Python Script for SEGMENT_TEST_TABLE - INSERT and UPDATE Operations
Technology: Python 3.x with cx_Oracle
Purpose: Perform INSERT and UPDATE operations on SEGMENT_TEST_TABLE
"""

import cx_Oracle
import sys
from datetime import datetime
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Database connection configuration
DB_USER = os.getenv('DB_USER', 'dev_user_26ai')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'your_password')
DB_HOST = os.getenv('DB_HOST', 'adb.us-phoenix-1.oraclecloud.com')
DB_PORT = os.getenv('DB_PORT', '1522')
DB_SERVICE = os.getenv('DB_SERVICE', 'gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com')

class SegmentTestDML:
    """Class to handle DML operations on SEGMENT_TEST_TABLE"""
    
    def __init__(self):
        """Initialize database connection"""
        try:
            dsn = cx_Oracle.makedsn(DB_HOST, DB_PORT, service_name=DB_SERVICE)
            self.connection = cx_Oracle.connect(DB_USER, DB_PASSWORD, dsn)
            self.cursor = self.connection.cursor()
            print("✓ Database connection established")
        except cx_Oracle.Error as e:
            print(f"✗ Error connecting to database: {e}")
            sys.exit(1)
    
    def insert_transaction(self, customer_id, order_id, product_id, 
                          transaction_amount, customer_name, product_name):
        """
        INSERT a new transaction record
        
        Args:
            customer_id (int): Customer ID
            order_id (int): Order ID
            product_id (int): Product ID
            transaction_amount (float): Transaction amount
            customer_name (str): Customer name
            product_name (str): Product name
        
        Returns:
            int: Last inserted transaction ID
        """
        try:
            insert_sql = """
                INSERT INTO SEGMENT_TEST_TABLE (
                    TRANSACTION_ID, CUSTOMER_ID, ORDER_ID, PRODUCT_ID,
                    TRANSACTION_AMOUNT, CUSTOMER_NAME, PRODUCT_NAME,
                    TRANSACTION_DATE, CREATION_DATE, STATUS_CODE, IS_PROCESSED
                ) VALUES (
                    SEGMENT_TEST_TABLE_SEQ.NEXTVAL, :customer_id, :order_id, :product_id,
                    :transaction_amount, :customer_name, :product_name,
                    SYSDATE, SYSDATE, 1, 'N'
                )
            """
            
            self.cursor.execute(insert_sql, {
                'customer_id': customer_id,
                'order_id': order_id,
                'product_id': product_id,
                'transaction_amount': transaction_amount,
                'customer_name': customer_name,
                'product_name': product_name
            })
            
            self.connection.commit()
            print(f"✓ Transaction inserted successfully | Customer: {customer_name}, Amount: {transaction_amount}")
            return True
            
        except cx_Oracle.Error as e:
            self.connection.rollback()
            print(f"✗ Error inserting transaction: {e}")
            return False
    
    def bulk_insert_transactions(self, num_records):
        """
        INSERT multiple transaction records in bulk
        
        Args:
            num_records (int): Number of records to insert
        
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            insert_sql = """
                INSERT INTO SEGMENT_TEST_TABLE (
                    TRANSACTION_ID, CUSTOMER_ID, ORDER_ID, PRODUCT_ID,
                    TRANSACTION_AMOUNT, TRANSACTION_DATE, CREATION_DATE,
                    STATUS_CODE, IS_PROCESSED
                ) VALUES (
                    SEGMENT_TEST_TABLE_SEQ.NEXTVAL, :cust_id, :order_id, :prod_id,
                    :amount, SYSDATE, SYSDATE, 1, 'N'
                )
            """
            
            records = []
            for i in range(num_records):
                records.append({
                    'cust_id': (i % 100) + 1,
                    'order_id': (i % 50) + 1,
                    'prod_id': (i % 20) + 1,
                    'amount': 100 + (i * 10)
                })
            
            self.cursor.executemany(insert_sql, records)
            self.connection.commit()
            print(f"✓ Bulk insert completed | Records inserted: {num_records}")
            return True
            
        except cx_Oracle.Error as e:
            self.connection.rollback()
            print(f"✗ Error in bulk insert: {e}")
            return False
    
    def update_transaction(self, transaction_id, transaction_amount, 
                          status_code, payment_status):
        """
        UPDATE an existing transaction record
        
        Args:
            transaction_id (int): Transaction ID to update
            transaction_amount (float): New transaction amount
            status_code (int): New status code
            payment_status (str): New payment status
        
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            update_sql = """
                UPDATE SEGMENT_TEST_TABLE SET
                    TRANSACTION_AMOUNT = :transaction_amount,
                    STATUS_CODE = :status_code,
                    PAYMENT_STATUS = :payment_status,
                    UPDATE_DATE = SYSDATE
                WHERE TRANSACTION_ID = :transaction_id
            """
            
            self.cursor.execute(update_sql, {
                'transaction_amount': transaction_amount,
                'status_code': status_code,
                'payment_status': payment_status,
                'transaction_id': transaction_id
            })
            
            if self.cursor.rowcount == 0:
                print(f"✗ Transaction ID not found: {transaction_id}")
                return False
            
            self.connection.commit()
            print(f"✓ Transaction updated | ID: {transaction_id}, New Amount: {transaction_amount}")
            return True
            
        except cx_Oracle.Error as e:
            self.connection.rollback()
            print(f"✗ Error updating transaction: {e}")
            return False
    
    def update_by_status(self, old_status, new_status):
        """
        UPDATE multiple records by status code
        
        Args:
            old_status (int): Current status code
            new_status (int): New status code
        
        Returns:
            int: Number of rows updated
        """
        try:
            update_sql = """
                UPDATE SEGMENT_TEST_TABLE SET
                    STATUS_CODE = :new_status,
                    UPDATE_DATE = SYSDATE
                WHERE STATUS_CODE = :old_status
            """
            
            self.cursor.execute(update_sql, {
                'new_status': new_status,
                'old_status': old_status
            })
            
            rows_updated = self.cursor.rowcount
            self.connection.commit()
            print(f"✓ Status update completed | Records updated: {rows_updated}")
            return rows_updated
            
        except cx_Oracle.Error as e:
            self.connection.rollback()
            print(f"✗ Error updating by status: {e}")
            return 0
    
    def close(self):
        """Close database connection"""
        try:
            self.cursor.close()
            self.connection.close()
            print("✓ Database connection closed")
        except cx_Oracle.Error as e:
            print(f"✗ Error closing connection: {e}")


def main():
    """Main function - Demo operations"""
    dml = SegmentTestDML()
    
    try:
        # Insert single transaction
        print("\n--- INSERT Single Transaction ---")
        dml.insert_transaction(
            customer_id=101,
            order_id=1001,
            product_id=501,
            transaction_amount=1500.50,
            customer_name='John Doe',
            product_name='Premium Product'
        )
        
        # Insert bulk transactions
        print("\n--- INSERT Bulk Transactions ---")
        dml.bulk_insert_transactions(50)
        
        # Update a transaction (you need a valid transaction ID)
        print("\n--- UPDATE Transaction ---")
        dml.update_transaction(
            transaction_id=1,
            transaction_amount=2000.75,
            status_code=2,
            payment_status='COMPLETED'
        )
        
        # Update by status
        print("\n--- UPDATE by Status ---")
        dml.update_by_status(old_status=1, new_status=2)
        
    finally:
        dml.close()


if __name__ == '__main__':
    main()
