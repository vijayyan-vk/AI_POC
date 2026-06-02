#!/usr/bin/env node
// =====================================================================
// Script: Multi-Language Table Manipulation Operations
// Language: JavaScript (Node.js)
// Operations: INSERT, SELECT, UPDATE, DELETE, MERGE, TRUNCATE
// Purpose: Demonstrates CRUD operations on random test tables
// Author: AI Assistant
// Date: June 2, 2026
// =====================================================================

const oracledb = require('oracledb');

class TableManipulator {
  constructor() {
    this.connection = null;
    this.config = {
      user: 'dev_user_26ai',
      password: 'your_password_here',
      connectionString: 'gcf91c40155de9b_vkatp26ai_low'
    };
  }

  // =====================================================================
  // Initialize Database Connection
  // =====================================================================
  async connect() {
    try {
      this.connection = await oracledb.getConnection(this.config);
      console.log('✓ Database connection established');
    } catch (error) {
      console.error(`✗ Connection error: ${error.message}`);
      throw error;
    }
  }

  // =====================================================================
  // Close Database Connection
  // =====================================================================
  async closeConnection() {
    if (this.connection) {
      try {
        await this.connection.close();
        console.log('✓ Database connection closed');
      } catch (error) {
        console.error(`✗ Error closing connection: ${error.message}`);
      }
    }
  }

  // =====================================================================
  // OPERATION 1: INSERT - Add new rows to test table
  // =====================================================================
  async insertOperation(tableName = 'TBL_0001_AAAAAAAA', numRows = 5) {
    console.log('\n[1] INSERT OPERATION - Adding new records');
    console.log('-'.repeat(50));
    
    try {
      for (let i = 1; i <= numRows; i++) {
        const idVal = 200 + i;
        const col01 = `INSERT_Test_${i}`;
        const col02 = Math.random() * 9000 + 1000;
        const col03 = new Date();

        const sql = `INSERT INTO ${tableName} (ID, COL_01, COL_02, COL_03) 
                     VALUES (:id, :col01, :col02, :col03)`;
        
        const binds = { id: idVal, col01, col02, col03 };
        await this.connection.execute(sql, binds);
        console.log(`Inserted row ${i}: ID=${idVal}, COL_01=${col01}, COL_02=${col02.toFixed(2)}`);
      }

      await this.connection.commit();
      console.log(`✓ INSERT Operation Completed - ${numRows} rows inserted`);
    } catch (error) {
      console.error(`✗ Error in INSERT: ${error.message}`);
      await this.connection.rollback();
    }
  }

  // =====================================================================
  // OPERATION 2: SELECT - Retrieve and display data
  // =====================================================================
  async selectOperation(tableName = 'TBL_0001_AAAAAAAA', limit = 5) {
    console.log('\n[2] SELECT OPERATION - Retrieving records');
    console.log('-'.repeat(50));
    
    try {
      const sql = `SELECT ID, COL_01, COL_02 FROM ${tableName} WHERE ROWNUM <= :limit`;
      const result = await this.connection.execute(sql, { limit });

      if (result.rows && result.rows.length > 0) {
        result.rows.forEach(row => {
          console.log(`ID: ${String(row[0]).padStart(4)} | COL_01: ${String(row[1]).padEnd(30)} | COL_02: ${row[2]}`);
        });
        console.log(`✓ SELECT Operation Completed - ${result.rows.length} rows retrieved`);
      } else {
        console.log('✓ SELECT Operation Completed - No rows found');
      }
    } catch (error) {
      console.error(`✗ Error in SELECT: ${error.message}`);
    }
  }

  // =====================================================================
  // OPERATION 3: UPDATE - Modify existing records
  // =====================================================================
  async updateOperation(tableName = 'TBL_0001_AAAAAAAA', idStart = 1, idEnd = 5, increment = 100) {
    console.log('\n[3] UPDATE OPERATION - Modifying records');
    console.log('-'.repeat(50));
    
    try {
      const sql = `UPDATE ${tableName} 
                   SET COL_02 = COL_02 + :increment 
                   WHERE ID >= :idStart AND ID <= :idEnd`;
      
      const result = await this.connection.execute(sql, { increment, idStart, idEnd });
      await this.connection.commit();
      
      console.log(`Updated ${result.rowsAffected} rows: Incremented COL_02 by ${increment}`);
      console.log('✓ UPDATE Operation Completed');
    } catch (error) {
      console.error(`✗ Error in UPDATE: ${error.message}`);
      await this.connection.rollback();
    }
  }

