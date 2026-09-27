import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Thrown when the API returns success:false. Carries the message
/// and (optional) field-level validation errors from the backend.
class ApiException implements Exception {
  final String message;
  final List<dynamic>? errors;
  ApiException(this.message, [this.errors]);

  @override
  String toString() => message;
}

class ApiService {
  // ---------------------------------------------------------------
  // IMPORTANT: change this base URL to match your setup.
  //   - Android Emulator -> XAMPP on same machine: http://10.0.2.2/bookstore_api
  //   - Physical device on same Wi-Fi as your PC:   http://<your-pc-lan-ip>/bookstore_api
  //   - iOS Simulator on same machine:               http://localhost/bookstore_api
  // ---------------------------------------------------------------
  static const String baseUrl = 'http://10.0.2.2/bookstore_api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw ApiException('Unexpected server response (status ${response.statusCode}).');
    }
    if (body['success'] == true) {
      return body;
    }
    throw ApiException(body['message'] ?? 'Something went wrong.', body['errors']);
  }

  // ---------------- AUTH ----------------

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login.php'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(res)['data'];
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register.php'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return _decode(res)['data'];
  }

  // ---------------- BOOKS ----------------

  static Future<List<dynamic>> listBooks({String search = '', String category = ''}) async {
    final uri = Uri.parse('$baseUrl/api/books/list.php').replace(queryParameters: {
      if (search.isNotEmpty) 'search': search,
      if (category.isNotEmpty) 'category': category,
    });
    final res = await http.get(uri, headers: await _headers());
    return _decode(res)['data'];
  }

  static Future<Map<String, dynamic>> getBook(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/books/get.php?id=$id'), headers: await _headers());
    return _decode(res)['data'];
  }

  static Future<void> createBook(Map<String, dynamic> bookData) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/books/create.php'),
      headers: await _headers(auth: true),
      body: jsonEncode(bookData),
    );
    _decode(res);
  }

  static Future<void> updateBook(Map<String, dynamic> bookData) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/books/update.php'),
      headers: await _headers(auth: true),
      body: jsonEncode(bookData),
    );
    _decode(res);
  }

  static Future<void> deleteBook(int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/books/delete.php'),
      headers: await _headers(auth: true),
      body: jsonEncode({'id': id}),
    );
    _decode(res);
  }

  // ---------------- CART ----------------

  static Future<Map<String, dynamic>> getCart() async {
    final res = await http.get(Uri.parse('$baseUrl/api/cart/get.php'), headers: await _headers(auth: true));
    return _decode(res)['data'];
  }

  static Future<void> addToCart(int bookId, int quantity) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/cart/add.php'),
      headers: await _headers(auth: true),
      body: jsonEncode({'book_id': bookId, 'quantity': quantity}),
    );
    _decode(res);
  }

  static Future<void> updateCartItem(int cartItemId, int quantity) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/cart/update.php'),
      headers: await _headers(auth: true),
      body: jsonEncode({'cart_item_id': cartItemId, 'quantity': quantity}),
    );
    _decode(res);
  }

  static Future<void> removeCartItem(int cartItemId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/cart/remove.php'),
      headers: await _headers(auth: true),
      body: jsonEncode({'cart_item_id': cartItemId}),
    );
    _decode(res);
  }

  // ---------------- ORDERS ----------------

  static Future<Map<String, dynamic>> placeOrder(String shippingAddress) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/orders/place.php'),
      headers: await _headers(auth: true),
      body: jsonEncode({'shipping_address': shippingAddress}),
    );
    return _decode(res)['data'];
  }

  static Future<List<dynamic>> listOrders() async {
    final res = await http.get(Uri.parse('$baseUrl/api/orders/list.php'), headers: await _headers(auth: true));
    return _decode(res)['data'];
  }

  static Future<void> updateOrderStatus(int orderId, String status) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/orders/update_status.php'),
      headers: await _headers(auth: true),
      body: jsonEncode({'order_id': orderId, 'status': status}),
    );
    _decode(res);
  }

  // ---------------- USERS (Admin) ----------------

  static Future<List<dynamic>> listUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/api/users/list.php'), headers: await _headers(auth: true));
    return _decode(res)['data'];
  }

  static Future<void> updateUserRole(int userId, String role) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/users/update_role.php'),
      headers: await _headers(auth: true),
      body: jsonEncode({'user_id': userId, 'role': role}),
    );
    _decode(res);
  }
}
