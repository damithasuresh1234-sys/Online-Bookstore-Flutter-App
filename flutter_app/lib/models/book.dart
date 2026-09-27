class Book {
  final int id;
  final String title;
  final String author;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String? imageUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is num) ? json['price'].toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock'].toString()) ?? 0,
      category: json['category'] ?? 'General',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        'image_url': imageUrl,
      };
}
