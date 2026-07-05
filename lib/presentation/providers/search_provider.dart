import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/destination_model.dart';
import '../../data/repositories/service_locator.dart';

class SearchProvider extends ChangeNotifier {
  static const String _prefRecentSearchKey = 'ezztrip_recent_searches';

  List<DestinationModel> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter criteria
  double? _maxBudget;
  double? _minRating;
  String? _selectedCategoryId;

  List<DestinationModel> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double? get maxBudget => _maxBudget;
  double? get minRating => _minRating;
  String? get selectedCategoryId => _selectedCategoryId;

  SearchProvider() {
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList(_prefRecentSearchKey) ?? [];
    notifyListeners();
  }

  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final term = query.trim();
    _recentSearches.remove(term); // Avoid duplicates
    _recentSearches.insert(0, term);
    
    if (_recentSearches.length > 6) {
      _recentSearches = _recentSearches.sublist(0, 6);
    }
    
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefRecentSearchKey, _recentSearches);
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefRecentSearchKey);
  }

  void setFilters({double? maxBudget, double? minRating, String? categoryId}) {
    _maxBudget = maxBudget;
    _minRating = minRating;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void clearFilters() {
    _maxBudget = null;
    _minRating = null;
    _selectedCategoryId = null;
    notifyListeners();
  }

  Future<void> performSearch(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await locator.destinationRepository.searchDestinations(query);
      
      // Apply Client-Side Filters
      _searchResults = results.where((d) {
        if (_maxBudget != null && d.estimatedBudget > _maxBudget!) return false;
        if (_minRating != null && d.rating < _minRating!) return false;
        if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty && d.categoryId != _selectedCategoryId) return false;
        return true;
      }).toList();

      if (query.trim().isNotEmpty) {
        await addRecentSearch(query);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
