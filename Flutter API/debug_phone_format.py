from database import SessionLocal
import models

def debug_phone_format():
    """Telefon numarası formatını debug et"""
    db = SessionLocal()
    try:
        print("=== TELEFON NUMARASI FORMAT DEBUG ===")
        
        # phone_verification tablosundaki telefon numaralarını kontrol et
        print("\n1. phone_verification tablosu:")
        phone_verifications = db.query(models.PhoneVerification).all()
        for pv in phone_verifications:
            print(f"   - Orijinal: '{pv.phone_number}' | Uzunluk: {len(pv.phone_number)}")
        
        # users tablosundaki telefon numaralarını kontrol et
        print("\n2. users tablosu:")
        users = db.query(models.User).all()
        for user in users:
            print(f"   - Orijinal: '{user.phone_number}' | Uzunluk: {len(user.phone_number)}")
        
        # Test telefon numarası
        test_phone = "05389874376"
        print(f"\n3. Test telefon numarası: '{test_phone}' | Uzunluk: {len(test_phone)}")
        
        # Backend formatına çevir
        formatted_phone = test_phone
        if test_phone.startswith('0'):
            formatted_phone = '+90 ' + test_phone[1:4] + ' ' + test_phone[4:7] + ' ' + test_phone[7:9] + ' ' + test_phone[9:11]
        
        print(f"   Formatlanmış: '{formatted_phone}' | Uzunluk: {len(formatted_phone)}")
        
    except Exception as e:
        print(f"Hata: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    debug_phone_format()
