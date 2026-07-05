import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/favorites_repository.dart';

class MockFavoritesRepository implements FavoritesRepository {
  static const String _prefDestKey = 'ezztrip_fav_destinations';
  static const String _prefHotelKey = 'ezztrip_fav_hotels';
  static const String _prefPkgKey = 'ezztrip_fav_packages';

  Future<List<String>> _getSavedList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> _saveList(String key, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, list);
  }

  @override
  Future<List<String>> getFavoriteDestinations(String userId) async {
    return _getSavedList('${_prefDestKey}_$userId');
  }

  @override
  Future<List<String>> getFavoriteHotels(String userId) async {
    return _getSavedList('${_prefHotelKey}_$userId');
  }

  @override
  Future<List<String>> getFavoritePackages(String userId) async {
    return _getSavedList('${_prefPkgKey}_$userId');
  }

  @override
  Future<void> toggleFavoriteDestination(String userId, String destinationId) async {
    final key = '${_prefDestKey}_$userId';
    final current = await _getSavedList(key);
    if (current.contains(destinationId)) {
      current.remove(destinationId);
    } else {
      current.add(destinationId);
    }
    await _saveList(key, current);
  }

  @override
  Future<void> toggleFavoriteHotel(String userId, String hotelId) async {
    final key = '${_prefHotelKey}_$userId';
    final current = await _getSavedList(key);
    if (current.contains(hotelId)) {
      current.remove(hotelId);
    } else {
      current.add(hotelId);
    }
    await _saveList(key, current);
  }

  @override
  Future<void> toggleFavoritePackage(String userId, String packageId) async {
    final key = '${_prefPkgKey}_$userId';
    final current = await _getSavedList(key);
    if (current.contains(packageId)) {
      current.remove(packageId);
    } else {
      current.add(packageId);
    }
    await _saveList(key, current);
  }

  @override
  Future<bool> isFavoriteDestination(String userId, String destinationId) async {
    final list = await getFavoriteDestinations(userId);
    return list.contains(destinationId);
  }

  @override
  Future<bool> isFavoriteHotel(String userId, String hotelId) async {
    final list = await getFavoriteHotels(userId);
    return list.contains(hotelId);
  }

  @override
  Future<bool> isFavoritePackage(String userId, String packageId) async {
    final list = await getFavoritePackages(userId);
    return list.contains(packageId);
  }
}
