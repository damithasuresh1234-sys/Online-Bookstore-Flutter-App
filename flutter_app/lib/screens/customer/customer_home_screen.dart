import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'browse_books_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // APP COLORS
  static const Color primaryGreen = Color(0xFF3F5F54);
  static const Color cream = Color(0xFFF7F6F3);
  static const Color lightCream = Color(0xFFE8E5DB);
  static const Color accentOrange = Color(0xFFD98E4A);
  static const Color textGrey = Color(0xFF5C625B);

  int _index = 0;

  final _screens = const [
    BrowseBooksScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,

        backgroundColor: Colors.white,

        indicatorColor: lightCream,

        surfaceTintColor: Colors.transparent,

        labelBehavior:
        NavigationDestinationLabelBehavior.alwaysShow,

        onDestinationSelected: (i) {
          setState(() {
            _index = i;
          });
        },

        destinations: [
          const NavigationDestination(
            icon: Icon(
              Icons.menu_book_outlined,
              color: textGrey,
            ),

            selectedIcon: Icon(
              Icons.menu_book,
              color: primaryGreen,
            ),

            label: 'Browse',
          ),

          NavigationDestination(
            icon: Badge(
              backgroundColor: accentOrange,

              textColor: Colors.white,

              label: Text(
                '${cart.itemCount}',
              ),

              isLabelVisible:
              cart.itemCount > 0,

              child: const Icon(
                Icons.shopping_cart_outlined,
                color: textGrey,
              ),
            ),

            selectedIcon: Badge(
              backgroundColor: accentOrange,

              textColor: Colors.white,

              label: Text(
                '${cart.itemCount}',
              ),

              isLabelVisible:
              cart.itemCount > 0,

              child: const Icon(
                Icons.shopping_cart,
                color: primaryGreen,
              ),
            ),

            label: 'Cart',
          ),

          const NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
              color: textGrey,
            ),

            selectedIcon: Icon(
              Icons.receipt_long,
              color: primaryGreen,
            ),

            label: 'Orders',
          ),

          const NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: textGrey,
            ),

            selectedIcon: Icon(
              Icons.person,
              color: primaryGreen,
            ),

            label: 'Profile',
          ),
        ],
      ),
    );
  }
}