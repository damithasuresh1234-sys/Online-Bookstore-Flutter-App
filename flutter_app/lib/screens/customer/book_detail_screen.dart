import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../theme.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;

  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Book? _book;
  bool _isLoading = true;
  String? _error;
  int _quantity = 1;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getBook(widget.bookId);

      setState(() {
        _book = Book.fromJson(data);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to load book details.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart() async {
    setState(() => _isAdding = true);

    try {
      await context.read<CartProvider>().addToCart(
        _book!.id,
        _quantity,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${_book!.title} to cart'),
          backgroundColor: AppTheme.primary,
        ),
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to cart.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _error != null
          ? Center(
        child: Text(_error!),
      )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final book = _book!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Book Image
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 260,
                width: 180,
                child: book.imageUrl != null &&
                    book.imageUrl!.isNotEmpty
                    ? Image.network(
                  book.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE5EBDD),
                    child: const Icon(
                      Icons.menu_book,
                      size: 60,
                      color: AppTheme.primary,
                    ),
                  ),
                )
                    : Container(
                  color: const Color(0xFFE5EBDD),
                  child: const Icon(
                    Icons.menu_book,
                    size: 60,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Book Title
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),

          const SizedBox(height: 4),

          // Author
          Text(
            'by ${book.author}',
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 12),

          // Price and Category
          Row(
            children: [
              Text(
                '\$${book.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),

              const SizedBox(width: 12),

              Chip(
                label: Text(book.category),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Stock
          Text(
            book.stock > 0
                ? '${book.stock} in stock'
                : 'Out of stock',
            style: TextStyle(
              color: book.stock > 0
                  ? AppTheme.primary
                  : Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.darkText,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            book.description.isNotEmpty
                ? book.description
                : 'No description available.',
            style: const TextStyle(
              height: 1.4,
              color: AppTheme.secondaryText,
            ),
          ),

          const SizedBox(height: 28),

          if (book.stock > 0) ...[
            Row(
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.darkText,
                  ),
                ),

                const SizedBox(width: 16),

                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppTheme.primary,
                  ),
                ),

                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),

                IconButton(
                  onPressed: _quantity < book.stock
                      ? () => setState(() => _quantity++)
                      : null,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAdding ? null : _addToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: _isAdding
                    ? const Text('Adding...')
                    : const Text('Add to Cart'),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                child: const Text('Out of Stock'),
              ),
            ),
        ],
      ),
    );
  }
}