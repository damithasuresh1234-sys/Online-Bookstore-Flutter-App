import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/api_service.dart';
import '../../widgets/book_card.dart';
import 'book_detail_screen.dart';

class BrowseBooksScreen extends StatefulWidget {
  const BrowseBooksScreen({super.key});

  @override
  State<BrowseBooksScreen> createState() => _BrowseBooksScreenState();
}

class _BrowseBooksScreenState extends State<BrowseBooksScreen> {
  final _searchController = TextEditingController();

  List<Book> _books = [];

  bool _isLoading = true;
  String? _error;

  String _selectedCategory = 'All';

  Timer? _debounce;

  final _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Technology',
    'Self-Help',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.listBooks(
        search: _searchController.text.trim(),
        category: _selectedCategory == 'All'
            ? ''
            : _selectedCategory,
      );

      setState(() {
        _books = data.map((e) => Book.fromJson(e)).toList();
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error =
        'Could not load books. Check your connection and API URL.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
      _loadBooks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookstore'),
      ),

      body: RefreshIndicator(
        color: const Color(0xFF3F5F54),

        onRefresh: _loadBooks,

        child: Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                8,
              ),

              child: TextField(
                controller: _searchController,

                onChanged: _onSearchChanged,

                decoration: InputDecoration(
                  hintText: 'Search by title or author...',

                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF3F5F54),
                  ),

                  suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Color(0xFF3F5F54),
                    ),

                    onPressed: () {
                      _searchController.clear();
                      _loadBooks();
                    },
                  )
                      : null,
                ),
              ),
            ),

            // CATEGORY CHIPS
            SizedBox(
              height: 42,

              child: ListView.separated(
                scrollDirection: Axis.horizontal,

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                itemCount: _categories.length,

                separatorBuilder:
                    (_, __) =>
                const SizedBox(width: 8),

                itemBuilder: (
                    context,
                    index,
                    ) {
                  final category =
                  _categories[index];

                  final selected =
                      category ==
                          _selectedCategory;

                  return ChoiceChip(
                    label: Text(
                      category,

                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(
                          0xFF3F5F54,
                        ),

                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),

                    selected: selected,

                    selectedColor:
                    const Color(
                      0xFF3F5F54,
                    ),

                    backgroundColor:
                    const Color(
                      0xFFE8E5DB,
                    ),

                    side: BorderSide(
                      color: selected
                          ? const Color(
                        0xFF3F5F54,
                      )
                          : const Color(
                        0xFFD2CEC1,
                      ),
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    onSelected: (_) {
                      setState(() {
                        _selectedCategory =
                            category;
                      });

                      _loadBooks();
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // BOOK LIST
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // LOADING
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(
          color:
          Color(0xFF3F5F54),
        ),
      );
    }

    // ERROR
    if (_error != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              const Icon(
                Icons.cloud_off,
                size: 48,
                color:
                Color(0xFF3F5F54),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                _error!,
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(
                height: 12,
              ),

              ElevatedButton(
                onPressed:
                _loadBooks,

                child:
                const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // NO BOOKS
    if (_books.isEmpty) {
      return const Center(
        child: Text(
          'No books found.',

          style: TextStyle(
            color:
            Color(0xFF5C625B),
            fontSize: 16,
          ),
        ),
      );
    }

    // BOOK GRID
    return GridView.builder(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        16,
      ),

      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        childAspectRatio: 0.62,

        crossAxisSpacing: 12,

        mainAxisSpacing: 12,
      ),

      itemCount:
      _books.length,

      itemBuilder: (
          context,
          index,
          ) {
        final book =
        _books[index];

        return BookCard(
          book: book,

          onTap: () =>
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      BookDetailScreen(
                        bookId:
                        book.id,
                      ),
                ),
              ),
        );
      },
    );
  }
}