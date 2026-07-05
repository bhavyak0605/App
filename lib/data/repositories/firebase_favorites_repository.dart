import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/favorites_repository.dart';

class FirebaseFavoritesRepository implements FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference _userFavDoc(String userId) {
    return _firestore.collection('favorites').doc(userId);
  }

  @override
  Future<List<String>> getFavoriteDestinations(String userId) async {
    final doc = await _userFavDoc(userId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['destinations'] != null) {
        return List<String>.from(data['destinations']);
      }
    }
    return [];
  }

  @override
  Future<List<String>> getFavoriteHotels(String userId) async {
    final doc = await _userFavDoc(userId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['hotels'] != null) {
        return List<String>.from(data['hotels']);
      }
    }
    return [];
  }

  @override
  Future<List<String>> getFavoritePackages(String userId) async {
    final doc = await _userFavDoc(userId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['packages'] != null) {
        return List<String>.from(data['packages']);
      }
    }
    return [];
  }

  @override
  Future<void> toggleFavoriteDestination(String userId, String destinationId) async {
    final docRef = _userFavDoc(userId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      await docRef.set({
        'destinations': [destinationId],
        'hotels': [],
        'packages': [],
      });
      return;
    }

    final data = doc.data() as Map<String, dynamic>;
    final list = List<String>.from(data['destinations'] ?? []);
    
    if (list.contains(destinationId)) {
      await docRef.update({
        'destinations': FieldValue.arrayRemove([destinationId]),
      });
    } else {
      await docRef.update({
        'destinations': FieldValue.arrayUnion([destinationId]),
      });
    }
  }

  @override
  Future<void> toggleFavoriteHotel(String userId, String hotelId) async {
    final docRef = _userFavDoc(userId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      await docRef.set({
        'destinations': [],
        'hotels': [hotelId],
        'packages': [],
      });
      return;
    }

    final data = doc.data() as Map<String, dynamic>;
    final list = List<String>.from(data['hotels'] ?? []);
    
    if (list.contains(hotelId)) {
      await docRef.update({
        'hotels': FieldValue.arrayRemove([hotelId]),
      });
    } else {
      await docRef.update({
        'hotels': FieldValue.arrayUnion([hotelId]),
      });
    }
  }

  @override
  Future<void> toggleFavoritePackage(String userId, String packageId) async {
    final docRef = _userFavDoc(userId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      await docRef.set({
        'destinations': [],
        'hotels': [],
        'packages': [packageId],
      });
      return;
    }

    final data = doc.data() as Map<String, dynamic>;
    final list = List<String>.from(data['packages'] ?? []);
    
    if (list.contains(packageId)) {
      await docRef.update({
        'packages': FieldValue.arrayRemove([packageId]),
      });
    } else {
      await docRef.update({
        'packages': FieldValue.arrayUnion([packageId]),
      });
    }
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
