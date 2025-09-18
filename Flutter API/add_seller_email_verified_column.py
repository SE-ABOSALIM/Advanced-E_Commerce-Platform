import psycopg2
from psycopg2 import Error
import os
from dotenv import load_dotenv

# Environment variables'ları yükle
load_dotenv('config.env')

def add_seller_email_verified_column():
    """Sellers tablosuna email_verified kolonunu ekle"""
    try:
        # PostgreSQL bağlantısı
        connection = psycopg2.connect(
            host='localhost',
            database='postgres',
            user='postgres',
            password='Hms24680',
            port='5432'
        )
        
        cursor = connection.cursor()
        
        # 1. email_verified kolonunu ekle
        print("📧 Sellers tablosuna email_verified kolonu ekleniyor...")
        cursor.execute("""
            ALTER TABLE sellers 
            ADD COLUMN IF NOT EXISTS email_verified VARCHAR(50) DEFAULT 'pending'
        """)
        
        # 2. Mevcut satıcıların email_verified durumunu 'pending' yap
        print("🔄 Mevcut satıcıların email_verified durumu güncelleniyor...")
        cursor.execute("""
            UPDATE sellers 
            SET email_verified = 'pending' 
            WHERE email_verified IS NULL
        """)
        
        # 3. email_verifications_seller tablosunu oluştur
        print("📋 email_verifications_seller tablosu oluşturuluyor...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS email_verifications_seller (
                id SERIAL PRIMARY KEY,
                email VARCHAR(255) UNIQUE NOT NULL,
                verification_code VARCHAR(10) NOT NULL,
                is_verified VARCHAR(50) DEFAULT 'pending',
                attempts INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                expires_at TIMESTAMP NOT NULL
            )
        """)
        
        # 4. Değişiklikleri kaydet
        connection.commit()
        
        print("✅ Sellers tablosu başarıyla güncellendi!")
        print("✅ email_verifications_seller tablosu oluşturuldu!")
        
        # 5. Kontrol et
        cursor.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'sellers' AND column_name = 'email_verified'")
        if cursor.fetchone():
            print("✅ email_verified kolonu başarıyla eklendi!")
        else:
            print("❌ email_verified kolonu eklenemedi!")
        
        cursor.execute("SELECT COUNT(*) FROM sellers")
        seller_count = cursor.fetchone()[0]
        print(f"📊 Toplam satıcı sayısı: {seller_count}")
        
    except (Exception, Error) as error:
        print(f"❌ Hata: {error}")
    finally:
        if connection:
            cursor.close()
            connection.close()
            print("🔌 Veritabanı bağlantısı kapatıldı")

if __name__ == "__main__":
    add_seller_email_verified_column()