  // =====================================================================
  // OPERATION 4: DELETE - Remove specific records
  // =====================================================================
  async deleteOperation(tableName = 'TBL_0001_AAAAAAAA', idStart = 200, idEnd = 204) {
    console.log('\n[4] DELETE OPERATION - Removing records');
    console.log('-'.repeat(50));
    
    try {
      const sql = `DELETE FROM ${tableName} 
                   WHERE ID >= :idStart AND ID <= :idEnd`;
      
      const result = await this.connection.execute(sql, { idStart, idEnd });
      await this.connection.commit();
      
      console.log(`Deleted ${result.rowsAffected} rows with ID between ${idStart} and ${idEnd}`);
      console.log('✓ DELETE Operation Completed');
    } catch (error) {
      console.error(`✗ Error in DELETE: ${error.message}`);
      await this.connection.rollback();
    }
  }

  // =====================================================================
  // OPERATION 5: MERGE - Conditional insert/update operations
  // =====================================================================
  async mergeOperation(sourceTable = 'TBL_0001_AAAAAAAA', targetTable = 'TBL_0002_BBBBBBBB') {
    console.log('\n[5] MERGE OPERATION - Conditional DML');
    console.log('-'.repeat(50));
    
    try {
      const sql = `MERGE INTO ${targetTable} t
                   USING (SELECT * FROM ${sourceTable} WHERE ROWNUM <= 3) s
                   ON (t.ID = s.ID)
                   WHEN MATCHED THEN 
                       UPDATE SET t.COL_02 = s.COL_02 + 50
                   WHEN NOT MATCHED THEN 
                       INSERT (ID, COL_01, COL_02, COL_03) 
                       VALUES (s.ID, s.COL_01, s.COL_02, s.COL_03)`;
      
      await this.connection.execute(sql);
      await this.connection.commit();
      
      console.log(`MERGE: Updated/Inserted records from ${sourceTable} to ${targetTable}`);
      console.log('✓ MERGE Operation Completed');
    } catch (error) {
      console.error(`✗ Error in MERGE: ${error.message}`);
      await this.connection.rollback();
    }
  }

  // =====================================================================
  // OPERATION 6: TRUNCATE - Remove all records from table
  // =====================================================================
  async truncateOperation(tableName = 'TBL_0003_CCCCCCCC') {
    console.log('\n[6] TRUNCATE OPERATION - Removing all records');
    console.log('-'.repeat(50));
    
    try {
      // Verify table exists and get row count
      const verifySql = `SELECT COUNT(*) as cnt FROM ${tableName}`;
      const verifyResult = await this.connection.execute(verifySql);
      const countBefore = verifyResult.rows[0][0];

      // Truncate the table
      const sql = `TRUNCATE TABLE ${tableName}`;
      await this.connection.execute(sql);
      
      console.log(`Truncated table: ${tableName} (${countBefore} rows removed)`);
      console.log('✓ TRUNCATE Operation Completed');
    } catch (error) {
      console.error(`✗ Error in TRUNCATE: ${error.message}`);
    }
  }

  // =====================================================================
  // Run All Operations
  // =====================================================================
  async runAllOperations() {
    console.log('\n' + '='.repeat(50));
    console.log('JavaScript Table Manipulation - All Operations');
    console.log('='.repeat(50));
    
    try {
      await this.insertOperation('TBL_0001_AAAAAAAA', 5);
      await this.selectOperation('TBL_0001_AAAAAAAA', 5);
      await this.updateOperation('TBL_0001_AAAAAAAA', 1, 5, 100);
      await this.deleteOperation('TBL_0001_AAAAAAAA', 200, 204);
      await this.mergeOperation('TBL_0001_AAAAAAAA', 'TBL_0002_BBBBBBBB');
      await this.truncateOperation('TBL_0003_CCCCCCCC');
    } catch (error) {
      console.error(`✗ Error during operations: ${error.message}`);
    }

    console.log('\n' + '='.repeat(50));
    console.log('All JavaScript Operations Completed Successfully');
    console.log('='.repeat(50));
  }
}

// =====================================================================
// Main Execution
// =====================================================================
(async () => {
  const manipulator = new TableManipulator();
  
  try {
    await manipulator.connect();
    await manipulator.runAllOperations();
  } catch (error) {
    console.error(`✗ Fatal error: ${error.message}`);
  } finally {
    await manipulator.closeConnection();
  }
})();

module.exports = TableManipulator;