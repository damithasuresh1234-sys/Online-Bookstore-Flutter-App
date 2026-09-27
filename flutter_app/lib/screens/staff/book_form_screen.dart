import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/api_service.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book; // null = creating a new book, non-null = editing
  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;
  String _category = 'General';
  bool _isSaving = false;

  final _categories = ['General', 'Fiction', 'Non-Fiction', 'Technology', 'Self-Help'];

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _descriptionController = TextEditingController(text: book?.description ?? '');
    _priceController = TextEditingController(text: book != null ? book.price.toString() : '');
    _stockController = TextEditingController(text: book != null ? book.stock.toString() : '');
    _imageUrlController = TextEditingController(text: book?.imageUrl ?? '');
    if (book != null) _category = book.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'title': _titleController.text.trim(),
      'author': _authorController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'stock': int.parse(_stockController.text.trim()),
      'category': _category,
      'image_url': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
    };

    try {
      if (_isEditing) {
        data['id'] = widget.book!.id;
        await ApiService.updateBook(data);
      } else {
        await ApiService.createBook(data);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      final msg = e.errors != null && e.errors!.isNotEmpty ? e.errors!.join('\n') : e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red.shade600));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save book.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Book' : 'Add Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Author is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price (\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final parsed = double.tryParse(v.trim());
                        if (parsed == null) return 'Enter a valid number';
                        if (parsed < 0) return 'Must be positive';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final parsed = int.tryParse(v.trim());
                        if (parsed == null) return 'Enter a whole number';
                        if (parsed < 0) return 'Must be positive';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'General'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Cover image URL (optional)'),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? 'Save Changes' : 'Add Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
