import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/staff/staff_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'theme.dart';

void main() {
  runApp(const BookstoreApp());
}

class BookstoreApp extends StatelessWidget {
  const BookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Online Bookstore',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const RootRouter(),
      ),
    );
  }
}

/// Decides which screen to show based on auth state and user role.
class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    switch (auth.user!.role) {
      case UserRole.admin:
        return const AdminDashboardScreen();
      case UserRole.staff:
        return const StaffDashboardScreen();
      case UserRole.customer:
        return const CustomerHomeScreen();
    }
  }
}
