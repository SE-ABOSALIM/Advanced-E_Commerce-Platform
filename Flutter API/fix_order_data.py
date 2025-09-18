import psycopg2
from datetime import datetime

def fix_order_data():
    try:
        # Database bağlantısı
        conn = psycopg2.connect(
            host="localhost",
            database="postgres",
            user="postgres",
            password="Hms24680"
        )
        
        cursor = conn.cursor()
        
        # Mevcut yanlış veriyi kontrol et
        cursor.execute("SELECT * FROM \"order\" WHERE id = 15")
        order = cursor.fetchone()
        
        if order:
            print("=== MEVCUT YANLIŞ VERİ ===")
            print(f"ID: {order[0]}")
            print(f"Code: {order[1]}")
            print(f"Created Date: {order[2]}")
            print(f"Estimated Delivery: {order[3]}")
            print(f"Delivered Date: {order[4]} (YANLIŞ - Bu cargo_company olmalı)")
            print(f"Cargo Company: {order[5]} (YANLIŞ - Bu address olmalı)")
            print(f"Address: {order[6]} (YANLIŞ - Bu status olmalı)")
            print(f"Status: {order[7]} (YANLIŞ - Bu None)")
            
            # Doğru verileri güncelle
            cursor.execute("""
                UPDATE "order" 
                SET 
                    order_cargo_company = %s,
                    order_address = %s,
                    order_status = %s,
                    order_delivered_date = %s
                WHERE id = 15
            """, (
                order[4],  # Jetkargo -> order_cargo_company
                order[5],  # 20 -> order_address
                order[6],  # delivered -> order_status
                datetime.now()  # Şu anki tarih -> order_delivered_date
            ))
            
            conn.commit()
            print("\n=== VERİ DÜZELTİLDİ ===")
            
            # Düzeltilmiş veriyi kontrol et
            cursor.execute("SELECT * FROM \"order\" WHERE id = 15")
            fixed_order = cursor.fetchone()
            
            print("=== DÜZELTİLMİŞ VERİ ===")
            print(f"ID: {fixed_order[0]}")
            print(f"Code: {fixed_order[1]}")
            print(f"Created Date: {fixed_order[2]}")
            print(f"Estimated Delivery: {fixed_order[3]}")
            print(f"Delivered Date: {fixed_order[4]}")
            print(f"Cargo Company: {fixed_order[5]}")
            print(f"Address: {fixed_order[6]}")
            print(f"Status: {fixed_order[7]}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    fix_order_data() 