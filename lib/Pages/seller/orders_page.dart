import 'package:flutter/material.dart';
import '../../Models/seller.dart';
import '../../Services/api_service.dart';
import '../../Widgets/custom_dialog.dart';
import '../../Utils/language_manager.dart';

class SellerOrdersPage extends StatefulWidget {
  final Seller seller;

  const SellerOrdersPage({Key? key, required this.seller}) : super(key: key);

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage> with SingleTickerProviderStateMixin {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final orders = await ApiService.fetchSellerOrders(widget.seller.id);
      
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: LanguageManager.translate('Hata'),
          message: LanguageManager.translate('Siparişler yüklenirken hata oluştu. Lütfen tekrar deneyin.'),
          buttonText: LanguageManager.translate('Tamam'),
        );
      }
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await ApiService.updateSellerOrderStatus(orderId, newStatus);
      
      // Siparişleri yeniden yükle
      await _loadOrders();
      
      if (mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: LanguageManager.translate('Başarılı!'),
          message: LanguageManager.translate('Sipariş durumu güncellendi'),
          buttonText: LanguageManager.translate('Tamam'),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: LanguageManager.translate('Hata'),
          message: LanguageManager.translate('Sipariş durumu güncellenirken hata oluştu. Lütfen tekrar deneyin.'),
          buttonText: LanguageManager.translate('Tamam'),
        );
      }
    }
  }

  // Aktif siparişleri getir (teslim edilmemiş ve iptal edilmemiş)
  List<dynamic> get _activeOrders {
    final active = _orders.where((order) => order['status'] != 'delivered' && order['status'] != 'cancelled').toList();
    active.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
    return active;
  }

  // Teslim edilen siparişleri getir
  List<dynamic> get _deliveredOrders {
    final delivered = _orders.where((order) => order['status'] == 'delivered').toList();
    delivered.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
    return delivered;
  }

  // İptal edilen siparişler
  List<dynamic> get _cancelledOrders {
    final cancelled = _orders.where((order) => order['status'] == 'cancelled').toList();
    cancelled.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
    return cancelled;
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return LanguageManager.translate('Beklemede');
      case 'processing':
        return LanguageManager.translate('İşleme Alındı');
      case 'shipped':
        return LanguageManager.translate('Kargoya Verildi');
      case 'delivered':
        return LanguageManager.translate('Teslim Edildi');
      case 'cancelled':
        return LanguageManager.translate('İptal Edildi');
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      children: [
        // TabBar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: primaryColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: LanguageManager.translate('Aktif Siparişler')),
                Tab(text: LanguageManager.translate('Teslim Edilen')),
                Tab(text: LanguageManager.translate('İptal Edilen')),
              ],
            ),
          ),
        ),
        // TabBarView
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(_activeOrders, LanguageManager.translate('Henüz aktif sipariş yok.')),
                    _buildOrdersList(_deliveredOrders, LanguageManager.translate('Henüz teslim edilen sipariş yok.')),
                    _buildOrdersList(_cancelledOrders, LanguageManager.translate('Henüz iptal edilen sipariş yok.')),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<dynamic> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              orders == _activeOrders ? Icons.shopping_bag_outlined :
              orders == _deliveredOrders ? Icons.done_all :
              Icons.remove_shopping_cart,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sipariş başlığı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${LanguageManager.translate('Sipariş')} ${order['order_code']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['status']).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(order['status']),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Kullanıcı bilgileri
                  if (order['user'] != null) ...[
                    Text(
                      LanguageManager.translate('Müşteri Bilgileri'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order['user']['name_surname'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      order['user']['email'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      order['user']['phone_number'] ?? LanguageManager.translate('Telefon bilgisi yok'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Adres bilgileri
                  if (order['address'] != null) ...[
                    Text(
                      LanguageManager.translate('Teslimat Adresi'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${order['address']['city']}, ${order['address']['district']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${order['address']['neighbourhood']}, ${order['address']['street_name']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${LanguageManager.translate('Bina')}: ${order['address']['building_number']}, ${LanguageManager.translate('Daire')}: ${order['address']['apartment_number']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Sipariş tarihleri
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageManager.translate('Sipariş Tarihi'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              order['order_created_date'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageManager.translate('Tahmini Teslimat'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              order['order_estimated_delivery'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Ürünler
                  if (order['products'] != null && order['products'].isNotEmpty) ...[
                    Text(
                      LanguageManager.translate('Sipariş Edilen Ürünler'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...order['products'].map<Widget>((product) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['product_name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${LanguageManager.translate('Adet')}: ${product['quantity']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${LanguageManager.translate('Fiyat')}: ${product['total_price'].toStringAsFixed(2)} TL',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Durum güncelleme butonları (sadece aktif siparişler için)
                  if (_tabController.index == 0) ...[
                    if (order['status'] == 'pending') ...[
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageManager.translate('Sipariş Durumu Güncelle'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateOrderStatus(
                                      order['order_id'],
                                      'processing',
                                    ),
                                    icon: const Icon(Icons.check_circle),
                                    label: Text(LanguageManager.translate('Sipariş Alındı')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateOrderStatus(
                                      order['order_id'],
                                      'cancelled',
                                    ),
                                    icon: const Icon(Icons.cancel),
                                    label: Text(LanguageManager.translate('İptal Et')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else if (order['status'] == 'processing') ...[
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sipariş Durumu Güncelle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateOrderStatus(
                                      order['order_id'],
                                      'shipped',
                                    ),
                                    icon: const Icon(Icons.local_shipping),
                                    label: Text(LanguageManager.translate('Kargoya Verildi')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else if (order['status'] == 'shipped') ...[
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageManager.translate('Sipariş Durumu Güncelle'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateOrderStatus(
                                      order['order_id'],
                                      'delivered',
                                    ),
                                    icon: const Icon(Icons.done_all),
                                    label: Text(LanguageManager.translate('Teslim Edildi')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 