import 'package:flutter/material.dart';
import '../Models/product.dart';
import '../Models/seller.dart';
import '../Models/session.dart';
import '../API/api_service.dart';
import '../Widgets/custom_dialog.dart';
import '../Utils/language_manager.dart';
import '../Utils/app_config.dart';
import 'login.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout.dart';

class CartItem {
  final Product product;
  int quantity;
  
  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(map['product']),
      quantity: map['quantity'],
    );
  }
}

class MyCartContent extends StatefulWidget {
  const MyCartContent({super.key});

  @override
  State<MyCartContent> createState() => _MyCartContentState();
}

class _MyCartContentState extends State<MyCartContent> {
  List<CartItem> _cartItems = [];
  Set<String> _selectedItems = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    CartManager.loadCart().then((_) => _loadCartItems());
  }

  void _loadCartItems() {
    setState(() {
      _cartItems = CartManager.cartItems;
    });
  }

  void _removeFromCart(CartItem cartItem) {
    setState(() {
      CartManager.removeFromCart(cartItem);
      _cartItems = CartManager.cartItems;
      _selectedItems.remove(cartItem.product.id);
    });
  }

  void _updateQuantity(CartItem cartItem, bool increase) {
    setState(() {
      if (increase) {
        CartManager.incrementQuantity(cartItem.product.id);
      } else if (cartItem.quantity > 1) {
        CartManager.decrementQuantity(cartItem.product.id);
      }
      _cartItems = CartManager.cartItems;
    });
  }

  void _toggleSelection(String productId) {
    setState(() {
      if (_selectedItems.contains(productId)) {
        _selectedItems.remove(productId);
      } else {
        _selectedItems.add(productId);
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear();
    });
  }

  void _deleteSelectedItems() {
    setState(() {
      for (var productId in _selectedItems) {
        CartManager.removeFromCartById(productId);
      }
      _cartItems = CartManager.cartItems;
      _selectedItems.clear();
      _isSelectionMode = false;
    });
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_cartItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _toggleSelectionMode,
                  icon: Icon(
                    _isSelectionMode ? Icons.close : Icons.check_box_outlined,
                    color: const Color(0xFF1877F2),
                  ),
                  label: Text(
                    _isSelectionMode ? LanguageManager.translate('İptal') : LanguageManager.translate('Seçim Yap'),
                    style: const TextStyle(
                      color: Color(0xFF1877F2),
                    ),
                  ),
                ),
                if (_isSelectionMode && _selectedItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: _deleteSelectedItems,
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    label: Text(
                      '${_selectedItems.length} Ürünü Sil',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: _cartItems.isEmpty
              ? Center(
                  child: Text(
                    LanguageManager.translate('Sepetiniz boş'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = _cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              cartItem.product.imageUrl.isNotEmpty ? AppConfig.getImageUrl(cartItem.product.imageUrl) : '',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                cartItem.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!_isSelectionMode) ...[
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: cartItem.quantity > 1
                                    ? () => _updateQuantity(cartItem, false)
                                    : null,
                                color: const Color(0xFF1877F2),
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _updateQuantity(cartItem, true),
                                color: const Color(0xFF1877F2),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '₺${cartItem.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF1877F2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: _isSelectionMode
                            ? Checkbox(
                                value: _selectedItems.contains(cartItem.product.id),
                                onChanged: (bool? value) {
                                  _toggleSelection(cartItem.product.id);
                                },
                                activeColor: const Color(0xFF1877F2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeFromCart(cartItem),
                              ),
                      ),
                    );
                  },
                ),
        ),
        if (_cartItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LanguageManager.translate('Toplam:'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₺${_calculateTotal().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1877F2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Session.currentUser == null) {
                        CustomDialog.showWarning(
                          context: context,
                          title: LanguageManager.translate('Giriş Gerekli'),
                          message: LanguageManager.translate('Ödeme işlemi için giriş yapmanız gerekiyor!'),
                          buttonText: LanguageManager.translate('Giriş Yap'),
                          onButtonPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CheckoutPage()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      LanguageManager.translate('Ödemeye Geç'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class CartManager {
  static List<CartItem> cartItems = [];
  static final ValueNotifier<int> cartItemCount = ValueNotifier<int>(0);

  static Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = Session.currentUser?.email ?? 'guest';
    final cartJson = jsonEncode(cartItems.map((item) => item.toMap()).toList());
    await prefs.setString('cart_$userEmail', cartJson);
  }

  static Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = Session.currentUser?.email ?? 'guest';
    final cartJson = prefs.getString('cart_$userEmail');

    if (cartJson != null) {
      final List<dynamic> decoded = jsonDecode(cartJson);
      cartItems = decoded.map((e) => CartItem.fromMap(e)).toList();
      _updateCartCount();
    } else {
      cartItems = [];
      _updateCartCount();
    }
  }

  static void addToCart(Product product) {
    final existingItemIndex = cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingItemIndex != -1) {
      cartItems[existingItemIndex].quantity++;
    } else {
      cartItems.add(CartItem(product: product));
    }
    _updateCartCount();
    saveCart();
  }

  static void removeFromCart(CartItem cartItem) {
    cartItems.removeWhere((item) => item.product.id == cartItem.product.id);
    _updateCartCount();
    saveCart();
  }

  static void removeFromCartById(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
    _updateCartCount();
    saveCart();
  }

  static void incrementQuantity(String productId) {
    final item = cartItems.firstWhere((item) => item.product.id == productId);
    item.quantity++;
    _updateCartCount();
    saveCart();
  }

  static void decrementQuantity(String productId) {
    final item = cartItems.firstWhere((item) => item.product.id == productId);
    if (item.quantity > 1) {
      item.quantity--;
      _updateCartCount();
      saveCart();
    }
  }

  static void _updateCartCount() {
    cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  static bool isInCart(String productId) {
    return cartItems.any((item) => item.product.id == productId);
  }

  static Future<void> clearCart() async {
    cartItems.clear();
    cartItemCount.value = 0;
    final prefs = await SharedPreferences.getInstance();
    final userEmail = Session.currentUser?.email ?? 'guest';
    await prefs.remove('cart_$userEmail');
  }

  static Future<void> mergeGuestCartToUserCart(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final guestCartJson = prefs.getString('cart_guest');
    if (guestCartJson == null) return;
    final List<dynamic> guestDecoded = jsonDecode(guestCartJson);
    final List<CartItem> guestCartItems = guestDecoded.map((e) => CartItem.fromMap(e)).toList();

    // Kullanıcı sepetini yükle
    final userCartJson = prefs.getString('cart_$userEmail');
    List<CartItem> userCartItems = [];
    if (userCartJson != null) {
      final List<dynamic> userDecoded = jsonDecode(userCartJson);
      userCartItems = userDecoded.map((e) => CartItem.fromMap(e)).toList();
    }

    // Guest ürünlerini kullanıcı sepetine ekle (varsa miktarları birleştir)
    for (final guestItem in guestCartItems) {
      final index = userCartItems.indexWhere((item) => item.product.id == guestItem.product.id);
      if (index != -1) {
        userCartItems[index].quantity += guestItem.quantity;
      } else {
        userCartItems.add(guestItem);
      }
    }

    // Sonucu kaydet
    await prefs.setString('cart_$userEmail', jsonEncode(userCartItems.map((item) => item.toMap()).toList()));
    await prefs.remove('cart_guest');
  }
}
