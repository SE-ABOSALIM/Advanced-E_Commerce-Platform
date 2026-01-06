import 'package:flutter/material.dart';
import 'cart/my_cart.dart';
import 'profile/profile.dart';
import '../../Management_Pages/favorites_manager.dart';
import '../../Models/session.dart';
import '../../Models/seller_session.dart';
import '../../Models/product.dart';

import 'product/product_detail_page.dart';
import '../seller/auth.dart';
import '../seller/dashboard.dart';
import 'auth/login.dart';
import '../../Services/api_service.dart';
import '../../Utils/language_manager.dart';
import '../../Utils/app_config.dart';

class HomePage extends StatefulWidget {
  final bool skipSellerCheck;
  final int? selectedIndex;
  const HomePage({Key? key, this.skipSellerCheck = false, this.selectedIndex}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  int _selectedIndex = 0;
  String? _selectedCategory;

  List<String> get _categories => [
    LanguageManager.translate('Kıyafet'),
    LanguageManager.translate('Elektronik'),
    LanguageManager.translate('Kozmetik'),
    LanguageManager.translate('Mobilya'),
    LanguageManager.translate('Spor'),
    LanguageManager.translate('Oyuncak'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    LanguageManager.initialize().then((_) {
      setState(() {}); // Dili güncelle
    });
  }

  @override
  void initState() {
    super.initState();
    CartManager.loadCart();
    _loadProducts();
    if (widget.selectedIndex != null) {
      _selectedIndex = widget.selectedIndex!;
    }
    if (!widget.skipSellerCheck) {
      _checkSellerSession();
    }
    LanguageManager.initialize().then((_) {
      setState(() {});
    });
  }

  Future<void> _checkSellerSession() async {
    // Eğer seller session varsa dashboard'a yönlendir
    if (SellerSession.currentSeller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SellerDashboardPage(seller: SellerSession.currentSeller!),
          ),
        );
      });
    } else {
      // Try to load seller session from SharedPreferences
      final seller = await SellerSession.loadSellerSession();
      if (seller != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SellerDashboardPage(seller: seller),
            ),
          );
        });
      }
    }
  }

  Future<void> _loadProducts() async {
    final products = await ApiService.fetchProducts();
    setState(() {
      _products = products.map((e) => Product.fromMap(e)).toList();
      _filteredProducts = _products;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products.where((product) {
        final nameLower = product.name.toLowerCase();
        final searchLower = query.toLowerCase();
        
        // Akıllı arama: Karışık yazıda bile ürün adı geçiyorsa bul
        bool matchesSearch = false;
        if (searchLower.isNotEmpty) {
          // Normal arama
          if (nameLower.contains(searchLower)) {
            matchesSearch = true;
          } else {
            // Akıllı arama: Ürün adının kelimelerini ara
            final productWords = nameLower.split(' ');
            for (final word in productWords) {
              if (word.length >= 3 && searchLower.contains(word)) {
                matchesSearch = true;
                break;
              }
            }
          }
        } else {
          matchesSearch = true; // Arama boşsa tüm ürünleri göster
        }
        
        // Kategori kontrolü
        bool matchesCategory = true;
        if (_selectedCategory != null) {
          // Seçili kategoriyi orijinal dilde eşleştir
          String originalCategory = '';
          for (final cat in ['Kıyafet', 'Elektronik', 'Kozmetik', 'Mobilya', 'Spor', 'Oyuncak']) {
            if (LanguageManager.translate(cat) == _selectedCategory) {
              originalCategory = cat;
              break;
            }
          }
          matchesCategory = product.category == originalCategory;
        }
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _filterProducts(_searchController.text);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedIndex == 0)
              Text(
                LanguageManager.translate('Ana Sayfa'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontFamily: 'Roboto',
                ),
              )
            else
              Text(
                _selectedIndex == 1 ? LanguageManager.translate('Sepetim') : LanguageManager.translate('Profilim'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontFamily: 'Roboto',
                ),
              ),
            const SizedBox(height: 2),
            if (_selectedIndex == 0)
              Text(
                LanguageManager.translate('Hoş Geldiniz'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              )
            else if (_selectedIndex == 1)
              Text(
                LanguageManager.translate('Ürünleriniz'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              )
            else
              Text(
                LanguageManager.translate('Hesap Bilgileriniz'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        titleSpacing: 8,
        centerTitle: false,
        backgroundColor: const Color(0xFF1877F2),
        elevation: 0,
        actions: [
          if (_selectedIndex == 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: () async {
                  // Eğer seller session varsa dashboard'a yönlendir
                  if (SellerSession.currentSeller != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerDashboardPage(seller: SellerSession.currentSeller!),
                      ),
                    );
                  } else {
                    // Session yoksa auth sayfasına yönlendir
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellerAuthPage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1877F2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  SellerSession.currentSeller != null ? LanguageManager.translate('Satıcı Paneli') : LanguageManager.translate('Satıcı Ol'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_selectedIndex == 2)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Session.currentUser == null
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1877F2),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                                             child: Text(
                         LanguageManager.translate('Giriş Yap/Kayıt Ol'),
                         style: const TextStyle(
                           fontSize: 12,
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                    )
                  : null,
            ),
        ],
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: LanguageManager.translate('Ana Sayfa'),
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                ValueListenableBuilder<int>(
                  valueListenable: CartManager.cartItemCount,
                  builder: (context, count, child) {
                    if (count > 0) {
                      return Positioned(
                        right: -8,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            label: LanguageManager.translate('Sepet'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: LanguageManager.translate('Profil'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1877F2),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedIconTheme: const IconThemeData(
          color: Color(0xFF1877F2),
        ),
        unselectedIconTheme: const IconThemeData(
          color: Colors.grey,
        ),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const MyCartContent();
      case 2:
        return const ProfileContent();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterProducts,
            decoration: InputDecoration(
              hintText: LanguageManager.translate('Ürün ara...'),
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _filterProducts('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF1877F2), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      LanguageManager.translate('Tümü'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByCategory(null);
                      }
                    },
                    selectedColor: const Color(0xFF1877F2),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: _selectedCategory == null ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              }
              final category = _categories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    category,
                    style: const TextStyle(fontSize: 14),
                  ),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    if (selected) {
                      _filterByCategory(category);
                    } else {
                      _filterByCategory(null);
                    }
                  },
                  selectedColor: const Color(0xFF1877F2),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: _selectedCategory == category ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Text(
                    LanguageManager.translate('Ürün bulunamadı'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
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
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onCartUpdated: () => setState(() {}),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onCartUpdated;

  const ProductCard({super.key, required this.product, required this.onCartUpdated});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _loadProductRating();
  }

  Future<void> _loadProductRating() async {
    try {
      final reviews = await ApiService.getProductReviews(int.parse(widget.product.id));
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<int>(0, (sum, review) => sum + (review['rating'] as int));
        setState(() {
          _averageRating = totalRating / reviews.length;
          _reviewCount = reviews.length;
          _isLoadingRating = false;
        });
      } else {
        setState(() {
          _averageRating = 0.0;
          _reviewCount = 0;
          _isLoadingRating = false;
        });
      }
    } catch (e) {
      setState(() {
        _averageRating = 0.0;
        _reviewCount = 0;
        _isLoadingRating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: widget.product),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    widget.product.imageUrl.isNotEmpty ? AppConfig.getImageUrl(widget.product.imageUrl) : '',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₺${widget.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1877F2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Ortalama Yıldız
                  if (!_isLoadingRating && _averageRating > 0) ...[
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < _averageRating.floor() ? Icons.star : 
                            (index == _averageRating.floor() && _averageRating % 1 > 0) ? Icons.star_half : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '${_averageRating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ] else if (!_isLoadingRating) ...[
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star_border,
                            color: Colors.grey[300],
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          LanguageManager.translate('Yeni'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailSheet extends StatefulWidget {
  final Product product;
  final VoidCallback onCartUpdated;

  const ProductDetailSheet({
    super.key,
    required this.product,
    required this.onCartUpdated,
  });

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadCartData();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
                  size: 30,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.product.imageUrl.isNotEmpty ? AppConfig.getImageUrl(widget.product.imageUrl) : '',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
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
                ),
                const SizedBox(height: 20),
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '₺${widget.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF1877F2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  LanguageManager.translate('Ürün Açıklaması'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (CartManager.isInCart(widget.product.id)) {
                        // Ürün sepette ise ana sayfadaki sepet sekmesine yönlendir
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage(selectedIndex: 1)),
                        );
                      } else {
                        // Ürün sepette değilse sepete ekle ve ana sayfaya yönlendir
                        CartManager.addToCart(widget.product);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CartManager.isInCart(widget.product.id) 
                          ? Colors.white 
                          : const Color(0xFF1877F2),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: CartManager.isInCart(widget.product.id) 
                            ? const BorderSide(color: Color(0xFF1877F2), width: 2)
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      CartManager.isInCart(widget.product.id) ? LanguageManager.translate('Ürün Sepette') : LanguageManager.translate('Sepete Ekle'),
                      style: TextStyle(
                        fontSize: 18,
                        color: CartManager.isInCart(widget.product.id) 
                            ? const Color(0xFF1877F2) 
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
