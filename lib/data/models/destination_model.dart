import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationModel {
  final String id;
  final String name;
  final String city;
  final String description;
  final List<String> images;
  final String weatherTemp;
  final String weatherCondition;
  final String bestTimeToVisit;
  final double rating;
  final double latitude;
  final double longitude;
  final double estimatedBudget;
  final List<String> attractions;
  final bool isFeatured;
  final String categoryId;

  DestinationModel({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.images,
    required this.weatherTemp,
    required this.weatherCondition,
    required this.bestTimeToVisit,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.estimatedBudget,
    required this.attractions,
    required this.isFeatured,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'description': description,
      'images': images,
      'weatherTemp': weatherTemp,
      'weatherCondition': weatherCondition,
      'bestTimeToVisit': bestTimeToVisit,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'estimatedBudget': estimatedBudget,
      'attractions': attractions,
      'isFeatured': isFeatured,
      'categoryId': categoryId,
    };
  }

  factory DestinationModel.fromMap(Map<String, dynamic> map, String docId) {
    return DestinationModel(
      id: docId,
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      weatherTemp: map['weatherTemp'] ?? '25°C',
      weatherCondition: map['weatherCondition'] ?? 'Sunny',
      bestTimeToVisit: map['bestTimeToVisit'] ?? 'Oct - Mar',
      rating: (map['rating'] ?? 0.0).toDouble(),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      estimatedBudget: (map['estimatedBudget'] ?? 0.0).toDouble(),
      attractions: List<String>.from(map['attractions'] ?? []),
      isFeatured: map['isFeatured'] ?? false,
      categoryId: map['categoryId'] ?? '',
    );
  }

  factory DestinationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DestinationModel.fromMap(data, doc.id);
  }
}
