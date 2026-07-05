import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/trip_repository.dart';
import '../models/trip_model.dart';

class FirebaseTripRepository implements TripRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<TripModel> createTrip(TripModel trip) async {
    final docRef = _firestore.collection('trips').doc();
    final newTrip = TripModel(
      id: docRef.id,
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
    await docRef.set(newTrip.toMap());
    return newTrip;
  }

  @override
  Future<TripModel> updateTrip(TripModel trip) async {
    await _firestore.collection('trips').doc(trip.id).update(trip.toMap());
    return trip;
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).delete();
  }

  @override
  Future<List<TripModel>> getUserTrips(String userId) async {
    final querySnapshot = await _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: false)
        .get();
    return querySnapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
  }
}
