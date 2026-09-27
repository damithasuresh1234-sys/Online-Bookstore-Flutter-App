import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../widgets/status_badge.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<BookOrder> _orders = [];
  bool _isLoading = true;
  String? _error;

  final _statusFlow = ['pending', 'processing', 'shipped', 'completed', 'cancelled'];

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
      setState(() => _orders = data.map((e) => BookOrder.fromJson(e)).toList());
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to load orders.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(BookOrder order, String newStatus) async {
    try {
      await ApiService.updateOrderStatus(order.id, newStatus);
      _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _orders.isEmpty
                  ? ListView(children: const [SizedBox(height: 120), Center(child: Text('No orders yet.'))])
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          child: ExpansionTile(
                            title: Text('Order #${order.id} — ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${order.createdAt}  •  \$${order.totalAmount.toStringAsFixed(2)}'),
                            trailing: StatusBadge(status: order.status),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Customer: ${order.customerEmail}', style: TextStyle(color: Colors.grey.shade700)),
                                    Text('Ship to: ${order.shippingAddress}', style: TextStyle(color: Colors.grey.shade700)),
                                    const SizedBox(height: 8),
                                    ...order.items.map((item) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Row(
                                            children: [
                                              Expanded(child: Text('${item.titleSnapshot} x${item.quantity}')),
                                              Text('\$${(item.priceSnapshot * item.quantity).toStringAsFixed(2)}'),
                                            ],
                                          ),
                                        )),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Text('Update status:', style: TextStyle(fontWeight: FontWeight.w500)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            initialValue: order.status,
                                            isExpanded: true,
                                            items: _statusFlow
                                                .map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1))))
                                                .toList(),
                                            onChanged: (newStatus) {
                                              if (newStatus != null && newStatus != order.status) {
                                                _updateStatus(order, newStatus);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
