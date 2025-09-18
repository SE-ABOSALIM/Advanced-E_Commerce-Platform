import 'package:flutter/material.dart';
import '../Models/seller.dart';
import '../Models/seller_session.dart';
import '../API/api_service.dart';
import 'seller_products_page.dart';
import 'seller_orders_page.dart';
import 'seller_edit_profile.dart';
import 'seller_auth.dart';
import 'seller_reviews_page.dart';
import '../Widgets/custom_dialog.dart';
import '../Utils/language_manager.dart';
import 'dart:async';
import 'home.dart';
import 'seller_settings_page.dart';

class SellerDashboardPage extends StatefulWidget {
  final Seller seller;

  const SellerDashboardPage({Key? key, required this.seller}) : super(key: key);

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  Map<String, dynamic>? _statistics;
  bool _isLoadingStatistics = true;
  List<dynamic> _activeOrders = [];
  bool _isLoadingActiveOrders = true;
  // Güncel seller bilgilerini tutmak için
  late Seller _currentSeller;
  // Timer ve interval kaldırıldı

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Güncel seller bilgilerini başlat
    _currentSeller = widget.seller;
    // Oturumdan gelen seller eski olabilir; API'den kesin takipçi sayısını çekip ekranda güncelle
    _refreshFollowersCount();
    _loadStatistics();
    _loadActiveOrders();
    // Session kontrolü
    if (SellerSession.currentSeller == null) {
      SellerSession.currentSeller = widget.seller;
    }
  }
  // Timer ile ilgili fonksiyonlar kaldırıldı

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refreshFollowersCount() async {
    try {
      final res = await ApiService.getSellerFollowersCount(_currentSeller.id);
      final followers = res['followers_count'] ?? _currentSeller.followersCount;
      setState(() {
        _currentSeller = _currentSeller.copyWith(followersCount: followers);
      });
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _selectedIndex == 0) {
      _loadStatistics();
      _loadActiveOrders();
    }
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoadingStatistics = true;
      });

      final statistics = await ApiService.fetchSellerStatistics(_currentSeller.id);
      
      setState(() {
        _statistics = statistics;
        _isLoadingStatistics = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStatistics = false;
      });
      
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Hata',
          message: 'İstatistikler yüklenirken hata oluştu: $e',
          buttonText: 'Tamam',
        );
      }
    }
  }

  Future<void> _loadActiveOrders() async {
    try {
      setState(() {
        _isLoadingActiveOrders = true;
      });

      final orders = await ApiService.fetchSellerActiveOrders(_currentSeller.id);
      
      setState(() {
        _activeOrders = orders;
        _isLoadingActiveOrders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingActiveOrders = false;
      });
      
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: LanguageManager.translate('Hata'),
          message: '${LanguageManager.translate('Aktif siparişler yüklenirken hata oluştu')}: $e',
          buttonText: LanguageManager.translate('Tamam'),
        );
      }
    }
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return LanguageManager.translate('Ana Sayfa');
      case 1:
        return LanguageManager.translate('Ürünlerim');
      case 2:
        return LanguageManager.translate('Siparişler');
      case 3:
        return LanguageManager.translate('Profil');
      default:
        return LanguageManager.translate('Ana Sayfa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            tooltip: 'Kullanıcı Anasayfası',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(skipSellerCheck: true)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SellerSettingsPage(seller: _currentSeller)),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            await _loadStatistics();
            await _loadActiveOrders();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: LanguageManager.translate('Ana Sayfa'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: LanguageManager.translate('Ürünlerim'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: LanguageManager.translate('Siparişler'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: LanguageManager.translate('Profil'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildProducts();
      case 2:
        return _buildOrders();
      case 3:
        return _buildProfile();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadStatistics();
        await _loadActiveOrders();
        // Timer reset kaldırıldı
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 24),
            Text(
              LanguageManager.translate('Hızlı İstatistikler'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Temel istatistikler
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLoadingStatistics ? '...' : '${_statistics?['total_products'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(LanguageManager.translate('Ürün')),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 40,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLoadingStatistics ? '...' : '${_statistics?['total_orders'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(LanguageManager.translate('Siparişler')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Sipariş Durumları
            Text(
              LanguageManager.translate('Sipariş Durumları'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 1. Satır: Beklemede ve Aktif Siparişler
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(Icons.schedule, size: 30, color: Colors.orange),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingStatistics ? '...' : '${_statistics?['pending_orders'] ?? 0}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(LanguageManager.translate('Beklemede'), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_cart, size: 30, color: Colors.blue),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingStatistics
                              ? '...'
                              : '${(_statistics?['pending_orders'] ?? 0) + (_statistics?['processing_orders'] ?? 0) + (_statistics?['shipped_orders'] ?? 0)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(LanguageManager.translate('Aktif Siparişler'), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 2. Satır: Alınan, Kargoda, Teslim
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, size: 30, color: Colors.blue),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingStatistics ? '...' : '${_statistics?['processing_orders'] ?? 0}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(LanguageManager.translate('İşleme Alındı'), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(Icons.local_shipping, size: 30, color: Colors.purple),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingStatistics ? '...' : '${_statistics?['shipped_orders'] ?? 0}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(LanguageManager.translate('Kargoda'), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(Icons.done_all, size: 30, color: Colors.green),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingStatistics ? '...' : '${_statistics?['delivered_orders'] ?? 0}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(LanguageManager.translate('Teslim Edildi'), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Favori müşteri ve en çok satılan ürün
            Text(
              LanguageManager.translate('Öne Çıkanlar'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 30,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingStatistics ? '...' : '${_statistics?['favorite_customer']?['name'] ?? 'Henüz yok'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _isLoadingStatistics ? '' : '${_statistics?['favorite_customer']?['order_count'] ?? 0} ${LanguageManager.translate('Ürünler')}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 30,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingStatistics ? '...' : '${_statistics?['best_selling_product']?['name'] ?? LanguageManager.translate('Henüz yok')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _isLoadingStatistics ? '' : '${_statistics?['best_selling_product']?['sales_count'] ?? 0} ${LanguageManager.translate('Satış')}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProducts() {
            return SellerProductsPage(seller: _currentSeller);
  }

  Widget _buildOrders() {
            return SellerOrdersPage(seller: _currentSeller);
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profil Kartı
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.store, size: 50, color: Colors.blue.shade700),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _currentSeller.storeName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Takipçi Sayısı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_currentSeller.followersCount ?? 0} ${LanguageManager.translate('Takipçi')}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Mağaza Bilgileri
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.email, 'E-posta', _currentSeller.email),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.phone, 'Telefon', _currentSeller.phone),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.local_shipping, 'Kargo Şirketi', _currentSeller.cargoCompany ?? 'Araskargo'),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          _currentSeller.isVerified ? Icons.verified : Icons.hourglass_empty,
                          'Durum',
                          _currentSeller.isVerified ? LanguageManager.translate('Onaylı') : LanguageManager.translate('Beklemede'),
                          iconColor: _currentSeller.isVerified ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Butonlar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person, color: Colors.white),
              label: Text(
                LanguageManager.translate('Hesap Bilgilerim'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SellerEditProfilePage(seller: _currentSeller),
                  ),
                );
                if (result != null) {
                  setState(() {
                    if (result is Seller) {
                      // CRITICAL: API'den dönen seller verisi eksik olabilir
                      // Mevcut seller verisini koruyarak eksik alanları doldur
                      final completeResult = _currentSeller.copyWith(
                        name: result.name,
                        email: result.email,
                        phone: result.phone,
                        storeName: result.storeName,
                        storeDescription: result.storeDescription,
                        storeLogo: result.storeLogo,
                        cargoCompany: result.cargoCompany,
                        phoneVerified: result.phoneVerified,
                        emailVerified: result.emailVerified,
                        isVerified: result.isVerified,
                        updatedAt: result.updatedAt,
                        // followers_count ve diğer alanları mevcut seller'dan koru
                        followersCount: _currentSeller.followersCount,
                        createdAt: _currentSeller.createdAt,
                      );
                      
                      _currentSeller = completeResult;
                      SellerSession.currentSeller = completeResult;
                      // CRITICAL: SellerSession'ı güncel verilerle kaydet
                      // Bu olmadan uygulamadan çıkıp girince eski bilgiler geri döner
                      SellerSession.saveSellerSession(completeResult);
                    }
                  });
                  _loadStatistics();
                  _loadActiveOrders();
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.star, color: Colors.white),
              label: Text(
                LanguageManager.translate('Değerlendirmeler'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SellerReviewsPage(seller: _currentSeller),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Çıkış Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: Text(
                LanguageManager.translate('Çıkış Yap'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                await SellerSession.clearSellerSession();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerAuthPage()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Colors.blue.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageManager.translate(label),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


} 