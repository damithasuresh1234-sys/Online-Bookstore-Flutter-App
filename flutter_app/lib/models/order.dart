class OrderItem {
  final int bookId;
  final String titleSnapshot;
  final double priceSnapshot;
  final int quantity;

  OrderItem({
    required this.bookId,
    required this.titleSnapshot,
    required this.priceSnapshot,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      bookId: json['book_id'],
      titleSnapshot: json['title_snapshot'] ?? '',
      priceSnapshot: (json['price_snapshot'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }
}

class BookOrder {
  final int id;
  final int userId;
  final String customerName;
  final String customerEmail;
  final double totalAmount;
  final String shippingAddress;
  final String status;
  final String createdAt;
  final List<OrderItem> items;

  BookOrder({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.totalAmount,
    required this.shippingAddress,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory BookOrder.fromJson(Map<String, dynamic> json) {
    return BookOrder(
      id: json['id'],
      userId: json['user_id'],
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      totalAmount: (json['total_amount'] as num).toDouble(),
      shippingAddress: json['shipping_address'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }
}
