import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../account_setup/add_credit_card_page.dart';
import '../../../Models/credit_card.dart';
import '../../../Services/api_service.dart';
import '../../../Utils/language_manager.dart';

class MyCreditCardsPage extends StatefulWidget {
  final int userId;
  const MyCreditCardsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyCreditCardsPage> createState() => _MyCreditCardsPageState();
}

class _MyCreditCardsPageState extends State<MyCreditCardsPage> {
  List<CreditCard> cards = [];

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  Future<void> fetchCards() async {
    final list = await ApiService.fetchCreditCards();
    setState(() {
      cards = list.map((e) => CreditCard.fromMap(e)).toList();
    });
  }

  void _navigateToAddCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCreditCardPage(),
      ),
    ).then((_) {
      // Sayfa döndüğünde kartları yenile
      fetchCards();
    });
  }

  void _deleteCard(int cardId) async {
    await ApiService.deleteCreditCard(cardId);
    fetchCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          LanguageManager.translate('Ödeme Yöntemleri'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1877F2),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        LanguageManager.translate('Henüz kart eklenmemiş'),
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    String bankName = card.cardBrand.toLowerCase();
                    String bankImage = 'assets/Images/bank_card.png'; // Varsayılan resim
                    if (bankName.contains('ziraat')) {
                      bankImage = 'assets/Images/Ziraat.png';
                    } else if (bankName.contains('akbank')) {
                      bankImage = 'assets/Images/Akbank.png';
                    } else if (bankName.contains('iş bankası') || bankName.contains('isbank') || bankName.contains('is bankasi')) {
                      bankImage = 'assets/Images/Isbank.png';
                    } else if (bankName.contains('albaraka')) {
                      bankImage = 'assets/Images/Albaraka.png';
                    } else if (bankName.contains('kuveyt')) {
                      bankImage = 'assets/Images/kuveyt-turk.png';
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              child: Image.asset(
                                bankImage,
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Icon(Icons.credit_card, size: 30, color: Color(0xFF1877F2)),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          card.cardBrand.toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteCard(card.id!),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(LanguageManager.translate('Kart No') + ': **** **** **** ${card.last4}'),
                                  Text(LanguageManager.translate('Son Kullanma') + ': ${card.expiryMonth.toString().padLeft(2, '0')}/${(card.expiryYear % 100).toString().padLeft(2, '0')}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: _navigateToAddCard,
                icon: const Icon(Icons.add_card, size: 26),
                label: Text(
                  LanguageManager.translate('Yeni Kart Ekle'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.black45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String newString = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i != 0 && i % 4 == 0) newString += ' ';
      newString += digitsOnly[i];
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String newString = '';
    for (int i = 0; i < digitsOnly.length && i < 4; i++) {
      if (i == 2) newString += '/';
      newString += digitsOnly[i];
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

// Not: Kullanılmayan ve modele uymayan kart yardımcı extension'ı kaldırıldı.