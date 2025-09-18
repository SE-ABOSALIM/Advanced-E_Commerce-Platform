import requests
import json
from database import SessionLocal
import models
import time

def test_verification_flow():
    """Verification akışını test et"""
    base_url = "http://127.0.0.1:8000"
    test_phone = "05389874379"  # Yeni test numarası
    
    print("=== VERIFICATION AKIŞ TESTİ ===")
    
    # 1. Doğrulama kodu gönder
    print(f"\n1. Doğrulama kodu gönderiliyor: {test_phone}")
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
            # 2. Verification tablosunu kontrol et
            db = SessionLocal()
            verification = db.query(models.PhoneVerification).filter(
                models.PhoneVerification.phone_number == test_phone
            ).first()
            
            if verification:
                print(f"   ✅ Verification tablosuna kayıt düştü!")
                print(f"   - Kod: {verification.verification_code}")
                print(f"   - Durum: {verification.is_verified}")
                
                # 3. Kodu doğrula
                print(f"\n2. Kod doğrulanıyor: {verification.verification_code}")
                verify_response = requests.post(
                    f"{base_url}/verify-phone",
                    headers={"Content-Type": "application/json"},
                    data=json.dumps({
                        "phone_number": test_phone,
                        "verification_code": verification.verification_code
                    })
                )
                print(f"   Status: {verify_response.status_code}")
                print(f"   Response: {verify_response.text}")
                
                if verify_response.status_code == 200:
                    # 4. Verification tablosunu tekrar kontrol et
                    db.refresh(verification)
                    print(f"\n3. Doğrulama sonrası verification tablosu:")
                    print(f"   - Durum: {verification.is_verified}")
                    
                    # 5. Kullanıcı kaydı yap
                    print(f"\n4. Kullanıcı kaydı yapılıyor...")
                    user_data = {
                        "name_surname": "Test User Flow",
                        "email": "testflow2@example.com",
                        "password": "Test123!",
                        "phone_number": test_phone
                    }
                    
                    user_response = requests.post(
                        f"{base_url}/users",
                        headers={"Content-Type": "application/json"},
                        data=json.dumps(user_data)
                    )
                    print(f"   Status: {user_response.status_code}")
                    print(f"   Response: {user_response.text}")
                    
                    if user_response.status_code == 200:
                        # 6. Verification tablosunu son kontrol
                        print(f"\n5. Kayıt sonrası verification tablosu kontrolü:")
                        verification_after = db.query(models.PhoneVerification).filter(
                            models.PhoneVerification.phone_number == test_phone
                        ).first()
                        
                        if verification_after:
                            print(f"   ✅ Verification kaydı hala var!")
                            print(f"   - Durum: {verification_after.is_verified}")
                            print(f"   - Deneme sayısı: {verification_after.attempts}")
                        else:
                            print(f"   ❌ Verification kaydı silindi!")
                        
                        # 7. Users tablosunu kontrol et
                        user = db.query(models.User).filter(
                            models.User.phone_number == test_phone
                        ).first()
                        
                        if user:
                            print(f"   ✅ Users tablosunda kayıt var!")
                            print(f"   - phone_verified: {user.phone_verified}")
                        else:
                            print(f"   ❌ Users tablosunda kayıt yok!")
            
            db.close()
        
    except Exception as e:
        print(f"   Hata: {e}")

if __name__ == "__main__":
    test_verification_flow()
