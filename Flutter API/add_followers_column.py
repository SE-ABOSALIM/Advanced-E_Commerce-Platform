import sqlite3

def add_followers_column():
    try:
        # Database'e bağlan
        conn = sqlite3.connect('ecommerce.db')
        cursor = conn.cursor()
        
        # Sellers tablosuna followers_count sütunu ekle
        cursor.execute('ALTER TABLE sellers ADD COLUMN followers_count INTEGER DEFAULT 0')
        
        # Değişiklikleri kaydet
        conn.commit()
        print('✅ followers_count sütunu sellers tablosuna eklendi!')
        
        # Mevcut satıcıların takipçi sayısını güncelle
        cursor.execute('''
            UPDATE sellers 
            SET followers_count = (
                SELECT COUNT(*) 
                FROM users_sellers 
                WHERE users_sellers.seller_id = sellers.id
            )
        ''')
        
        conn.commit()
        print('✅ Mevcut satıcıların takipçi sayıları güncellendi!')
        
        # Kontrol et
        cursor.execute('SELECT id, store_name, followers_count FROM sellers LIMIT 5')
        sellers = cursor.fetchall()
        print('\n📊 İlk 5 satıcının takipçi sayıları:')
        for seller in sellers:
            print(f'   ID: {seller[0]}, Mağaza: {seller[1]}, Takipçi: {seller[2]}')
        
        conn.close()
        
    except Exception as e:
        print(f'❌ Hata: {e}')
        if 'duplicate column name' in str(e):
            print('ℹ️ followers_count sütunu zaten mevcut!')

if __name__ == "__main__":
    add_followers_column()
