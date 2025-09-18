class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String category;
  final int? sellerId;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.category,
    this.sellerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': int.parse(id), // Convert string id to int for backend
      'product_name': name,
      'product_price': price,
      'product_image_url': imageUrl,
      'product_description': description,
      'product_category': category,
      'seller_id': sellerId,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    String imageUrl = '';
    if (map['product_image_url'] != null) {
      imageUrl = map['product_image_url'].toString().replaceAll('{{', '').replaceAll('}}', '');
    }
    
    return Product(
      id: map['id'].toString(),
      name: map['product_name'],
      price: map['product_price'] is int ? (map['product_price'] as int).toDouble() : map['product_price'],
      imageUrl: imageUrl,
      description: map['product_description'],
      category: map['product_category'],
      sellerId: map['seller_id'],
    );
  }
} 