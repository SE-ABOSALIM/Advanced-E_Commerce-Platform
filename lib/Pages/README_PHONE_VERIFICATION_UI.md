# 📱 Flutter Telefon Doğrulama UI Sistemi

Bu dokümanda Flutter tarafında telefon doğrulama sisteminin nasıl çalıştığı açıklanmaktadır.

## 🎯 Genel Bakış

Telefon doğrulama sistemi, kullanıcı ve satıcı kayıtlarında telefon numarasının gerçek sahibine ait olduğunu kanıtlamak için kullanılır.

## 🔧 Sistem Bileşenleri

### 1. **PhoneVerificationPage** (`phone_verification_page.dart`)
- 6 haneli doğrulama kodu girişi
- Otomatik focus yönetimi
- Geri sayım sayacı (60 saniye)
- Kod yeniden gönderme
- Animasyonlar ve modern UI

### 2. **ApiService Güncellemeleri** (`api_service.dart`)
- `sendVerificationCode()` - Doğrulama kodu gönder
- `verifyPhone()` - Telefon numarasını doğrula
- `registerUser()` - Kullanıcı kaydı
- `registerSeller()` - Satıcı kaydı

### 3. **Güncellenmiş Kayıt Sayfaları**
- `sign-up.dart` - Kullanıcı kaydı
- `seller_signup.dart` - Satıcı kaydı

## 🚀 İş Akışı

### **Kullanıcı Kaydı:**
1. Kullanıcı kayıt formunu doldurur
2. "Kayıt Ol" butonuna basar
3. Telefon doğrulama kodu gönderilir
4. `PhoneVerificationPage` açılır
5. Kullanıcı 6 haneli kodu girer
6. Kod doğrulanır
7. Kullanıcı kaydı tamamlanır
8. Login sayfasına yönlendirilir

### **Satıcı Kaydı:**
1. Satıcı kayıt formunu doldurur
2. "Kayıt Ol" butonuna basar
3. Telefon doğrulama kodu gönderilir
4. `PhoneVerificationPage` açılır
5. Satıcı 6 haneli kodu girer
6. Kod doğrulanır
7. Satıcı kaydı tamamlanır
8. Satıcı login sayfasına yönlendirilir

## 🎨 UI Özellikleri

### **Doğrulama Kodu Girişi:**
- 6 ayrı input kutusu
- Otomatik focus geçişi
- Sadece rakam girişi
- Her kutu için ayrı controller
- Focus durumuna göre border rengi

### **Animasyonlar:**
- Fade-in animasyonu (800ms)
- Smooth geçişler
- Loading göstergeleri

### **Responsive Tasarım:**
- Mobil uyumlu
- Farklı ekran boyutları
- Scroll desteği

## 📱 Kullanım Örnekleri

### **Doğrulama Sayfasını Açma:**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => PhoneVerificationPage(
      phoneNumber: '+90 555 123 45 67',
      userType: 'user', // veya 'seller'
      userData: {
        'name_surname': 'John Doe',
        'email': 'john@example.com',
        'password': 'password123',
        'phone_number': '+90 555 123 45 67',
      },
    ),
  ),
);
```

### **API Çağrıları:**
```dart
// Doğrulama kodu gönder
final response = await ApiService.sendVerificationCode(phoneNumber);

// Kodu doğrula
final result = await ApiService.verifyPhone(phoneNumber, code);

// Kullanıcı kaydı
final user = await ApiService.registerUser(userData);

// Satıcı kaydı
final seller = await ApiService.registerSeller(sellerData);
```

## 🧪 Test Etme

### **Test Sayfası:**
`test_phone_verification.dart` dosyası ile sistem test edilebilir:

1. Test sayfasını aç
2. Telefon numarası gir
3. "Doğrulama Sayfasını Aç" butonuna bas
4. Doğrulama kodunu test et

### **Test Senaryoları:**
- ✅ Geçerli telefon numarası
- ✅ 6 haneli doğrulama kodu
- ✅ Kod yeniden gönderme
- ✅ Geri sayım sayacı
- ✅ Hata durumları
- ✅ Başarılı doğrulama

## ⚠️ Önemli Notlar

### **Telefon Numarası Formatı:**
- Format: `+90 5XX XXX XX XX`
- Ülke kodu: `+90` (zorunlu)
- Operatör kodu: `5XX` (5 ile başlayan)
- Abone numarası: `XXX XX XX` (7 haneli)

### **Doğrulama Kodu:**
- 6 haneli rakam
- 5 dakika geçerlilik
- Maksimum 3 deneme
- Otomatik yenileme

### **Güvenlik:**
- API çağrıları güvenli
- Hata mesajları kullanıcı dostu
- Session yönetimi
- Input validasyonu

## 🔄 Entegrasyon

### **Mevcut Sistemler:**
- ✅ Kullanıcı kayıt sistemi
- ✅ Satıcı kayıt sistemi
- ✅ API servisleri
- ✅ Dil desteği
- ✅ Hata yönetimi

### **Gelecek Geliştirmeler:**
- [ ] SMS servisi entegrasyonu
- [ ] Push notification
- [ ] 2FA desteği
- [ ] Biyometrik doğrulama
- [ ] WhatsApp entegrasyonu

## 📋 Kontrol Listesi

- [ ] PhoneVerificationPage oluşturuldu
- [ ] ApiService güncellendi
- [ ] Kullanıcı kayıt entegrasyonu
- [ ] Satıcı kayıt entegrasyonu
- [ ] Test sayfası oluşturuldu
- [ ] UI testleri yapıldı
- [ ] API testleri yapıldı
- [ ] Hata durumları test edildi

## 🆘 Sorun Giderme

### **Yaygın Hatalar:**
1. **Import hatası**: `phone_verification_page.dart` import edildi mi?
2. **API hatası**: Backend çalışıyor mu?
3. **Navigation hatası**: Route tanımlı mı?
4. **State hatası**: Controller'lar dispose edildi mi?

### **Debug İpuçları:**
- Console log'larını kontrol et
- API yanıtlarını incele
- Widget tree'yi kontrol et
- State değişikliklerini izle

## 🔗 İlgili Dosyalar

- `phone_verification_page.dart` - Ana doğrulama sayfası
- `test_phone_verification.dart` - Test sayfası
- `api_service.dart` - API servisleri
- `sign-up.dart` - Kullanıcı kayıt
- `seller_signup.dart` - Satıcı kayıt
- `custom_dialog.dart` - Dialog widget'ları
- `language_manager.dart` - Dil desteği

## 📞 Destek

Herhangi bir sorun yaşarsanız:
1. Test sayfasını çalıştırın
2. Console log'larını kontrol edin
3. API endpoint'lerini test edin
4. Widget tree'yi inceleyin
