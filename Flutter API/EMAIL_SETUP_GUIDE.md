# 📧 Email Ayarları Yapılandırma Rehberi

## Gmail için Email Ayarları

### 1. Gmail App Password Oluşturma

1. **Gmail hesabınıza giriş yapın**
2. **Google Hesap ayarlarına gidin:** https://myaccount.google.com/
3. **Güvenlik** sekmesine tıklayın
4. **2 Adımlı Doğrulama**'yı etkinleştirin (eğer etkin değilse)
5. **Uygulama Şifreleri**'ne tıklayın
6. **Uygulama seçin:** "Diğer (Özel ad)" seçin
7. **Ad girin:** "CepteVar Email Service"
8. **Oluştur** butonuna tıklayın
9. **16 haneli şifreyi kopyalayın** (örn: `abcd efgh ijkl mnop`)

### 2. config.env Dosyasını Güncelleyin

`Flutter API/config.env` dosyasını açın ve şu satırları güncelleyin:

```env
# Email Ayarları (Gmail için)
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=your-gmail@gmail.com
SENDER_PASSWORD=abcd efgh ijkl mnop
```

**Örnek:**
```env
SENDER_EMAIL=mahmibey@gmail.com
SENDER_PASSWORD=abcd efgh ijkl mnop
```

### 3. Test Etme

Ayarları güncelledikten sonra:

1. **Backend'i yeniden başlatın:**
   ```bash
   cd "Flutter API"
   uvicorn main:app --reload
   ```

2. **Flutter uygulamasında email doğrulama butonuna basın**

3. **Backend konsolunda şu mesajları görmelisiniz:**
   ```
   ✅ Email başarıyla gönderildi: mahmibey@gmail.com
   ```

### 4. Sorun Giderme

**Hata: "Authentication failed"**
- App password'ün doğru olduğundan emin olun
- 2 Adımlı Doğrulama'nın etkin olduğundan emin olun

**Hata: "Connection refused"**
- SMTP_SERVER ve SMTP_PORT ayarlarını kontrol edin
- İnternet bağlantınızı kontrol edin

**Hata: "Username and Password not accepted"**
- Gmail kullanıcı adınızın doğru olduğundan emin olun
- App password'ün doğru kopyalandığından emin olun

### 5. Güvenlik Notları

- ✅ App password kullanın (normal şifre değil)
- ✅ config.env dosyasını git'e commit etmeyin
- ✅ App password'ü kimseyle paylaşmayın
- ✅ Düzenli olarak app password'ü yenileyin

### 6. Test Modu

Email ayarları yapılandırılmamışsa, sistem test modunda çalışır:
- Email gönderilmez
- Kod konsola yazdırılır
- API başarılı yanıt döner

Bu sayede email ayarları olmadan da sistemi test edebilirsiniz.
