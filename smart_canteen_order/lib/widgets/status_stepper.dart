import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/order_model.dart';

class StatusStepper extends StatelessWidget {
  final OrderStatus currentStatus;

  const StatusStepper({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStatus == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.nonVegBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.nonVeg.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: AppColors.nonVeg),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'This order was cancelled. Any debited amount has been refunded to your wallet.',
                style: TextStyle(color: AppColors.nonVeg, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      {'title': 'Placed', 'subtitle': 'Order Received', 'icon': Icons.receipt_long},
      {'title': 'Preparing', 'subtitle': 'In Kitchen', 'icon': Icons.soup_kitchen},
      {'title': 'Ready', 'subtitle': 'At Counter', 'icon': Icons.fastfood},
      {'title': 'Collected', 'subtitle': 'Done', 'icon': Icons.check_circle_outline},
    ];

    int activeIndex = 0;
    switch (currentStatus) {
      case OrderStatus.placed:
        activeIndex = 0;
        break;
      case OrderStatus.preparing:
        activeIndex = 1;
        break;
      case OrderStatus.ready:
        activeIndex = 2;
        break;
      case OrderStatus.completed:
        activeIndex = 3;
        break;
      case OrderStatus.cancelled:
        activeIndex = -1;
        break;
    }

    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              // Divider line
              final stepIndex = index ~/ 2;
              final isPassed = stepIndex < activeIndex;

              return Expanded(
                child: Container(
                  height: 3,
                  color: isPassed ? AppColors.primary : AppColors.borderLight,
                ),
              );
            } else {
              // Step circle
              final stepIndex = index ~/ 2;
              final isPassed = stepIndex < activeIndex;
              final isCurrent = stepIndex == activeIndex;
              final item = steps[stepIndex];

              return Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : isPassed
                              ? AppColors.primaryDark
                              : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        isPassed ? Icons.check : (item['icon'] as IconData),
                        size: 18,
                        color: isCurrent || isPassed ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    item['subtitle'] as String,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              );
            }
          }),
        ),
      ],
    );
  }
}

