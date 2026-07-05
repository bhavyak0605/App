import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String userId;
  final String destinationId;
  final String destinationName;
  final String destinationImage;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int travelers;
  final String notes;
  final String status; // 'upcoming', 'completed', 'cancelled'

  TripModel({
    required this.id,
    required this.userId,
    required this.destinationId,
    required this.destinationName,
    required this.destinationImage,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.travelers,
    required this.notes,
    required this.status,
  });

  TripModel copyWith({
    String? destinationId,
    String? destinationName,
    String? destinationImage,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    int? travelers,
    String? notes,
    String? status,
  }) {
    return TripModel(
      id: id,
      userId: userId,
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      destinationImage: destinationImage ?? this.destinationImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      travelers: travelers ?? this.travelers,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'destinationImage': destinationImage,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'budget': budget,
      'travelers': travelers,
      'notes': notes,
      'status': status,
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime start = DateTime.now();
    DateTime end = DateTime.now().add(const Duration(days: 4));

    if (map['startDate'] != null) {
      start = map['startDate'] is Timestamp 
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['startDate']) ?? DateTime.now();
    }
    if (map['endDate'] != null) {
      end = map['endDate'] is Timestamp 
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['endDate']) ?? DateTime.now().add(const Duration(days: 4));
    }

    return TripModel(
      id: docId,
      userId: map['userId'] ?? '',
      destinationId: map['destinationId'] ?? '',
      destinationName: map['destinationName'] ?? '',
      destinationImage: map['destinationImage'] ?? '',
      startDate: start,
      endDate: end,
      budget: (map['budget'] ?? 0.0).toDouble(),
      travelers: (map['travelers'] ?? 1).toInt(),
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'upcoming',
    );
  }

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TripModel.fromMap(data, doc.id);
  }
}
