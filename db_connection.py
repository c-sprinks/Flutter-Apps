import os
import psycopg2
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Access database credentials from environment variables
database_host = os.environ.get("PGHOST")
database_name = os.environ.get("PGDATABASE")
database_user = os.environ.get("PGUSER")
database_password = os.environ.get("PGPASSWORD")

# Check if environment variables are set
if not all([database_host, database_name, database_user, database_password]):
    logging.error("Missing database environment variables.  Please set PGHOST, PGDATABASE, PGUSER, and PGPASSWORD.")
    exit()

# Establish a connection to the database
try:
    conn = psycopg2.connect(host=database_host, database=database_name, 
user=database_user, password=database_password)
    conn.autocommit = False  # Disable autocommit for explicit commits
    cur = conn.cursor()

    # Insert a new conversation entry
    cur.execute("""
        INSERT INTO conversations (user_id, message_text, sender, timestamp)
        VALUES (%s, %s, %s, CURRENT_TIMESTAMP);
    """, ('user1', 'Hello, world!', 'Alice'))

    conn.commit()  # Commit the transaction
    print("Conversation entry inserted successfully!")

except psycopg2.Error as e:
    error_message = f"Error inserting conversation entry: {e}"
    logging.error(error_message)
    print(error_message)

finally:
    if cur:
        try:
            cur.close()
        except Exception as e:
            logging.error(f"Error closing cursor: {e}")
    if conn:
        try:
            conn.close()
        except Exception as e:
            logging.error(f"Error closing connection: {e}")