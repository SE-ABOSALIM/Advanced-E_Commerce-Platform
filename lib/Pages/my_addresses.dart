import 'package:flutter/material.dart';
import '../Models/address.dart';
import '../API/api_service.dart';
import 'add_address_page.dart';
import '../Widgets/custom_dialog.dart';
import '../Utils/language_manager.dart';

class MyAddressesPage extends StatefulWidget {
  final int userId;
  const MyAddressesPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyAddressesPage> createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  List<Address> addresses = [];

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    final list = await ApiService.fetchAddresses();
    setState(() {
      addresses = list.map((e) => Address.fromMap(e)).toList();
    });
  }

  void _navigateToAddAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAddressPage(),
      ),
    ).then((_) {
      // Sayfa döndüğünde adresleri yenile
      fetchAddresses();
    });
  }

  void _deleteAddress(int addressId) async {
    await ApiService.deleteAddress(addressId);
    fetchAddresses();
  }

  void _showEditAddressDialog(Address address) {
    // TODO: Edit dialog'u da sayfa haline getirilecek
    CustomDialog.showWarning(
      context: context,
      title: LanguageManager.translate('Bilgi'),
      message: LanguageManager.translate('Düzenleme özelliği yakında eklenecek'),
      buttonText: LanguageManager.translate('Tamam'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          LanguageManager.translate('Adreslerim'),
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
          addresses.isEmpty
              ? Center(child: Text(LanguageManager.translate('Henüz adres eklenmemiş')))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address.addressName.isNotEmpty ? address.addressName : LanguageManager.translate('Adres'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditAddressDialog(address),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteAddress(address.id!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${address.city}, ${address.district}, ${address.neighbourhood}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${address.streetName} Sokak, Bina: ${address.buildingNumber}, Daire: ${address.apartmentNumber}',
                              style: const TextStyle(fontSize: 15, color: Colors.grey),
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
                onPressed: _navigateToAddAddress,
                icon: const Icon(Icons.add_location_alt, size: 26),
                                label: Text(
                  LanguageManager.translate('Yeni Adres Ekle'),
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