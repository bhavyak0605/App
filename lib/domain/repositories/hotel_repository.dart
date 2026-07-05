import '../../data/models/hotel_model.dart';

abstract class HotelRepository {
  Future<List<HotelModel>> getHotelsForDestination(String destinationId);
  Future<List<HotelModel>> getAllHotels();
  Future<HotelModel?> getHotelDetails(String hotelId);
}
