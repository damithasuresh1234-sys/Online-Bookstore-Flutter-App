import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  double _total = 0;
  bool _isLoading = false;

  List<CartItem> get items => _items;
  double get total => _total;
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getCart();
      _items = (data['items'] as List<dynamic>).map((e) => CartItem.fromJson(e)).toList();
      _total = (data['total'] as num).toDouble();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(int bookId, int quantity) async {
    await ApiService.addToCart(bookId, quantity);
    await fetchCart();
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    await ApiService.updateCartItem(cartItemId, quantity);
    await fetchCart();
  }

  Future<void> removeItem(int cartItemId) async {
    await ApiService.removeCartItem(cartItemId);
    await fetchCart();
  }

  void clearLocal() {
    _items = [];
    _total = 0;
    notifyListeners();
  }
}
