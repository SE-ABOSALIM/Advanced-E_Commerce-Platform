import 'package:flutter/material.dart';
import '../Database/database_helper.dart';
import '../Models/product.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({Key? key}) : super(key: key);

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  List<Product> products = [];
  final dbHelper = DatabaseHelper();
  bool isLoading = true;
  String? selectedImage;

  static const List<String> _images = [
    'assets/Images/Iphone-14-Pro.jpg',
    'assets/Images/Samsung-Galaxy-S23.png',
    'assets/Images/Macbook-Pro.jpeg',
    'assets/Images/Bar.jpg',
    'assets/Images/Dumbell.jpg',
    'assets/Images/Gomlek.jpg',
    'assets/Images/Kazak.jpg',
    'assets/Images/Monopoly.png',
    'assets/Images/Pantolon.png',
    'assets/Images/Uno.jpg',
    'assets/Images/Gardrop.png',
    'assets/Images/Koltuk.png',
  ];

  final List<String> categories = [
    'Elektronik',
    'Kıyafet',
    'Kozmetik',
    'Mobilya',
    'Spor',
    'Oyuncak',
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final list = await dbHelper.getAllProducts();
    setState(() {
      products = list;
      isLoading = false;
    });
  }

  void _showProductDialog({Product? product}) {
    final _formKey = GlobalKey<FormState>();
    String name = product?.name ?? '';
    String price = product?.price.toString() ?? '';
    String description = product?.description ?? '';
    String category = product?.category ?? '';
    selectedImage = product?.imageUrl.isNotEmpty == true
        ? (product!.imageUrl.startsWith('assets/') ? product!.imageUrl : 'assets/${product!.imageUrl}')
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Yeni Ürün Ekle' : 'Ürünü Düzenle'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedImage,
                  items: _images.map((img) {
                    return DropdownMenuItem(
                      value: img,
                      child: Row(
                        children: [
                          Image.asset(img, width: 40, height: 40),
                          const SizedBox(width: 8),
                          Text(img.split('/').last),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedImage = v;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Ürün Fotoğrafı'),
                  validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(labelText: 'Ürün Adı'),
                  onSaved: (v) => name = v ?? '',
                  validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                ),
                TextFormField(
                  initialValue: price,
                  decoration: InputDecoration(labelText: 'Fiyat'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => price = v ?? '',
                  validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                ),
                TextFormField(
                  initialValue: description,
                  decoration: InputDecoration(labelText: 'Açıklama'),
                  onSaved: (v) => description = v ?? '',
                  validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                ),
                DropdownButtonFormField<String>(
                  value: category.isNotEmpty ? category : null,
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      category = v ?? '';
                    });
                  },
                  decoration: InputDecoration(labelText: 'Kategori'),
                  validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (product == null) {
                  await dbHelper.insertProduct(Product(
                    id: '',
                    name: name,
                    price: double.tryParse(price) ?? 0,
                    imageUrl: selectedImage ?? '',
                    description: description,
                    category: category,
                  ));
                } else {
                  await dbHelper.updateProduct(Product(
                    id: product.id,
                    name: name,
                    price: double.tryParse(price) ?? 0,
                    imageUrl: selectedImage ?? '',
                    description: description,
                    category: category,
                  ));
                }
                Navigator.pop(context);
                fetchProducts();
              }
            },
            child: Text(product == null ? 'Ekle' : 'Kaydet'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String id) async {
    await dbHelper.deleteProduct(int.parse(id));
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Yönetimi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF1877F2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('Hiç ürün yok.'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            product.imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      product.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.error_outline, size: 40, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
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
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showProductDialog(product: product),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteProduct(product.id),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Fiyat: ₺${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('Kategori: ${product.category}', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text('Açıklama: ${product.description}', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(
            Icons.add,
            color: Colors.white
        ),
        backgroundColor: Color(0xFF1877F2),
        tooltip: 'Ürün Ekle',
      ),
    );
  }
} 