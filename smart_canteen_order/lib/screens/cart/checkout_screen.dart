import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/pickup_slot.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/pickup_slot_picker.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = AppConstants.paymentMethods.first;
  PickupSlot? _selectedSlot;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    _selectedSlot = orderProv.selectedSlot;
  }

  void _handlePlaceOrder() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProv = Provider.of<OrderProvider>(context, listen: false);

    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to place your order')),
      );
      return;
    }

    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup time slot')),
      );
      return;
    }

    // Wallet balance check if wallet payment selected
    if (_selectedPaymentMethod == 'Campus Wallet') {
      if (auth.user!.walletBalance < cart.grandTotal) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Insufficient Wallet Balance'),
            content: Text(
              'Your wallet balance is ${AppConstants.currencySymbol}${auth.user!.walletBalance.toStringAsFixed(2)}, but order total is ${AppConstants.currencySymbol}${cart.grandTotal.toStringAsFixed(2)}.\n\nWould you like to top-up ₹500 now?',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  auth.topUpWallet(500.0);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added ₹500 to Campus Wallet!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: const Text('Top-up ₹500'),
              ),
            ],
          ),
        );
        return;
      }

      // Deduct wallet
      await auth.deductWallet(cart.grandTotal);
    }

    setState(() => _isSubmitting = true);

    try {
      final order = await orderProv.placeOrder(
        user: auth.user!,
        cart: cart,
        slot: _selectedSlot!,
        paymentMethod: _selectedPaymentMethod,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup & Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Slot Picker
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: PickupSlotPicker(
                    slots: orderProv.slots,
                    selectedSlot: _selectedSlot,
                    onSlotSelected: (slot) {
                      setState(() {
                        _selectedSlot = slot;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Method
                Container(
                  padding: const EdgeInsets.all(18),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.payment, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Select Payment Method',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final method in AppConstants.paymentMethods)
                        RadioListTile<String>(
                          value: method,
                          groupValue: _selectedPaymentMethod,
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Text(method, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              if (method == 'Campus Wallet') ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySubtle,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Bal: ${AppConstants.currencySymbol}${auth.user?.walletBalance.toStringAsFixed(0) ?? "0"}',
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedPaymentMethod = val);
                            }
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Order Review Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Items:', style: TextStyle(color: Colors.grey)),
                          Text('${cart.itemCount} items', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Selected Pickup:', style: TextStyle(color: Colors.grey)),
                          Text(
                            _selectedSlot?.label ?? 'None selected',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Payable:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '${AppConstants.currencySymbol}${cart.grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Place Order Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handlePlaceOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          'Confirm & Place Order (${AppConstants.currencySymbol}${cart.grandTotal.toStringAsFixed(0)})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

