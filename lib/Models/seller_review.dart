class SellerReview {
  final int id;
  final int productId;
  final int sellerId;
  final int userId;
  final int rating;
  final String? comment;
  final String? createdAt;

  SellerReview({
    required this.id,
    required this.productId,
    required this.sellerId,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory SellerReview.fromJson(Map<String, dynamic> json) {
    return SellerReview(
      id: json['id'],
      productId: json['product_id'],
      sellerId: json['seller_id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'seller_id': sellerId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
    };
  }
}
