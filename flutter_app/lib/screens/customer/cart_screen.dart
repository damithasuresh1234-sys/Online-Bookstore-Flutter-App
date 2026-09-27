import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryGreen = Color(0xFF3F5F54);
  static const Color cream = Color(0xFFF7F6F3);
  static const Color lightCream = Color(0xFFE8E5DB);
  static const Color accentOrange = Color(0xFFD98E4A);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  Future<void> _changeQuantity(
      int cartItemId,
      int newQty,
      ) async {
    try {
      await context
          .read<CartProvider>()
          .updateQuantity(cartItemId, newQty);
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Future<void> _removeItem(int cartItemId) async {
    try {
      await context.read<CartProvider>().removeItem(cartItemId);
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),

      body: cart.isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      )
          : cart.items.isEmpty
          ? _buildEmptyCart()
          : _buildCartList(cart),

      bottomNavigationBar: cart.items.isEmpty
          ? null
          : _buildCheckoutSection(cart),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 70,
            color: primaryGreen,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryGreen,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Browse books and add your favourites.',
            style: TextStyle(
              color: Color(0xFF5C625B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(CartProvider cart) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        24,
      ),

      itemCount: cart.items.length,

      separatorBuilder: (_, __) =>
      const SizedBox(height: 12),

      itemBuilder: (context, index) {
        final item = cart.items[index];

        return Card(
          elevation: 2,

          color: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // BOOK IMAGE
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12),

                  child: SizedBox(
                    width: 72,
                    height: 100,

                    child: item.imageUrl != null &&
                        item.imageUrl!.isNotEmpty
                        ? Image.network(
                      item.imageUrl!,

                      fit: BoxFit.cover,

                      errorBuilder:
                          (_, __, ___) =>
                          _imagePlaceholder(),
                    )
                        : _imagePlaceholder(),
                  ),
                ),

                const SizedBox(width: 14),

                // BOOK DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Text(
                        item.title,

                        maxLines: 2,

                        overflow:
                        TextOverflow.ellipsis,

                        style:
                        const TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '\$${item.price.toStringAsFixed(2)} each',

                        style: const TextStyle(
                          fontSize: 12,
                          color:
                          Color(0xFF5C625B),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // QUANTITY SELECTOR
                      Container(
                        decoration:
                        BoxDecoration(
                          color: lightCream,

                          borderRadius:
                          BorderRadius.circular(
                            10,
                          ),
                        ),

                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,

                          children: [
                            IconButton(
                              visualDensity:
                              VisualDensity.compact,

                              icon: const Icon(
                                Icons.remove,
                                color:
                                primaryGreen,
                                size: 18,
                              ),

                              onPressed:
                              item.quantity > 1
                                  ? () =>
                                  _changeQuantity(
                                    item.cartItemId,
                                    item.quantity -
                                        1,
                                  )
                                  : null,
                            ),

                            Text(
                              '${item.quantity}',

                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                color:
                                primaryGreen,
                              ),
                            ),

                            IconButton(
                              visualDensity:
                              VisualDensity.compact,

                              icon: const Icon(
                                Icons.add,
                                color:
                                primaryGreen,
                                size: 18,
                              ),

                              onPressed:
                              item.quantity <
                                  item.stock
                                  ? () =>
                                  _changeQuantity(
                                    item.cartItemId,
                                    item.quantity +
                                        1,
                                  )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // PRICE + DELETE
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,

                  children: [
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',

                      style:
                      const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),

                      onTap: () =>
                          _removeItem(
                            item.cartItemId,
                          ),

                      child: Container(
                        padding:
                        const EdgeInsets.all(
                          7,
                        ),

                        decoration:
                        BoxDecoration(
                          color: const Color(
                            0xFFF5E1DE,
                          ),

                          shape:
                          BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.delete_outline,
                          color:
                          Colors.red,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutSection(
      CartProvider cart,
      ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          14,
          20,
          16,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.08,
              ),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),

        child: Row(
          children: [
            // TOTAL
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                mainAxisSize:
                MainAxisSize.min,

                children: [
                  const Text(
                    'Total',

                    style: TextStyle(
                      color:
                      Color(0xFF5C625B),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '\$${cart.total.toStringAsFixed(2)}',

                    style:
                    const TextStyle(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      primaryGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // CHECKOUT BUTTON
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                    const CheckoutScreen(),
                  ),
                );
              },

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                accentOrange,

                foregroundColor:
                Colors.white,

                elevation: 0,

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),

              child: const Text(
                'Checkout',

                style: TextStyle(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: lightCream,

      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 36,
          color: primaryGreen,
        ),
      ),
    );
  }
}