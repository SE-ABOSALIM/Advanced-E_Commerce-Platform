import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../Services/api_service.dart';
import '../../../Models/session.dart';
import '../../../Widgets/custom_dialog.dart';
import '../../../Utils/language_manager.dart';

class AddCreditCardPage extends StatefulWidget {
  final bool fromCheckout;
  
  const AddCreditCardPage({Key? key, this.fromCheckout = false}) : super(key: key);

  @override
  State<AddCreditCardPage> createState() => _AddCreditCardPageState();
}

class _AddCreditCardPageState extends State<AddCreditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _saveCreditCard() async {
    if (Session.currentUser?.id == null) {
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: LanguageManager.translate('Hata'),
          message: LanguageManager.translate('Kart eklemek için önce giriş yapmalısınız.'),
          buttonText: LanguageManager.translate('Tamam'),
        );
      }
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cleanNumber = _cardNumberController.text.replaceAll(' ', '');
      final isValid = _validateCardNumber(cleanNumber);
      if (!isValid) {
        throw Exception(LanguageManager.translate('Girdiğiniz kredi kartı geçersiz'));
      }

      final expiry = _parseExpiry(_expiryController.text);
      // 1) Tokenize et (gerçek gateway entegrasyonuna hazır arayüz)
      final tokenized = await ApiService.tokenizeCard(
        userId: Session.currentUser!.id!,
        cardHolderName: _cardholderController.text.trim(),
        cardNumber: cleanNumber,
        expireMonth: expiry['month']!,
        expireYear: expiry['year']!,
        cvc: _cvvController.text,
      );

      // 2) Token bilgisiyle kartı kaydet
      await ApiService.addCreditCard({
        'user_id': Session.currentUser!.id,
        'provider': 'iyzico', // Gerçek provider
        'card_token': tokenized['card_token'],
        'card_brand': tokenized['card_brand'],
        'last4': tokenized['last4'],
        'expiry_month': tokenized['expiry_month'],
        'expiry_year': tokenized['expiry_year'],
        'is_default': true,
      });

      if (mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: LanguageManager.translate('Başarılı!'),
          message: LanguageManager.translate('Kart başarıyla eklendi'),
          buttonText: LanguageManager.translate('Tamam'),
          onButtonPressed: () {
            if (widget.fromCheckout) {
              // Checkout sayfasından geldiyse true döndür
              Navigator.pop(context, true);
            } else {
              // Normal sayfadan geldiyse sadece kapat
              Navigator.pop(context);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        
        // Backend'den gelen hata mesajlarını kullanıcı dostu hale getir
        if (errorMessage.contains('Bu kart zaten eklenmiş')) {
          errorMessage = LanguageManager.translate('Girilen kart zaten sistemde kayıtlıdır.');
        } else if (errorMessage.contains('Kart tokenleştirme başarısız')) {
          errorMessage = LanguageManager.translate('Kart bilgileri doğrulanamadı. Lütfen bilgileri kontrol edin.');
        } else if (errorMessage.contains('Kart doğrulanamadı')) {
          errorMessage = LanguageManager.translate('Kart bilgileri doğrulanamadı. Lütfen bilgileri kontrol edin.');
        } else if (errorMessage.contains('Kredi kartı eklenemedi')) {
          errorMessage = LanguageManager.translate('Kart eklenirken bir hata oluştu. Lütfen tekrar deneyin.');
        } else {
          // Genel hata mesajı
          errorMessage = LanguageManager.translate('Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.');
        }
        
        CustomDialog.showError(
          context: context,
          title: LanguageManager.translate('Hata'),
          message: errorMessage,
          buttonText: LanguageManager.translate('Tamam'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageManager.translate('Kart Ekle')),
        backgroundColor: const Color(0xFF6B73FF),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _cardholderController,
                              decoration: InputDecoration(
                                labelText: LanguageManager.translate('Kart Sahibi'),
                                border: const OutlineInputBorder(),
                                hintText: LanguageManager.translate('Ad Soyad'),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LanguageManager.translate('Kart sahibinin adı zorunludur');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _cardNumberController,
                              decoration: InputDecoration(
                                labelText: LanguageManager.translate('Kart Numarası'),
                                border: const OutlineInputBorder(),
                                hintText: LanguageManager.translate('1234 5678 9012 3456'),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 19,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                CardNumberInputFormatter(),
                              ],
                              validator: (value) {
                                String cleanValue = (value ?? '').replaceAll(' ', '');
                                if (cleanValue.isEmpty) {
                                  return LanguageManager.translate('Kart numarası zorunludur');
                                }
                                if (!_validateCardNumber(cleanValue)) {
                                  return LanguageManager.translate('Girdiğiniz kredi kartı geçersiz');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _expiryController,
                                    decoration: InputDecoration(
                                      labelText: LanguageManager.translate('Son Kullanma Tarihi'),
                                      border: const OutlineInputBorder(),
                                      hintText: LanguageManager.translate('AA/YY'),
                                    ),
                                    maxLength: 5,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      ExpiryDateInputFormatter(),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return LanguageManager.translate('Son kullanma tarihi zorunludur');
                                      }
                                      if (!_validateExpiry(value)) {
                                        return LanguageManager.translate('Geçersiz son kullanma tarihi');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _cvvController,
                                    decoration: InputDecoration(
                                      labelText: LanguageManager.translate('CVV'),
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return LanguageManager.translate('CVV zorunludur');
                                      }
                                      if (value.length != 3) {
                                        return LanguageManager.translate('CVV 3 haneli olmalıdır');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveCreditCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        LanguageManager.translate('Kartı Kaydet'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Güvenlik ve doğrulama yardımcıları
bool _validateCardNumber(String digits) {
  if (digits.length < 12 || digits.length > 19) return false;
  // Luhn algoritması
  int sum = 0;
  bool alternate = false;
  for (int i = digits.length - 1; i >= 0; i--) {
    int n = int.parse(digits[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  if (sum % 10 != 0) return false;
  // Temel marka uzunluk kontrolleri
  final brand = _detectCardBrand(digits);
  switch (brand) {
    case 'visa':
      return digits.startsWith('4') && (digits.length == 13 || digits.length == 16 || digits.length == 19);
    case 'mastercard':
      final prefix = int.parse(digits.substring(0, 2));
      final prefix4 = int.parse(digits.substring(0, 4));
      final inRange = (prefix >= 51 && prefix <= 55) || (prefix4 >= 2221 && prefix4 <= 2720);
      return inRange && digits.length == 16;
    case 'amex':
      return (digits.startsWith('34') || digits.startsWith('37')) && digits.length == 15;
    case 'discover':
      return digits.length == 16;
    default:
      return true; // Diğer markalar için Luhn yeterli
  }
}

String _detectCardBrand(String digits) {
  if (digits.startsWith('4')) return 'visa';
  final two = digits.substring(0, 2);
  final four = digits.substring(0, 4);
  final intTwo = int.tryParse(two) ?? 0;
  final intFour = int.tryParse(four) ?? 0;
  if ((intTwo >= 51 && intTwo <= 55) || (intFour >= 2221 && intFour <= 2720)) return 'mastercard';
  if (digits.startsWith('34') || digits.startsWith('37')) return 'amex';
  if (digits.startsWith('6')) return 'discover';
  return 'unknown';
}

bool _validateExpiry(String value) {
  if (!RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(value)) return false;
  final parts = value.split('/');
  final month = int.parse(parts[0]);
  final yearTwo = int.parse(parts[1]);
  final now = DateTime.now();
  final currentTwo = int.parse(now.year.toString().substring(2));
  final fullYear = 2000 + yearTwo + (yearTwo < currentTwo ? 100 : 0) - 100; // Normalize 2 haneli yıl
  final exp = DateTime(2000 + yearTwo, month + 1, 0);
  return exp.isAfter(DateTime(now.year, now.month, 0));
}

Map<String, int> _parseExpiry(String value) {
  final parts = value.split('/');
  return {
    'month': int.parse(parts[0]),
    'year': 2000 + int.parse(parts[1]),
  };
}

String _tokenize(String digits) {
  // Basit bir tokenleştirme yerel mock: sadece maskeleme + hash benzeri
  final last4 = digits.substring(digits.length - 4);
  final prefix = digits.substring(0, 6);
  return 'tok_${prefix}xxxxxx$last4';
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll('/', '');
    if (text.length <= 2) {
      return newValue;
    }

    final formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
} 