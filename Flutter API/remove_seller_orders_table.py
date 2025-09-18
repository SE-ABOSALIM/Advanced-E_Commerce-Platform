import psycopg2
from psycopg2 import sql

# Database connection parameters
DB_NAME = "e_ticaret"
DB_USER = "postgres"
DB_PASSWORD = "123456"
DB_HOST = "localhost"
DB_PORT = "5432"

def remove_seller_orders_table():
    try:
        # Connect to the database
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        
        cursor = conn.cursor()
        
        # Drop seller_orders table
        drop_table_query = "DROP TABLE IF EXISTS seller_orders CASCADE;"
        
        cursor.execute(drop_table_query)
        conn.commit()
        
        print("✅ seller_orders tablosu başarıyla kaldırıldı!")
        print("📋 Artık users_order tablosunu kullanacağız.")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Hata: {e}")

if __name__ == "__main__":
    remove_seller_orders_table() 