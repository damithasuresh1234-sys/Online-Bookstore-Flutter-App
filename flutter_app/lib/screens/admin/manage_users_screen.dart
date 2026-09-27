import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  final _roles = ['customer', 'staff', 'admin'];

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
      final data = await ApiService.listUsers();
      setState(() => _users = data.cast<Map<String, dynamic>>());
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to load users.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changeRole(Map<String, dynamic> user, String newRole) async {
    try {
      await ApiService.updateUserRole(user['id'], newRole);
      _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user!.id;

    return RefreshIndicator(
      onRefresh: _load,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final isSelf = user['id'] == currentUserId;
                    return Card(
                      child: ListTile(
                        title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(user['email']),
                        trailing: SizedBox(
                          width: 150,
                          child: DropdownButtonFormField<String>(
                            initialValue: user['role'],
                            isExpanded: true,
                            decoration: const InputDecoration(isDense: true),
                            items: _roles
                                .map((r) => DropdownMenuItem(value: r, child: Text(roleToLabel(roleFromString(r)))))
                                .toList(),
                            onChanged: isSelf
                                ? null
                                : (newRole) {
                                    if (newRole != null && newRole != user['role']) {
                                      _changeRole(user, newRole);
                                    }
                                  },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
