import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  void _showReceiptDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Receipt ${order.orderToken}'),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Pickup Slot: ${order.pickupSlot.label}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Counter: ${order.pickupCounter}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(height: 20),
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.foodItem.name}',
                          style: const TextStyle(fontSize: 13)),
                      Text('${AppConstants.currencySymbol}${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('${AppConstants.currencySymbol}${order.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              if (order.discountAmount > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount:', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                    Text('-${AppConstants.currencySymbol}${order.discountAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tax (5%):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('${AppConstants.currencySymbol}${order.taxAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Paid:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('${AppConstants.currencySymbol}${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Payment via ${order.paymentMethod} • Status: ${order.paymentStatus}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _handleReorder(BuildContext context, OrderModel order) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    for (final item in order.items) {
      cart.addToCart(
        item.foodItem,
        quantity: item.quantity,
        selectedAddons: item.selectedAddons,
        specialInstructions: item.specialInstructions,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${order.items.length} items from ${order.orderToken} to cart!'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'GO TO CART',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    final userId = auth.user?.uid ?? '';
    final activeOrders = orderProv.getActiveOrdersForUser(userId);
    final pastOrders = orderProv.getPastOrdersForUser(userId);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Active Orders'),
                    if (activeOrders.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${activeOrders.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(text: 'Past Orders (${pastOrders.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(context, activeOrders, isActiveList: true),
            _buildOrderList(context, pastOrders, isActiveList: false),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderModel> list, {required bool isActiveList}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActiveList ? Icons.takeout_dining_outlined : Icons.history,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              isActiveList ? 'No active orders' : 'No past orders yet',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isActiveList
                  ? 'Your active orders will show live progress here.'
                  : 'Orders you have completed will appear here.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = list[index];

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        order.orderToken,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('hh:mm a').format(order.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
              const SizedBox(height: 10),

              // Items summary text
              Text(
                order.items.map((i) => '${i.quantity}x ${i.foodItem.name}').join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              // Slot & Counter
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Pickup: ${order.pickupSlot.label}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Text(
                    '${AppConstants.currencySymbol}${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Action buttons
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _showReceiptDialog(context, order),
                    icon: const Icon(Icons.receipt_outlined, size: 16),
                    label: const Text('Receipt', style: TextStyle(fontSize: 12)),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => _handleReorder(context, order),
                    icon: const Icon(Icons.replay, size: 14),
                    label: const Text('Reorder', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(orderId: order.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.my_location, size: 14),
                    label: const Text('Track Live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

