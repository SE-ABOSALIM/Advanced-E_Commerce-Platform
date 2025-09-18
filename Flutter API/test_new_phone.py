import requests
import json
from database import SessionLocal
import models

def test_new_phone():
    """Yeni telefon numarası ile test"""
    base_url = "http://127.0.0.1:8000"
    new_phone = "05389874377"  # Yeni numara
    
    print("=== YENİ TELEFON NUMARASI TESTİ ===")
    
    # 1. Normal kullanıcı için doğrulama kodu gönder
    print(f"\n1. Normal kullanıcı için doğrulama kodu gönderiliyor: {new_phone}")
    try:
        response = requests.post(
            f"{base_url}/send-verification-code",
            headers={"Content-Type": "application/json"},
            data=json.dumps({
                "phone_number": new_phone,
                "language": "tr"
            })
        )
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
        
        if response.status_code == 200:
            # Verification tablosunu kontrol et
            db = SessionLocal()
            verification = db.query(models.PhoneVerification).filter(
                models.PhoneVerification.phone_number == new_phone
            ).first()
            
            if verification:
                print(f"   ✅ Verification tablosuna kayıt düştü!")
                print(f"   - Kod: {verification.verification_code}")
                print(f"   - Durum: {verification.is_verified}")
            else:
                print(f"   ❌ Verification tablosuna kayıt düşmedi!")
            
            db.close()
        
    except Exception as e:
        print(f"   Hata: {e}")
    
    # 2. Tabloları kontrol et
    print(f"\n2. Tabloların durumu:")
    db = SessionLocal()
    try:
        # phone_verification
        pv_count = db.query(models.PhoneVerification).count()
        print(f"   phone_verification: {pv_count} kayıt")
        
        # phone_verification_seller
        pvs_count = db.query(models.PhoneVerificationSeller).count()
        print(f"   phone_verification_seller: {pvs_count} kayıt")
        
        if pv_count > 0:
            verifications = db.query(models.PhoneVerification).all()
            for v in verifications:
                print(f"   - {v.phone_number} | Durum: {v.is_verified} | Kod: {v.verification_code}")
        
    except Exception as e:
        print(f"   Hata: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    test_new_phone()
