from database import SessionLocal
import models
from sqlalchemy import text

def check_phone_verification_tables():
    """Telefon doğrulama tablolarını kontrol et"""
    db = SessionLocal()
    try:
        print("=== TELEFON DOĞRULAMA TABLOLARI KONTROLÜ ===")
        
        # phone_verification tablosunu kontrol et
        print("\n1. phone_verification tablosu:")
        phone_verifications = db.query(models.PhoneVerification).all()
        if phone_verifications:
            for pv in phone_verifications:
                print(f"   - {pv.phone_number} | Durum: {pv.is_verified} | Kod: {pv.verification_code}")
        else:
            print("   - Tablo boş")
        
        # phone_verification_seller tablosunu kontrol et
        print("\n2. phone_verification_seller tablosu:")
        seller_verifications = db.query(models.PhoneVerificationSeller).all()
        if seller_verifications:
            for sv in seller_verifications:
                print(f"   - {sv.phone_number} | Durum: {sv.is_verified} | Kod: {sv.verification_code}")
        else:
            print("   - Tablo boş")
        
        # users tablosunu kontrol et
        print("\n3. users tablosu:")
        users = db.query(models.User).all()
        if users:
            for user in users:
                print(f"   - {user.phone_number} | Email: {user.email} | Doğrulama: {user.phone_verified}")
        else:
            print("   - Tablo boş")
        
        # sellers tablosunu kontrol et
        print("\n4. sellers tablosu:")
        sellers = db.query(models.Seller).all()
        if sellers:
            for seller in sellers:
                print(f"   - {seller.phone} | Email: {seller.email} | Doğrulama: {seller.phone_verified}")
        else:
            print("   - Tablo boş")
        
        print("\n=== KONTROL TAMAMLANDI ===")
        
    except Exception as e:
        print(f"Hata: {e}")
    finally:
        db.close()

def test_seller_verification_endpoint():
    """Seller doğrulama endpoint'ini test et"""
    import requests
    import json
    
    print("\n=== SELLER DOĞRULAMA ENDPOINT TESTİ ===")
    
    # Test telefon numarası
    test_phone = "05389874376"
    
    try:
        # 1. Doğrulama kodu gönder
        print(f"\n1. Doğrulama kodu gönderiliyor: {test_phone}")
        response = requests.post(
            "http://127.0.0.1:8000/send-seller-verification-code",
            headers={"Content-Type": "application/json"},
            data=json.dumps({
                "phone_number": test_phone,
                "language": "tr"
            })
        )
        
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
        
        if response.status_code == 200:
            # 2. Gönderilen kodu al
            db = SessionLocal()
            verification = db.query(models.PhoneVerificationSeller).filter(
                models.PhoneVerificationSeller.phone_number == test_phone
            ).first()
            
            if verification:
                code = verification.verification_code
                print(f"\n2. Gönderilen kod: {code}")
                
                # 3. Kodu doğrula
                print(f"\n3. Kod doğrulanıyor: {code}")
                verify_response = requests.post(
                    "http://127.0.0.1:8000/verify-seller-phone",
                    headers={"Content-Type": "application/json"},
                    data=json.dumps({
                        "phone_number": test_phone,
                        "verification_code": code
                    })
                )
                
                print(f"   Status: {verify_response.status_code}")
                print(f"   Response: {verify_response.text}")
            else:
                print("   Doğrulama kaydı bulunamadı")
            
            db.close()
        
    except Exception as e:
        print(f"Test hatası: {e}")

if __name__ == "__main__":
    check_phone_verification_tables()
    test_seller_verification_endpoint()
