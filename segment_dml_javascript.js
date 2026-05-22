/**
 * JavaScript/Node.js Script for SEGMENT_TEST_TABLE - DELETE Operations
 * Technology: Node.js with oracledb
 * Purpose: Perform DELETE operations on SEGMENT_TEST_TABLE
 * 
 * Installation: npm install oracledb dotenv
 */

const oracledb = require('oracledb');
require('dotenv').config();

// Database configuration
const dbConfig = {
    user: process.env.DB_USER || 'dev_user_26ai',
    password: process.env.DB_PASSWORD || 'your_password',
    connectString: process.env.DB_CONNECT_STRING || 'adb.us-phoenix-1.oraclecloud.com:1522/gcf91c40155de9b_vkatp26ai_low.adb.oraclecloud.com'
};

class SegmentTestDelete {
    /**
     * Initialize database connection
     */
    async connect() {
        try {
            this.connection = await oracledb.getConnection(dbConfig);
            console.log('✓ Database connection established');
        } catch (error) {
            console.error(`✗ Error connecting to database: ${error.message}`);
            throw error;
        }
    }

    /**
     * DELETE a single transaction by ID
     * 
     * @param {number} transactionId - Transaction ID to delete
     * @returns {Promise<boolean>} - True if successful
     */
    async deleteTransaction(transactionId) {
        try {
            const result = await this.connection.execute(
                `DELETE FROM SEGMENT_TEST_TABLE WHERE TRANSACTION_ID = :transactionId`,
                [transactionId],
                { autoCommit: true }
            );

            if (result.rowsAffected === 0) {
                console.log(`✗ Transaction ID not found: ${transactionId}`);
                return false;
            }

            console.log(`✓ Transaction deleted | ID: ${transactionId}, Rows affected: ${result.rowsAffected}`);
            return true;

        } catch (error) {
            console.error(`✗ Error deleting transaction: ${error.message}`);
            return false;
        }
    }

    /**
     * DELETE transactions by status code
     * 
     * @param {number} statusCode - Status code to match
     * @returns {Promise<number>} - Number of rows deleted
     */
    async deleteByStatus(statusCode) {
        try {
            const result = await this.connection.execute(
                `DELETE FROM SEGMENT_TEST_TABLE WHERE STATUS_CODE = :statusCode`,
                [statusCode],
                { autoCommit: true }
            );

            console.log(`✓ Delete by status completed | Status: ${statusCode}, Rows deleted: ${result.rowsAffected}`);
            return result.rowsAffected;

        } catch (error) {
            console.error(`✗ Error deleting by status: ${error.message}`);
            return 0;
        }
    }

    /**
     * DELETE transactions by date range
     * 
     * @param {string} startDate - Start date (YYYY-MM-DD)
     * @param {string} endDate - End date (YYYY-MM-DD)
     * @returns {Promise<number>} - Number of rows deleted
     */
    async deleteByDateRange(startDate, endDate) {
        try {
            const result = await this.connection.execute(
                `DELETE FROM SEGMENT_TEST_TABLE 
                 WHERE CREATION_DATE >= TO_DATE(:startDate, 'YYYY-MM-DD') 
                 AND CREATION_DATE < TO_DATE(:endDate, 'YYYY-MM-DD')`,
                [startDate, endDate],
                { autoCommit: true }
            );

            console.log(`✓ Delete by date range completed | From: ${startDate} To: ${endDate}, Rows deleted: ${result.rowsAffected}`);
            return result.rowsAffected;

        } catch (error) {
            console.error(`✗ Error deleting by date range: ${error.message}`);
            return 0;
        }
    }

    /**
     * DELETE archived transactions
     * 
     * @returns {Promise<number>} - Number of rows deleted
     */
    async deleteArchivedTransactions() {
        try {
            const result = await this.connection.execute(
                `DELETE FROM SEGMENT_TEST_TABLE WHERE IS_ARCHIVED = 'Y'`,
                [],
                { autoCommit: true }
            );

            console.log(`✓ Archived transactions deleted | Rows deleted: ${result.rowsAffected}`);
            return result.rowsAffected;

        } catch (error) {
            console.error(`✗ Error deleting archived transactions: ${error.message}`);
            return 0;
        }
    }

    /**
     * DELETE transactions with errors (for cleanup)
     * 
     * @returns {Promise<number>} - Number of rows deleted
     */
    async deleteErrorTransactions() {
        try {
            const result = await this.connection.execute(
                `DELETE FROM SEGMENT_TEST_TABLE WHERE ERROR_CODE IS NOT NULL`,
                [],
                { autoCommit: true }
            );

            console.log(`✓ Error transactions deleted | Rows deleted: ${result.rowsAffected}`);
            return result.rowsAffected;

        } catch (error) {
            console.error(`✗ Error deleting error transactions: ${error.message}`);
            return 0;
        }
    }

    /**
     * BULK DELETE - Delete multiple specific transactions
     * 
     * @param {array} transactionIds - Array of transaction IDs to delete
     * @returns {Promise<number>} - Number of rows deleted
     */
    async bulkDelete(transactionIds) {
        try {
            const placeholders = transactionIds.map((_, i) => `:id${i}`).join(',');
            const bindParams = {};
            transactionIds.forEach((id, i) => {
                bindParams[`id${i}`] = id;
            });

            const result = await this.connection.execute(
                `DELETE FROM SEGMENT_TEST_TABLE WHERE TRANSACTION_ID IN (${placeholders})`,
                bindParams,
                { autoCommit: true }
            );

            console.log(`✓ Bulk delete completed | Records deleted: ${result.rowsAffected}`);
            return result.rowsAffected;

        } catch (error) {
            console.error(`✗ Error in bulk delete: ${error.message}`);
            return 0;
        }
    }

    /**
     * Close database connection
     */
    async disconnect() {
        try {
            if (this.connection) {
                await this.connection.close();
                console.log('✓ Database connection closed');
            }
        } catch (error) {
            console.error(`✗ Error closing connection: ${error.message}`);
        }
    }
}

/**
 * Main execution function
 */
async function main() {
    const dml = new SegmentTestDelete();

    try {
        await dml.connect();

        // Delete single transaction
        console.log('\n--- DELETE Single Transaction ---');
        await dml.deleteTransaction(10001);

        // Delete by status code
        console.log('\n--- DELETE by Status Code ---');
        await dml.deleteByStatus(5);

        // Delete by date range
        console.log('\n--- DELETE by Date Range ---');
        await dml.deleteByDateRange('2026-01-01', '2026-02-01');

        // Delete archived transactions
        console.log('\n--- DELETE Archived Transactions ---');
        await dml.deleteArchivedTransactions();

        // Delete error transactions
        console.log('\n--- DELETE Error Transactions ---');
        await dml.deleteErrorTransactions();

        // Bulk delete
        console.log('\n--- BULK DELETE ---');
        await dml.bulkDelete([10005, 10006, 10007, 10008]);

    } catch (error) {
        console.error(`Fatal error: ${error.message}`);
    } finally {
        await dml.disconnect();
    }
}

// Execute main function
if (require.main === module) {
    main().catch(error => {
        console.error(error);
        process.exit(1);
    });
}

// Export for use as module
module.exports = SegmentTestDelete;
