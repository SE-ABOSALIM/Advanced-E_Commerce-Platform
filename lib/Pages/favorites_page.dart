import 'package:flutter/material.dart';
import '../Management Pages/favorites_manager.dart';
import '../Models/session.dart';
import 'my-cart.dart';
import '../Models/product.dart';
import '../API/api_service.dart';
import 'login.dart';
import 'product_detail_page.dart';
import 'home.dart' as home;
import '../Utils/language_manager.dart';
import '../Utils/app_config.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserAndLoadFavorites();
  }

  void _checkUserAndLoadFavorites() {
    if (Session.currentUser == null) {
      // Kullanıcı giriş yapmamış, login sayfasına yönlendir
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(
              infoMessage: 'Favorilerinizi görüntülemek için giriş yapmanız gerekiyor.',
            ),
          ),
        );
      });
    } else {
      // Kullanıcı giriş yapmış, favorileri yükle
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    final user = Session.currentUser;
    final favoriteIds = await FavoritesManager.getFavorites(user?.email);
    final allProducts = await ApiService.fetchProducts();
    await CartManager.loadCart(); // Sepet verilerini yükle
    setState(() {
      _favoriteProducts = allProducts.map((e) => Product.fromMap(e)).where((p) => favoriteIds.contains(p.id)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          LanguageManager.translate('Favorilerim'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        LanguageManager.translate('Henüz favori ürününüz bulunmuyor'),
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = _favoriteProducts[index];
                    return _buildProductCard(product);
                  },
                ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün resmi
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          AppConfig.getImageUrl(product.imageUrl),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 60, color: Colors.grey),
                        ),
                ),
              ),
            ),
            
            // Ürün bilgileri
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün adı
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Fiyat
                    Text(
                      '₺${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1877F2),
                      ),
                    ),
                    const Spacer(),
                    
                    // Butonlar
                    Row(
                      children: [
                        // Sepete ekle butonu
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: ElevatedButton.icon(
                                                             onPressed: () {
                                 if (CartManager.isInCart(product.id)) {
                                   // Ürün sepette ise ana sayfadaki sepet sekmesine yönlendir
                                   Navigator.pushReplacement(
                                     context,
                                     MaterialPageRoute(builder: (context) => const home.HomePage(selectedIndex: 1, skipSellerCheck: true)),
                                   );
                                 } else {
                                   // Ürün sepette değilse sepete ekle
                                   CartManager.addToCart(product);
                                 }
                               },
                              icon: Icon(
                                CartManager.isInCart(product.id) ? Icons.shopping_cart_checkout : Icons.shopping_cart, 
                                size: 14
                              ),
                              label: Text(
                                CartManager.isInCart(product.id) ? LanguageManager.translate('Sepette') : LanguageManager.translate('Sepete Ekle'), 
                                style: const TextStyle(fontSize: 10)
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CartManager.isInCart(product.id) 
                                    ? Colors.white 
                                    : const Color(0xFF1877F2),
                                foregroundColor: CartManager.isInCart(product.id) 
                                    ? const Color(0xFF1877F2) 
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: CartManager.isInCart(product.id) 
                                      ? const BorderSide(color: Color(0xFF1877F2), width: 1)
                                      : BorderSide.none,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        
                        // Favorilerden çıkar butonu
                        SizedBox(
                          height: 32,
                          width: 32,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                              onPressed: () async {
                                final user = Session.currentUser;
                                await FavoritesManager.removeFavorite(user?.email, product.id);
                                _loadFavorites();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 