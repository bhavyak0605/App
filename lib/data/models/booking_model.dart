import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String hotelImage;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalPrice;
  final int guestCount;
  final String status; // 'confirmed', 'pending', 'cancelled'
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.hotelImage,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    required this.guestCount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'hotelImage': hotelImage,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'totalPrice': totalPrice,
      'guestCount': guestCount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime checkIn = DateTime.now();
    DateTime checkOut = DateTime.now().add(const Duration(days: 1));
    DateTime created = DateTime.now();

    if (map['checkInDate'] != null) {
      checkIn = map['checkInDate'] is Timestamp 
          ? (map['checkInDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['checkInDate']) ?? DateTime.now();
    }
    if (map['checkOutDate'] != null) {
      checkOut = map['checkOutDate'] is Timestamp 
          ? (map['checkOutDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['checkOutDate']) ?? DateTime.now().add(const Duration(days: 1));
    }
    if (map['createdAt'] != null) {
      created = map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    }

    return BookingModel(
      id: docId,
      userId: map['userId'] ?? '',
      hotelId: map['hotelId'] ?? '',
      hotelName: map['hotelName'] ?? '',
      hotelImage: map['hotelImage'] ?? '',
      checkInDate: checkIn,
      checkOutDate: checkOut,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      guestCount: (map['guestCount'] ?? 1).toInt(),
      status: map['status'] ?? 'pending',
      createdAt: created,
    );
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BookingModel.fromMap(data, doc.id);
  }
}
