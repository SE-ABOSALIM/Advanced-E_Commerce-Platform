import requests
import json
from database import SessionLocal
import models

def test_scenario():
    """Test senaryosu: Aynı telefon numarası ile hem user hem seller kaydı"""
    base_url = "http://127.0.0.1:8000"
    test_phone = "05389874376"
    
    print("=== TEST SENARYOSU: AYNI TELEFON NUMARASI KONTROLÜ ===")
    
    # 1. Normal kullanıcı için doğrulama kodu gönder
    print(f"\n1. Normal kullanıcı için doğrulama kodu gönderiliyor: {test_phone}")
    try:
        response = requests.post(
            f"{base_url}/send-verification-code",
            headers={"Content-Type": "application/json"},
            data=json.dumps({
                "phone_number": test_phone,
                "language": "tr"
            })
        )
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
        
        if response.status_code == 200:
            # Doğrulama kodunu al
            db = SessionLocal()
            verification = db.query(models.PhoneVerification).filter(
                models.PhoneVerification.phone_number == test_phone
            ).first()
            
            if verification:
                code = verification.verification_code
                print(f"   Gönderilen kod: {code}")
                
                # Kodu doğrula
                verify_response = requests.post(
                    f"{base_url}/verify-phone",
                    headers={"Content-Type": "application/json"},
                    data=json.dumps({
                        "phone_number": test_phone,
                        "verification_code": code
                    })
                )
                print(f"   Doğrulama Status: {verify_response.status_code}")
                print(f"   Doğrulama Response: {verify_response.text}")
                
                if verify_response.status_code == 200:
                    # Normal kullanıcı kaydı yap
                    user_data = {
                        "name_surname": "Test User",
                        "email": "testuser@example.com",
                        "password": "Test123!",
                        "phone_number": test_phone
                    }
                    
                    user_response = requests.post(
                        f"{base_url}/users",
                        headers={"Content-Type": "application/json"},
                        data=json.dumps(user_data)
                    )
                    print(f"   User kayıt Status: {user_response.status_code}")
                    print(f"   User kayıt Response: {user_response.text}")
            
            db.close()
        
    except Exception as e:
        print(f"   Hata: {e}")
    
    # 2. Şimdi aynı telefon numarası ile seller kaydı yapmaya çalış
    print(f"\n2. Aynı telefon numarası ile seller kaydı yapmaya çalışılıyor: {test_phone}")
    try:
        seller_response = requests.post(
            f"{base_url}/send-seller-verification-code",
            headers={"Content-Type": "application/json"},
            data=json.dumps({
                "phone_number": test_phone,
                "language": "tr"
            })
        )
        print(f"   Status: {seller_response.status_code}")
        print(f"   Response: {seller_response.text}")
        
        # Beklenen sonuç: 400 hatası - "Bu telefon numarasına kayıtlı başka bir hesap vardır"
        
    except Exception as e:
        print(f"   Hata: {e}")
    
    # 3. Tabloları kontrol et
    print(f"\n3. Tabloların son durumu:")
    db = SessionLocal()
    try:
        # phone_verification
        pv_count = db.query(models.PhoneVerification).count()
        print(f"   phone_verification: {pv_count} kayıt")
        
        # phone_verification_seller
        pvs_count = db.query(models.PhoneVerificationSeller).count()
        print(f"   phone_verification_seller: {pvs_count} kayıt")
        
        # users
        users_count = db.query(models.User).count()
        print(f"   users: {users_count} kayıt")
        
        # sellers
        sellers_count = db.query(models.Seller).count()
        print(f"   sellers: {sellers_count} kayıt")
        
    except Exception as e:
        print(f"   Hata: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    test_scenario()
