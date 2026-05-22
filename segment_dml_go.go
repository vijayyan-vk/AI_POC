package main

/*
Go Program for SEGMENT_TEST_TABLE - All DML Operations
Technology: Go 1.19+ with database/sql and godror driver
Purpose: Perform INSERT, UPDATE, DELETE, and SELECT operations
Build: go build -o segment_dml_go segment_dml_go.go
Run: ./segment_dml_go

Installation:
go get github.com/godror/godror
*/

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	_ "github.com/godror/godror"
)

// Config holds database configuration
type Config struct {
	User        string
	Password    string
	Host        string
	Port        string
	Service     string
	ConnectStr  string
}

// SegmentTestDML handles all DML operations
type SegmentTestDML struct {
	db *sql.DB
}

// NewSegmentTestDML creates a new instance
func NewSegmentTestDML(config Config) (*SegmentTestDML, error) {
	connectStr := fmt.Sprintf("%s/%s@%s:%s/%s",
		config.User, config.Password, config.Host, config.Port, config.Service)

	db, err := sql.Open("godror", connectStr)
	if err != nil {
		return nil, fmt.Errorf("error opening connection: %w", err)
	}

	// Test connection
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("error connecting to database: %w", err)
	}

	fmt.Println("✓ Database connection established")
	return &SegmentTestDML{db: db}, nil
}

// InsertTransaction inserts a single transaction
func (s *SegmentTestDML) InsertTransaction(customerID, orderID, productID int, 
	amount float64, customerName, productName string) (int64, error) {
	
	query := `INSERT INTO SEGMENT_TEST_TABLE (
		TRANSACTION_ID, CUSTOMER_ID, ORDER_ID, PRODUCT_ID,
		TRANSACTION_AMOUNT, CUSTOMER_NAME, PRODUCT_NAME,
		TRANSACTION_DATE, CREATION_DATE, STATUS_CODE, IS_PROCESSED
	) VALUES (
		SEGMENT_TEST_TABLE_SEQ.NEXTVAL, :1, :2, :3,
		:4, :5, :6, SYSDATE, SYSDATE, 1, 'N'
	)`

	result, err := s.db.Exec(query, customerID, orderID, productID, 
		amount, customerName, productName)
	if err != nil {
		return 0, fmt.Errorf("error inserting transaction: %w", err)
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return 0, fmt.Errorf("error getting rows affected: %w", err)
	}

	fmt.Printf("✓ Transaction inserted | Customer: %s, Amount: %.2f, Rows: %d\n", 
		customerName, amount, rows)
	return rows, nil
}

// BulkInsertTransactions inserts multiple transactions
func (s *SegmentTestDML) BulkInsertTransactions(numRecords int) (int64, error) {
	query := `INSERT INTO SEGMENT_TEST_TABLE (
		TRANSACTION_ID, CUSTOMER_ID, ORDER_ID, PRODUCT_ID,
		TRANSACTION_AMOUNT, TRANSACTION_DATE, CREATION_DATE,
		STATUS_CODE, IS_PROCESSED
	) VALUES (
		SEGMENT_TEST_TABLE_SEQ.NEXTVAL, :1, :2, :3,
		:4, SYSDATE, SYSDATE, 1, 'N'
	)`

	stmt, err := s.db.Prepare(query)
	if err != nil {
		return 0, fmt.Errorf("error preparing statement: %w", err)
	}
	defer stmt.Close()

	totalRows := int64(0)
	for i := 0; i < numRecords; i++ {
		custID := (i % 100) + 1
		orderID := (i % 50) + 1
		prodID := (i % 20) + 1
		amount := 100.00 + float64(i*10)

		result, err := stmt.Exec(custID, orderID, prodID, amount)
		if err != nil {
			return totalRows, fmt.Errorf("error in bulk insert at record %d: %w", i, err)
		}

		rows, err := result.RowsAffected()
		if err == nil {
			totalRows += rows
		}
	}

	fmt.Printf("✓ Bulk insert completed | Records inserted: %d\n", totalRows)
	return totalRows, nil
}

