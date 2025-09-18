class Seller {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String phoneVerified;
  final String emailVerified;
  final String storeName;
  final String? storeDescription;
  final String? storeLogo;
  final String? cargoCompany;
  final bool isVerified;
  final int followersCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Seller({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.phoneVerified,
    required this.emailVerified,
    required this.storeName,
    this.storeDescription,
    this.storeLogo,
    this.cargoCompany,
    required this.isVerified,
    required this.followersCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'phone_verified': phoneVerified,
      'email_verified': emailVerified,
      'store_name': storeName,
      'store_description': storeDescription,
      'store_logo_url': storeLogo,
      'cargo_company': cargoCompany,
      'is_verified': isVerified ? 'verified' : 'pending',
      'followers_count': followersCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Seller.fromMap(Map<String, dynamic> map) {
    // Handle is_verified as string and convert to bool
    bool isVerified = false;
    if (map['is_verified'] != null) {
      if (map['is_verified'] is String) {
        isVerified = map['is_verified'] == 'verified';
      } else if (map['is_verified'] is bool) {
        isVerified = map['is_verified'];
      }
    }
    
    return Seller(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      phoneVerified: map['phone_verified'] ?? 'pending',
      emailVerified: map['email_verified'] ?? 'pending',
      storeName: map['store_name'],
      storeDescription: map['store_description'],
      storeLogo: map['store_logo_url'],
      cargoCompany: map['cargo_company'],
      isVerified: isVerified,
      followersCount: map['followers_count'] is String 
          ? int.tryParse(map['followers_count']) ?? 0 
          : map['followers_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Seller copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? phoneVerified,
    String? emailVerified,
    String? storeName,
    String? storeDescription,
    String? storeLogo,
    String? cargoCompany,
    bool? isVerified,
    int? followersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Seller(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      storeName: storeName ?? this.storeName,
      storeDescription: storeDescription ?? this.storeDescription,
      storeLogo: storeLogo ?? this.storeLogo,
      cargoCompany: cargoCompany ?? this.cargoCompany,
      isVerified: isVerified ?? this.isVerified,
      followersCount: followersCount ?? this.followersCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 