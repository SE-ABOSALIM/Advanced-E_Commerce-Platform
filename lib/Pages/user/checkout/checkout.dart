import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'payment_success.dart';
import '../cart/my_cart.dart';
import '../auth/login.dart';
import '../account_setup/add_address_page.dart';
import '../account_setup/add_credit_card_page.dart';
import '../../../Models/session.dart';
import '../../../Models/address.dart';
import '../../../Models/credit_card.dart';
import '../../../Models/order.dart';
import '../../../Services/api_service.dart';
import '../../../Widgets/custom_dialog.dart';
import '../../../Services/seller_api_service.dart';
import '../../../Utils/language_manager.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<Address> addresses = [];
  List<CreditCard> cards = [];
  Address? selectedAddress;
  CreditCard? selectedCard;
  final TextEditingController _cvvController = TextEditingController();
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    if (Session.currentUser == null) {
      // Giriş yoksa login sayfasına yönlendir
      Future.microtask(() {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      });
    } else {
      _fetchAddresses();
      _fetchCards();
    }
  }

  @override
  void dispose() {
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddresses() async {
    final list = await ApiService.fetchAddresses();
    setState(() {
      addresses = list.map((e) => Address.fromMap(e)).toList();
      if (addresses.isNotEmpty) selectedAddress = addresses.first;
    });
  }

  Future<void> _fetchCards() async {
    final list = await ApiService.fetchCreditCards();
    setState(() {
      cards = list.map((e) => CreditCard.fromMap(e)).toList();
      if (cards.isNotEmpty) selectedCard = cards.firstWhere((c) => c.isDefault, orElse: () => cards.first);
    });
  }

  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAddressPage(fromCheckout: true),
      ),
    );
    
    if (result == true) {
      // Adres eklendiyse yeniden yükle
      await _fetchAddresses();
    }
  }

  Future<void> _navigateToAddCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCreditCardPage(fromCheckout: true),
      ),
    );
    
    if (result == true) {
      // Kart eklendiyse yeniden yükle
      await _fetchCards();
    }
  }

  Future<void> _handlePayment() async {
    try {
      if (selectedAddress == null || selectedCard == null) {
        CustomDialog.showError(
          context: context,
          title: LanguageManager.translate('Hata'),
          message: LanguageManager.translate('Lütfen adres ve kart seçiniz!'),
          buttonText: LanguageManager.translate('Tamam'),
        );
        return;
      }
      if (_cvvController.text.length != 3) {
        CustomDialog.showError(
          context: context,
          title: LanguageManager.translate('Hata'),
          message: LanguageManager.translate('CVV 3 haneli olmalı!'),
          buttonText: LanguageManager.translate('Tamam'),
        );
        return;
      }
      setState(() { _isPaying = true; });
      
      final kartlar = cards;
      final kart = kartlar.firstWhere((k) => k.id == selectedCard!.id);
      final double toplamTutar = CartManager.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      
      // Bakiye kontrolü ve gerçek ödeme çekimi backend'de yapılacak.
      final now = DateTime.now();
      final createdDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
      String randomOrderCode() {
        final rand = List.generate(10, (_) => (0 + (9 * (DateTime.now().microsecondsSinceEpoch + DateTime.now().millisecond) % 10)).toString());
        rand.shuffle();
        return rand.join();
      }
      // 1. Ürünleri satıcıya göre grupla
      final Map<int, List<CartItem>> sellerCartMap = {};
      for (final item in CartManager.cartItems) {
        final sellerId = item.product.sellerId ?? 0;
        sellerCartMap.putIfAbsent(sellerId, () => []).add(item);
      }
      // 2. Her satıcı için ayrı sipariş oluştur
      for (final entry in sellerCartMap.entries) {
        final sellerId = entry.key;
        final sellerItems = entry.value;
        // Satıcının kargo firmasını çek
        final seller = await SellerApiService.getSellerById(sellerId);
        final seciliKargo = seller.cargoCompany ?? 'Araskargo';
        final teslimGun = 1; // İsterseniz kargo firmasına göre gün belirleyebilirsiniz
        final estimatedDateObj = now.add(Duration(days: teslimGun));
        final estimatedDate = "${estimatedDateObj.day.toString().padLeft(2, '0')}/${estimatedDateObj.month.toString().padLeft(2, '0')}/${estimatedDateObj.year}";
        final order = Order(
          orderCode: randomOrderCode(),
          orderCreatedDate: createdDate,
          orderEstimatedDelivery: estimatedDate,
          orderCargoCompany: seciliKargo,
          orderAddress: selectedAddress!.id!,
          orderStatus: 'pending',
        );
        final double sellerTotal = sellerItems.fold(0.0, (sum, item) => sum + item.totalPrice);
        // Sipariş oluştur (Backend'de transaction içinde para çekme ile birlikte)
        await ApiService.addOrder(
          order.toMap(),
          cardId: kart.id,
          amount: sellerTotal,
          cartItems: sellerItems.map((item) => {
            'product': item.product.toMap(),
            'quantity': item.quantity,
            'totalPrice': item.totalPrice,
          }).toList(),
        );
      }
      // Sepeti temizle ve başarıya yönlendir
      setState(() { _isPaying = false; });
      await CartManager.clearCart();
      setState(() {});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaymentSuccessPage()),
      );
      
    } catch (e) {
      setState(() { _isPaying = false; });
      CustomDialog.showError(
        context: context,
        title: LanguageManager.translate('Ödeme Başarısız'),
        message: '${LanguageManager.translate('Ödeme işlemi başarısız:')} $e\n${LanguageManager.translate('Para çekilmedi!')}',
        buttonText: LanguageManager.translate('Tamam'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Session.currentUser == null) {
      return const SizedBox(); // login yönlendirmesi için
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              _buildHeader(),
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFBFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Adres Seçimi
                          _buildAddressSection(),
                          const SizedBox(height: 24),
                          // Kart Seçimi
                          _buildCardSection(),
                          const SizedBox(height: 24),
                          // Sepet Özeti
                          _buildCartSummary(),
                          const SizedBox(height: 32),
                          // Ödeme Butonu
                          _buildPaymentButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageManager.translate('Ödeme'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Güvenli ödeme işlemi',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.payment,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF6B73FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  LanguageManager.translate('Teslimat Adresi'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (addresses.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            LanguageManager.translate('Kayıtlı adres yok.'),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToAddAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B73FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_location, size: 20),
                        label: Text(
                          LanguageManager.translate('Adres Ekle'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...addresses.map((a) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedAddress == a ? const Color(0xFF6B73FF) : Colors.grey.shade200,
                    width: selectedAddress == a ? 2 : 1,
                  ),
                  color: selectedAddress == a ? const Color(0xFF6B73FF).withOpacity(0.05) : Colors.white,
                ),
                child: RadioListTile<Address>(
                  value: a,
                  groupValue: selectedAddress,
                  onChanged: (v) => setState(() => selectedAddress = v),
                  title: Text(
                    a.addressName.isNotEmpty ? a.addressName : LanguageManager.translate('Adres'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    '${a.city}, ${a.district}, ${a.streetName} No:${a.buildingNumber} D:${a.apartmentNumber}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  activeColor: const Color(0xFF6B73FF),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Color(0xFF6B73FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  LanguageManager.translate('Ödeme Kartı'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (cards.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            LanguageManager.translate('Kayıtlı kart yok.'),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToAddCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B73FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_card, size: 20),
                        label: Text(
                          LanguageManager.translate('Kart Ekle'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...cards.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedCard == c ? const Color(0xFF6B73FF) : Colors.grey.shade200,
                    width: selectedCard == c ? 2 : 1,
                  ),
                  color: selectedCard == c ? const Color(0xFF6B73FF).withOpacity(0.05) : Colors.white,
                ),
                child: RadioListTile<CreditCard>(
                  value: c,
                  groupValue: selectedCard,
                  onChanged: (v) => setState(() => selectedCard = v),
                  title: Text(
                    c.cardBrand.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.grey.shade600, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '**** **** **** ${c.last4}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  activeColor: const Color(0xFF6B73FF),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )),
            if (selectedCard != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'CVV Kodu',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: LanguageManager.translate('CVV'),
                        hintText: '123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6B73FF), width: 2),
                        ),
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    final totalAmount = CartManager.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Color(0xFF6B73FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  LanguageManager.translate('Sepet Özeti'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...CartManager.cartItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B73FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Color(0xFF6B73FF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Adet: ${item.quantity}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₺${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF6B73FF),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B73FF), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LanguageManager.translate('Toplam:'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '₺${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B73FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isPaying ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B73FF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isPaying
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, size: 24),
                const SizedBox(width: 12),
                Text(
                  LanguageManager.translate('Ödemeyi Tamamla'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

// Not: Kullanılmayan ve modele uymayan kart yardımcı extension'ı kaldırıldı.