// UpdateTransaction updates a single transaction
func (s *SegmentTestDML) UpdateTransaction(transactionID int, amount float64, 
	statusCode int, paymentStatus string) error {
	
	query := `UPDATE SEGMENT_TEST_TABLE SET
		TRANSACTION_AMOUNT = :1,
		STATUS_CODE = :2,
		PAYMENT_STATUS = :3,
		UPDATE_DATE = SYSDATE
	WHERE TRANSACTION_ID = :4`

	result, err := s.db.Exec(query, amount, statusCode, paymentStatus, transactionID)
	if err != nil {
		return fmt.Errorf("error updating transaction: %w", err)
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("error getting rows affected: %w", err)
	}

	if rows == 0 {
		return fmt.Errorf("transaction ID not found: %d", transactionID)
	}

	fmt.Printf("✓ Transaction updated | ID: %d, Amount: %.2f, Status: %d, Rows: %d\n",
		transactionID, amount, statusCode, rows)
	return nil
}

// UpdateByStatus updates multiple transactions by status
func (s *SegmentTestDML) UpdateByStatus(oldStatus, newStatus int) (int64, error) {
	query := `UPDATE SEGMENT_TEST_TABLE SET
		STATUS_CODE = :1,
		UPDATE_DATE = SYSDATE
	WHERE STATUS_CODE = :2`

	result, err := s.db.Exec(query, newStatus, oldStatus)
	if err != nil {
		return 0, fmt.Errorf("error updating by status: %w", err)
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return 0, fmt.Errorf("error getting rows affected: %w", err)
	}

	fmt.Printf("✓ Status update completed | From: %d To: %d, Rows: %d\n",
		oldStatus, newStatus, rows)
	return rows, nil
}

// DeleteTransaction deletes a single transaction
func (s *SegmentTestDML) DeleteTransaction(transactionID int) error {
	query := `DELETE FROM SEGMENT_TEST_TABLE WHERE TRANSACTION_ID = :1`

	result, err := s.db.Exec(query, transactionID)
	if err != nil {
		return fmt.Errorf("error deleting transaction: %w", err)
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("error getting rows affected: %w", err)
	}

	if rows == 0 {
		return fmt.Errorf("transaction ID not found: %d", transactionID)
	}

	fmt.Printf("✓ Transaction deleted | ID: %d, Rows: %d\n", transactionID, rows)
	return nil
}

// DeleteByStatus deletes transactions by status
func (s *SegmentTestDML) DeleteByStatus(statusCode int) (int64, error) {
	query := `DELETE FROM SEGMENT_TEST_TABLE WHERE STATUS_CODE = :1`

	result, err := s.db.Exec(query, statusCode)
	if err != nil {
		return 0, fmt.Errorf("error deleting by status: %w", err)
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return 0, fmt.Errorf("error getting rows affected: %w", err)
	}

	fmt.Printf("✓ Delete by status completed | Status: %d, Rows: %d\n", statusCode, rows)
	return rows, nil
}

// GetTransaction retrieves a single transaction
func (s *SegmentTestDML) GetTransaction(transactionID int) error {
	query := `SELECT TRANSACTION_ID, CUSTOMER_ID, ORDER_ID, PRODUCT_ID, 
		TRANSACTION_AMOUNT, STATUS_CODE, PAYMENT_STATUS, CREATION_DATE 
	FROM SEGMENT_TEST_TABLE WHERE TRANSACTION_ID = :1`

	var (
		tid, custID, orderID, prodID, statusCode int
		amount                                   float64
		paymentStatus                            string
		createdDate                              time.Time
	)

	err := s.db.QueryRow(query, transactionID).Scan(
		&tid, &custID, &orderID, &prodID, &amount, &statusCode, &paymentStatus, &createdDate)
	
	if err == sql.ErrNoRows {
		return fmt.Errorf("transaction not found: %d", transactionID)
	}
	if err != nil {
		return fmt.Errorf("error retrieving transaction: %w", err)
	}

	fmt.Printf("✓ Transaction retrieved:\n  ID: %d, Customer: %d, Amount: %.2f, Status: %d, Payment: %s\n",
		tid, custID, amount, statusCode, paymentStatus)
	return nil
}

