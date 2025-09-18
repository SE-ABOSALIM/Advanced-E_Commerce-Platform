import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

# Database connection parameters
DB_NAME = "postgres"
DB_USER = "postgres"
DB_PASSWORD = "Hms24680"
DB_HOST = "localhost"
DB_PORT = "5432"

def update_address_columns():
    try:
        # Connect to database
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        # Update building_number column from integer to text
        cursor.execute("""
            ALTER TABLE address 
            ALTER COLUMN building_number TYPE TEXT USING building_number::TEXT
        """)
        print("building_number column updated to TEXT")
        
        # Update apartment_number column from integer to text
        cursor.execute("""
            ALTER TABLE address 
            ALTER COLUMN apartment_number TYPE TEXT USING apartment_number::TEXT
        """)
        print("apartment_number column updated to TEXT")
        
        cursor.close()
        conn.close()
        print("Address table columns updated successfully!")
        
    except Exception as e:
        print(f"Error updating address columns: {e}")

if __name__ == "__main__":
    update_address_columns() 