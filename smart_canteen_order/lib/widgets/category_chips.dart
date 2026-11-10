import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All':
        return Icons.restaurant_menu;
      case 'Breakfast':
        return Icons.breakfast_dining;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Snacks':
        return Icons.tapas;
      case 'Beverages':
        return Icons.local_cafe;
      case 'Desserts':
        return Icons.icecream;
      case 'Daily Specials':
        return Icons.local_fire_department;
      default:
        return Icons.fastfood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = AppConstants.categories[index];
          final isSelected = cat == selectedCategory;

          return ChoiceChip(
            showCheckmark: false,
            avatar: Icon(
              _getCategoryIcon(cat),
              size: 16,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            label: Text(cat),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: Theme.of(context).cardColor,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : null,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onSelected: (selected) {
              if (selected) {
                onSelected(cat);
              }
            },
          );
        },
      ),
    );
  }
}

