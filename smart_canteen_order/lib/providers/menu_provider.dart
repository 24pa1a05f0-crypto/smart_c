import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/database_service.dart';

enum SortOption { popular, priceLowToHigh, priceHighToLow, fastPrep }

class MenuProvider extends ChangeNotifier {
  final DatabaseService _dbService;

  List<FoodItem> _allItems = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _onlyVeg = false;
  SortOption _currentSort = SortOption.popular;
  bool _isLoading = false;

  List<FoodItem> get allItems => _allItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get onlyVeg => _onlyVeg;
  SortOption get currentSort => _currentSort;
  bool get isLoading => _isLoading;

  MenuProvider({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService() {
    _init();
  }

  void _init() {
    _allItems = _dbService.getCachedMenu();
    notifyListeners();

    _dbService.menuStream.listen((items) {
      _allItems = items;
      notifyListeners();
    });
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleVegOnly(bool value) {
    _onlyVeg = value;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  List<FoodItem> get filteredItems {
    var items = List<FoodItem>.from(_allItems);

    // 1. Category Filter
    if (_selectedCategory != 'All') {
      items = items.where((i) => i.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    // 2. Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      items = items.where((i) {
        return i.name.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q) ||
            i.category.toLowerCase().contains(q) ||
            i.tags.any((tag) => tag.toLowerCase().contains(q));
      }).toList();
    }

    // 3. Veg Only Filter
    if (_onlyVeg) {
      items = items.where((i) => i.isVeg).toList();
    }

    // 4. Sorting
    switch (_currentSort) {
      case SortOption.popular:
        items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.priceLowToHigh:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.fastPrep:
        items.sort((a, b) => a.prepTimeMinutes.compareTo(b.prepTimeMinutes));
        break;
    }

    return items;
  }

  // --- Admin Actions ---
  Future<void> addFoodItem(FoodItem item) async {
    await _dbService.addMenuItem(item);
  }

  Future<void> updateFoodItem(FoodItem item) async {
    await _dbService.updateMenuItem(item);
  }

  Future<void> deleteFoodItem(String id) async {
    await _dbService.deleteMenuItem(id);
  }

  Future<void> toggleAvailability(String id, bool isAvailable) async {
    await _dbService.toggleItemAvailability(id, isAvailable);
  }
}

