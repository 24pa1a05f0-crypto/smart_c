import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/theme_provider.dart';
import 'home/home_screen.dart';
import 'cart/cart_screen.dart';
import 'orders/order_history_screen.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class NavigationShell extends StatefulWidget {
  final int initialIndex;

  const NavigationShell({super.key, this.initialIndex = 0});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final orders = Provider.of<OrderProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    final activeOrdersCount = auth.user != null
        ? orders.getActiveOrdersForUser(auth.user!.uid).length
        : 0;

    final isWideScreen = MediaQuery.of(context).size.width >= 900;

    final pages = [
      const HomeScreen(),
      const CartScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
      const AdminDashboardScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Desktop / Web Side Navigation Rail
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              extended: MediaQuery.of(context).size.width >= 1200,
              minExtendedWidth: 220,
              backgroundColor: Theme.of(context).cardColor,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.restaurant, color: Colors.white, size: 22),
                      ),
                    ),
                    if (MediaQuery.of(context).size.width >= 1200) ...[
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Text(
                            'Campus Dining',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Theme Toggle
                        IconButton(
                          icon: Icon(
                            theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          ),
                          tooltip: 'Toggle Theme',
                          onPressed: () => theme.toggleTheme(),
                        ),
                        const SizedBox(height: 10),
                        // Quick Demo Role Switcher
                        Tooltip(
                          message: 'Switch to ${auth.isAdmin ? "Student" : "Admin"} mode',
                          child: InkWell(
                            onTap: () {
                              auth.switchDemoRole();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Switched to ${auth.isAdmin ? "Canteen Admin / Staff" : "Student Diner"} mode!',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: auth.isAdmin ? AppColors.secondarySubtle : AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                auth.isAdmin ? 'STAFF' : 'STUDENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: auth.isAdmin ? AppColors.secondary : AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu, color: AppColors.primary),
                  label: Text('Food Menu'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: cart.itemCount > 0,
                    label: Text('${cart.itemCount}'),
                    backgroundColor: AppColors.secondary,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cart.itemCount > 0,
                    label: Text('${cart.itemCount}'),
                    backgroundColor: AppColors.secondary,
                    child: const Icon(Icons.shopping_bag, color: AppColors.primary),
                  ),
                  label: Text('Cart (${cart.itemCount})'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: activeOrdersCount > 0,
                    label: Text('$activeOrdersCount'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: activeOrdersCount > 0,
                    label: Text('$activeOrdersCount'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long, color: AppColors.primary),
                  ),
                  label: const Text('My Orders'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.primary),
                  label: Text('Profile'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                  label: Text('Kitchen Admin'),
                ),
              ],
            ),

          // Main View Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),

      // Mobile Bottom Navigation Bar
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              indicatorColor: AppColors.primarySubtle,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu, color: AppColors.primary),
                  label: 'Menu',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cart.itemCount > 0,
                    label: Text('${cart.itemCount}'),
                    backgroundColor: AppColors.secondary,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cart.itemCount > 0,
                    label: Text('${cart.itemCount}'),
                    backgroundColor: AppColors.secondary,
                    child: const Icon(Icons.shopping_bag, color: AppColors.primary),
                  ),
                  label: 'Cart',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: activeOrdersCount > 0,
                    label: Text('$activeOrdersCount'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: activeOrdersCount > 0,
                    label: Text('$activeOrdersCount'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long, color: AppColors.primary),
                  ),
                  label: 'Orders',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.primary),
                  label: 'Profile',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                  label: 'Admin',
                ),
              ],
            ),
    );
  }
}