// GetAllTransactions retrieves all transactions
func (s *SegmentTestDML) GetAllTransactions(limit int) error {
	query := `SELECT TRANSACTION_ID, CUSTOMER_ID, TRANSACTION_AMOUNT, STATUS_CODE, CREATION_DATE 
	FROM SEGMENT_TEST_TABLE ORDER BY TRANSACTION_ID DESC FETCH FIRST :1 ROWS ONLY`

	rows, err := s.db.Query(query, limit)
	if err != nil {
		return fmt.Errorf("error querying transactions: %w", err)
	}
	defer rows.Close()

	fmt.Printf("✓ Retrieved transactions (limit %d):\n", limit)
	count := 0
	for rows.Next() {
		var tid, custID, status int
		var amount float64
		var createdDate time.Time

		err := rows.Scan(&tid, &custID, &amount, &status, &createdDate)
		if err != nil {
			return fmt.Errorf("error scanning row: %w", err)
		}

		fmt.Printf("  ID: %d, Customer: %d, Amount: %.2f, Status: %d, Date: %s\n",
			tid, custID, amount, status, createdDate.Format("2006-01-02"))
		count++
	}

	fmt.Printf("  Total rows: %d\n", count)
	return rows.Err()
}

// Close closes database connection
func (s *SegmentTestDML) Close() error {
	if err := s.db.Close(); err != nil {
		return fmt.Errorf("error closing connection: %w", err)
	}
	fmt.Println("✓ Database connection closed")
	return nil
}

func main() {
	// Parse command line flags
	operation := flag.String("op", "demo", "Operation: insert, update, delete, select, or demo")
	transID := flag.Int("id", 0, "Transaction ID")
	amount := flag.Float64("amount", 0, "Transaction amount")
	status := flag.Int("status", 1, "Status code")
	custID := flag.Int("cust", 0, "Customer ID")
	orderID := flag.Int("order", 0, "Order ID")
	prodID := flag.Int("prod", 0, "Product ID")
	custName := flag.String("custname", "Test Customer", "Customer name")
	prodName := flag.String("prodname", "Test Product", "Product name")
	flag.Parse()

	// Database configuration
	config := Config{
		User:    os.Getenv("DB_USER"),
		Password: os.Getenv("DB_PASSWORD"),
		Host:    os.Getenv("DB_HOST"),
		Port:    os.Getenv("DB_PORT"),
		Service: os.Getenv("DB_SERVICE"),
	}

	if config.User == "" {
		config.User = "dev_user_26ai"
	}
	if config.Password == "" {
		config.Password = "your_password"
	}
	if config.Host == "" {
		config.Host = "adb.us-phoenix-1.oraclecloud.com"
	}
	if config.Port == "" {
		config.Port = "1522"
	}
	if config.Service == "" {
		config.Service = "gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com"
	}

	// Connect to database
	dml, err := NewSegmentTestDML(config)
	if err != nil {
		log.Fatalf("Error: %v", err)
	}
	defer dml.Close()

	// Execute operation
	switch *operation {
	case "insert":
		_, err = dml.InsertTransaction(*custID, *orderID, *prodID, *amount, *custName, *prodName)
	case "bulk":
		_, err = dml.BulkInsertTransactions(50)
	case "update":
		err = dml.UpdateTransaction(*transID, *amount, *status, "PENDING")
	case "delete":
		err = dml.DeleteTransaction(*transID)
	case "select":
		err = dml.GetTransaction(*transID)
	case "all":
		err = dml.GetAllTransactions(20)
	case "demo":
		fmt.Println("\n--- INSERT Demo ---")
		dml.InsertTransaction(101, 1001, 501, 1500.50, "John Doe", "Premium Product")
		
		fmt.Println("\n--- BULK INSERT Demo ---")
		dml.BulkInsertTransactions(10)
		
		fmt.Println("\n--- SELECT ALL Demo ---")
		dml.GetAllTransactions(10)
		
		fmt.Println("\n--- UPDATE Demo ---")
		dml.UpdateTransaction(1, 2000.75, 2, "COMPLETED")
		
		fmt.Println("\n--- UPDATE STATUS Demo ---")
		dml.UpdateByStatus(1, 2)
		
		fmt.Println("\n--- SELECT Demo ---")
		dml.GetTransaction(1)
	default:
		fmt.Printf("Unknown operation: %s\n", *operation)
		flag.PrintDefaults()
		os.Exit(1)
	}

	if err != nil {
		log.Fatalf("Error: %v", err)
	}
}
