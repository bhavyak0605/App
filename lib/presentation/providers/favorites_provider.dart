import 'package:flutter/material.dart';
import '../../data/repositories/service_locator.dart';

class FavoritesProvider extends ChangeNotifier {
  List<String> _favDestIds = [];
  List<String> _favHotelIds = [];
  List<String> _favPkgIds = [];
  
  bool _isLoading = false;

  List<String> get favDestIds => _favDestIds;
  List<String> get favHotelIds => _favHotelIds;
  List<String> get favPkgIds => _favPkgIds;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        locator.favoritesRepository.getFavoriteDestinations(userId),
        locator.favoritesRepository.getFavoriteHotels(userId),
        locator.favoritesRepository.getFavoritePackages(userId),
      ]);

      _favDestIds = results[0];
      _favHotelIds = results[1];
      _favPkgIds = results[2];
    } catch (e) {
      print("Error loading favorites: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isDestFav(String destinationId) => _favDestIds.contains(destinationId);
  bool isHotelFav(String hotelId) => _favHotelIds.contains(hotelId);
  bool isPkgFav(String packageId) => _favPkgIds.contains(packageId);

  Future<void> toggleDestinationFav(String userId, String destinationId) async {
    try {
      if (_favDestIds.contains(destinationId)) {
        _favDestIds.remove(destinationId);
      } else {
        _favDestIds.add(destinationId);
      }
      notifyListeners(); // Immediate UI update for Snappy responsiveness
      await locator.favoritesRepository.toggleFavoriteDestination(userId, destinationId);
    } catch (e) {
      print("Toggle dest favorite error: $e");
    }
  }

  Future<void> toggleHotelFav(String userId, String hotelId) async {
    try {
      if (_favHotelIds.contains(hotelId)) {
        _favHotelIds.remove(hotelId);
      } else {
        _favHotelIds.add(hotelId);
      }
      notifyListeners();
      await locator.favoritesRepository.toggleFavoriteHotel(userId, hotelId);
    } catch (e) {
      print("Toggle hotel favorite error: $e");
    }
  }

  Future<void> togglePackageFav(String userId, String packageId) async {
    try {
      if (_favPkgIds.contains(packageId)) {
        _favPkgIds.remove(packageId);
      } else {
        _favPkgIds.add(packageId);
      }
      notifyListeners();
      await locator.favoritesRepository.toggleFavoritePackage(userId, packageId);
    } catch (e) {
      print("Toggle package favorite error: $e");
    }
  }
}
