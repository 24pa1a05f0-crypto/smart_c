import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/pickup_slot.dart';

class PickupSlotPicker extends StatelessWidget {
  final List<PickupSlot> slots;
  final PickupSlot? selectedSlot;
  final ValueChanged<PickupSlot> onSlotSelected;

  const PickupSlotPicker({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final periods = slots.map((s) => s.period).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Select Pickup Time Slot',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '⚡ Zero Wait Time',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Your food will be hot and packed ready at your selected time.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),

        // List each period
        for (final period in periods) ...[
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  period,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.where((s) => s.period == period).length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 74,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final slot = slots.where((s) => s.period == period).toList()[index];
              final isSelected = selectedSlot?.id == slot.id;
              final isFull = !slot.isAvailable;

              return InkWell(
                onTap: isFull ? null : () => onSlotSelected(slot),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySubtle
                        : isFull
                            ? Colors.grey.shade100
                            : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isFull
                              ? Colors.grey.shade300
                              : AppColors.borderLight,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.access_time,
                            size: 15,
                            color: isSelected
                                ? AppColors.primary
                                : isFull
                                    ? Colors.grey
                                    : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              slot.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isFull ? Colors.grey : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        slot.availabilityStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isFull
                              ? Colors.red.shade400
                              : slot.availableSlots <= 3
                                  ? Colors.amber.shade800
                                  : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

