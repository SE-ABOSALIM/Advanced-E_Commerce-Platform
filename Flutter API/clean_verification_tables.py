from database import SessionLocal
import models

def clean_verification_tables():
    """Telefon doğrulama tablolarını temizle"""
    db = SessionLocal()
    try:
        print("=== TELEFON DOĞRULAMA TABLOLARI TEMİZLENİYOR ===")
        
        # phone_verification tablosunu temizle
        count1 = db.query(models.PhoneVerification).delete()
        print(f"phone_verification tablosundan {count1} kayıt silindi")
        
        # phone_verification_seller tablosunu temizle
        count2 = db.query(models.PhoneVerificationSeller).delete()
        print(f"phone_verification_seller tablosundan {count2} kayıt silindi")
        
        db.commit()
        print("Tablolar başarıyla temizlendi!")
        
    except Exception as e:
        print(f"Hata: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    clean_verification_tables()
