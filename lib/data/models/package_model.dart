import 'package:cloud_firestore/cloud_firestore.dart';

class PackageModel {
  final String id;
  final String title;
  final String destinationId;
  final String description;
  final double price;
  final double rating;
  final int durationDays;
  final List<String> images;

  PackageModel({
    required this.id,
    required this.title,
    required this.destinationId,
    required this.description,
    required this.price,
    required this.rating,
    required this.durationDays,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destinationId': destinationId,
      'description': description,
      'price': price,
      'rating': rating,
      'durationDays': durationDays,
      'images': images,
    };
  }

  factory PackageModel.fromMap(Map<String, dynamic> map, String docId) {
    return PackageModel(
      id: docId,
      title: map['title'] ?? '',
      destinationId: map['destinationId'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      durationDays: (map['durationDays'] ?? 1).toInt(),
      images: List<String>.from(map['images'] ?? []),
    );
  }

  factory PackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PackageModel.fromMap(data, doc.id);
  }
}
