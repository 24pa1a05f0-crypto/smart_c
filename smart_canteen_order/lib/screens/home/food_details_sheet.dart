import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/food_item.dart';
import '../../providers/cart_provider.dart';

class FoodDetailsSheet extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailsSheet({super.key, required this.foodItem});

  @override
  State<FoodDetailsSheet> createState() => _FoodDetailsSheetState();
}

class _FoodDetailsSheetState extends State<FoodDetailsSheet> {
  int _quantity = 1;
  final Set<String> _selectedAddonIds = {};
  final _instructionsController = TextEditingController();

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double get _currentTotalPrice {
    double base = widget.foodItem.price;
    for (final addon in widget.foodItem.availableAddons) {
      if (_selectedAddonIds.contains(addon.id)) {
        base += addon.price;
      }
    }
    return base * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: widget.foodItem.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(Icons.fastfood, size: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category & Veg Tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.foodItem.isVeg ? AppColors.vegBg : AppColors.nonVegBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.foodItem.isVeg ? '🟢 100% VEGETARIAN' : '🔴 NON-VEG',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: widget.foodItem.isVeg ? AppColors.veg : AppColors.nonVeg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.foodItem.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.foodItem.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' (${widget.foodItem.reviewsCount})',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.foodItem.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${AppConstants.currencySymbol}${widget.foodItem.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Text(
                    widget.foodItem.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // Nutrition & Prep Info Badges
                  Row(
                    children: [
                      _buildInfoBadge(Icons.timer_outlined, '${widget.foodItem.prepTimeMinutes} mins', 'Ready in'),
                      const SizedBox(width: 10),
                      _buildInfoBadge(Icons.local_fire_department_outlined, '${widget.foodItem.calories} kcal', 'Calories'),
                      const SizedBox(width: 10),
                      _buildInfoBadge(Icons.verified_outlined, 'Fresh Made', 'Kitchen Quality'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Allergens
                  if (widget.foodItem.allergens.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          'Contains: ${widget.foodItem.allergens.join(", ")}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Custom Add-ons
                  if (widget.foodItem.availableAddons.isNotEmpty) ...[
                    const Text(
                      'Customize & Extras',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final addon in widget.foodItem.availableAddons)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _selectedAddonIds.contains(addon.id),
                        title: Text(addon.name, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(
                          '+${AppConstants.currencySymbol}${addon.price.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        activeColor: AppColors.primary,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedAddonIds.add(addon.id);
                            } else {
                              _selectedAddonIds.remove(addon.id);
                            }
                          });
                        },
                      ),
                    const SizedBox(height: 12),
                  ],

                  // Special Instructions
                  const Text(
                    'Cooking Instructions (Optional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Less spicy, pack chutney separately...',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Fixed Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                // Quantity Stepper
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18, color: AppColors.primary),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Add to Cart Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedAddonsList = widget.foodItem.availableAddons
                          .where((a) => _selectedAddonIds.contains(a.id))
                          .toList();

                      cart.addToCart(
                        widget.foodItem,
                        quantity: _quantity,
                        selectedAddons: selectedAddonsList,
                        specialInstructions: _instructionsController.text.trim(),
                      );

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${_quantity}x ${widget.foodItem.name} to cart!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Add to Cart • ${AppConstants.currencySymbol}${_currentTotalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
  }

  Widget _buildInfoBadge(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

