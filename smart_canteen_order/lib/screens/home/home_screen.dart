import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/food_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/food_card.dart';
import '../../widgets/responsive_layout.dart';
import '../cart/cart_screen.dart';
import 'food_details_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showFoodDetails(BuildContext context, FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodDetailsSheet(foodItem: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = Provider.of<MenuProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    final filteredItems = menu.filteredItems;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.lunch_dining, color: AppColors.primary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${auth.user?.displayName.split(" ").first ?? "Diner"} 👋',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 2),
                          Text(
                            'Main Campus Canteen • Counter 1 & 2',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Wallet Chip
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 15, color: AppColors.primaryDark),
                      const SizedBox(width: 5),
                      Text(
                        '${AppConstants.currencySymbol}${auth.user?.walletBalance.toStringAsFixed(0) ?? "0"}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Search Bar & Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Search Field
                    TextField(
                      onChanged: (val) => menu.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search biryani, dosa, coffee, rolls...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        suffixIcon: menu.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => menu.setSearchQuery(''),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filters Row (Veg only toggle + Sort)
                    Row(
                      children: [
                        // Veg Toggle
                        FilterChip(
                          avatar: Icon(
                            Icons.circle,
                            size: 10,
                            color: menu.onlyVeg ? Colors.white : AppColors.veg,
                          ),
                          label: const Text('Veg Only', style: TextStyle(fontSize: 12)),
                          selected: menu.onlyVeg,
                          selectedColor: AppColors.veg,
                          labelStyle: TextStyle(
                            color: menu.onlyVeg ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (selected) => menu.toggleVegOnly(selected),
                        ),
                        const SizedBox(width: 8),

                        // Sort Dropdown
                        PopupMenuButton<SortOption>(
                          onSelected: (option) => menu.setSortOption(option),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: SortOption.popular,
                              child: Text('Top Rated / Popular'),
                            ),
                            const PopupMenuItem(
                              value: SortOption.priceLowToHigh,
                              child: Text('Price: Low to High'),
                            ),
                            const PopupMenuItem(
                              value: SortOption.priceHighToLow,
                              child: Text('Price: High to Low'),
                            ),
                            const PopupMenuItem(
                              value: SortOption.fastPrep,
                              child: Text('Fastest Preparation'),
                            ),
                          ],
                          child: Chip(
                            avatar: const Icon(Icons.sort, size: 14, color: AppColors.primary),
                            label: const Text('Sort', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            backgroundColor: Theme.of(context).cardColor,
                            side: const BorderSide(color: AppColors.borderLight),
                          ),
                        ),
                        const Spacer(),

                        // Item Count
                        Text(
                          '${filteredItems.length} dishes',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Promo Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF047857), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '🔥 SPECIAL PROMO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Flat 20% OFF Campus Meals!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Apply code STUDENT20 at checkout',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        cart.applyCoupon('STUDENT20');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coupon STUDENT20 copied & applied!'),
                            backgroundColor: AppColors.primaryDark,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('APPLY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

            // Categories horizontal list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CategoryChips(
                  selectedCategory: menu.selectedCategory,
                  onSelected: (cat) => menu.setCategory(cat),
                ),
              ),
            ),

            // Food Items Grid
            if (filteredItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 54, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'No matching food items found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try searching for another dish or clearing filters',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          menu.setCategory('All');
                          menu.setSearchQuery('');
                          menu.toggleVegOnly(false);
                        },
                        child: const Text('Reset All Filters'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveLayout.isDesktop(context)
                        ? 4
                        : ResponsiveLayout.isTablet(context)
                            ? 3
                            : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
                    childAspectRatio: ResponsiveLayout.isDesktop(context)
                        ? 0.76
                        : ResponsiveLayout.isTablet(context)
                            ? 0.78
                            : (MediaQuery.of(context).size.width > 500 ? 0.75 : 1.15),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      return FoodCard(
                        foodItem: item,
                        onTap: () => _showFoodDetails(context, item),
                      );
                    },
                    childCount: filteredItems.length,
                  ),
                ),
              ),

            // Extra padding at bottom for fab / navigation
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),

      // Floating Cart Preview on mobile
      floatingActionButton: cart.itemCount > 0 && !ResponsiveLayout.isDesktop(context)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: Text(
                'View Cart (${cart.itemCount}) • ${AppConstants.currencySymbol}${cart.grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
    );
  }
}

