import '../../data/models/trip_model.dart';

abstract class TripRepository {
  Future<TripModel> createTrip(TripModel trip);
  Future<TripModel> updateTrip(TripModel trip);
  Future<void> deleteTrip(String tripId);
  Future<List<TripModel>> getUserTrips(String userId);
}
