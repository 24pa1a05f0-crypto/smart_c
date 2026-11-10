import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/food_item.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddFoodItemDialog(BuildContext context) {
    final menu = Provider.of<MenuProvider>(context, listen: false);

    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final imageController = TextEditingController(
      text: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
    );
    final prepTimeController = TextEditingController(text: '10');
    final caloriesController = TextEditingController(text: '350');
    String category = 'Snacks';
    bool isVeg = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Add New Menu Item'),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Dish Name'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Price (₹)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: AppConstants.categories
                              .where((c) => c != 'All')
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => category = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description / Ingredients'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: prepTimeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Prep Time (mins)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: caloriesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Vegetarian Dish'),
                    subtitle: Text(isVeg ? '🟢 Pure Veg' : '🔴 Non-Veg'),
                    value: isVeg,
                    activeColor: AppColors.veg,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setModalState(() => isVeg = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0.0;
                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid dish name and price')),
                  );
                  return;
                }

                final newItem = FoodItem(
                  id: 'dish_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  category: category,
                  description: descController.text.trim(),
                  price: price,
                  imageUrl: imageController.text.trim(),
                  isVeg: isVeg,
                  prepTimeMinutes: int.tryParse(prepTimeController.text) ?? 10,
                  calories: int.tryParse(caloriesController.text) ?? 350,
                  rating: 4.8,
                  reviewsCount: 1,
                  tags: ['Newly Added'],
                );

                menu.addFoodItem(newItem);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "$name" to the canteen menu!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: const Text('Add to Menu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.soup_kitchen, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Canteen Admin Portal'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              icon: const Icon(Icons.table_restaurant),
              text: 'Kitchen KDS (${orderProv.orders.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).length})',
            ),
            const Tab(
              icon: Icon(Icons.menu_book),
              text: 'Menu & Stock',
            ),
            const Tab(
              icon: Icon(Icons.analytics_outlined),
              text: 'Stats & Slots',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKitchenOrdersTab(context),
          _buildMenuManagementTab(context),
          _buildAnalyticsTab(context),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddFoodItemDialog(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Dish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  // --- TAB 1: KITCHEN DISPLAY SYSTEM (KDS) ORDERS ---
  Widget _buildKitchenOrdersTab(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final orders = orderProv.orders;

    if (orders.isEmpty) {
      return const Center(child: Text('No kitchen orders placed yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: order.status == OrderStatus.ready
                  ? AppColors.primary
                  : order.status == OrderStatus.preparing
                      ? AppColors.statusPreparing
                      : AppColors.borderLight,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.orderToken,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        order.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.statusDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: order.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Pickup Details
              Text(
                'Pickup Slot: ${order.pickupSlot.label} • ${order.pickupCounter}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              const Divider(height: 18),

              // Items Checklist
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check_box_outline_blank, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${item.quantity}x ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Expanded(
                        child: Text(
                          item.foodItem.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (item.specialInstructions.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.specialInstructions,
                            style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // Kitchen Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status == OrderStatus.placed)
                    ElevatedButton.icon(
                      onPressed: () {
                        orderProv.updateOrderStatus(order.id, OrderStatus.preparing);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order ${order.orderToken} marked as In Kitchen Prep!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusPreparing),
                      icon: const Icon(Icons.soup_kitchen, size: 16),
                      label: const Text('Start Cooking'),
                    ),
                  if (order.status == OrderStatus.preparing)
                    ElevatedButton.icon(
                      onPressed: () {
                        orderProv.updateOrderStatus(order.id, OrderStatus.ready);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order ${order.orderToken} is READY for pickup!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Mark Ready at Counter'),
                    ),
                  if (order.status == OrderStatus.ready)
                    ElevatedButton.icon(
                      onPressed: () {
                        orderProv.updateOrderStatus(order.id, OrderStatus.completed);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order ${order.orderToken} marked Completed!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Mark Collected'),
                    ),
                  if (order.status == OrderStatus.completed)
                    const Text('Order Fulfilled', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: MENU & STOCK MANAGEMENT ---
  Widget _buildMenuManagementTab(BuildContext context) {
    final menu = Provider.of<MenuProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Menu Catalog (${menu.allItems.length} items)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddFoodItemDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Dish'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: menu.allItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = menu.allItems[index];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    // Veg indicator
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.isVeg ? AppColors.veg : AppColors.nonVeg,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title & Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${item.category} • ${AppConstants.currencySymbol}${item.price.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    // Stock toggle switch
                    Row(
                      children: [
                        Text(
                          item.isAvailable ? 'In Stock' : 'Sold Out',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.isAvailable ? AppColors.primary : Colors.red,
                          ),
                        ),
                        Switch(
                          value: item.isAvailable,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            menu.toggleAvailability(item.id, val);
                          },
                        ),
                      ],
                    ),

                    // Delete item button
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Menu Item?'),
                            content: Text('Remove "${item.name}" from the menu?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () {
                                  menu.deleteFoodItem(item.id);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- TAB 3: STATS & PICKUP SLOTS ---
  Widget _buildAnalyticsTab(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final totalRevenue = orderProv.todayRevenue;
    final totalOrders = orderProv.orders.length;
    final activeOrders = orderProv.orders.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Metric Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Revenue',
                  '${AppConstants.currencySymbol}${totalRevenue.toStringAsFixed(0)}',
                  Icons.currency_rupee,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Active Orders',
                  '$activeOrders',
                  Icons.soup_kitchen,
                  AppColors.statusPreparing,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Total Served',
                  '$totalOrders',
                  Icons.receipt,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pickup Slots Occupancy Monitor
          const Text('Live Pickup Slot Load & Capacity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Monitor canteen rush to avoid pickup counter congestion',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                for (final slot in orderProv.slots) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${slot.label} (${slot.period})',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              '${slot.bookedOrders}/${slot.maxCapacity} booked (${(slot.occupancyRatio * 100).toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: slot.occupancyRatio > 0.8 ? Colors.red : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: slot.occupancyRatio.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.shade200,
                            color: slot.occupancyRatio > 0.8
                                ? Colors.red
                                : slot.occupancyRatio > 0.5
                                    ? Colors.amber
                                    : AppColors.primary,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (slot != orderProv.slots.last) const Divider(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

