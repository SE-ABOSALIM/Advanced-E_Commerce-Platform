import sqlite3

def check_database():
    try:
        # Database'e bağlan
        conn = sqlite3.connect('ecommerce.db')
        cursor = conn.cursor()
        
        print("🔍 DATABASE KONTROLÜ")
        print("=" * 50)
        
        # Kullanıcıları kontrol et
        cursor.execute('SELECT id, email FROM users LIMIT 10')
        users = cursor.fetchall()
        print(f"\n👥 KULLANICILAR (Toplam: {len(users)}):")
        if users:
            for user in users:
                print(f"   ID: {user[0]}, Email: {user[1]}")
        else:
            print("   ❌ Hiç kullanıcı yok!")
        
        # Satıcıları kontrol et
        cursor.execute('SELECT id, store_name FROM sellers LIMIT 10')
        sellers = cursor.fetchall()
        print(f"\n🏪 SATICILAR (Toplam: {len(sellers)}):")
        if sellers:
            for seller in sellers:
                print(f"   ID: {seller[0]}, Mağaza: {seller[1]}")
        else:
            print("   ❌ Hiç satıcı yok!")
        
        # Takip kayıtlarını kontrol et
        cursor.execute('SELECT user_id, seller_id FROM users_sellers LIMIT 10')
        follows = cursor.fetchall()
        print(f"\n❤️ TAKIP KAYITLARI (Toplam: {len(follows)}):")
        if follows:
            for follow in follows:
                print(f"   Kullanıcı {follow[0]} -> Satıcı {follow[1]}")
        else:
            print("   ❌ Hiç takip kaydı yok!")
        
        conn.close()
        
    except Exception as e:
        print(f'❌ Hata: {e}')

if __name__ == "__main__":
    check_database()
