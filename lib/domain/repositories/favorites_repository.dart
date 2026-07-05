abstract class FavoritesRepository {
  Future<List<String>> getFavoriteDestinations(String userId);
  Future<List<String>> getFavoriteHotels(String userId);
  Future<List<String>> getFavoritePackages(String userId);
  
  Future<void> toggleFavoriteDestination(String userId, String destinationId);
  Future<void> toggleFavoriteHotel(String userId, String hotelId);
  Future<void> toggleFavoritePackage(String userId, String packageId);
  
  Future<bool> isFavoriteDestination(String userId, String destinationId);
  Future<bool> isFavoriteHotel(String userId, String hotelId);
  Future<bool> isFavoritePackage(String userId, String packageId);
}
