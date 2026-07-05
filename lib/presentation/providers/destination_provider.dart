import 'package:flutter/material.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/package_model.dart';
import '../../data/models/hotel_model.dart';
import '../../data/repositories/service_locator.dart';

class DestinationProvider extends ChangeNotifier {
  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  List<DestinationModel> _featuredDestinations = [];
  List<PackageModel> _packages = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  List<BannerModel> get banners => _banners;
  List<CategoryModel> get categories => _categories;
  List<DestinationModel> get featuredDestinations => _featuredDestinations;
  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cache for destination details
  final Map<String, List<ReviewModel>> _reviewsCache = {};
  final Map<String, List<HotelModel>> _hotelsCache = {};

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Parallel requests for efficiency
      final results = await Future.wait([
        locator.destinationRepository.getBanners(),
        locator.destinationRepository.getCategories(),
        locator.destinationRepository.getFeaturedDestinations(),
        locator.destinationRepository.getPackages(),
      ]);

      _banners = results[0] as List<BannerModel>;
      _categories = results[1] as List<CategoryModel>;
      _featuredDestinations = results[2] as List<DestinationModel>;
      _packages = results[3] as List<PackageModel>;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<List<ReviewModel>> loadDestinationReviews(String destinationId) async {
    if (_reviewsCache.containsKey(destinationId)) {
      return _reviewsCache[destinationId]!;
    }
    try {
      final reviews = await locator.destinationRepository.getDestinationReviews(destinationId);
      _reviewsCache[destinationId] = reviews;
      return reviews;
    } catch (_) {
      return [];
    }
  }

  Future<List<HotelModel>> loadHotelsForDestination(String destinationId) async {
    if (_hotelsCache.containsKey(destinationId)) {
      return _hotelsCache[destinationId]!;
    }
    try {
      final hotels = await locator.hotelRepository.getHotelsForDestination(destinationId);
      _hotelsCache[destinationId] = hotels;
      return hotels;
    } catch (_) {
      return [];
    }
  }

  Future<List<DestinationModel>> getDestinationsByCategory(String categoryId) async {
    try {
      return await locator.destinationRepository.getDestinationsByCategory(categoryId);
    } catch (_) {
      return [];
    }
  }
}
