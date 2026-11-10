import 'package:flutter_test/flutter_test.dart';
import 'package:smart_canteen_order/models/food_item.dart';
import 'package:smart_canteen_order/providers/menu_provider.dart';

void main() {
  group('MenuProvider Filter Tests', () {
    late MenuProvider menu;

    setUp(() {
      menu = MenuProvider();
    });

    test('Loads initial menu items', () {
      expect(menu.allItems.isNotEmpty, isTrue);
    });

    test('Filter by category returns matching category items only', () {
      menu.setCategory('Breakfast');
      final breakfastItems = menu.filteredItems;

      expect(breakfastItems.every((i) => i.category == 'Breakfast'), isTrue);
    });

    test('Filter by Veg Only returns only vegetarian items', () {
      menu.toggleVegOnly(true);
      final vegItems = menu.filteredItems;

      expect(vegItems.every((i) => i.isVeg), isTrue);
    });

    test('Search query matches dish name', () {
      menu.setSearchQuery('Biryani');
      final searchResults = menu.filteredItems;

      expect(searchResults.any((i) => i.name.contains('Biryani')), isTrue);
    });
  });
}

