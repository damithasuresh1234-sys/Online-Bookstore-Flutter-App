import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../widgets/status_badge.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // APP COLORS
  static const Color primaryGreen = Color(0xFF3F5F54);
  static const Color lightCream = Color(0xFFE8E5DB);
  static const Color accentOrange = Color(0xFFD98E4A);
  static const Color textGrey = Color(0xFF5C625B);

  List<BookOrder> _orders = [];

  bool _isLoading = true;
  String? _error;

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
      final data = await ApiService.listOrders();

      setState(() {
        _orders = data
            .map((e) => BookOrder.fromJson(e))
            .toList();
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),

      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: _load,

        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: primaryGreen,
          ),
        )
            : _error != null
            ? _buildError()
            : _orders.isEmpty
            ? _buildEmptyOrders()
            : _buildOrdersList(),
      ),
    );
  }

  // ERROR STATE
  Widget _buildError() {
    return ListView(
      children: [
        const SizedBox(height: 120),

        Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: primaryGreen,
              ),

              const SizedBox(height: 16),

              Text(
                _error ?? 'Something went wrong.',

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: textGrey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _load,

                icon: const Icon(
                  Icons.refresh,
                ),

                label: const Text(
                  'Try Again',
                ),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  accentOrange,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // EMPTY STATE
  Widget _buildEmptyOrders() {
    return ListView(
      children: [
        const SizedBox(height: 120),

        const Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 70,
                color: primaryGreen,
              ),

              SizedBox(height: 16),

              Text(
                'No orders yet',

                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.bold,
                  color: primaryGreen,
                ),
              ),

              SizedBox(height: 6),

              Text(
                'You have not placed any orders yet.',

                style: TextStyle(
                  color: textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ORDERS LIST
  Widget _buildOrdersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),

      itemCount: _orders.length,

      separatorBuilder: (_, __) =>
      const SizedBox(height: 12),

      itemBuilder: (context, index) {
        final order = _orders[index];

        return Card(
          elevation: 2,

          color: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),

          clipBehavior:
          Clip.antiAlias,

          child: ExpansionTile(
            tilePadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            childrenPadding:
            EdgeInsets.zero,

            iconColor:
            primaryGreen,

            collapsedIconColor:
            textGrey,

            title: Text(
              'Order #${order.id}',

              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
                fontSize: 16,
                color:
                primaryGreen,
              ),
            ),

            subtitle: Padding(
              padding:
              const EdgeInsets.only(
                top: 5,
              ),

              child: Text(
                '${order.createdAt}  •  \$${order.totalAmount.toStringAsFixed(2)}',

                style:
                const TextStyle(
                  color: textGrey,
                  fontSize: 13,
                ),
              ),
            ),

            trailing: StatusBadge(
              status:
              order.status,
            ),

            children: [
              Container(
                width: double.infinity,

                color: lightCream,

                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  16,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    // SHIPPING ADDRESS
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 19,
                          color:
                          primaryGreen,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Expanded(
                          child: Text(
                            order.shippingAddress,

                            style:
                            const TextStyle(
                              color:
                              textGrey,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    const Text(
                      'Items',

                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        color:
                        primaryGreen,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // ORDER ITEMS
                    ...order.items.map(
                          (item) => Container(
                        margin:
                        const EdgeInsets.only(
                          bottom: 6,
                        ),

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                            10,
                          ),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              size: 17,
                              color:
                              primaryGreen,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Expanded(
                              child: Text(
                                '${item.titleSnapshot} x${item.quantity}',

                                maxLines:
                                2,

                                overflow:
                                TextOverflow.ellipsis,

                                style:
                                const TextStyle(
                                  color:
                                  textGrey,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Text(
                              '\$${(item.priceSnapshot * item.quantity).toStringAsFixed(2)}',

                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.w600,
                                color:
                                primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}