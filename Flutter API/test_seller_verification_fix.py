import requests
import json

def test_seller_verification_fix():
    """Satıcı verification endpoint'inin düzeltilip düzeltilmediğini test et"""
    base_url = "http://127.0.0.1:8000"
    test_phone = "05380708813"  # Normal kullanıcı olarak kayıtlı olan numara
    
    print("=== SATICI VERIFICATION FIX TESTİ ===")
    print(f"📞 Test telefon: {test_phone}")
    print(f"ℹ️ Bu numara normal kullanıcı olarak kayıtlı")
    
    # Satıcı verification kodu gönder
    print(f"\n1. Satıcı verification kodu gönderiliyor...")
    try:
        response = requests.post(
            f"{base_url}/send-seller-verification-code",
            headers={"Content-Type": "application/json"},
            data=json.dumps({
                "phone_number": test_phone,
                "language": "tr"
            })
        )
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
        
        if response.status_code == 200:
            print(f"   ✅ Başarılı! Artık normal kullanıcı kontrolü yapılmıyor")
        else:
            print(f"   ❌ Hala hata var")
            
    except Exception as e:
        print(f"   ❌ Hata: {e}")

if __name__ == "__main__":
    test_seller_verification_fix()
