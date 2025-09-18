class CreditCard {
  final int? id;
  final int? userId;
  final String provider;
  final String cardToken;
  final String cardBrand;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;
  final String? createdAt;
  final String? updatedAt;

  CreditCard({
    this.id,
    this.userId,
    required this.provider,
    required this.cardToken,
    required this.cardBrand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'provider': provider,
      'card_token': cardToken,
      'card_brand': cardBrand,
      'last4': last4,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      provider: (map['provider'] ?? 'local').toString(),
      cardToken: (map['card_token'] ?? '').toString(),
      cardBrand: (map['card_brand'] ?? 'unknown').toString(),
      last4: (map['last4'] ?? '').toString(),
      expiryMonth: int.tryParse((map['expiry_month'] ?? '').toString()) ?? (map['expiry_month'] ?? 0),
      expiryYear: int.tryParse((map['expiry_year'] ?? '').toString()) ?? (map['expiry_year'] ?? 0),
      isDefault: (map['is_default'] ?? false) == true || (map['is_default']?.toString() == 'true') || (map['is_default'] == 1),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }
}