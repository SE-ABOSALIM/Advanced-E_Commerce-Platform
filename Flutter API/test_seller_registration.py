import requests
import json
from database import SessionLocal
import models

def test_seller_registration():
    """Seller kayıt işlemini test et"""
    base_url = "http://127.0.0.1:8000"
    test_phone = "05389874376"
    
    print("=== SELLER KAYIT TESTİ ===")
    
    # 1. Seller doğrulama kodunu al
    print(f"\n1. Seller doğrulama kodu alınıyor: {test_phone}")
    db = SessionLocal()
    verification = db.query(models.PhoneVerificationSeller).filter(
        models.PhoneVerificationSeller.phone_number == test_phone
    ).first()
    
    if verification:
        code = verification.verification_code
        print(f"   Doğrulama kodu: {code}")
        
        # 2. Kodu doğrula
        print(f"\n2. Kod doğrulanıyor: {code}")
        verify_response = requests.post(
            f"{base_url}/verify-seller-phone",
            headers={"Content-Type": "application/json"},
            data=json.dumps({
                "phone_number": test_phone,
                "verification_code": code
            })
        )
        print(f"   Status: {verify_response.status_code}")
        print(f"   Response: {verify_response.text}")
        
        if verify_response.status_code == 200:
            # 3. Seller kaydı yap
            print(f"\n3. Seller kaydı yapılıyor")
            seller_data = {
                "name": "Test Seller",
                "email": "testseller@example.com",
                "password": "Test123!",
                "phone": test_phone,
                "store_name": "Test Store",
                "store_description": "Test store description",
                "cargo_company": "Araskargo"
            }
            
            seller_response = requests.post(
                f"{base_url}/sellers/signup",
                data=seller_data
            )
            print(f"   Status: {seller_response.status_code}")
            print(f"   Response: {seller_response.text}")
            
            if seller_response.status_code == 200:
                print(f"\n✅ Seller kaydı başarılı!")
                
                # 4. Şimdi aynı telefon numarası ile tekrar seller kaydı yapmaya çalış
                print(f"\n4. Aynı telefon numarası ile tekrar seller kaydı yapmaya çalışılıyor")
                duplicate_response = requests.post(
                    f"{base_url}/send-seller-verification-code",
                    headers={"Content-Type": "application/json"},
                    data=json.dumps({
                        "phone_number": test_phone,
                        "language": "tr"
                    })
                )
                print(f"   Status: {duplicate_response.status_code}")
                print(f"   Response: {duplicate_response.text}")
                
                # Beklenen sonuç: 400 hatası - "Bu telefon numarasına kayıtlı başka bir satıcı hesabı vardır"
            else:
                print(f"\n❌ Seller kaydı başarısız!")
        else:
            print(f"\n❌ Kod doğrulama başarısız!")
    else:
        print(f"\n❌ Doğrulama kaydı bulunamadı!")
    
    db.close()
    
    # 5. Tabloları kontrol et
    print(f"\n5. Tabloların son durumu:")
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
        
        if sellers_count > 0:
            sellers = db.query(models.Seller).all()
            for seller in sellers:
                print(f"   - Seller: {seller.phone} | Email: {seller.email}")
        
    except Exception as e:
        print(f"   Hata: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    test_seller_registration()
