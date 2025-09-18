import sqlite3

def check_schema():
    try:
        # Database'e bağlan
        conn = sqlite3.connect('ecommerce.db')
        cursor = conn.cursor()
        
        print("🔍 DATABASE SCHEMA KONTROLÜ")
        print("=" * 50)
        
        # Users tablosu schema'sı
        cursor.execute("PRAGMA table_info(users)")
        users_columns = cursor.fetchall()
        print(f"\n👥 USERS TABLOSU SÜTUNLARI:")
        for col in users_columns:
            print(f"   {col[1]} ({col[2]}) - PK: {col[5]}")
        
        # Sellers tablosu schema'sı
        cursor.execute("PRAGMA table_info(sellers)")
        sellers_columns = cursor.fetchall()
        print(f"\n🏪 SELLERS TABLOSU SÜTUNLARI:")
        for col in sellers_columns:
            print(f"   {col[1]} ({col[2]}) - PK: {col[5]}")
        
        # Users_sellers tablosu schema'sı
        cursor.execute("PRAGMA table_info(users_sellers)")
        users_sellers_columns = cursor.fetchall()
        print(f"\n❤️ USERS_SELLERS TABLOSU SÜTUNLARI:")
        for col in users_sellers_columns:
            print(f"   {col[1]} ({col[2]}) - PK: {col[5]}")
        
        conn.close()
        
    except Exception as e:
        print(f'❌ Hata: {e}')

if __name__ == "__main__":
    check_schema()
