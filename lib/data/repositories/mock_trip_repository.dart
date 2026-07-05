import 'package:uuid/uuid.dart';
import '../../core/constants/app_assets.dart';
import '../../domain/repositories/trip_repository.dart';
import '../models/trip_model.dart';

class MockTripRepository implements TripRepository {
  final List<TripModel> _trips = [];
  final _uuid = const Uuid();

  MockTripRepository() {
    // Add default initial mock trips to make the dashboard feel populated
    _trips.addAll([
      TripModel(
        id: 'trip_default_1',
        userId: 'mock_user_123',
        destinationId: 'dest_kyoto',
        destinationName: 'Kyoto',
        destinationImage: AppAssets.destinationKyoto,
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 36)),
        budget: 2500.0,
        travelers: 2,
        notes: 'Explore temples, try local ramen, and photograph bamboo forests!',
        status: 'upcoming',
      ),
      TripModel(
        id: 'trip_default_2',
        userId: 'mock_user_123',
        destinationId: 'dest_paris',
        destinationName: 'Paris',
        destinationImage: AppAssets.destinationParis,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().subtract(const Duration(days: 55)),
        budget: 3200.0,
        travelers: 1,
        notes: 'Eiffel tower visit, Louvre museum tour. Loved local cafes!',
        status: 'completed',
      )
    ]);
  }

  @override
  Future<TripModel> createTrip(TripModel trip) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final newTrip = TripModel(
      id: 'trip_${_uuid.v4().substring(0, 8)}',
      userId: trip.userId,
      destinationId: trip.destinationId,
      destinationName: trip.destinationName,
      destinationImage: trip.destinationImage,
      startDate: trip.startDate,
      endDate: trip.endDate,
      budget: trip.budget,
      travelers: trip.travelers,
      notes: trip.notes,
      status: 'upcoming',
    );
    _trips.add(newTrip);
    return newTrip;
  }

  @override
  Future<TripModel> updateTrip(TripModel trip) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index != -1) {
      _trips[index] = trip;
      return trip;
    }
    throw Exception('Trip not found');
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _trips.removeWhere((t) => t.id == tripId);
  }

  @override
  Future<List<TripModel>> getUserTrips(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _trips.where((t) => t.userId == userId).toList();
  }
}
