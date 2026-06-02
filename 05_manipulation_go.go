package main

// =====================================================================
// Script: Multi-Language Table Manipulation Operations
// Language: Go
// Operations: INSERT, SELECT, UPDATE, DELETE, MERGE, TRUNCATE
// Purpose: Demonstrates CRUD operations on random test tables
// Author: AI Assistant
// Date: June 2, 2026
// =====================================================================

import (
	"database/sql"
	"fmt"
	"log"
	"math/rand"
	"time"

	_ "github.com/godror/godror"
)

type TableManipulator struct {
	db *sql.DB
}

// Database connection configuration
const (
	dbUser = "dev_user_26ai"
	dbPass = "your_password_here"
	dbDSN  = "gcf91c40155de9b_vkatp26ai_low"
)

// =====================================================================
// Initialize Database Connection
// =====================================================================
func NewTableManipulator() (*TableManipulator, error) {
	connectString := fmt.Sprintf("%s/%s@%s", dbUser, dbPass, dbDSN)
	db, err := sql.Open("godror", connectString)
	if err != nil {
		log.Printf("✗ Connection error: %v", err)
		return nil, err
	}

	if err = db.Ping(); err != nil {
		log.Printf("✗ Ping error: %v", err)
		return nil, err
	}

	fmt.Println("✓ Database connection established")
	return &TableManipulator{db: db}, nil
}

// =====================================================================
// Close Database Connection
// =====================================================================
func (tm *TableManipulator) Close() error {
	if tm.db != nil {
		err := tm.db.Close()
		if err == nil {
			fmt.Println("✓ Database connection closed")
		}
		return err
	}
	return nil
}

// =====================================================================
// OPERATION 1: INSERT - Add new rows to test table
// =====================================================================
func (tm *TableManipulator) InsertOperation(tableName string, numRows int) error {
	fmt.Println("\n[1] INSERT OPERATION - Adding new records")
	fmt.Println(repeatString("-", 50))

	for i := 1; i <= numRows; i++ {
		idVal := 200 + i
		col01 := fmt.Sprintf("INSERT_Test_%d", i)
		col02 := rand.Float64()*8000 + 1000
		col03 := time.Now()

		sql := fmt.Sprintf(
			"INSERT INTO %s (ID, COL_01, COL_02, COL_03) VALUES (:1, :2, :3, :4)",
			tableName)

		_, err := tm.db.Exec(sql, idVal, col01, col02, col03)
		if err != nil {
			log.Printf("✗ Error inserting row %d: %v", i, err)
			return err
		}
		fmt.Printf("Inserted row %d: ID=%d, COL_01=%s, COL_02=%.2f\n", i, idVal, col01, col02)
	}

	fmt.Printf("✓ INSERT Operation Completed - %d rows inserted\n", numRows)
	return nil
}

// =====================================================================
// OPERATION 2: SELECT - Retrieve and display data
// =====================================================================
func (tm *TableManipulator) SelectOperation(tableName string, limit int) error {
	fmt.Println("\n[2] SELECT OPERATION - Retrieving records")
	fmt.Println(repeatString("-", 50))

	sql := fmt.Sprintf("SELECT ID, COL_01, COL_02 FROM %s WHERE ROWNUM <= :1", tableName)
	rows, err := tm.db.Query(sql, limit)
	if err != nil {
		log.Printf("✗ Error in SELECT: %v", err)
		return err
	}
	defer rows.Close()

	count := 0
	for rows.Next() {
		var id int
		var col01 string
		var col02 float64

		if err := rows.Scan(&id, &col01, &col02); err != nil {
			log.Printf("✗ Error scanning row: %v", err)
			return err
		}

		fmt.Printf("ID: %4d | COL_01: %-30s | COL_02: %.2f\n", id, col01, col02)
		count++
	}

	if err = rows.Err(); err != nil {
		log.Printf("✗ Error in SELECT: %v", err)
		return err
	}

	fmt.Printf("✓ SELECT Operation Completed - %d rows retrieved\n", count)
	return nil
}

// =====================================================================
// OPERATION 3: UPDATE - Modify existing records
// =====================================================================
func (tm *TableManipulator) UpdateOperation(tableName string, idStart, idEnd, increment int) error {
	fmt.Println("\n[3] UPDATE OPERATION - Modifying records")
	fmt.Println(repeatString("-", 50))

	sql := fmt.Sprintf(
		"UPDATE %s SET COL_02 = COL_02 + :1 WHERE ID >= :2 AND ID <= :3",
		tableName)

	result, err := tm.db.Exec(sql, increment, idStart, idEnd)
	if err != nil {
		log.Printf("✗ Error in UPDATE: %v", err)
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("✗ Error getting rows affected: %v", err)
		return err
	}

	fmt.Printf("Updated %d rows: Incremented COL_02 by %d\n", rowsAffected, increment)
	fmt.Println("✓ UPDATE Operation Completed")
	return nil
}

