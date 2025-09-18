import requests
import json
from twilio_sms_service import twilio_sms_service

def test_sms():
    """SMS gönderimini test et"""
    test_phone = "+905380708813"  # Test telefon numarası
    test_code = "123456"
    
    print("=== SMS GÖNDERİM TESTİ ===")
    print(f"📞 Test telefon: {test_phone}")
    print(f"🔢 Test kod: {test_code}")
    
    # 1. Basit SMS testi
    print(f"\n1. Basit SMS testi...")
    simple_message = f"Test mesajı: {test_code}"
    result = twilio_sms_service.send_sms(test_phone, simple_message, "tr")
    
    print(f"   Sonuç: {result}")
    
    # 2. Doğrulama SMS testi
    print(f"\n2. Doğrulama SMS testi...")
    verification_result = twilio_sms_service.send_verification_sms(test_phone, test_code, "tr")
    
    print(f"   Sonuç: {verification_result}")

if __name__ == "__main__":
    test_sms()
