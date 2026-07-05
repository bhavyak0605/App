import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../models/hotel_model.dart';

class FirebaseHotelRepository implements HotelRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<HotelModel>> getHotelsForDestination(String destinationId) async {
    final querySnapshot = await _firestore
        .collection('hotels')
        .where('destinationId', isEqualTo: destinationId)
        .get();
    return querySnapshot.docs.map((doc) => HotelModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<HotelModel>> getAllHotels() async {
    final querySnapshot = await _firestore.collection('hotels').get();
    return querySnapshot.docs.map((doc) => HotelModel.fromFirestore(doc)).toList();
  }

  @override
  Future<HotelModel?> getHotelDetails(String hotelId) async {
    final doc = await _firestore.collection('hotels').doc(hotelId).get();
    if (doc.exists) {
      return HotelModel.fromFirestore(doc);
    }
    return null;
  }
}
