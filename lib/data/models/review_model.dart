import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final double rating;
  final String text;
  final DateTime date;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.rating,
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'rating': rating,
      'text': text,
      'date': Timestamp.fromDate(date),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime dateValue = DateTime.now();
    if (map['date'] != null) {
      if (map['date'] is Timestamp) {
        dateValue = (map['date'] as Timestamp).toDate();
      } else if (map['date'] is String) {
        dateValue = DateTime.tryParse(map['date']) ?? DateTime.now();
      }
    }

    return ReviewModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous User',
      userPhoto: map['userPhoto'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      text: map['text'] ?? '',
      date: dateValue,
    );
  }

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel.fromMap(data, doc.id);
  }
}