// =====================================================================
// OPERATION 4: DELETE - Remove specific records
// =====================================================================
func (tm *TableManipulator) DeleteOperation(tableName string, idStart, idEnd int) error {
	fmt.Println("\n[4] DELETE OPERATION - Removing records")
	fmt.Println(repeatString("-", 50))

	sql := fmt.Sprintf(
		"DELETE FROM %s WHERE ID >= :1 AND ID <= :2",
		tableName)

	result, err := tm.db.Exec(sql, idStart, idEnd)
	if err != nil {
		log.Printf("✗ Error in DELETE: %v", err)
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Printf("✗ Error getting rows affected: %v", err)
		return err
	}

	fmt.Printf("Deleted %d rows with ID between %d and %d\n", rowsAffected, idStart, idEnd)
	fmt.Println("✓ DELETE Operation Completed")
	return nil
}

// =====================================================================
// OPERATION 5: MERGE - Conditional insert/update operations
// =====================================================================
func (tm *TableManipulator) MergeOperation(sourceTable, targetTable string) error {
	fmt.Println("\n[5] MERGE OPERATION - Conditional DML")
	fmt.Println(repeatString("-", 50))

	mergeSql := fmt.Sprintf(
		`MERGE INTO %s t
         USING (SELECT * FROM %s WHERE ROWNUM <= 3) s
         ON (t.ID = s.ID)
         WHEN MATCHED THEN 
             UPDATE SET t.COL_02 = s.COL_02 + 50
         WHEN NOT MATCHED THEN 
             INSERT (ID, COL_01, COL_02, COL_03) 
             VALUES (s.ID, s.COL_01, s.COL_02, s.COL_03)`,
		targetTable, sourceTable)

	_, err := tm.db.Exec(mergeSql)
	if err != nil {
		log.Printf("✗ Error in MERGE: %v", err)
		return err
	}

	fmt.Printf("MERGE: Updated/Inserted records from %s to %s\n", sourceTable, targetTable)
	fmt.Println("✓ MERGE Operation Completed")
	return nil
}

// =====================================================================
// OPERATION 6: TRUNCATE - Remove all records from table
// =====================================================================
func (tm *TableManipulator) TruncateOperation(tableName string) error {
	fmt.Println("\n[6] TRUNCATE OPERATION - Removing all records")
	fmt.Println(repeatString("-", 50))

	// Get row count before truncate
	var countBefore int
	err := tm.db.QueryRow(fmt.Sprintf("SELECT COUNT(*) FROM %s", tableName)).Scan(&countBefore)
	if err != nil {
		log.Printf("✗ Error getting row count: %v", err)
		return err
	}

	// Truncate the table
	truncateSql := fmt.Sprintf("TRUNCATE TABLE %s", tableName)
	_, err = tm.db.Exec(truncateSql)
	if err != nil {
		log.Printf("✗ Error in TRUNCATE: %v", err)
		return err
	}

	fmt.Printf("Truncated table: %s (%d rows removed)\n", tableName, countBefore)
	fmt.Println("✓ TRUNCATE Operation Completed")
	return nil
}

// =====================================================================
// Run All Operations
// =====================================================================
func (tm *TableManipulator) RunAllOperations() error {
	fmt.Println("\n" + repeatString("=", 50))
	fmt.Println("Go Table Manipulation - All Operations")
	fmt.Println(repeatString("=", 50))

	operations := []func() error{
		func() error { return tm.InsertOperation("TBL_0001_AAAAAAAA", 5) },
		func() error { return tm.SelectOperation("TBL_0001_AAAAAAAA", 5) },
		func() error { return tm.UpdateOperation("TBL_0001_AAAAAAAA", 1, 5, 100) },
		func() error { return tm.DeleteOperation("TBL_0001_AAAAAAAA", 200, 204) },
		func() error { return tm.MergeOperation("TBL_0001_AAAAAAAA", "TBL_0002_BBBBBBBB") },
		func() error { return tm.TruncateOperation("TBL_0003_CCCCCCCC") },
	}

	for _, op := range operations {
		if err := op(); err != nil {
			fmt.Printf("✗ Error during operation: %v\n", err)
			return err
		}
	}

	fmt.Println("\n" + repeatString("=", 50))
	fmt.Println("All Go Operations Completed Successfully")
	fmt.Println(repeatString("=", 50))
	return nil
}

// =====================================================================
// Helper Functions
// =====================================================================
func repeatString(s string, count int) string {
	result := ""
	for i := 0; i < count; i++ {
		result += s
	}
	return result
}

// =====================================================================
// Main Execution
// =====================================================================
func main() {
	rand.Seed(time.Now().UnixNano())

	manipulator, err := NewTableManipulator()
	if err != nil {
		log.Fatalf("✗ Fatal error: %v", err)
	}
	defer manipulator.Close()

	if err := manipulator.RunAllOperations(); err != nil {
		log.Fatalf("✗ Fatal error during operations: %v", err)
	}
}