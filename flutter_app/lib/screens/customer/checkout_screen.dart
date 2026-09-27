import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Theme colors
  static const Color primaryGreen = Color(0xFF3F5F54);
  static const Color lightCream = Color(0xFFE8E5DB);
  static const Color accentOrange = Color(0xFFD98E4A);
  static const Color textGrey = Color(0xFF5C625B);

  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);

    try {
      final result = await ApiService.placeOrder(
        _addressController.text.trim(),
      );

      if (!mounted) return;

      context.read<CartProvider>().clearLocal();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: primaryGreen,
              ),
              SizedBox(width: 10),
              Text(
                'Order Placed!',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Order #${result['order_id']} confirmed.\n\n'
                'Total: \$${(result['total'] as num).toStringAsFixed(2)}',
            style: const TextStyle(
              color: textGrey,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: accentOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              // ORDER SUMMARY TITLE
              const Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: primaryGreen,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Order Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ORDER SUMMARY CARD
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [
                      ...cart.items.map(
                            (item) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 7,
                          ),

                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.title} x${item.quantity}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: textGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Text(
                                '\$${item.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Divider(),
                      ),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ),

                          Text(
                            '\$${cart.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // SHIPPING ADDRESS TITLE
              const Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: primaryGreen,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ADDRESS FIELD
              TextFormField(
                controller: _addressController,
                maxLines: 4,

                decoration: InputDecoration(
                  hintText: 'Enter your full delivery address',

                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(
                      bottom: 70,
                    ),
                    child: Icon(
                      Icons.home_outlined,
                      color: primaryGreen,
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: lightCream,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: lightCream,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: primaryGreen,
                      width: 1.5,
                    ),
                  ),
                ),

                validator: (v) {
                  if (v == null || v.trim().length < 5) {
                    return 'Please enter a valid shipping address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 32),

              // PLACE ORDER BUTTON
              ElevatedButton.icon(
                onPressed:
                _isPlacingOrder ? null : _placeOrder,

                icon: _isPlacingOrder
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.shopping_bag_outlined,
                ),

                label: Text(
                  _isPlacingOrder
                      ? 'Placing Order...'
                      : 'Place Order',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),

                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}