import psycopg2
from datetime import datetime

def update_existing_delivered_orders():
    try:
        # Database bağlantısı
        conn = psycopg2.connect(
            host="localhost",
            database="postgres",
            user="postgres",
            password="Hms24680"
        )
        cursor = conn.cursor()
        
        # Teslim edilmiş ama teslim tarihi olmayan siparişleri bul
        cursor.execute("""
            SELECT id, order_code, order_status, order_delivered_date 
            FROM "order" 
            WHERE order_status = 'delivered' AND order_delivered_date IS NULL
        """)
        
        results = cursor.fetchall()
        print("=== GÜNCELLENECEK SİPARİŞLER ===")
        
        if not results:
            print("✅ Güncellenecek sipariş yok!")
        else:
            current_time = datetime.now()
            print(f"Şu anki zaman: {current_time}")
            
            for row in results:
                order_id, order_code, status, delivered_date = row
                print(f"Güncelleniyor - Sipariş ID: {order_id}, Kod: {order_code}")
                
                # Teslim tarihini güncelle
                cursor.execute("""
                    UPDATE "order" 
                    SET order_delivered_date = %s 
                    WHERE id = %s
                """, (current_time, order_id))
            
            conn.commit()
            print(f"✅ {len(results)} sipariş güncellendi!")
        
        # Güncelleme sonrası kontrol
        cursor.execute("""
            SELECT id, order_code, order_status, order_delivered_date 
            FROM "order" 
            WHERE order_status = 'delivered'
        """)
        
        updated_results = cursor.fetchall()
        print("\n=== GÜNCELLEME SONRASI TESLİM EDİLMİŞ SİPARİŞLER ===")
        for row in updated_results:
            order_id, order_code, status, delivered_date = row
            print(f"Sipariş ID: {order_id}, Kod: {order_code}, Durum: {status}, Teslim Tarihi: {delivered_date}")
        
    except Exception as e:
        print(f"❌ Hata: {e}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    update_existing_delivered_orders() 