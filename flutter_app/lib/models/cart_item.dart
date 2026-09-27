class CartItem {
  final int cartItemId;
  final int bookId;
  final String title;
  final String author;
  final double price;
  final String? imageUrl;
  final int stock;
  int quantity;

  CartItem({
    required this.cartItemId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: json['cart_item_id'],
      bookId: json['book_id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'],
      quantity: json['quantity'],
    );
  }
}
