import 'package:cloud_firestore/cloud_firestore.dart';

class HotelModel {
  final String id;
  final String name;
  final String destinationId;
  final List<String> images;
  final double pricePerNight;
  final double rating;
  final List<String> amenities;
  final String distanceFromCenter;
  final double latitude;
  final double longitude;
  final bool isAvailable;

  HotelModel({
    required this.id,
    required this.name,
    required this.destinationId,
    required this.images,
    required this.pricePerNight,
    required this.rating,
    required this.amenities,
    required this.distanceFromCenter,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'destinationId': destinationId,
      'images': images,
      'pricePerNight': pricePerNight,
      'rating': rating,
      'amenities': amenities,
      'distanceFromCenter': distanceFromCenter,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
    };
  }

  factory HotelModel.fromMap(Map<String, dynamic> map, String docId) {
    return HotelModel(
      id: docId,
      name: map['name'] ?? '',
      destinationId: map['destinationId'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      pricePerNight: (map['pricePerNight'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      amenities: List<String>.from(map['amenities'] ?? []),
      distanceFromCenter: map['distanceFromCenter'] ?? '0.5 km from center',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  factory HotelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HotelModel.fromMap(data, doc.id);
  }
}
