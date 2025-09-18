import sqlite3
from datetime import datetime

def add_test_data():
    try:
        # Database'e bağlan
        conn = sqlite3.connect('ecommerce.db')
        cursor = conn.cursor()
        
        print("🧪 TEST VERİLERİ EKLENİYOR...")
        print("=" * 50)
        
        # Test kullanıcısı ekle (users tablosu schema'sına uygun)
        cursor.execute('''
            INSERT OR IGNORE INTO users (id, name_surname, password, email, phone_number, phone_verified, created_at, updated_at)
            VALUES (20, 'Test User', '123456', 'test@test.com', '+90 532 123 45 67', 'pending', ?, ?)
        ''', (datetime.now().isoformat(), datetime.now().isoformat()))
        
        # Test satıcısı ekle (sellers tablosu schema'sına uygun)
        cursor.execute('''
            INSERT OR IGNORE INTO sellers (id, name, email, password, phone, phone_verified, store_name, store_description, created_at, updated_at, followers_count)
            VALUES (11, 'Test Seller', 'seller@test.com', '123456', '+90 532 987 65 43', 'pending', 'Test Mağaza', 'Test mağaza açıklaması', ?, ?, 0)
        ''', (datetime.now().isoformat(), datetime.now().isoformat()))
        
        # Değişiklikleri kaydet
        conn.commit()
        print("✅ Test verileri eklendi!")
        
        # Kontrol et
        cursor.execute('SELECT id, email FROM users WHERE id = 20')
        user = cursor.fetchone()
        if user:
            print(f"👤 Test Kullanıcı: ID {user[0]}, Email: {user[1]}")
        
        cursor.execute('SELECT id, store_name FROM sellers WHERE id = 11')
        seller = cursor.fetchone()
        if seller:
            print(f"🏪 Test Satıcı: ID {seller[0]}, Mağaza: {seller[1]}")
        
        conn.close()
        
    except Exception as e:
        print(f'❌ Hata: {e}')

if __name__ == "__main__":
    add_test_data()
