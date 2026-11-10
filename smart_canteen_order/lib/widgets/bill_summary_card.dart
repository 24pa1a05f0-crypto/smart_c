import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class BillSummaryCard extends StatelessWidget {
  final double subtotal;
  final double discountAmount;
  final double packagingFee;
  final double taxAmount;
  final double grandTotal;
  final String? appliedCoupon;
  final VoidCallback? onRemoveCoupon;

  const BillSummaryCard({
    super.key,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.packagingFee = 10.0,
    required this.taxAmount,
    required this.grandTotal,
    this.appliedCoupon,
    this.onRemoveCoupon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildRow('Item Subtotal', subtotal),
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Coupon ($appliedCoupon)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (onRemoveCoupon != null) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onRemoveCoupon,
                        child: const Icon(Icons.close, size: 14, color: Colors.red),
                      ),
                    ],
                  ],
                ),
                Text(
                  '-${AppConstants.currencySymbol}${discountAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _buildRow('Packaging & Tray Fee', packagingFee),
          const SizedBox(height: 8),
          _buildRow('Canteen GST / Taxes (5%)', taxAmount),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${AppConstants.currencySymbol}${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          '${AppConstants.currencySymbol}${value.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

