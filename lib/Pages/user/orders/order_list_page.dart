import 'package:flutter/material.dart';
import '../../../Models/order.dart';
import '../../../Models/product.dart';
import '../../../Models/seller.dart';
import '../../../Models/address.dart';
import '../../../Services/api_service.dart';
import '../../../Widgets/custom_dialog.dart';
import '../../../Utils/language_manager.dart';
import '../../../Utils/app_config.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await ApiService.fetchOrders();
    setState(() {
      _orders = orders.map((e) => Order.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Future<List<Product>> _getProducts(int orderId) async {
    final products = await ApiService.fetchProducts();
    return products.map((e) => Product.fromMap(e)).toList();
  }

  Future<Address?> _getAddress(int addressId) async {
    final addresses = await ApiService.fetchAddresses();
    return addresses.map((e) => Address.fromMap(e)).firstWhere(
      (a) => a.id == addressId,
      orElse: () => Address(
        id: -1,
        city: '',
        district: '',
        neighbourhood: '',
        streetName: '',
        buildingNumber: '',
        apartmentNumber: '',
        addressName: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageManager.translate('Siparişlerim'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1877F2),
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text(LanguageManager.translate('Henüz siparişiniz yok.')))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return FutureBuilder<List<Product>>(
                      future: _getProducts(order.id!),
                      builder: (context, snapshot) {
                        final products = snapshot.data ?? [];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${LanguageManager.translate('Sipariş Kodu')}: ${order.orderCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(order.orderCargoCompany, style: const TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('${LanguageManager.translate('Sipariş Tarihi')}: ${order.orderCreatedDate}'),
                                if (order.orderStatus == 'processing' || order.orderStatus == 'shipped' || order.orderStatus == 'delivered') ...[
                                  Text('${LanguageManager.translate('Tahmini Teslim')}: ${order.orderEstimatedDelivery}'),
                                ],
                                FutureBuilder<Address?>(
                                  future: _getAddress(order.orderAddress),
                                  builder: (context, addrSnap) {
                                    final addr = addrSnap.data;
                                    if (addr == null) return const SizedBox();
                                    return Text('${LanguageManager.translate('Adres')}: ${addr.city}, ${addr.district}, ${addr.streetName} No:${addr.buildingNumber} D:${addr.apartmentNumber}');
                                  },
                                ),
                                const Divider(),
                                Text(LanguageManager.translate('Ürünler:'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ...products.map((p) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                                                             leading: Image.network(
                                         p.imageUrl.isNotEmpty ? AppConfig.getImageUrl(p.imageUrl) : '',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(Icons.image),
                                      ),
                                      title: Text(p.name),
                                      subtitle: Text('₺${p.price.toStringAsFixed(2)}'),
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
} 