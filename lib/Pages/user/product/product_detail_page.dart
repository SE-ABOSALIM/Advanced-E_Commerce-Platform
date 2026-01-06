import 'package:flutter/material.dart';
import '../home.dart' as home;
import '../cart/my_cart.dart';
import '../../seller/profile_page.dart';
import '../../../Models/product.dart';
import '../../../Models/seller.dart';
import '../../../Models/session.dart';
import '../../../Management_Pages/favorites_manager.dart';
import '../../../Services/seller_api_service.dart';
import '../../../Services/api_service.dart';
import '../../../Utils/language_manager.dart';
import '../../../Utils/privacy_manager.dart';
import '../../../Utils/app_config.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isFavorite = false;
  Seller? _seller;
  bool _isLoadingSeller = false;
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = false;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadSellerInfo();
    _loadCartData();
    _loadProductReviews();
  }

  Future<void> _loadProductReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });
    
    try {
      final reviews = await ApiService.getProductReviews(int.parse(widget.product.id));
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
        _calculateAverageRating();
      });
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  void _calculateAverageRating() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      return;
    }
    
    final totalRating = _reviews.fold<int>(0, (sum, review) => sum + (review['rating'] as int));
    _averageRating = totalRating / _reviews.length;
  }

  String _formatDate(String? dateString) {
            if (dateString == null) return LanguageManager.translate('Bilinmiyor');
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
              return LanguageManager.translate('Bilinmiyor');
    }
  }

  Future<void> _loadCartData() async {
    await CartManager.loadCart();
    setState(() {});
  }

  Future<void> _loadFavoriteStatus() async {
    final userEmail = Session.currentUser?.email;
    final fav = await FavoritesManager.isFavorite(userEmail, widget.product.id);
    setState(() {
      _isFavorite = fav;
    });
  }

  Future<void> _toggleFavorite() async {
    final userEmail = Session.currentUser?.email;
    if (_isFavorite) {
      await FavoritesManager.removeFavorite(userEmail, widget.product.id);
    } else {
      await FavoritesManager.addFavorite(userEmail, widget.product.id);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<void> _loadSellerInfo() async {
    if (widget.product.sellerId != null) {
      setState(() {
        _isLoadingSeller = true;
      });
      
      try {
        final seller = await SellerApiService.getSellerById(widget.product.sellerId!);
        setState(() {
          _seller = seller;
          _isLoadingSeller = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingSeller = false;
        });
      }
    }
  }

  Widget _buildReviewCard(dynamic review) {
    return FutureBuilder<bool>(
      future: PrivacyManager.isPrivacyEnabled(),
      builder: (context, privacySnapshot) {
        final isPrivacyEnabled = privacySnapshot.data ?? false;
        String displayName = review['user_name'] ?? LanguageManager.translate('Anonim');
        
                  if (isPrivacyEnabled && displayName != LanguageManager.translate('Anonim')) {
          displayName = PrivacyManager.maskUserName(displayName);
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı adı (yıldızların üstünde)
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1877F2),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Yıldızlar
                    ...List.generate(5, (index) {
                      return Icon(
                        index < review['rating'] ? Icons.star : Icons.star_border,
                        color: index < review['rating'] ? Colors.amber : Colors.grey,
                        size: 20,
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      '${review['rating']}/5',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (review['comment'] != null && review['comment'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    review['comment'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 8),
                // Tarih (sağ tarafta)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatDate(review['created_at']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageManager.translate('Ürün Detayı'), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1877F2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        product.imageUrl.isNotEmpty ? AppConfig.getImageUrl(product.imageUrl) : '',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 220,
                            height: 220,
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₺${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 22, color: Color(0xFF1877F2), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Ortalama Yıldız
                  if (_averageRating > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < _averageRating.floor() ? Icons.star : 
                            (index == _averageRating.floor() && _averageRating % 1 > 0) ? Icons.star_half : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${_averageRating.toStringAsFixed(1)} (${_reviews.length} ${LanguageManager.translate('yorum')})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Satıcı Bilgileri (başlık olmadan)
                  if (widget.product.sellerId != null) ...[
                    if (_isLoadingSeller)
                      const Center(child: CircularProgressIndicator())
                    else if (_seller != null)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerProfilePage(sellerId: widget.product.sellerId!),
                            ),
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blue.shade100,
                                  child: _seller!.storeLogo != null && _seller!.storeLogo!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: Image.network(
                                            AppConfig.getImageUrl(_seller!.storeLogo!),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.store,
                                                size: 30,
                                                color: Colors.blue,
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.store,
                                          size: 30,
                                          color: Colors.blue,
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _seller!.storeName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Ürün Açıklaması
                  Text(LanguageManager.translate('Ürün Açıklaması'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
                  
                  // Ürün Yorumları
                  if (_reviews.isNotEmpty) ...[
                    Text(LanguageManager.translate('Ürün Yorumları'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._reviews.map((review) => _buildReviewCard(review)),
                  ] else if (_isLoadingReviews) ...[
                    const Center(child: CircularProgressIndicator()),
                  ] else ...[
                    Text(
                      LanguageManager.translate('Henüz yorum yapılmamış'),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  // Alt boşluk (sabit buton için)
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Sabit Sepete Ekle Butonu
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (CartManager.isInCart(product.id)) {
                      // Ürün sepette ise ana sayfadaki sepet sekmesine yönlendir
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const home.HomePage(selectedIndex: 1, skipSellerCheck: true)),
                      );
                    } else {
                      // Ürün sepette değilse sepete ekle ve ana sayfaya yönlendir
                      CartManager.addToCart(product);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const home.HomePage(skipSellerCheck: true)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CartManager.isInCart(product.id) 
                        ? Colors.white 
                        : const Color(0xFF1877F2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: CartManager.isInCart(product.id) 
                          ? const BorderSide(color: Color(0xFF1877F2), width: 2)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    CartManager.isInCart(product.id) ? LanguageManager.translate('Ürün Sepette') : LanguageManager.translate('Sepete Ekle'),
                    style: TextStyle(
                      fontSize: 18, 
                      color: CartManager.isInCart(product.id) 
                          ? const Color(0xFF1877F2) 
                          : Colors.white, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Favori Butonu
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 